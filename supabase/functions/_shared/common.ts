// Núcleo compartilhado das funções de pagamento (Etapa 07).
// Segredos vêm só de variáveis de ambiente (Supabase Secrets) — nunca do cliente.
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.47.10';

export const admin = (): SupabaseClient =>
  createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false } });

export const json = (b: unknown, status = 200) =>
  new Response(JSON.stringify(b), { status, headers: { 'content-type': 'application/json' } });

/** Cliente "como o chamador" + usuário validado no GoTrue (nunca lido do corpo). */
export async function caller(req: Request) {
  const auth = req.headers.get('Authorization');
  if (!auth) return null;
  const c = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: auth } }, auth: { persistSession: false } });
  const { data, error } = await c.auth.getUser();
  return error || !data?.user ? null : { client: c, user: data.user };
}

export type Env = 'sandbox' | 'production';
export interface Ev {
  provider: 'apple' | 'google' | 'mercadopago'; env: Env; eventId: string; type: string;
  occurredAt: Date; token?: string | null; ref: string; plan: 'monthly' | 'annual';
  state: 'pending' | 'active' | 'grace' | 'canceled' | 'expired' | 'refunded' | 'revoked';
  start?: Date | null; end?: Date | null; autoRenew?: boolean | null;
  // gross_cents obrigatório; fee_cents/tax_cents só quando o provedor INFORMA (senão: estimativa).
  payment?: { external_id: string; gross_cents: number; fee_cents?: number; paid_at?: string } | null;
  refund?: { external_id: string; at?: string; charged_back?: boolean; refund_cents?: number;
             external_ref?: string } | null;
}

export async function ingest(db: SupabaseClient, e: Ev) {
  const { data, error } = await db.rpc('payments_ingest_event', {
    p_provider: e.provider, p_env: e.env, p_event_id: e.eventId, p_type: e.type,
    p_occurred_at: e.occurredAt.toISOString(), p_account_token: e.token ?? null, p_original_ref: e.ref,
    p_plan: e.plan, p_state: e.state, p_period_start: e.start?.toISOString() ?? null,
    p_period_end: e.end?.toISOString() ?? null, p_auto_renew: e.autoRenew ?? null,
    p_payment: e.payment ?? null, p_refund: e.refund ?? null,
  });
  if (error) throw new Error('ingest_rpc:' + error.code);
  return data as { status: string; user_id?: string };
}

export async function catalogRows(db: SupabaseClient, provider: string) {
  const { data } = await db.from('payment_catalog').select('plan,external_product_id,base_plan_id,price_cents')
    .eq('provider', provider).eq('environment', 'production').eq('active', true);
  return data ?? [];
}

export const b64 = (s: string) => Uint8Array.from(atob(s.replace(/-/g, '+').replace(/_/g, '/')), (c) => c.charCodeAt(0));
export const ts = (v?: string | number | null) => (v ? new Date(typeof v === 'string' ? v : Number(v)) : null);

export function timingEqual(a: string, b: string) {
  if (a.length !== b.length) return false;
  let d = 0; for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return d === 0;
}
