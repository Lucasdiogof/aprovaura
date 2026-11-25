// Apple: (1) Notificações V2 do App Store Server (POST {signedPayload}, sem JWT — a autenticidade vem
// da assinatura JWS + cadeia fixada na raiz Apple) e (2) verificação pós-compra vinda do app
// (POST {signedTransaction} COM JWT do usuário). O cliente nunca confirma pagamento: aqui o
// backend valida e só então grava o entitlement.
import { admin, caller, catalogRows, ingest, json } from '../_shared/common.ts';
import { appleEvent, appleOfficialEvent, verifyJws } from '../_shared/apple.ts';

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method' }, 405);
  const db = admin();
  let body: any;
  try { body = await req.json(); } catch { return json({ error: 'body' }, 400); }
  try {
    const cat = await catalogRows(db, 'apple');
    if (body.signedPayload) {
      const n = await verifyJws(body.signedPayload);
      if (n.data?.bundleId !== (Deno.env.get('APPLE_BUNDLE_ID') ?? 'com.lucasdiogof.aprovaura')) return json({ ok: true, ignored: 'bundle' });
      if (!n.data?.signedTransactionInfo) return json({ ok: true, ignored: 'no_tx' }); // ex.: TEST
      const tx = await verifyJws(n.data.signedTransactionInfo);
      const ren = n.data.signedRenewalInfo ? await verifyJws(n.data.signedRenewalInfo) : null;
      const ev = appleEvent(tx, ren, n.notificationType, n.subtype ?? null, 'apple:' + n.notificationUUID, cat);
      if (!ev) return json({ ok: true, ignored: 'product' });
      const r = await ingest(db, ev);
      // 5xx faz a Apple reenviar; "conflict" é definitivo (não reenviar).
      return r.status === 'failed' ? json({ error: 'failed' }, 500) : json({ ok: true, status: r.status });
    }
    // "Restaurar compras": o StoreKit só devolve o que está vigente; o servidor relê o estado OFICIAL
    // (inclusive expirado/revogado) das assinaturas Apple já ligadas à conta do usuário.
    if (body.action === 'refresh') {
      const me = await caller(req);
      if (!me) return json({ error: 'unauthorized' }, 401);
      const { data: subs } = await db.from('provider_subscriptions').select('original_ref,environment')
        .eq('provider', 'apple').eq('user_id', me.user.id);
      let ok = 0, failed = 0;
      for (const s of subs ?? []) {
        try {
          const ev = await appleOfficialEvent(s.original_ref, s.environment, cat);
          if (ev) await ingest(db, { ...ev, occurredAt: new Date() });
          ok++;
        } catch (e) { failed++; console.error('apple refresh', (e as Error).message); }
      }
      return failed && !ok ? json({ error: 'upstream' }, 502) : json({ ok: true, refreshed: ok, failed });
    }
    // Verificação vinda do app (usuário autenticado).
    if (body.signedTransaction) {
      const me = await caller(req);
      if (!me) return json({ error: 'unauthorized' }, 401);
      const tx = await verifyJws(body.signedTransaction);
      const { data: t } = await db.from('purchase_account_tokens').select('token').eq('user_id', me.user.id).maybeSingle();
      if (!t || String(tx.appAccountToken ?? '').toLowerCase() !== t.token) return json({ error: 'account_mismatch' }, 403);
      const clientEv = appleEvent(tx, null, 'SUBSCRIBED', null, 'apple:client:' + tx.transactionId, cat);
      if (!clientEv) return json({ error: 'product' }, 422);
      // A transação do app é só uma foto: reenviá-la (ex.: "Restaurar compras") NÃO pode reabrir uma assinatura
      // cancelada nem apagar autoRenew. O estado vem da consulta OFICIAL à Apple; da transação só vem o pagamento.
      let ev = clientEv;
      try {
        const off = await appleOfficialEvent(String(tx.originalTransactionId), clientEv.env, cat);
        if (off) ev = { ...off, occurredAt: new Date(), payment: clientEv.payment };
      } catch (e) { console.error('apple client official', (e as Error).message); } // sem a API: cai na transação
      const r = await ingest(db, ev);
      return r.status === 'processed' ? json({ ok: true }) : json({ error: r.status }, r.status === 'conflict' ? 409 : 500);
    }
    return json({ error: 'body' }, 400);
  } catch (e) {
    // Nunca devolve detalhes (nem payload) ao chamador.
    console.error('payments-apple', (e as Error).message);
    return json({ error: 'invalid' }, 400);
  }
});
