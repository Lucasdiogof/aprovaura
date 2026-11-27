// Provisiona um professor parceiro. O navegador NUNCA recebe chave privilegiada:
// 1) a identidade do chamador vem do JWT e precisa passar em admin_assert()
//    (RPC chamada COM o JWT dele, então a autorização é a do banco);
// 2) só então o cliente de serviço procura/cria a conta (conta única: se o e-mail
//    já existe, é reutilizada, a senha NUNCA é tocada);
// 3) a parceria é criada por admin_promote_partner COM o JWT do admin, para a
//    auditoria registrar o ator correto;
// 4) conta nova nasce com senha aleatória descartada; o professor define a própria
//    senha pelo botão do e-mail de convite (/convite?th=...: abre a tela de senha e já
//    entra logado). Nenhuma senha é guardada.
// Deploy: supabase functions deploy admin-provision-partner (verify_jwt = true).
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.47.10';
import { publishableKey, secretKey } from '../_shared/keys.ts';

// QA_ORIGIN (opcional) só existe no ambiente local de QA; em produção a lista é só a web oficial.
const ORIGINS = ['https://aprovaura.lucksrei.com', ...(Deno.env.get('QA_ORIGIN') ? [Deno.env.get('QA_ORIGIN')!] : [])];
const cors = (req: Request) => ({
  'Access-Control-Allow-Origin': ORIGINS.includes(req.headers.get('Origin') ?? '')
    ? req.headers.get('Origin')! : ORIGINS[0],
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Vary': 'Origin',
});
const json = (req: Request, status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors(req), 'Content-Type': 'application/json' } });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== 'POST') return json(req, 405, { error: 'method_not_allowed' });
  const auth = req.headers.get('Authorization');
  if (!auth) return json(req, 401, { error: 'unauthorized' });

  const url = Deno.env.get('SUPABASE_URL')!;
  const caller = createClient(url, publishableKey(), { global: { headers: { Authorization: auth } } });
  const { error: adminErr } = await caller.rpc('admin_assert');
  if (adminErr) return json(req, adminErr.code === '42501' ? 403 : 401, { error: 'forbidden' });

  let b: Record<string, unknown>;
  try { b = await req.json(); } catch { return json(req, 400, { error: 'invalid_json' }); }
  const email = String(b.email ?? '').trim().toLowerCase();
  const name = String(b.display_name ?? '').trim();
  if (!/^[^@\s]{1,64}@[^@\s]+\.[^@\s]+$/.test(email) || email.length > 254) return json(req, 400, { error: 'invalid_email' });
  if (name.length < 2 || name.length > 80) return json(req, 400, { error: 'invalid_name' });

  // Nome de usuário (mesma regra do app: 3 a 20 de A-Z a-z 0-9 . _). Só vale para conta NOVA;
  // numa conta existente o usuário mantém o dele. O professor pode trocá-lo depois em "Minha conta".
  const username = String(b.username ?? '').trim();
  if (username && !/^[A-Za-z0-9._]{3,20}$/.test(username)) return json(req, 400, { error: 'invalid_username' });

  const svc = createClient(url, secretKey());
  const found = await svc.rpc('service_find_user_by_email', { p_email: email });
  if (found.error) return json(req, 500, { error: 'lookup_failed' });
  let userId: string | null = found.data;
  let created = false;

  if (!userId) {
    if (!username) return json(req, 400, { error: 'invalid_username' });
    const free = await svc.rpc('is_username_available', { p_username: username });
    if (free.error) return json(req, 500, { error: 'lookup_failed' });
    if (!free.data) return json(req, 409, { error: 'username_in_use' });
    const pwd = crypto.randomUUID() + crypto.randomUUID(); // descartada: ninguém a conhece
    const lang = ['pt', 'en', 'es'].includes(String(b.lang)) ? String(b.lang) : 'pt';
    const r = await svc.auth.admin.createUser({
      // invite=true só vale para o e-mail de convite abaixo (botão em vez de código); é apagado logo depois.
      email, password: pwd, email_confirm: false, user_metadata: { lang, name, username, partner: true, invite: true },
    });
    if (r.error || !r.data.user) {
      const again = await svc.rpc('service_find_user_by_email', { p_email: email }); // corrida
      if (!again.data) return json(req, 500, { error: 'create_failed' });
      userId = again.data;
    } else {
      userId = r.data.user.id; created = true;
      await svc.from('profiles').upsert({ id: userId, name }, { onConflict: 'id', ignoreDuplicates: true });
    }
  }

  const bps = b.commission_bps == null || b.commission_bps === '' ? null : Number(b.commission_bps);
  const promoted = await caller.rpc('admin_promote_partner', {
    p_user: userId, p_display_name: name, p_referral_code: b.referral_code || null,
    p_commission_bps: bps, p_pix_key_type: b.pix_key_type || null, p_pix_key: b.pix_key || null,
  });
  if (promoted.error) {
    if (created) await svc.auth.admin.deleteUser(userId!); // não deixa conta órfã
    const code = promoted.error.code;
    return json(req, code === 'P0051' || code === 'P0052' ? 409 : 400,
      { error: code === 'P0051' ? 'already_partner' : code === 'P0052' ? 'code_in_use' : 'rejected' });
  }

  let recovery = false;
  if (created) {
    const anon = createClient(url, publishableKey());
    recovery = !(await anon.auth.resetPasswordForEmail(email)).error;
    // O e-mail já foi montado: o "esqueci a senha" futuro volta a mandar o código normal.
    await svc.auth.admin.updateUserById(userId!, { user_metadata: { invite: false } });
  }
  return json(req, 200, { partner_id: promoted.data, user_id: userId, created_account: created, recovery_sent: recovery });
});
