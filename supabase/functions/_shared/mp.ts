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

/** HMAC oficial: manifest "id:<data.id>;request-id:<x-request-id>;ts:<ts>;" com o segredo do webhook. */
export async function verifySignature(req: Request, dataId: string) {
  const secret = Deno.env.get('MP_WEBHOOK_SECRET');
  const sig = req.headers.get('x-signature') ?? '', rid = req.headers.get('x-request-id') ?? '';
  if (!secret || !sig) return false;
  const parts = Object.fromEntries(sig.split(',').map((p) => p.trim().split('=') as [string, string]));
  if (!parts.ts || !parts.v1) return false;
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const mac = new Uint8Array(await crypto.subtle.sign('HMAC', key,
    new TextEncoder().encode(`id:${dataId.toLowerCase()};request-id:${rid};ts:${parts.ts};`)));
  return timingEqual([...mac].map((b) => b.toString(16).padStart(2, '0')).join(''), parts.v1);
}

// Falha fechada: sem MP_COLLECTOR_ID (titularidade confirmada) nada é aceito.
function assertCollector(p: any) {
  const c = Deno.env.get('MP_COLLECTOR_ID');
  if (!c || String(p.collector_id) !== c) throw new Error('collector_mismatch');
}

async function plans(db: SupabaseClient) {
  return await catalogRows(db, 'mercadopago');
}
const cents = (v: number) => Math.round(v * 100);
const feeCents = (p: any) => cents((p.fee_details ?? []).reduce((s: number, f: any) => s + Number(f.amount || 0), 0));

/** Pix avulso: aprovado concede período fixo; estorno/chargeback reverte. */
export async function processPayment(db: SupabaseClient, id: string | number) {
  const p = await mp(`/v1/payments/${id}`);
  assertCollector(p);
  if (p.payment_method_id !== 'pix') return 'ignored'; // cartão recorrente chega por authorized_payments
  const cat = await plans(db);
  const row = cat.find((c) => Number(c.price_cents) === cents(p.transaction_amount));
  if (!row || p.currency_id !== 'BRL' || !p.external_reference) return 'invalid';
  const env = p.live_mode ? 'production' : 'sandbox';
  const base = { provider: 'mercadopago' as const, env: env as Ev['env'], occurredAt: new Date(p.date_last_updated ?? Date.now()),
    token: p.external_reference, ref: 'pix:' + p.id, plan: row.plan as Ev['plan'] };
  let ev: Ev;
  if (p.status === 'approved' && !(p.transaction_amount_refunded > 0)) {
    ev = { ...base, eventId: `mp:payment:${p.id}:approved`, type: 'pix_paid', state: 'active',
      payment: { external_id: String(p.id), gross_cents: cents(p.transaction_amount), fee_cents: feeCents(p), paid_at: p.date_approved } };
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
  return r.status;
}

/** Cobrança recorrente de cartão (authorized_payment) → renovação/ativação. */
export async function processAuthorizedPayment(db: SupabaseClient, id: string | number) {
  const a = await mp(`/authorized_payments/${id}`);
  if (a.payment?.status !== 'approved') return a.payment?.status ?? 'pending';
  const pay = await mp(`/v1/payments/${a.payment.id}`);
  assertCollector(pay);
  const pre = await mp(`/preapproval/${a.preapproval_id}`);
  const row = (await plans(db)).find((c) => Number(c.price_cents) === cents(pay.transaction_amount));
  if (!row || pay.currency_id !== 'BRL' || !pre.external_reference) return 'invalid';
  const r = await ingest(db, { provider: 'mercadopago', env: pay.live_mode ? 'production' : 'sandbox',
    eventId: `mp:auth:${a.id}:approved`, type: 'card_paid', occurredAt: new Date(pay.date_approved ?? Date.now()),
    token: pre.external_reference, ref: 'pre:' + pre.id, plan: row.plan as Ev['plan'], state: 'active',
    end: pre.next_payment_date ? new Date(pre.next_payment_date) : null, autoRenew: pre.status === 'authorized',
    payment: { external_id: String(pay.id), gross_cents: cents(pay.transaction_amount), fee_cents: feeCents(pay), paid_at: pay.date_approved } });
  if (r.status === 'failed') throw new Error('ingest_failed');
  return r.status;
}

/** Mudança de status da assinatura (cancelada/pausada): mantém acesso até o fim do período pago. */
export async function processPreapproval(db: SupabaseClient, id: string) {
  const pre = await mp(`/preapproval/${id}`);
  const { data: sub } = await db.from('provider_subscriptions').select('plan,environment,period_end,state')
    .eq('provider', 'mercadopago').eq('original_ref', 'pre:' + pre.id).maybeSingle();
  if (!sub) return 'wait_first_payment'; // autorização sem cobrança aprovada não concede acesso
  const end = sub.period_end ? new Date(sub.period_end) : new Date();
  const state: Ev['state'] = pre.status === 'authorized' ? 'active' : end > new Date() ? 'canceled' : 'expired';
  const r = await ingest(db, { provider: 'mercadopago', env: sub.environment, eventId: `mp:pre:${pre.id}:${pre.status}:${pre.last_modified}`,
    type: 'preapproval_' + pre.status, occurredAt: new Date(pre.last_modified ?? Date.now()), ref: 'pre:' + pre.id,
    plan: sub.plan, state, end, autoRenew: pre.status === 'authorized' });
  if (r.status === 'failed') throw new Error('ingest_failed');
  return r.status;
}
