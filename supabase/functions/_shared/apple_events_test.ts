// Testes locais (sem rede): mapeamento de transação/notificação Apple → evento normalizado.
// ATENÇÃO: isto é SIMULAÇÃO (transações fabricadas na mão) — NÃO conta como homologação do Sandbox oficial.
// Rodar: deno test --allow-env supabase/functions/_shared/apple_events_test.ts
import { appleEvent } from './apple.ts';

const assert = (c: boolean, m: string) => { if (!c) throw new Error(m); };
const eq = (a: unknown, b: unknown, m: string) => assert(JSON.stringify(a) === JSON.stringify(b), `${m}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);

const CAT = [
  { plan: 'monthly', external_product_id: 'aprovaura_premium_monthly' },
  { plan: 'annual', external_product_id: 'aprovaura_premium_annual' },
];
const DAY = 86_400_000;
const now = Date.now();
const tx = (o: Record<string, unknown> = {}) => ({
  bundleId: 'com.lucasdiogof.aprovaura', productId: 'aprovaura_premium_monthly', environment: 'Sandbox',
  originalTransactionId: '2000000000000001', transactionId: '2000000000000001', appAccountToken: 'abc',
  purchaseDate: now, expiresDate: now + 30 * DAY, signedDate: now, price: 19900, currency: 'BRL', ...o,
});

Deno.test('compra mensal Sandbox: ativa, ambiente sandbox, bruto 19,90 (preço em milésimos)', () => {
  const e = appleEvent(tx(), { autoRenewStatus: 1 }, 'SUBSCRIBED', null, 'apple:n1', CAT)!;
  eq([e.state, e.env, e.plan, e.autoRenew], ['active', 'sandbox', 'monthly', true], 'estado');
  eq(e.payment?.gross_cents, 1990, 'bruto');
});

Deno.test('anual: R$ 189,90 vem da transação, não do catálogo', () => {
  const e = appleEvent(tx({ productId: 'aprovaura_premium_annual', price: 189900, expiresDate: now + 365 * DAY }), null, 'DID_RENEW', null, 'apple:n2', CAT)!;
  eq([e.plan, e.payment?.gross_cents], ['annual', 18990], 'anual');
});

Deno.test('cancelou a renovação: continua válido até o fim (canceled com end futuro)', () => {
  const e = appleEvent(tx(), { autoRenewStatus: 0 }, 'DID_CHANGE_RENEWAL_STATUS', 'AUTO_RENEW_DISABLED', 'apple:n3', CAT)!;
  eq([e.state, e.autoRenew], ['canceled', false], 'cancelamento');
  assert(e.end!.getTime() > now, 'acesso até o fim do período');
});

Deno.test('expirou', () => {
  const e = appleEvent(tx({ expiresDate: now - DAY }), null, 'EXPIRED', 'VOLUNTARY', 'apple:n4', CAT)!;
  eq(e.state, 'expired', 'expirada');
  eq(e.payment, null, 'sem pagamento');
});

Deno.test('falha de cobrança com carência', () => {
  const g = now + 5 * DAY;
  const e = appleEvent(tx({ expiresDate: now - DAY }), { autoRenewStatus: 1, gracePeriodExpiresDate: g }, 'DID_FAIL_TO_RENEW', 'GRACE_PERIOD', 'apple:n5', CAT)!;
  eq(e.state, 'grace', 'carência');
  eq(e.end!.getTime(), g, 'fim da carência');
});

Deno.test('reembolso e revogação atualizam o estado e geram ajuste, nunca pagamento', () => {
  const rf = appleEvent(tx({ revocationDate: now, revocationReason: 1 }), null, 'REFUND', null, 'apple:n6', CAT)!;
  eq([rf.state, rf.payment], ['refunded', null], 'reembolso');
  assert(!!rf.refund && rf.refund.external_ref === 'apple-refund:2000000000000001', 'ajuste do reembolso');
  const rv = appleEvent(tx({ revocationDate: now, revocationReason: 0 }), null, 'REVOKE', null, 'apple:n7', CAT)!;
  eq(rv.state, 'revoked', 'revogada');
});

Deno.test('eventos de outro app/produto ou moeda diferente não geram dinheiro', () => {
  eq(appleEvent(tx({ bundleId: 'com.outro.app' }), null, 'SUBSCRIBED', null, 'x', CAT), null, 'outro bundle');
  eq(appleEvent(tx({ productId: 'desconhecido' }), null, 'SUBSCRIBED', null, 'x', CAT), null, 'produto desconhecido');
  eq(appleEvent(tx({ currency: 'USD' }), null, 'SUBSCRIBED', null, 'x', CAT)!.payment, null, 'moeda diferente');
});

Deno.test('Produção é distinguida de Sandbox', () => {
  eq(appleEvent(tx({ environment: 'Production' }), null, 'SUBSCRIBED', null, 'x', CAT)!.env, 'production', 'produção');
});
