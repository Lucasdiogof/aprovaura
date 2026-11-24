// Mercado Pago: webhook. Autentica por HMAC oficial, NUNCA confia no corpo — relê o recurso na API
// e valida conta recebedora, valor, moeda, plano e referência antes de qualquer efeito.
import { admin, json } from '../_shared/common.ts';
import { processAuthorizedPayment, processChargeback, processPayment, processPreapproval, verifySignature } from '../_shared/mp.ts';

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method' }, 405);
  const url = new URL(req.url);
  let body: any = {};
  try { body = await req.json(); } catch { /* IPN antigo só com query */ }
  const id = String(url.searchParams.get('data.id') ?? body?.data?.id ?? '');
  const type = String(body?.type ?? url.searchParams.get('type') ?? '');
  if (!id || !(await verifySignature(req, id))) return json({ error: 'unauthorized' }, 401);
  try {
    const db = admin();
    const r = type === 'payment' ? await processPayment(db, id)
      : type === 'subscription_authorized_payment' ? await processAuthorizedPayment(db, id)
      : type === 'subscription_preapproval' ? await processPreapproval(db, id)
      : ['topic_chargebacks_wh', 'chargebacks'].includes(type) ? await processChargeback(db, id) : 'ignored';
    return json({ ok: true, result: r });
  } catch (e) {
    console.error('mp-webhook', type, (e as Error).message);
    return json({ error: 'retry' }, 500); // o Mercado Pago reenvia
  }
});
