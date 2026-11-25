// Reconciliação periódica (agendada por cron externo/pg_cron; protegida por CRON_SECRET).
// Relê o estado OFICIAL de cada assinatura vencendo/pendente e reaplica pelo mesmo caminho dos
// webhooks (idempotente). Lote pequeno e intervalo mínimo de 12 h por assinatura (ver
// service_subscriptions_to_check): respeita limites de API e não roda a cada abertura do app.
import { admin, catalogRows, ingest, json, timingEqual } from '../_shared/common.ts';
import { appleOfficialEvent } from '../_shared/apple.ts';
import { applyGoogleVoided, listVoided, processGoogleToken } from '../_shared/google.ts';
import { reconcileMpPending, reconcilePreapproval } from '../_shared/mp.ts';

Deno.serve(async (req) => {
  const secret = Deno.env.get('CRON_SECRET'), got = req.headers.get('x-cron-secret') ?? '';
  if (!secret || !timingEqual(secret, got)) return json({ error: 'unauthorized' }, 401);
  const db = admin();
  const out = { checked: 0, failed: 0, voided: 0, voidedFailed: 0 };
  const appleCat = await catalogRows(db, 'apple');
  // Paginação: até 4 lotes de 50 por execução. Todo item tentado (inclusive com erro) recebe last_checked_at,
  // então uma falha persistente não trava a fila (head-of-line) e é retentada só após o intervalo mínimo.
  const subs: any[] = [];
  for (let i = 0; i < 4; i++) {
    const { data } = await db.rpc('service_subscriptions_to_check', { p_limit: 50 });
    const batch = (data ?? []) as any[];
    if (!batch.length) break;
    for (const s of batch) await db.rpc('service_mark_checked', { p_id: s.id }); // reserva: evita repetir no mesmo lote
    subs.push(...batch);
    if (batch.length < 50) break;
  }
  for (const s of subs) {
    try {
      if (s.provider === 'apple') {
        const ev = await appleOfficialEvent(s.original_ref, s.environment, appleCat);
        if (ev) await ingest(db, { ...ev, occurredAt: new Date() });
      } else if (s.provider === 'google') {
        await processGoogleToken(db, s.original_ref, `recon:google:${s.original_ref}:${new Date().toISOString().slice(0, 13)}`, new Date());
      } else if (s.original_ref.startsWith('pre:')) {
        await reconcilePreapproval(db, s.original_ref.slice(4));
      }
      out.checked++;
    } catch (e) {
      out.failed++;
      console.error('reconcile', s.provider, (e as Error).message); // sem token/ref nos logs
    }
  }
  // Alternativa ao RTDN para reembolsos/chargebacks: lista oficial de compras anuladas (janela de 3 dias, idempotente).
  if (Deno.env.get('GOOGLE_SA_JSON')) {
    try {
      for (const v of await listVoided(Date.now() - 3 * 864e5)) {
        try {
          const r = await applyGoogleVoided(db, { purchaseToken: v.purchaseToken, orderId: v.orderId, chargeback: v.voidedReason === 7 },
            'google:void:' + v.orderId, new Date(Number(v.voidedTimeMillis) || Date.now()));
          if (r.status === 'processed') out.voided++;
        } catch (e) { out.voidedFailed++; console.error('voided', (e as Error).message); }
      }
    } catch (e) { out.voidedFailed++; console.error('voided_list', (e as Error).message); }
  }
  const mpPending = Deno.env.get('MP_ACCESS_TOKEN') ? await reconcileMpPending(db) : null; // só com Mercado Pago configurado
  return json({ ...out, mpPending });
});
