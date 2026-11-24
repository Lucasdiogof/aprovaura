-- Reverte 0600 SEM apagar tabelas de provas/aceites (preserva dados reais).
-- Para remover tudo, drope as tabelas manualmente depois de revisar.
-- Depois de rodar este arquivo, reexecute as definições de is_admin,
-- bootstrap_first_admin, admin_set_admin, maybe_grant_trial, get_my_access,
-- app_pre_request, _apply_signup_referral, get_public_app_config e
-- admin_update_commercial_config dos arquivos 20261124000100..0500.
drop trigger if exists on_auth_email_confirmed_trg on auth.users;
drop function if exists on_auth_email_confirmed();
drop function if exists require_email_reverification(uuid);
drop function if exists search_active_partners(text, integer, integer);
drop function if exists get_study_sharing();
drop function if exists set_study_sharing(boolean, text, boolean, boolean);
drop function if exists get_legal_status();
drop function if exists record_legal_acceptance(text, text);
drop function if exists _apply_signup_legal(uuid);
drop function if exists owner_attest_email(uuid, text);
