// Testes locais (sem rede): processGoogleToken com a Developer API do Google Play e o banco simulados.
// ATENÇÃO: isto é MOCK — não conta como homologação real. Cobre mapeamento de estados, compra de teste,
// conta divergente, produto desconhecido, acknowledge só após persistir, troca de token e pagamento só quando devido.
// Rodar: deno test --allow-env supabase/functions/_shared/google_processors_test.ts
import { processGoogleToken } from './google.ts';

const assert = (c: boolean, m: string) => { if (!c) throw new Error(m); };
const eq = (a: unknown, b: unknown, m: string) => assert(JSON.stringify(a) === JSON.stringify(b), `${m}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);

const CAT = [
  { plan: 'monthly', external_product_id: 'aprovaura_premium', base_plan_id: 'monthly', price_cents: 1990 },
  { plan: 'annual', external_product_id: 'aprovaura_premium', base_plan_id: 'annual', price_cents: 19000 },
];

function fakeDb(ingestResult = 'processed') {
  const rpcs: any[] = [];
  const chain = (table: string): any => new Proxy({}, { get: (_t, k: string) => {
    if (k === 'then') return (res: any) => res({ data: table === 'payment_catalog' ? CAT : null });
    return () => chain(table);
  } });
  const db: any = { from: (t: string) => chain(t),
    rpc: (_n: string, a: any) => { rpcs.push(a); return Promise.resolve({ data: { status: ingestResult }, error: null }); } };
  return { db, rpcs };
}

async function pem() {
  const k = await crypto.subtle.generateKey({ name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' }, true, ['sign']);
  const der = new Uint8Array(await crypto.subtle.exportKey('pkcs8', k.privateKey));
  return `-----BEGIN PRIVATE KEY-----\n${btoa(String.fromCharCode(...der)).match(/.{1,64}/g)!.join('\n')}\n-----END PRIVATE KEY-----`;
}

const sub = (o: Record<string, unknown> = {}, li: Record<string, unknown> = {}) => ({
  subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE', acknowledgementState: 'ACKNOWLEDGEMENT_STATE_PENDING',
  startTime: '2026-11-25T10:00:00Z', externalAccountIdentifiers: { obfuscatedExternalAccountId: 'tok-1' },
  lineItems: [{ productId: 'aprovaura_premium', offerDetails: { basePlanId: 'monthly' }, expiryTime: '2026-12-25T10:00:00Z',
    latestSuccessfulOrderId: 'GPA.1', autoRenewingPlan: { autoRenewEnabled: true }, ...li }], ...o });

async function run(s: unknown, f: (calls: string[]) => Promise<void>) {
  Deno.env.set('GOOGLE_SA_JSON', JSON.stringify({ client_email: 'sa@x.iam', private_key: await pem() }));
  const calls: string[] = [], orig = globalThis.fetch;
  globalThis.fetch = ((url: string, init?: RequestInit) => {
    const u = String(url);
    if (u.includes('oauth2.googleapis.com')) return Promise.resolve(new Response(JSON.stringify({ access_token: 't' })));
    calls.push((init?.method ?? 'GET') + ' ' + u.split('/applications/')[1]);
    return Promise.resolve(u.includes(':acknowledge') ? new Response('{}') : new Response(JSON.stringify(s)));
  }) as typeof fetch;
  try { await f(calls); } finally { globalThis.fetch = orig; Deno.env.delete('GOOGLE_SA_JSON'); }
}

Deno.test('ativa mensal: concede, paga 19,90 do catálogo e confirma (ack) só depois de persistir', () => run(sub(), async (calls) => {
  const { db, rpcs } = fakeDb();
  eq((await processGoogleToken(db, 'T', 'e1', new Date(), 'tok-1')).status, 'processed', 'status');
  const e = rpcs[0];
  eq([e.p_env, e.p_plan, e.p_state, e.p_account_token, e.p_auto_renew, e.p_payment.gross_cents, e.p_payment.external_id], ['production', 'monthly', 'active', 'tok-1', true, 1990, 'GPA.1'], 'evento');
  assert(calls.some((c) => c.includes('subscriptions/aprovaura_premium/tokens/T:acknowledge')), 'ack enviado');
}));

Deno.test('anual: plano annual e R$ 190,00', () => run(sub({}, { offerDetails: { basePlanId: 'annual' } }), async () => {
  const { db, rpcs } = fakeDb();
  await processGoogleToken(db, 'T', 'e', new Date());
  eq([rpcs[0].p_plan, rpcs[0].p_payment.gross_cents], ['annual', 19000], 'anual');
}));

Deno.test('compra de teste: ambiente sandbox e SEM pagamento/comissão', () => run(sub({ testPurchase: {} }), async () => {
  const { db, rpcs } = fakeDb();
  await processGoogleToken(db, 'T', 'e', new Date());
  eq([rpcs[0].p_env, rpcs[0].p_payment], ['sandbox', null], 'teste');
}));

Deno.test('conta divergente (token de outro usuário): não grava nada nem confirma', () => run(sub(), async (calls) => {
  const { db, rpcs } = fakeDb();
  eq((await processGoogleToken(db, 'T', 'e', new Date(), 'outro')).status, 'account_mismatch', 'status');
  eq(rpcs.length, 0, 'sem ingest'); assert(!calls.some((c) => c.includes('acknowledge')), 'sem ack');
}));

Deno.test('produto/base plan desconhecido é ignorado', () => run(sub({}, { productId: 'outro' }), async (calls) => {
  const { db, rpcs } = fakeDb();
  eq((await processGoogleToken(db, 'T', 'e', new Date())).status, 'ignored_product', 'status');
  eq(rpcs.length, 0, 'sem ingest'); assert(!calls.some((c) => c.includes('acknowledge')), 'sem ack');
}));

Deno.test('já reconhecida (renovação): não reenvia acknowledge', () => run(sub({ acknowledgementState: 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED' }), async (calls) => {
  const { db } = fakeDb();
  await processGoogleToken(db, 'T', 'e', new Date());
  assert(!calls.some((c) => c.includes('acknowledge')), 'sem ack');
}));

Deno.test('ingest não processado (duplicado): não confirma de novo', () => run(sub(), async (calls) => {
  const { db } = fakeDb('duplicate');
  eq((await processGoogleToken(db, 'T', 'e', new Date())).status, 'duplicate', 'status');
  assert(!calls.some((c) => c.includes('acknowledge')), 'sem ack');
}));

Deno.test('pendente: sem pagamento e sem ack; em retenção (on hold) e expirada: expired sem pagamento', async () => {
  for (const [st, want] of [['SUBSCRIPTION_STATE_PENDING', 'pending'], ['SUBSCRIPTION_STATE_ON_HOLD', 'expired'], ['SUBSCRIPTION_STATE_EXPIRED', 'expired']]) {
    await run(sub({ subscriptionState: st }), async (calls) => {
      const { db, rpcs } = fakeDb();
      await processGoogleToken(db, 'T', 'e', new Date());
      eq([rpcs[0].p_state, rpcs[0].p_payment], [want, null], st);
      assert(!calls.some((c) => c.includes('acknowledge')), 'sem ack ' + st);
    });
  }
});

Deno.test('cancelada (acesso até o fim) e carência mantêm acesso e pagamento', async () => {
  for (const [st, want] of [['SUBSCRIPTION_STATE_CANCELED', 'canceled'], ['SUBSCRIPTION_STATE_IN_GRACE_PERIOD', 'grace']]) {
    await run(sub({ subscriptionState: st }, { autoRenewingPlan: { autoRenewEnabled: false } }), async () => {
      const { db, rpcs } = fakeDb();
      await processGoogleToken(db, 'T', 'e', new Date());
      eq([rpcs[0].p_state, rpcs[0].p_payment.gross_cents], [want, 1990], st);
    });
  }
});

Deno.test('linkedPurchaseToken: encerra a assinatura antiga e vigora a nova', () => run(sub({ linkedPurchaseToken: 'OLD' }), async () => {
  const { db, rpcs } = fakeDb();
  await processGoogleToken(db, 'NEW', 'e', new Date());
  eq([rpcs[0].p_original_ref, rpcs[0].p_state, rpcs[0].p_event_id], ['OLD', 'expired', 'google:replaced:NEW'], 'antiga encerrada');
  eq([rpcs[1].p_original_ref, rpcs[1].p_state], ['NEW', 'active'], 'nova vigente');
}));
