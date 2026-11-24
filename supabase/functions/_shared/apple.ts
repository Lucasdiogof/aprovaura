// Apple: validação REAL de JWS (assinatura + cadeia de certificados fixada na raiz Apple),
// mapeamento de transações/notificações V2 e consulta à App Store Server API.
import { compactVerify, decodeProtectedHeader, importPKCS8, importX509, SignJWT } from 'npm:jose@5';
import * as x509 from 'npm:@peculiar/x509@1';
import { Ev } from './common.ts';

export const BUNDLE_ID = () => Deno.env.get('APPLE_BUNDLE_ID') ?? 'com.lucasdiogof.aprovaura';

/** Verifica o JWS (ES256) e a cadeia leaf → intermediária → raiz Apple fixada em APPLE_ROOT_CA_PEM. */
export async function verifyJws(jws: string): Promise<Record<string, any>> {
  const h = decodeProtectedHeader(jws);
  if (h.alg !== 'ES256' || !Array.isArray(h.x5c) || h.x5c.length !== 3) throw new Error('bad_jws');
  const pem = Deno.env.get('APPLE_ROOT_CA_PEM');
  if (!pem) throw new Error('apple_root_not_configured');
  const [leaf, inter, root] = h.x5c.map((c: string) => new x509.X509Certificate(c));
  const pinned = new x509.X509Certificate(pem);
  const now = new Date();
  const same = (a: ArrayBuffer, b: ArrayBuffer) => new Uint8Array(a).join() === new Uint8Array(b).join();
  if (!same(root.rawData, pinned.rawData)) throw new Error('untrusted_root');
  for (const c of [leaf, inter, root]) if (now < c.notBefore || now > c.notAfter) throw new Error('cert_expired');
  if (!(await leaf.verify({ publicKey: inter, date: now })) || !(await inter.verify({ publicKey: root, date: now })) ||
      !(await root.verify({ publicKey: root, date: now }))) throw new Error('bad_chain');
  // Extensões que a Apple marca em certificados de recibo (leaf e intermediária).
  if (!leaf.getExtension('1.2.840.113635.100.6.11.1') || !inter.getExtension('1.2.840.113635.100.6.2.1')) {
    throw new Error('bad_oid');
  }
  const key = await importX509(leaf.toString('pem'), 'ES256');
  const { payload } = await compactVerify(jws, key);
  return JSON.parse(new TextDecoder().decode(payload));
}

type Cat = { plan: string; external_product_id: string }[];

/** Transação (+ renovação) → evento normalizado. Devolve null se produto/bundle não confere. */
export function appleEvent(tx: any, ren: any | null, type: string, subtype: string | null,
                           eventId: string, cat: Cat): Ev | null {
  if (tx.bundleId !== BUNDLE_ID()) return null;
  const row = cat.find((c) => c.external_product_id === tx.productId);
  if (!row) return null;
  const env = tx.environment === 'Production' ? 'production' : 'sandbox';
  const exp = tx.expiresDate ? new Date(tx.expiresDate) : null;
  let state: Ev['state'] = 'active';
  if (tx.revocationDate) state = tx.revocationReason === 0 ? 'revoked' : 'refunded';
  else if (type === 'EXPIRED' || type === 'GRACE_PERIOD_EXPIRED' || (exp && exp < new Date() && type !== 'DID_FAIL_TO_RENEW')) state = 'expired';
  else if (type === 'DID_FAIL_TO_RENEW') state = subtype === 'GRACE_PERIOD' ? 'grace' : 'canceled';
  else if (type === 'REFUND') state = 'refunded';
  else if (type === 'REVOKE') state = 'revoked';
  else if (ren && ren.autoRenewStatus === 0) state = 'canceled'; // cancelou a renovação: vale até o fim
  const end = state === 'grace' && ren?.gracePeriodExpiresDate ? new Date(ren.gracePeriodExpiresDate) : exp;
  const paid = ['SUBSCRIBED', 'DID_RENEW', 'OFFER_REDEEMED'].includes(type) && !tx.revocationDate &&
               typeof tx.price === 'number' && tx.price > 0 && tx.currency === 'BRL';
  const refunded = state === 'refunded' || state === 'revoked';
  return {
    provider: 'apple', env, eventId, type: type.toLowerCase(), occurredAt: new Date(tx.signedDate ?? Date.now()),
    token: tx.appAccountToken ?? null, ref: String(tx.originalTransactionId), plan: row.plan as any, state,
    start: tx.purchaseDate ? new Date(tx.purchaseDate) : null, end,
    autoRenew: ren ? ren.autoRenewStatus === 1 : null,
    // price vem em milésimos da moeda (19900 = R$ 19,90). Valor pago pelo cliente (bruto).
    payment: paid ? { external_id: String(tx.transactionId), gross_cents: Math.round(tx.price / 10),
                      paid_at: new Date(tx.purchaseDate).toISOString() } : null,
    refund: refunded ? { external_id: String(tx.transactionId), at: new Date(tx.revocationDate ?? Date.now()).toISOString(),
                         charged_back: false, external_ref: 'apple-refund:' + tx.transactionId } : null,
  };
}

async function appleJwt() {
  const key = await importPKCS8(Deno.env.get('APPLE_IAP_PRIVATE_KEY')!, 'ES256');
  return await new SignJWT({ bid: BUNDLE_ID() })
    .setProtectedHeader({ alg: 'ES256', kid: Deno.env.get('APPLE_IAP_KEY_ID')!, typ: 'JWT' })
    .setIssuer(Deno.env.get('APPLE_IAP_ISSUER_ID')!).setIssuedAt().setExpirationTime('10m')
    .setAudience('appstoreconnect-v1').sign(key);
}

/** Consulta oficial do estado atual (App Store Server API). */
export async function appleLookup(originalTransactionId: string, env: 'sandbox' | 'production') {
  const host = env === 'production' ? 'api.storekit.itunes.apple.com' : 'api.storekit-sandbox.itunes.apple.com';
  const r = await fetch(`https://${host}/inApps/v1/subscriptions/${encodeURIComponent(originalTransactionId)}`,
    { headers: { Authorization: 'Bearer ' + await appleJwt() } });
  if (!r.ok) throw new Error('apple_api_' + r.status);
  const last = (await r.json()).data?.[0]?.lastTransactions?.[0];
  if (!last) throw new Error('apple_no_data');
  return { status: last.status as number, tx: await verifyJws(last.signedTransactionInfo),
           ren: last.signedRenewalInfo ? await verifyJws(last.signedRenewalInfo) : null };
}
