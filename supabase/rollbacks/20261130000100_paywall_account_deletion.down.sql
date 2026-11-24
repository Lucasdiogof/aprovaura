-- Reverte a Etapa 08 (backend). Gate volta à versão da Etapa 07 (20261129000100, seção 4).
drop function if exists get_my_access_context();
drop function if exists get_my_payment_history();
drop trigger if exists payments_minimize_trg on auth.users;
drop function if exists payments_minimize_on_account_delete();
drop trigger if exists app_admins_protect_last_trg on app_admins;
drop function if exists app_admins_protect_last();
drop trigger if exists partners_anonymize_trg on partners;
drop function if exists partners_anonymize_on_account_delete();
-- FKs (restrict) e NOT NULL de partners.user_id só podem voltar se não houver parceria anonimizada.
