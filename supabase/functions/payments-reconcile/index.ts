// Reconciliação periódica (agendada por cron externo/pg_cron; protegida por CRON_SECRET).
// Relê o estado OFICIAL de cada assinatura vencendo/pendente e reaplica pelo mesmo caminho dos
// webhooks (idempotente). Lote pequeno e intervalo mínimo de 12 h por assinatura (ver
// service_subscriptions_to_check): respeita limites de API e não roda a cada abertura do app.
import { admin, catalogRows, ingest, json, timingEqual } from '../_shared/common.ts';
import { appleEvent, appleLookup } from '../_shared/apple.ts';
import { processGoogleToken } from '../_shared/google.ts';
import { reconcileMpPending, reconcilePreapproval } from '../_shared/mp.ts';

Deno.serve(async (req) => {
  const secret = Deno.env.get('CRON_SECRET'), got = req.headers.get('x-cron-secret') ?? '';
  if (!secret || !timingEqual(secret, got)) return json({ error: 'unauthorized' }, 401);
  const db = admin();
  const { data: subs } = await db.rpc('service_subscriptions_to_check', { p_limit: 50 });
  const out = { checked: 0, failed: 0 };
  const appleCat = await catalogRows(db, 'apple');
  for (const s of (subs ?? []) as any[]) {
    try {
      if (s.provider === 'apple') {
        const { status, tx, ren } = await appleLookup(s.original_ref, s.environment);
        const type = status === 2 ? 'EXPIRED' : status === 4 ? 'DID_FAIL_TO_RENEW' : status === 5 ? 'REVOKE' : 'RECON';
        const ev = appleEvent(tx, ren, type, status === 4 ? 'GRACE_PERIOD' : null,
          `recon:apple:${s.original_ref}:${status}:${tx.expiresDate}`, appleCat);
        if (ev) await ingest(db, { ...ev, occurredAt: new Date() });
      } else if (s.provider === 'google') {
        await processGoogleToken(db, s.original_ref, `recon:google:${s.original_ref}:${new Date().toISOString().slice(0, 13)}`, new Date());
      } else if (s.original_ref.startsWith('pre:')) {
        await reconcilePreapproval(db, s.original_ref.slice(4));
      }
      await db.rpc('service_mark_checked', { p_id: s.id });
      out.checked++;
    } catch (e) {
      out.failed++;
      console.error('reconcile', s.provider, (e as Error).message); // sem token/ref nos logs
    }
  }
  const mpPending = Deno.env.get('MP_ACCESS_TOKEN') ? await reconcileMpPending(db) : null; // só com Mercado Pago configurado
  return json({ ...out, mpPending });
});
