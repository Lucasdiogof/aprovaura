-- Reverte a Etapa 09 (parte 1). Dados de faixa etária são descartados; aceites e consentimentos permanecem.
drop function if exists get_my_age_band();
drop function if exists set_my_age_band(text);
drop function if exists get_my_legal_history();
drop function if exists publish_legal_version(text, text, text, jsonb, timestamptz, boolean, jsonb);
drop table if exists user_age_declarations;
-- Restaura record_legal_acceptance (2 args), _student_shares e set_study_sharing da Etapa 02/06 a partir de
-- 20261125000100 / 20261127000100; get_public_app_config e app_pre_request voltam às versões de 20261130000100.
drop function if exists record_legal_acceptance(text, text, text);
create or replace function record_legal_acceptance(p_kind text, p_version text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  if not exists (select 1 from legal_documents where kind = p_kind and version = p_version and is_current) then
    raise exception 'unknown or outdated document' using errcode = 'P0050';
  end if;
  insert into legal_acceptances (user_id, kind, version, source) values (auth.uid(), p_kind, p_version, 'app')
  on conflict do nothing;
end $$;
select app_grant_functions(array['record_legal_acceptance'], array['authenticated']);
notify pgrst, 'reload schema';
