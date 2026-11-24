// Teste local (sem rede de provedor): assinatura HMAC do webhook do Mercado Pago e comparação em tempo constante.
// Rodar: deno test --allow-env supabase/functions/_shared/mp_signature_test.ts
import { verifySignature } from './mp.ts';
import { timingEqual } from './common.ts';

const SECRET = 'segredo-de-teste';

async function sign(dataId: string, rid: string, ts: string, secret = SECRET) {
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const mac = new Uint8Array(await crypto.subtle.sign('HMAC', key, new TextEncoder().encode((dataId ? `id:${dataId.toLowerCase()};` : '') + (rid ? `request-id:${rid};` : '') + `ts:${ts};`)));
  return [...mac].map((b) => b.toString(16).padStart(2, '0')).join('');
}
const req = (sig: string, rid = 'rid-1') => new Request('https://x.test/hook', { method: 'POST', headers: { 'x-signature': sig, 'x-request-id': rid } });
const assert = (c: boolean, m: string) => { if (!c) throw new Error(m); };

Deno.test('assinatura válida é aceita (id em maiúsculas é normalizado)', async () => {
  Deno.env.set('MP_WEBHOOK_SECRET', SECRET);
  const v1 = await sign('ABC123', 'rid-1', '1700000000');
  assert(await verifySignature(req(`ts=1700000000,v1=${v1}`), 'ABC123'), 'deveria aceitar');
});

Deno.test('assinatura adulterada, outro id, outro request-id e sem segredo são recusados', async () => {
  Deno.env.set('MP_WEBHOOK_SECRET', SECRET);
  const v1 = await sign('abc', 'rid-1', '1700000000');
  assert(!(await verifySignature(req(`ts=1700000000,v1=${v1.replace(/.$/, '0')}`), 'abc')) || v1.endsWith('0'), 'adulterada');
  assert(!(await verifySignature(req(`ts=1700000000,v1=${v1}`), 'outro-id')), 'outro id');
  assert(!(await verifySignature(req(`ts=1700000000,v1=${v1}`, 'rid-2'), 'abc')), 'outro request-id');
  assert(!(await verifySignature(req(`ts=1700000001,v1=${v1}`), 'abc')), 'ts alterado');
  assert(!(await verifySignature(req(''), 'abc')), 'sem cabeçalho');
  Deno.env.delete('MP_WEBHOOK_SECRET');
  assert(!(await verifySignature(req(`ts=1700000000,v1=${v1}`), 'abc')), 'sem segredo configurado falha fechada');
});

Deno.test('segredo errado é recusado', async () => {
  Deno.env.set('MP_WEBHOOK_SECRET', SECRET);
  const v1 = await sign('abc', 'rid-1', '1700000000', 'outro-segredo');
  assert(!(await verifySignature(req(`ts=1700000000,v1=${v1}`), 'abc')), 'segredo errado');
});

Deno.test('timingEqual', () => {
  assert(timingEqual('abc', 'abc'), 'iguais');
  assert(!timingEqual('abc', 'abd'), 'diferentes');
  assert(!timingEqual('abc', 'abcd'), 'tamanhos diferentes');
});

Deno.test('sem x-request-id o manifesto omite a parte (regra oficial) e valida', async () => {
  Deno.env.set('MP_WEBHOOK_SECRET', SECRET);
  const v1 = await sign('abc', '', '1700000000');
  const r = new Request('https://x.test/hook', { method: 'POST', headers: { 'x-signature': `ts=1700000000,v1=${v1}` } });
  assert(await verifySignature(r, 'abc'), 'sem request-id');
});
