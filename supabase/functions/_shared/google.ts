// Google Play: Developer API (subscriptionsv2), mapeamento, acknowledge e autenticação do Pub/Sub.
import { createRemoteJWKSet, importPKCS8, jwtVerify, SignJWT } from 'npm:jose@5';
import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.47.10';
import { catalogRows, Ev, ingest, ts } from './common.ts';

export const PKG = () => Deno.env.get('GOOGLE_PACKAGE_NAME') ?? 'com.lucasdiogof.aprovaura';

async function accessToken(): Promise<string> {
  const sa = JSON.parse(Deno.env.get('GOOGLE_SA_JSON') ?? '{}');
  if (!sa.private_key) throw new Error('google_sa_not_configured');
  const jwt = await new SignJWT({ scope: 'https://www.googleapis.com/auth/androidpublisher' })
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' }).setIssuer(sa.client_email)
    .setAudience('https://oauth2.googleapis.com/token').setIssuedAt().setExpirationTime('50m')
    .sign(await importPKCS8(sa.private_key, 'RS256'));
  const r = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST', headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: jwt }),
  });
  if (!r.ok) throw new Error('google_token_' + r.status);
  return (await r.json()).access_token;
}

const api = async (path: string, init?: RequestInit) =>
  fetch(`https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PKG()}/${path}`,
    { ...init, headers: { Authorization: 'Bearer ' + await accessToken(), 'content-type': 'application/json' } });

export async function fetchSubscription(token: string) {
  const r = await api(`purchases/subscriptionsv2/tokens/${encodeURIComponent(token)}`);
  if (!r.ok) throw new Error('google_api_' + r.status);
  return await r.json();
}

/** Autentica o push do Pub/Sub (OIDC do service account configurado) — sem isso, nada é processado. */
export async function verifyPubsub(req: Request) {
  const raw = (req.headers.get('Authorization') ?? '').replace(/^Bearer /i, '');
  const aud = Deno.env.get('GOOGLE_PUBSUB_AUDIENCE'), email = Deno.env.get('GOOGLE_PUBSUB_SA_EMAIL');
  if (!raw || !aud || !email) return false;
  try {
    const { payload } = await jwtVerify(raw, createRemoteJWKSet(new URL('https://www.googleapis.com/oauth2/v3/certs')),
      { issuer: ['https://accounts.google.com', 'accounts.google.com'], audience: aud });
    return payload.email === email && payload.email_verified === true;
  } catch { return false; }
}

const STATE: Record<string, Ev['state']> = {
  SUBSCRIPTION_STATE_ACTIVE: 'active', SUBSCRIPTION_STATE_CANCELED: 'canceled',
  SUBSCRIPTION_STATE_IN_GRACE_PERIOD: 'grace', SUBSCRIPTION_STATE_ON_HOLD: 'expired',
  SUBSCRIPTION_STATE_PAUSED: 'expired', SUBSCRIPTION_STATE_EXPIRED: 'expired',
  SUBSCRIPTION_STATE_PENDING: 'pending', SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED: 'expired',
};

/** Consulta o token, valida pacote/produto/base plan/conta, grava e só então confirma (acknowledge). */
export async function processGoogleToken(db: SupabaseClient, token: string, eventId: string, occurredAt: Date,
                                         expectToken?: string) {
  const s = await fetchSubscription(token);
  const li = s.lineItems?.[0];
  if (!li) throw new Error('google_no_line_item');
  const row = (await catalogRows(db, 'google')).find((c) => c.external_product_id === li.productId &&
    (c.base_plan_id ?? null) === (li.offerDetails?.basePlanId ?? null));
  if (!row) return { status: 'ignored_product' };
  const acct = s.externalAccountIdentifiers?.obfuscatedExternalAccountId ?? null;
  if (expectToken && acct !== expectToken) return { status: 'account_mismatch' };
  const state = STATE[s.subscriptionState] ?? 'pending';
  const test = !!s.testPurchase;
  const orderId = li.latestSuccessfulOrderId as string | undefined;
  // Troca de token (upgrade/reinscrição): a assinatura antiga é encerrada, a nova vira a vigente.
  if (s.linkedPurchaseToken) {
    await ingest(db, { provider: 'google', env: test ? 'sandbox' : 'production', eventId: 'google:replaced:' + token,
      type: 'replaced', occurredAt, ref: s.linkedPurchaseToken, plan: row.plan as any, state: 'expired', end: new Date() }).catch(() => {});
  }
  const paying = ['active', 'canceled', 'grace'].includes(state) && !!orderId && !test;
  const ev: Ev = {
    provider: 'google', env: test ? 'sandbox' : 'production', eventId, type: String(s.subscriptionState).toLowerCase(),
    occurredAt, token: acct, ref: token, plan: row.plan as any, state,
    start: ts(s.startTime), end: ts(li.expiryTime), autoRenew: li.autoRenewingPlan?.autoRenewEnabled ?? false,
    // A API v2 não devolve o preço pago: usa o preço de referência e fica "estimado" até conciliar com o relatório da Play.
    payment: paying ? { external_id: orderId!, gross_cents: Number(row.price_cents) } : null,
  };
  const r = await ingest(db, ev);
  if (r.status === 'processed' && ['active', 'canceled', 'grace'].includes(state) &&
      s.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING') {
    // Só após validar e persistir; renovações já vêm reconhecidas.
    await api(`purchases/subscriptions/${li.productId}/tokens/${encodeURIComponent(token)}:acknowledge`,
      { method: 'POST', body: '{}' });
  }
  return { status: r.status };
}
