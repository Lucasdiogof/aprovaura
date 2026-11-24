alter role authenticator reset pgrst.db_pre_request;
notify pgrst, 'reload config';
drop function if exists app_pre_request();
create or replace function essay_daily_evaluation_limit()
returns integer language sql immutable as $$ select 3 $$;
