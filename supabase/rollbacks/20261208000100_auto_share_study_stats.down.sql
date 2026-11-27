-- Restaura a regra anterior: compartilha só com consentimento concedido E faixa adulta declarada.
create or replace function _student_shares(p_student uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce((select granted from study_sharing_consents
                   where user_id = p_student order by id desc limit 1), false)
     and coalesce((select age_band = 'adult' from user_age_declarations where user_id = p_student), false);
$$;
