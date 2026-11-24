// Mercado Pago (Web/Portal): cria Pix avulso ou checkout hospedado de assinatura no cartão,
// consulta/atualiza a cobrança pendente e cancela a assinatura. Valor, moeda e duração vêm do
// catálogo do servidor — nunca do cliente. Nenhum PAN/CVV passa por aqui (checkout hospedado).
import { admin, caller, catalogRows, json } from '../_shared/common.ts';
import { mp, processPayment, reconcilePreapproval } from '../_shared/mp.ts';

const ENV = () => (Deno.env.get('MP_ENV') === 'sandbox' ? 'sandbox' : 'production');

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method' }, 405);
  const me = await caller(req);
  if (!me) return json({ error: 'unauthorized' }, 401);
  let b: any;
  try { b = await req.json(); } catch { return json({ error: 'body' }, 400); }
  const db = admin();
  try {
    const action = String(b.action);
    if (action === 'status') {
      const { data: c } = await db.from('mp_pending_charges').select('*').eq('user_id', me.user.id)
        .order('created_at', { ascending: false }).limit(1).maybeSingle();
      if (c?.status === 'pending' && c.method === 'pix' && c.mp_ref) {
        await processPayment(db, c.mp_ref); // confirma de fato (idempotente)
        const p = await mp(`/v1/payments/${c.mp_ref}`);
        const st = p.status === 'approved' ? 'approved' : ['cancelled', 'expired'].includes(p.status) ? 'expired'
          : p.status === 'rejected' ? 'rejected' : 'pending';
        if (st !== 'pending') await db.from('mp_pending_charges').update({ status: st }).eq('id', c.id);
        return json({ status: st });
      }
      if (c?.status === 'pending' && c.method === 'card' && c.mp_ref) { // cartão: confirma no Mercado Pago (nunca pelo retorno do checkout)
        await reconcilePreapproval(db, c.mp_ref).catch(() => {});
        const { data: c2 } = await db.from('mp_pending_charges').select('status').eq('id', c.id).single();
        return json({ status: c2?.status ?? 'pending' });
      }
      return json({ status: c?.status ?? 'none' });
    }
    if (action === 'cancel') { // cancela a assinatura de cartão; acesso segue até o fim do período
      const { data: s } = await db.from('provider_subscriptions').select('original_ref')
        .eq('user_id', me.user.id).eq('provider', 'mercadopago').like('original_ref', 'pre:%')
        .in('state', ['active', 'grace']).maybeSingle();
      if (!s) return json({ error: 'no_subscription' }, 404);
      await mp(`/preapproval/${s.original_ref.slice(4)}`, { method: 'PUT', body: JSON.stringify({ status: 'cancelled' }) });
      return json({ ok: true });
    }
    if (action !== 'create' || !['monthly', 'annual'].includes(b.plan) || !['pix', 'card'].includes(b.method)) {
      return json({ error: 'body' }, 400);
    }
    const env = ENV();
    // Falha fechada ANTES de criar qualquer cobrança: sem conta recebedora/segredo do webhook o pagamento nunca seria creditado.
    if (!Deno.env.get(env === 'sandbox' ? 'MP_SANDBOX_COLLECTOR_ID' : 'MP_COLLECTOR_ID') || !Deno.env.get('MP_WEBHOOK_SECRET')) return json({ error: 'provider_disabled' }, 403);
    const { data: cfg } = await db.from('payment_providers_config').select('enabled').eq('provider', 'mercadopago').eq('environment', env).single();
    if (!cfg?.enabled) return json({ error: 'provider_disabled' }, 403);
    // Gate de e-mail confirmado + token opaco (sem e-mail/nome no external_reference).
    const { data: token, error: te } = await me.client.rpc('get_purchase_account_token');
    if (te || !token) return json({ error: 'not_allowed' }, 403);
    // Não duplica assinatura: já há provedor vigente → orienta a gerenciar (não cancela nada sozinho).
    const { data: act } = await db.from('provider_subscriptions').select('provider,state,period_end').eq('user_id', me.user.id)
      .in('state', ['active', 'grace', 'canceled']).gt('period_end', new Date().toISOString());
    if (act?.some((s) => s.provider !== 'mercadopago' || b.method === 'card')) {
      return json({ error: 'already_subscribed', provider: act![0].provider }, 409);
    }
    const row = (await catalogRows(db, 'mercadopago')).find((c) => c.plan === b.plan);
    if (!row) return json({ error: 'plan' }, 422);
    const amount = Number(row.price_cents) / 100;
    const origin = Deno.env.get('PORTAL_BACK_URL') ?? 'https://aprovaura.lucksrei.com/minha-assinatura';

    const { data: old } = await db.from('mp_pending_charges').select('*').eq('user_id', me.user.id).eq('status', 'pending');
    for (const o of old ?? []) { // mesma tentativa reaproveitada; plano/método novo substitui a antiga
      if (o.plan === b.plan && o.method === b.method && (!o.expires_at || new Date(o.expires_at) > new Date())) return json({ charge: o });
      await db.from('mp_pending_charges').update({ status: 'superseded' }).eq('id', o.id);
      if (o.method === 'pix' && o.mp_ref) await mp(`/v1/payments/${o.mp_ref}`, { method: 'PUT', body: JSON.stringify({ status: 'cancelled' }) }).catch(() => {});
    }
    const pendingId = crypto.randomUUID();
    if (b.method === 'pix') {
      const exp = new Date(Date.now() + 30 * 60_000);
      const p = await mp('/v1/payments', { method: 'POST', headers: { 'X-Idempotency-Key': pendingId }, body: JSON.stringify({
        transaction_amount: amount, description: `Aprovaura Premium (${b.plan})`, payment_method_id: 'pix',
        payer: { email: me.user.email }, external_reference: token, notification_url: Deno.env.get('MP_NOTIFICATION_URL'),
        date_of_expiration: exp.toISOString().replace('Z', '+00:00') }) });
      const t = p.point_of_interaction?.transaction_data;
      const { data: c } = await db.from('mp_pending_charges').insert({ id: pendingId, user_id: me.user.id, plan: b.plan,
        method: 'pix', mp_ref: String(p.id), amount_cents: row.price_cents, qr_code: t?.qr_code, qr_base64: t?.qr_code_base64,
        expires_at: exp.toISOString() }).select().single();
      return json({ charge: c });
    }
    const pre = await mp('/preapproval', { method: 'POST', body: JSON.stringify({
      reason: `Aprovaura Premium (${b.plan})`, external_reference: token, payer_email: me.user.email, back_url: origin,
      status: 'pending', auto_recurring: { frequency: b.plan === 'annual' ? 12 : 1, frequency_type: 'months',
        transaction_amount: amount, currency_id: 'BRL' } }) });
    const { data: c } = await db.from('mp_pending_charges').insert({ id: pendingId, user_id: me.user.id, plan: b.plan,
      method: 'card', mp_ref: String(pre.id), amount_cents: row.price_cents, checkout_url: pre.init_point,
      expires_at: new Date(Date.now() + 24 * 3_600_000).toISOString() }).select().single();
    return json({ charge: c });
  } catch (e) {
    console.error('mp-checkout', (e as Error).message);
    return json({ error: 'unavailable' }, 502);
  }
});
