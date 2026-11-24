// Testes locais (sem rede, sem Mercado Pago real): processadores do webhook com a API do MP e o banco simulados.
// Cobrem validação de conta recebedora/valor/moeda/plano/ambiente, idempotência, reembolso, chargeback e conciliação.
// Rodar: deno test --allow-env supabase/functions/_shared/mp_processors_test.ts
import { paymentInfo, processAuthorizedPayment, processChargeback, processPayment, processPreapproval, reconcilePreapproval } from './mp.ts';

const assert = (c: boolean, m: string) => { if (!c) throw new Error(m); };
const eq = (a: unknown, b: unknown, m: string) => assert(JSON.stringify(a) === JSON.stringify(b), `${m}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);

const CAT = [{ plan: 'monthly', price_cents: 1990 }, { plan: 'annual', price_cents: 19000 }];

function fakeDb(tables: Record<string, unknown> = {}) {
  const rpcs: any[] = [], updates: any[] = [];
  tables = { purchase_account_tokens: { user_id: 'u1' }, ...tables };
  const chain = (table: string): any => new Proxy({}, { get: (_t, k: string) => {
    if (k === 'then') return (res: any) => res({ data: table === 'payment_catalog' ? CAT : (tables[table] ?? null) });
    if (k === 'maybeSingle' || k === 'single') return () => Promise.resolve({ data: tables[table] ?? null });
    if (k === 'update') return (v: unknown) => { updates.push({ table, v }); return chain(table); };
    return () => chain(table);
  } });
  const db: any = { from: (t: string) => chain(t), rpc: (_n: string, a: any) => { rpcs.push(a); return Promise.resolve({ data: { status: 'processed' }, error: null }); } };
  return { db, rpcs, updates };
}

function stubApi(routes: Record<string, unknown>) {
  const calls: { path: string; method: string }[] = [];
  const orig = globalThis.fetch;
  globalThis.fetch = ((url: string, init?: RequestInit) => {
    const path = String(url).replace('https://api.mercadopago.com', '');
    calls.push({ path, method: init?.method ?? 'GET' });
    const r = routes[path];
    return Promise.resolve(r === undefined ? new Response('{}', { status: 404 }) : new Response(JSON.stringify(r), { status: 200 }));
  }) as typeof fetch;
  return { calls, restore: () => { globalThis.fetch = orig; } };
}

const pix = (o: Record<string, unknown> = {}) => ({ id: 111, collector_id: 207507198, payment_method_id: 'pix', status: 'approved', transaction_amount: 19.9,
  currency_id: 'BRL', live_mode: true, external_reference: 'tok-1', date_approved: '2026-11-24T10:00:00.000-03:00', date_last_updated: '2026-11-24T10:00:01.000-03:00',
  fee_details: [{ type: 'mercadopago_fee', amount: 0.12 }], ...o });

async function withEnv<T>(f: () => Promise<T>) {
  Deno.env.set('MP_ACCESS_TOKEN', 'x'); Deno.env.set('MP_COLLECTOR_ID', '207507198'); Deno.env.set('MP_SANDBOX_COLLECTOR_ID', '555');
  try { return await f(); } finally { for (const k of ['MP_ACCESS_TOKEN', 'MP_COLLECTOR_ID', 'MP_SANDBOX_COLLECTOR_ID']) Deno.env.delete(k); }
}

Deno.test('Pix aprovado em produção: concede, taxa informada, bruto/plano do catálogo', () => withEnv(async () => {
  const api = stubApi({ '/v1/payments/111': pix() }); const { db, rpcs, updates } = fakeDb();
  try {
    eq(await processPayment(db, 111), 'processed', 'resultado');
    const e = rpcs[0];
    eq([e.p_type, e.p_env, e.p_plan, e.p_state, e.p_account_token, e.p_original_ref], ['pix_paid', 'production', 'monthly', 'active', 'tok-1', 'pix:111'], 'evento');
    eq([e.p_payment.gross_cents, e.p_payment.fee_cents, e.p_payment.fee_source], [1990, 12, 'reported'], 'pagamento');
    assert(!('tax_cents' in e.p_payment), 'imposto nunca é inventado');
    assert(updates.some((u) => u.table === 'mp_pending_charges' && u.v.status === 'approved'), 'cobrança aberta fechada');
  } finally { api.restore(); }
}));

Deno.test('Pix anual: bruto integral de R$ 190,00 e plano annual', () => withEnv(async () => {
  const api = stubApi({ '/v1/payments/112': pix({ id: 112, transaction_amount: 190 }) }); const { db, rpcs } = fakeDb();
  try { await processPayment(db, 112); eq([rpcs[0].p_plan, rpcs[0].p_payment.gross_cents], ['annual', 19000], 'anual'); } finally { api.restore(); }
}));

Deno.test('live_mode=false vira sandbox (financeiro do banco ignora sandbox)', () => withEnv(async () => {
  const api = stubApi({ '/v1/payments/113': pix({ id: 113, live_mode: false, collector_id: 555 }) }); const { db, rpcs } = fakeDb();
  try { await processPayment(db, 113); eq(rpcs[0].p_env, 'sandbox', 'ambiente'); } finally { api.restore(); }
  // ambientes separados: teste com a conta de produção (ou real com a de teste) é recusado
  for (const o of [{ live_mode: false, collector_id: 207507198 }, { live_mode: true, collector_id: 555 }]) {
    const a2 = stubApi({ '/v1/payments/113': pix({ id: 113, ...o }) }); let e = '';
    try { await processPayment(fakeDb().db, 113); } catch (x) { e = (x as Error).message; } finally { a2.restore(); }
    eq(e, 'collector_mismatch', 'mistura de ambientes ' + JSON.stringify(o));
  }
}));

Deno.test('conta recebedora diferente, sem collector configurado: recusa e não concede', async () => {
  Deno.env.set('MP_ACCESS_TOKEN', 'x');
  const api = stubApi({ '/v1/payments/114': pix({ id: 114, collector_id: 999 }) }); const { db, rpcs } = fakeDb();
  try {
    Deno.env.set('MP_COLLECTOR_ID', '207507198');
    let err = ''; try { await processPayment(db, 114); } catch (e) { err = (e as Error).message; }
    eq(err, 'collector_mismatch', 'collector'); eq(rpcs.length, 0, 'nada concedido');
    Deno.env.delete('MP_COLLECTOR_ID'); err = '';
    try { await processPayment(db, 114); } catch (e) { err = (e as Error).message; }
    eq(err, 'collector_mismatch', 'sem MP_COLLECTOR_ID falha fechada');
  } finally { api.restore(); Deno.env.delete('MP_ACCESS_TOKEN'); Deno.env.delete('MP_COLLECTOR_ID'); }
});

Deno.test('valor fora do catálogo e moeda errada: invalid, nada concedido', () => withEnv(async () => {
  const { db, rpcs } = fakeDb();
  for (const o of [{ transaction_amount: 10 }, { currency_id: 'USD' }]) {
    const api = stubApi({ '/v1/payments/115': pix({ id: 115, ...o }) });
    try { eq(await processPayment(db, 115), 'invalid', JSON.stringify(o)); } finally { api.restore(); }
  }
  eq(rpcs.length, 0, 'nenhum evento');
}));

Deno.test('pendente, em processamento, recusado e cancelado não concedem nada', () => withEnv(async () => {
  for (const st of ['pending', 'in_process', 'rejected', 'cancelled']) {
    const api = stubApi({ '/v1/payments/116': pix({ id: 116, status: st }) }); const { db, rpcs } = fakeDb();
    try { eq(await processPayment(db, 116), st, st); eq(rpcs.length, 0, st); } finally { api.restore(); }
  }
}));

Deno.test('notificação duplicada/atrasada gera o MESMO eventId (o banco deduplica)', () => withEnv(async () => {
  const api = stubApi({ '/v1/payments/117': pix({ id: 117 }) }); const { db, rpcs } = fakeDb();
  try {
    await processPayment(db, 117); await processPayment(db, 117);
    eq(rpcs[0].p_event_id, rpcs[1].p_event_id, 'idempotência'); eq(rpcs[0].p_event_id, 'mp:payment:117:approved', 'formato');
  } finally { api.restore(); }
}));

Deno.test('Pix reembolsado/chargeback: total encerra acesso; parcial mantém até o fim do período', () => withEnv(async () => {
  let api = stubApi({ '/v1/payments/118': pix({ id: 118, status: 'refunded', transaction_amount_refunded: 19.9 }) }); let f = fakeDb();
  try { await processPayment(f.db, 118); eq([f.rpcs[0].p_type, f.rpcs[0].p_state], ['refund', 'refunded'], 'total'); } finally { api.restore(); }
  api = stubApi({ '/v1/payments/119': pix({ id: 119, status: 'charged_back', transaction_amount_refunded: 0 }) }); f = fakeDb();
  try { await processPayment(f.db, 119); eq([f.rpcs[0].p_state, f.rpcs[0].p_refund.charged_back], ['refunded', true], 'chargeback'); } finally { api.restore(); }
  api = stubApi({ '/v1/payments/120': pix({ id: 120, status: 'approved', transaction_amount_refunded: 5 }) }); f = fakeDb({ provider_subscriptions: { period_end: '2026-12-24T00:00:00Z' } });
  try { await processPayment(f.db, 120); eq([f.rpcs[0].p_state, f.rpcs[0].p_refund.refund_cents], ['canceled', 500], 'parcial'); } finally { api.restore(); }
}));

const pre = (o: Record<string, unknown> = {}) => ({ id: 'pre-1', status: 'authorized', external_reference: 'tok-1', next_payment_date: '2026-12-24T00:00:00Z', last_modified: '2026-11-24T10:00:00Z', ...o });

Deno.test('cartão: cobrança aprovada ativa/renova (anual = 190,00) e fecha a cobrança aberta', () => withEnv(async () => {
  const api = stubApi({ '/authorized_payments/9': { id: 9, preapproval_id: 'pre-1', payment: { id: 500, status: 'approved' } },
    '/v1/payments/500': pix({ id: 500, payment_method_id: 'visa', transaction_amount: 190 }), '/preapproval/pre-1': pre() });
  const { db, rpcs, updates } = fakeDb();
  try {
    await processAuthorizedPayment(db, 9);
    eq([rpcs[0].p_type, rpcs[0].p_plan, rpcs[0].p_payment.gross_cents, rpcs[0].p_auto_renew, rpcs[0].p_original_ref], ['card_paid', 'annual', 19000, true, 'pre:pre-1'], 'cartão');
    assert(updates.some((u) => u.v.status === 'approved'), 'cobrança fechada');
  } finally { api.restore(); }
}));

Deno.test('cartão: recusada/pendente não concede; conta recebedora errada falha fechada', () => withEnv(async () => {
  let api = stubApi({ '/authorized_payments/9': { id: 9, preapproval_id: 'pre-1', payment: { id: 500, status: 'rejected' } } }); let f = fakeDb();
  try { eq(await processAuthorizedPayment(f.db, 9), 'rejected', 'recusada'); eq(f.rpcs.length, 0, 'nada'); } finally { api.restore(); }
  api = stubApi({ '/authorized_payments/9': { id: 9, preapproval_id: 'pre-1', payment: { id: 500, status: 'approved' } }, '/v1/payments/500': pix({ id: 500, collector_id: 1 }) }); f = fakeDb();
  try { let e = ''; try { await processAuthorizedPayment(f.db, 9); } catch (x) { e = (x as Error).message; } eq(e, 'collector_mismatch', 'collector'); } finally { api.restore(); }
}));

Deno.test('cartão: cancelamento mantém acesso até o fim do período; sem 1ª cobrança aprovada não concede', () => withEnv(async () => {
  const future = new Date(Date.now() + 10 * 86_400_000).toISOString();
  let api = stubApi({ '/preapproval/pre-1': pre({ status: 'cancelled' }) });
  let f = fakeDb({ provider_subscriptions: { plan: 'monthly', environment: 'production', period_end: future, state: 'active' } });
  try { await processPreapproval(f.db, 'pre-1'); eq(f.rpcs[0].p_state, 'canceled', 'canceled até o fim'); eq(f.rpcs[0].p_auto_renew, false, 'sem renovação'); } finally { api.restore(); }
  api = stubApi({ '/preapproval/pre-1': pre({ status: 'cancelled' }) }); f = fakeDb();
  try { eq(await processPreapproval(f.db, 'pre-1'), 'wait_first_payment', 'sem cobrança'); eq(f.rpcs.length, 0, 'nada'); } finally { api.restore(); }
}));

Deno.test('cartão reembolsado/chargeback: só age em pagamento registrado; cancela a assinatura no MP', () => withEnv(async () => {
  const route = { '/v1/payments/600': pix({ id: 600, payment_method_id: 'master', status: 'refunded', transaction_amount_refunded: 19.9 }), '/preapproval/pre-1': pre() };
  let api = stubApi(route); let f = fakeDb(); // pagamento desconhecido (outra origem na mesma conta)
  try { eq(await processPayment(f.db, 600), 'ignored', 'desconhecido'); eq(f.rpcs.length, 0, 'nada'); } finally { api.restore(); }
  api = stubApi(route);
  f = fakeDb({ payments: { user_id: 'u1' }, provider_subscriptions: { original_ref: 'pre:pre-1', plan: 'monthly', environment: 'production', period_end: null } });
  try {
    await processPayment(f.db, 600);
    eq([f.rpcs[0].p_type, f.rpcs[0].p_state, f.rpcs[0].p_original_ref], ['refund', 'refunded', 'pre:pre-1'], 'refund');
    assert(api.calls.some((c) => c.method === 'PUT' && c.path === '/preapproval/pre-1'), 'assinatura cancelada no MP');
  } finally { api.restore(); }
}));

Deno.test('chargeback por tópico próprio relê o chargeback e reaplica o pagamento', () => withEnv(async () => {
  const api = stubApi({ '/v1/chargebacks/7': { payments: [{ id: 700 }] }, '/v1/payments/700': pix({ id: 700, status: 'charged_back' }) }); const { db, rpcs } = fakeDb();
  try { eq(await processChargeback(db, '7'), 'processed', 'cb'); eq(rpcs[0].p_refund.charged_back, true, 'charged_back'); } finally { api.restore(); }
}));

Deno.test('conciliação do cartão recupera cobranças aprovadas perdidas', () => withEnv(async () => {
  const api = stubApi({ '/authorized_payments/search?preapproval_id=pre-1': { results: [{ id: 9, payment: { status: 'approved' } }, { id: 10, payment: { status: 'rejected' } }] },
    '/authorized_payments/9': { id: 9, preapproval_id: 'pre-1', payment: { id: 500, status: 'approved' } }, '/v1/payments/500': pix({ id: 500, payment_method_id: 'visa' }), '/preapproval/pre-1': pre() });
  const { db, rpcs } = fakeDb();
  try { eq(await reconcilePreapproval(db, 'pre-1'), 1, 'uma recuperada'); assert(rpcs.some((r) => r.p_type === 'card_paid'), 'card_paid'); } finally { api.restore(); }
}));

Deno.test('paymentInfo: taxa só "informada" com fee_details; liquidação só quando liberado; sem imposto', () => {
  const a = paymentInfo({ id: 1, transaction_amount: 19.9, fee_details: [] });
  assert(!('fee_cents' in a) && !('fee_source' in a) && !('settled_cents' in a) && !('tax_cents' in a), 'sem dados do provedor: nada informado');
  const b = paymentInfo({ id: 1, transaction_amount: 19.9, fee_details: [{ amount: 0.5 }, { amount: 0.25 }], money_release_status: 'pending', transaction_details: { net_received_amount: 19.15 } });
  eq([b.fee_cents, 'settled_cents' in b], [75, false], 'taxa somada; não liberado');
  const c = paymentInfo({ id: 1, transaction_amount: 19.9, fee_details: [{ amount: 0.75 }], money_release_status: 'released', money_release_date: '2026-12-08T00:00:00Z', transaction_details: { net_received_amount: 19.15 } });
  eq([c.settled_cents, c.settled_at], [1915, '2026-12-08T00:00:00Z'], 'liquidado');
});

Deno.test('pagamento de outra origem (Payhip, mesma conta MP) é ignorado', () => withEnv(async () => {
  const api = stubApi({ '/v1/payments/130': pix({ id: 130, external_reference: 'payhip-xyz' }) }); const { db, rpcs } = fakeDb({ purchase_account_tokens: null });
  try { eq(await processPayment(db, 130), 'foreign', 'resultado'); eq(rpcs.length, 0, 'nada ingerido'); } finally { api.restore(); }
}));

Deno.test('pagamento sem external_reference é ignorado como de outra origem', () => withEnv(async () => {
  const api = stubApi({ '/v1/payments/131': pix({ id: 131, external_reference: null }) }); const { db, rpcs } = fakeDb();
  try { eq(await processPayment(db, 131), 'foreign', 'resultado'); eq(rpcs.length, 0, 'nada ingerido'); } finally { api.restore(); }
}));
