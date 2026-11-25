// Google Play: RTDN via Pub/Sub push (autenticado por OIDC) e verificação pós-compra vinda do
// app (JWT do usuário). O estado é SEMPRE relido na Developer API; a mensagem só avisa.
import { admin, caller, ingest, json } from '../_shared/common.ts';
import { applyGoogleVoided, PKG, processGoogleToken, verifyPubsub } from '../_shared/google.ts';

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method' }, 405);
  const db = admin();
  let body: any;
  try { body = await req.json(); } catch { return json({ error: 'body' }, 400); }
  try {
    if (body.message) {
      if (!(await verifyPubsub(req))) return json({ error: 'unauthorized' }, 401);
      const n = JSON.parse(new TextDecoder().decode(Uint8Array.from(atob(body.message.data), (c) => c.charCodeAt(0))));
      if (n.packageName !== PKG()) return json({ ok: true, ignored: 'package' });
      const at = new Date(Number(n.eventTimeMillis) || Date.now());
      const id = 'google:rtdn:' + body.message.messageId;
      if (n.subscriptionNotification) {
        const r = await processGoogleToken(db, n.subscriptionNotification.purchaseToken, id, at);
        return r.status === 'failed' ? json({ error: 'failed' }, 500) : json({ ok: true, status: r.status });
      }
      if (n.voidedPurchaseNotification) { // reembolso/chargeback/revogação
        const v = n.voidedPurchaseNotification;
        const r = await applyGoogleVoided(db, { purchaseToken: v.purchaseToken, orderId: v.orderId, chargeback: v.refundType === 2 },
          'google:void:' + v.orderId, at);
        if (r.status === 'unknown_token') return json({ ok: true, ignored: 'unknown_token' });
        return r.status === 'failed' ? json({ error: 'failed' }, 500) : json({ ok: true, status: r.status });
      }
      return json({ ok: true, ignored: 'type' }); // testNotification etc.
    }
    if (body.action === 'refresh') { // "Restaurar compras": relê o estado OFICIAL das assinaturas do próprio usuário
      const me = await caller(req);
      if (!me) return json({ error: 'unauthorized' }, 401);
      const { data: t } = await db.from('purchase_account_tokens').select('token').eq('user_id', me.user.id).maybeSingle();
      const since = new Date(Date.now() - 90 * 864e5).toISOString();
      const { data: subs } = await db.from('provider_subscriptions').select('id,original_ref,last_checked_at')
        .eq('user_id', me.user.id).eq('provider', 'google').neq('state', 'refunded')
        .or(`state.neq.expired,period_end.gte.${since}`).order('created_at', { ascending: false }).limit(5);
      let ok = 0, failed = 0;
      for (const s of subs ?? []) {
        if (s.last_checked_at && Date.now() - Date.parse(s.last_checked_at) < 15_000) { ok++; continue; } // limite de API
        try {
          await processGoogleToken(db, s.original_ref, `google:refresh:${s.original_ref}:${new Date().toISOString().slice(0, 16)}`,
            new Date(), t?.token); // conta divergente nunca é gravada
          await db.rpc('service_mark_checked', { p_id: s.id });
          ok++;
        } catch (e) { failed++; console.error('refresh', (e as Error).message); }
      }
      return failed && !ok ? json({ error: 'upstream' }, 502) : json({ ok: true, refreshed: ok, failed });
    }
    if (body.purchaseToken) { // do app
      const me = await caller(req);
      if (!me) return json({ error: 'unauthorized' }, 401);
      const { data: t } = await db.from('purchase_account_tokens').select('token').eq('user_id', me.user.id).maybeSingle();
      if (!t) return json({ error: 'no_account_token' }, 403);
      const r = await processGoogleToken(db, String(body.purchaseToken), 'google:client:' + crypto.randomUUID(), new Date(), t.token);
      return r.status === 'processed' ? json({ ok: true }) :
        json({ error: r.status }, r.status === 'account_mismatch' ? 403 : r.status === 'conflict' ? 409 : 422);
    }
    return json({ error: 'body' }, 400);
  } catch (e) {
    console.error('payments-google', (e as Error).message);
    return json({ error: 'invalid' }, 400);
  }
});
