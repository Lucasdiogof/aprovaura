-- Estatísticas de estudo fluem automaticamente ao professor vinculado (decisão do dono, 27/11/2026).
-- Antes: só com consentimento ativo E faixa "adult". Agora: sempre, para todo aluno vinculado.
-- O app deixou de oferecer a chave de compartilhamento, a faixa etária e o histórico de aceites.
-- ATENÇÃO (jurídico): inclui menores de 18 anos. Exige atualizar Política de Privacidade e Termos
-- (hoje dizem que o aluno pode revogar) e os formulários de privacidade das lojas ANTES de aplicar.
-- As tabelas study_sharing_consents e user_age_declarations NÃO são alteradas (histórico preservado).
-- Rollback: supabase/rollbacks/20261208000100_auto_share_study_stats.down.sql
create or replace function _student_shares(p_student uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select true;
$$;
