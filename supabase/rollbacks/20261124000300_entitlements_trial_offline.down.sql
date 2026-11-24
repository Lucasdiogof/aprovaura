-- Reverte 0300 (apaga entitlements/trials: só antes de uso comercial real).
drop function if exists service_upsert_entitlement(uuid, text, text, text, text, timestamptz, timestamptz, boolean);
drop function if exists admin_revoke_entitlement(uuid, text);
drop function if exists admin_grant_courtesy(uuid, timestamptz, text);
drop function if exists get_my_access();
drop function if exists sign_access_token(jsonb);
drop function if exists _b64url(bytea);
drop function if exists _modpow_hex(numeric, text, numeric);
drop function if exists _num_to_hex(numeric, int);
drop function if exists _hex_to_num(text);
drop function if exists access_allowed(uuid);
drop function if exists compute_access(uuid);
drop function if exists maybe_grant_trial(uuid);
drop function if exists email_fingerprint(text);
drop table if exists server_secrets;
drop table if exists trial_grants;
drop table if exists entitlement_events;
drop table if exists entitlements;
drop function if exists entitlements_history();
