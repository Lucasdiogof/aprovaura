-- Achado do QA (Etapa 10B, auditoria com PAT): refresh_broken_streak(p_user_id, p_today) é SECURITY DEFINER
-- e estava executável por anon/authenticated via RPC, sem checar o dono. Com p_today distante qualquer pessoa
-- que soubesse o UUID zerava a sequência de estudo de outro usuário.
-- O app não a chama direto: só get_or_refresh_user_streak/register_activity_completion (SECURITY DEFINER,
-- executam como dono), então revogar não quebra nada.
revoke execute on function public.refresh_broken_streak(uuid, date) from public, anon, authenticated;
notify pgrst, 'reload schema';
