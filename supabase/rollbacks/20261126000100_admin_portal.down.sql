-- Reverte a Etapa 04. user_activity só guarda "visto por último": seguro apagar.
-- ATENÇÃO: _link_once/get_my_partner/admin_update_partner/admin_revoke_entitlement/
-- admin_update_commercial_config/admin_review_partner_change voltam às versões
-- anteriores reaplicando 20261124000200, 20261124000300 e 20261125000100.
drop function if exists touch_activity(text);
drop function if exists admin_assert();
drop function if exists service_find_user_by_email(text);
drop function if exists admin_dashboard(date, date);
drop function if exists admin_list_users(text, text, uuid, text, text, date, date, text, text, integer, integer);
drop function if exists admin_get_user(uuid);
drop function if exists admin_grant_premium(uuid, integer, timestamptz, boolean, text);
drop function if exists admin_promote_partner(uuid, text, text, integer, text, text);
drop function if exists admin_list_partners(text, text, integer, integer);
drop function if exists admin_get_partner(uuid);
drop function if exists admin_set_student_partner(uuid, uuid, text);
drop function if exists admin_pending_change_count();
drop function if exists admin_list_change_requests(text, integer, integer);
drop function if exists admin_list_subscriptions(text, text, text, integer, integer);
drop function if exists admin_get_config();
drop function if exists admin_list_audit(uuid, text, text, date, date, integer, integer);
drop function if exists admin_audit_actions();
drop function if exists admin_audit_neighbors(bigint);
drop function if exists _audit_row(admin_audit_log);
drop function if exists _validate_partner_fields(text, text, integer, text, text);
drop function if exists _admin_access_match(uuid, text);
drop function if exists _user_last_study(uuid);
drop function if exists _scrub(jsonb);
drop function if exists _tz_day_start(date);
drop function if exists _like_escape(text);
drop function if exists _page(integer, integer, integer);
drop table if exists user_activity;
-- default_commission_bps permanece (coluna inofensiva).
