-- Reverte 0100. Só execute se 0200+ já tiverem sido revertidas.
drop function if exists admin_set_commercial_enforcement(boolean);
drop function if exists admin_update_commercial_config(jsonb);
drop function if exists get_public_app_config();
drop function if exists commercial_enforced();
drop function if exists admin_set_admin(uuid, boolean, text);
drop function if exists bootstrap_first_admin(uuid);
drop function if exists require_admin();
drop function if exists is_admin(uuid);
drop table if exists commercial_config;
drop table if exists app_admins;
drop function if exists audit_event(text, text, text, jsonb, jsonb, text);
drop table if exists admin_audit_log;
drop function if exists app_lock_tables(text[]);
drop function if exists app_grant_functions(text[], text[]);
drop function if exists forbid_mutation();
