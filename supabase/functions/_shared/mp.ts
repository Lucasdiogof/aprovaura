// Mercado Pago (somente Web/Portal): chamadas à API, assinatura do webhook e processadores.
// Pix: o Mercado Pago NÃO oferece Pix recorrente automático neste fluxo — o Pix aqui é avulso, por
// período (30/365 dias), com renovação manual. Cartão: assinatura recorrente (preapproval).
import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.47.10';
import { catalogRows, Ev, ingest, timingEqual } from './common.ts';

const BASE = 'https://api.mercadopago.com';
export const mp = async (path: string, init: RequestInit = {}) => {
  const tok = Deno.env.get('MP_ACCESS_TOKEN');
  if (!tok) throw new Error('mp_not_configured');
  const r = await fetch(BASE + path, { ...init, headers: { Authorization: 'Bearer ' + tok, 'content-type': 'application/json', ...(init.headers ?? {}) } });
  if (!r.ok) throw new Error('mp_api_' + r.status);
  return await r.json();
};

/** Manifesto oficial: partes AUSENTES (ex.: sem x-request-id) são removidas, não enviadas vazias. */
export const manifest = (id: string, rid: string, ts: string) =>
  [id ? `id:${id.toLowerCase()};` : '', rid ? `request-id:${rid};` : '', ts ? `ts:${ts};` : ''].join('');

/** HMAC oficial: manifest "id:<data.id>;request-id:<x-request-id>;ts:<ts>;" com o segredo do webhook. */
export async function verifySignature(req: Request, dataId: string) {
  const secret = Deno.env.get('MP_WEBHOOK_SECRET');
  const sig = req.headers.get('x-signature') ?? '', rid = req.headers.get('x-request-id') ?? '';
  if (!secret || !sig) return false;
  const parts = Object.fromEntries(sig.split(',').map((p) => p.trim().split('=') as [string, string]));
  if (!parts.ts || !parts.v1) return false;
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const mac = new Uint8Array(await crypto.subtle.sign('HMAC', key,
    new TextEncoder().encode(manifest(dataId, rid, parts.ts))));
  return timingEqual([...mac].map((b) => b.toString(16).padStart(2, '0')).join(''), parts.v1);
}

// Falha fechada e ambientes separados, decididos pela CONTA RECEBEDORA (nunca só por live_mode: a conta vendedora de teste
// do Mercado Pago opera com live_mode=true). MP_COLLECTOR_ID + live_mode → produção; MP_SANDBOX_COLLECTOR_ID → sandbox.
function envOf(p: any): 'production' | 'sandbox' {
  const id = String(p.collector_id);
  const prod = Deno.env.get('MP_COLLECTOR_ID'), sbx = Deno.env.get('MP_SANDBOX_COLLECTOR_ID');
  if (prod && id === prod && p.live_mode) return 'production';
  if (sbx && id === sbx) return 'sandbox';
  throw new Error('collector_mismatch');
}

async function plans(db: SupabaseClient) {
  return await catalogRows(db, 'mercadopago');
}
const cents = (v: number) => Math.round(v * 100);
const feeCents = (p: any) => cents((p.fee_details ?? []).reduce((s: number, f: any) => s + Number(f.amount || 0), 0));

/** Valores que o Mercado Pago INFORMA para o pagamento (taxa de fee_details; liquidação só quando liberado).
 *  Sem fee_details a taxa NÃO é marcada como informada (o banco cai na estimativa e o pagamento fica pendente).
 *  O imposto nunca vem da API: segue "estimado" até a conciliação com o relatório/contador. */
export function paymentInfo(p: any) {
  const reported = Array.isArray(p.fee_details) && p.fee_details.length > 0;
  const rel = p.money_release_status === 'released' && p.transaction_details?.net_received_amount != null;
  return { external_id: String(p.id), gross_cents: cents(p.transaction_amount), paid_at: p.date_approved,
    ...(reported ? { fee_cents: feeCents(p), fee_source: 'reported' } : {}),
    ...(rel ? { settled_cents: cents(Number(p.transaction_details.net_received_amount)),
                settled_at: p.money_release_date ?? p.date_approved } : {}) };
}

/** Cobrança aberta do usuário (Pix ou assinatura de cartão) passa a refletir o desfecho real. */
async function closeCharge(db: SupabaseClient, mpRef: string, status: 'approved' | 'cancelled') {
  await db.from('mp_pending_charges').update({ status }).eq('mp_ref', mpRef).eq('status', 'pending');
}

/** A aplicação do Mercado Pago é compartilhada com o Payhip: só processamos cobrança cujo external_reference
 *  é um token de compra emitido por este sistema; qualquer outra origem é ignorada ('foreign'). */
async function ownToken(db: SupabaseClient, token: unknown) {
  if (typeof token !== 'string' || !token) return false;
  const { data } = await db.from('purchase_account_tokens').select('user_id').eq('token', token).maybeSingle();
  return !!data;
}

/** Pix avulso: aprovado concede período fixo; estorno/chargeback reverte. */
export async function processPayment(db: SupabaseClient, id: string | number) {
  const p = await mp(`/v1/payments/${id}`);
  const env = envOf(p);
  if (p.payment_method_id !== 'pix') return await processCardReversal(db, p); // aprovação do cartão chega por authorized_payments
  const cat = await plans(db);
  const row = cat.find((c) => Number(c.price_cents) === cents(p.transaction_amount));
  if (!(await ownToken(db, p.external_reference))) return 'foreign';
  if (!row || p.currency_id !== 'BRL') return 'invalid';
  const base = { provider: 'mercadopago' as const, env: env as Ev['env'], occurredAt: new Date(p.date_last_updated ?? Date.now()),
    token: p.external_reference, ref: 'pix:' + p.id, plan: row.plan as Ev['plan'] };
  let ev: Ev;
  if (p.status === 'approved' && !(p.transaction_amount_refunded > 0)) {
    ev = { ...base, eventId: `mp:payment:${p.id}:approved`, type: 'pix_paid', state: 'active',
      payment: paymentInfo(p) };
  } else if (['refunded', 'charged_back'].includes(p.status) || p.transaction_amount_refunded > 0) {
    const full = p.status !== 'approved';
    const { data: sub } = await db.from('provider_subscriptions').select('period_end').eq('provider', 'mercadopago').eq('original_ref', base.ref).maybeSingle();
    ev = { ...base, eventId: `mp:payment:${p.id}:${p.status}:${p.transaction_amount_refunded}`, type: 'refund',
      state: full ? 'refunded' : 'canceled', end: full ? new Date() : sub?.period_end ? new Date(sub.period_end) : null,
      refund: { external_id: String(p.id), at: p.date_last_updated, charged_back: p.status === 'charged_back',
                refund_cents: full ? undefined : cents(p.transaction_amount_refunded), external_ref: `mp-refund:${p.id}:${p.transaction_amount_refunded}` } };
  } else return p.status; // pending/in_process/rejected/cancelled: nada a conceder
  const r = await ingest(db, ev);
  if (r.status === 'failed') throw new Error('ingest_failed');
  if (p.status === 'approved' && !(p.transaction_amount_refunded > 0)) await closeCharge(db, String(p.id), 'approved');
  return r.status;
}

/** Reembolso/chargeback de pagamento de CARTÃO (recorrente): reverte comissão e encerra o acesso. Só age sobre
 *  pagamento que este sistema registrou (nunca sobre pagamento de outra origem na mesma conta). */
async function processCardReversal(db: SupabaseClient, p: any) {
  const reversed = ['refunded', 'charged_back'].includes(p.status) || p.transaction_amount_refunded > 0;
  if (!reversed) return 'ignored';
  const { data: pay } = await db.from('payments').select('user_id').eq('provider', 'mercadopago').eq('external_id', String(p.id)).maybeSingle();
  if (!pay) return 'ignored';
  const { data: sub } = await db.from('provider_subscriptions').select('original_ref,plan,environment,period_end')
    .eq('provider', 'mercadopago').eq('user_id', pay.user_id).like('original_ref', 'pre:%')
    .order('last_event_at', { ascending: false }).limit(1).maybeSingle();
  if (!sub) return 'ignored';
  const full = p.status !== 'approved';
  const r = await ingest(db, { provider: 'mercadopago', env: sub.environment, eventId: `mp:payment:${p.id}:${p.status}:${p.transaction_amount_refunded}`,
    type: 'refund', occurredAt: new Date(p.date_last_updated ?? Date.now()), ref: sub.original_ref, plan: sub.plan,
    state: full ? 'refunded' : 'canceled', end: full ? new Date() : sub.period_end ? new Date(sub.period_end) : null, autoRenew: false,
    refund: { external_id: String(p.id), at: p.date_last_updated, charged_back: p.status === 'charged_back',
              refund_cents: full ? undefined : cents(p.transaction_amount_refunded), external_ref: `mp-refund:${p.id}:${p.transaction_amount_refunded}` } });
  if (r.status === 'failed') throw new Error('ingest_failed');
  // Estorno total/chargeback: interrompe novas cobranças da assinatura (o Mercado Pago não faz isso sozinho).
  if (full) await mp(`/preapproval/${sub.original_ref.slice(4)}`, { method: 'PUT', body: JSON.stringify({ status: 'cancelled' }) }).catch(() => {});
  return r.status;
}

/** Chargeback (tópico próprio): relê o chargeback e reaplica cada pagamento afetado pelo mesmo caminho. */
export async function processChargeback(db: SupabaseClient, id: string) {
  const c = await mp(`/v1/chargebacks/${id}`);
  const ids: string[] = (c.payments ?? []).map((x: any) => String(x?.id ?? x));
  for (const pid of ids) await processPayment(db, pid);
  return ids.length ? 'processed' : 'empty';
}

/** Cobrança recorrente de cartão (authorized_payment) → renovação/ativação. */
export async function processAuthorizedPayment(db: SupabaseClient, id: string | number) {
  const a = await mp(`/authorized_payments/${id}`);
  if (a.payment?.status !== 'approved') return a.payment?.status ?? 'pending';
  const pay = await mp(`/v1/payments/${a.payment.id}`);
  const env = envOf(pay);
  const pre = await mp(`/preapproval/${a.preapproval_id}`);
  const row = (await plans(db)).find((c) => Number(c.price_cents) === cents(pay.transaction_amount));
  if (!(await ownToken(db, pre.external_reference))) return 'foreign';
  if (!row || pay.currency_id !== 'BRL') return 'invalid';
  const r = await ingest(db, { provider: 'mercadopago', env,
    eventId: `mp:auth:${a.id}:approved`, type: 'card_paid', occurredAt: new Date(pay.date_approved ?? Date.now()),
    token: pre.external_reference, ref: 'pre:' + pre.id, plan: row.plan as Ev['plan'], state: 'active',
    end: pre.next_payment_date ? new Date(pre.next_payment_date) : null, autoRenew: pre.status === 'authorized',
    payment: paymentInfo(pay) });
  if (r.status === 'failed') throw new Error('ingest_failed');
  await closeCharge(db, String(pre.id), 'approved');
  return r.status;
}

/** Recupera eventos perdidos de uma assinatura de cartão: reaplica cada cobrança aprovada (idempotente) e o estado. */
export async function reconcilePreapproval(db: SupabaseClient, id: string) {
  let n = 0;
  try {
    const s = await mp(`/authorized_payments/search?preapproval_id=${encodeURIComponent(id)}`);
    for (const a of s.results ?? []) if (a?.payment?.status === 'approved') { await processAuthorizedPayment(db, a.id); n++; }
  } catch (e) { console.error('mp-reconcile-search', (e as Error).message); }
  await processPreapproval(db, id);
  return n;
}

/** Cobranças abertas (Pix/cartão) criadas nos últimos 3 dias: confirma o desfecho real na API do Mercado Pago. */
export async function reconcileMpPending(db: SupabaseClient) {
  const since = new Date(Date.now() - 3 * 86_400_000).toISOString();
  const { data } = await db.from('mp_pending_charges').select('id,method,mp_ref,expires_at').eq('status', 'pending')
    .gt('created_at', since).not('mp_ref', 'is', null).limit(50);
  const out = { pending: 0, failed: 0 };
  for (const c of data ?? []) {
    try {
      if (c.method === 'pix') {
        await processPayment(db, c.mp_ref);
        const p = await mp(`/v1/payments/${c.mp_ref}`);
        if (['cancelled', 'expired', 'rejected'].includes(p.status)) await db.from('mp_pending_charges').update({ status: p.status === 'rejected' ? 'rejected' : 'expired' }).eq('id', c.id);
      } else await reconcilePreapproval(db, c.mp_ref);
      out.pending++;
    } catch (e) { out.failed++; console.error('mp-reconcile-pending', (e as Error).message); }
  }
  return out;
}

/** Mudança de status da assinatura (cancelada/pausada): mantém acesso até o fim do período pago. */
export async function processPreapproval(db: SupabaseClient, id: string) {
  const pre = await mp(`/preapproval/${id}`);
  const { data: sub } = await db.from('provider_subscriptions').select('plan,environment,period_end,state')
    .eq('provider', 'mercadopago').eq('original_ref', 'pre:' + pre.id).maybeSingle();
  if (!sub) {
    if (['cancelled', 'paused'].includes(pre.status)) await closeCharge(db, String(pre.id), 'cancelled');
    return 'wait_first_payment'; // autorização sem cobrança aprovada não concede acesso
  }
  const end = sub.period_end ? new Date(sub.period_end) : new Date();
  const state: Ev['state'] = pre.status === 'authorized' ? 'active' : end > new Date() ? 'canceled' : 'expired';
  const r = await ingest(db, { provider: 'mercadopago', env: sub.environment, eventId: `mp:pre:${pre.id}:${pre.status}:${pre.last_modified}`,
    type: 'preapproval_' + pre.status, occurredAt: new Date(pre.last_modified ?? Date.now()), ref: 'pre:' + pre.id,
    plan: sub.plan, state, end, autoRenew: pre.status === 'authorized' });
  if (r.status === 'failed') throw new Error('ingest_failed');
  return r.status;
}
