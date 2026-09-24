// Account deletion -- the only privileged step is removing the row from
// auth.users, which needs the service/secret key (never shipped to
// Flutter). Everything else about the user is already ON DELETE CASCADE
// straight off auth.users (see supabase/DELETE_ACCOUNT.md for the full
// table-by-table audit), so there is no separate "clean up first" RPC to
// call here -- deleting auth.users IS the cleanup.
//
// Security:
// - The caller's user id is NEVER taken from the request body. It's
//   resolved from the caller's own JWT via auth.getUser(), using a client
//   built with the anon/publishable key + the caller's own Authorization
//   header -- the same pattern Supabase's own docs use for "act as the
//   caller". getUser() revalidates the token against GoTrue; it doesn't
//   just decode the JWT locally.
// - A second, separate client -- built with the service/secret key,
//   never exposed to the caller -- is the only thing that calls
//   auth.admin.deleteUser(). That key only ever lives in this function's
//   environment (Supabase injects it automatically; see the deploy notes
//   for exactly which env var name to check for your project).
// - No table anywhere lets an authenticated user reference another
//   user's id for this operation -- there IS no id parameter at all.
//
// Idempotent by construction, not by an explicit check: a second call
// with the same (now-stale) token fails at auth.getUser() the moment the
// user no longer exists, before anything else runs. There's nothing left
// to double-delete.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.47.10';

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'method not allowed' }), { status: 405 });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'missing authorization header' }), { status: 401 });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;

  // Client "as the caller": anon/publishable key + their JWT, never the
  // service/secret key.
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userError } = await callerClient.auth.getUser();
  if (userError || !userData?.user) {
    return new Response(JSON.stringify({ error: 'invalid session' }), { status: 401 });
  }
  const userId = userData.user.id;

  // Supabase auto-injects the project's privileged key under this name
  // for every Edge Function -- on a project still using the legacy key
  // format this is the service_role JWT, on one migrated to the new
  // publishable/secret key format it's the sb_secret_... value. Same env
  // var name either way; nothing to change here when a project migrates.
  const secretKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const adminClient = createClient(supabaseUrl, secretKey);

  const { error: deleteError } = await adminClient.auth.admin.deleteUser(userId);
  if (deleteError) {
    // The account is untouched -- nothing ran before this point that
    // could have partially deleted anything.
    return new Response(JSON.stringify({ error: deleteError.message }), { status: 500 });
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
