// Google Play: RTDN via Pub/Sub push (autenticado por OIDC) e verificação pós-compra vinda do
// app (JWT do usuário). O estado é SEMPRE relido na Developer API; a mensagem só avisa.
import { admin, caller, ingest, json } from '../_shared/common.ts';
import { PKG, processGoogleToken, verifyPubsub } from '../_shared/google.ts';

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
        const { data: sub } = await db.from('provider_subscriptions').select('plan,environment')
          .eq('provider', 'google').eq('original_ref', v.purchaseToken).maybeSingle();
        if (!sub) return json({ ok: true, ignored: 'unknown_token' });
        const r = await ingest(db, { provider: 'google', env: sub.environment, eventId: id, type: 'voided', occurredAt: at,
          ref: v.purchaseToken, plan: sub.plan, state: 'refunded', end: new Date(),
          refund: { external_id: v.orderId, at: at.toISOString(), charged_back: v.refundType === 2,
                    external_ref: 'google-void:' + v.orderId } });
        return r.status === 'failed' ? json({ error: 'failed' }, 500) : json({ ok: true, status: r.status });
      }
      return json({ ok: true, ignored: 'type' }); // testNotification etc.
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
