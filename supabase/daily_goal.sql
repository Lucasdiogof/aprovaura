-- "Meta de hoje": quantas questões o usuário respondeu no dia corrente,
-- em horário de Brasília (nunca UTC, senão a virada acontece às 21h aqui).
--
-- Nenhuma tabela nova: user_question_progress (supabase/progress_schema.sql)
-- já tem updated_at, que a upsert de register_question_answered() sempre
-- toca -- tanto na primeira resposta quanto numa correção feita depois em
-- "revisar erros". Contar por updated_at (em vez de answered_at, que só
-- muda na primeira vez) é o que faz uma questão corrigida hoje contar pra
-- meta de hoje, igual a uma respondida pela primeira vez hoje.
--
-- Conta acerto OU erro (a meta é de atividade, não de domínio -- domínio
-- continua sendo só o que catalog_node_progress mede). SECURITY INVOKER
-- (padrão): a policy de leitura do próprio user_question_progress já basta,
-- mesmo padrão de get_quick_practice_questions().
--
-- Run once against a database that already has progress_schema.sql applied.

create or replace function get_daily_question_count(
  p_timezone text default 'America/Sao_Paulo'
)
returns integer
language sql
stable
as $$
  select count(*)::int
  from user_question_progress
  where user_id = auth.uid()
    and (updated_at at time zone p_timezone)::date
      = (now() at time zone p_timezone)::date;
$$;
