-- Respostas e atividades feitas offline, com a data em que realmente
-- aconteceram (APR-OFF-001, fila offline do app).
--
-- O app guarda no aparelho a resposta dada sem internet e a envia quando a
-- conexão volta. Sem este arquivo o servidor carimba tudo com now() do
-- momento da sincronização, então:
--   * a meta diária (get_daily_question_count, que conta por updated_at)
--     contaria a resposta no dia em que sincronizou, não no dia em que foi
--     dada;
--   * a ofensiva (register_activity_completion) creditaria o dia da
--     sincronização -- um dia em que a pessoa pode nem ter estudado.
--
-- O que muda (tudo compatível com o app antigo: os parâmetros novos têm
-- default, então chamar sem eles se comporta exatamente como antes):
--
--  1. register_question_answered(question, is_correct, answered_at)
--     - answered_at é opcional. Fora de [now() - 7 dias, now()] é ignorado
--       e vale now(): o relógio do aparelho nunca coloca resposta no futuro
--       nem reescreve o passado distante.
--     - "A mais recente vence": uma resposta só sobrescreve a linha se for
--       igual ou mais nova que a gravada. Assim uma resposta antiga
--       reenviada depois de uma nova (outro aparelho, fila atrasada) não
--       desfaz a nova. Repetir o mesmo envio continua sendo um no-op
--       (mesmo user_id+question_id), então nada duplica.
--
--  2. register_activity_completion(p_activity_date)
--     - p_activity_date é opcional (dia de Brasília em que a atividade
--       terminou). Sem ele (ou no futuro) vale hoje, como antes.
--     - Mais velho que 7 dias, ou anterior ao último dia já creditado:
--       nada muda, só devolve a linha atual. Nunca reduz nem reescreve a
--       ofensiva.
--     - A quebra de ofensiva passa a ser avaliada em relação ao dia da
--       atividade, não ao dia da sincronização; se a pessoa sincroniza dias
--       depois, a quebra seguinte é detectada normalmente na próxima
--       abertura (get_or_refresh_user_streak).
--     - Mesmo dia de novo continua sendo no-op; o app só envia uma entrada
--       por dia, então a sincronização é idempotente.
--
-- Rodar UMA vez (pelo SQL Editor ou `supabase db query`). É seguro rodar de
-- novo: faz drop da assinatura antiga e recria. Dropar a versão antiga é
-- necessário porque manter as duas deixaria a chamada com 2 argumentos
-- ambígua para o PostgREST. Nenhuma tabela é alterada; nenhum dado é
-- tocado. Não precisa de transação própria.
--
-- Depende de: progress_schema.sql, error_review_by_source.sql (coluna
-- source) e streaks_schema.sql já aplicados.

-- ---------------------------------------------------------------------------
-- 1. Resposta com data
-- ---------------------------------------------------------------------------

drop function if exists register_question_answered(uuid, boolean);
drop function if exists register_question_answered(uuid, boolean, timestamptz);

create function register_question_answered(
  p_question_id uuid,
  p_is_correct boolean,
  p_answered_at timestamptz default null
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_at timestamptz;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  v_at := case
    when p_answered_at is null then now()
    when p_answered_at > now() then now()
    when p_answered_at < now() - interval '7 days' then now()
    else p_answered_at
  end;

  insert into user_question_progress
    (user_id, question_id, is_correct, source, answered_at, updated_at)
  values (v_user_id, p_question_id, p_is_correct, 'practice', v_at, v_at)
  on conflict (user_id, question_id)
  do update set is_correct = excluded.is_correct,
                source = 'practice',
                updated_at = excluded.updated_at
  where user_question_progress.updated_at <= excluded.updated_at;
end;
$$;

-- ---------------------------------------------------------------------------
-- 2. Ofensiva com data da atividade
-- ---------------------------------------------------------------------------

drop function if exists register_activity_completion();
drop function if exists register_activity_completion(date);

create function register_activity_completion(
  p_activity_date date default null
)
returns table (
  current_streak integer,
  longest_streak integer,
  last_activity_date date,
  last_broken_streak integer,
  streak_break_version integer,
  seen_streak_break_version integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_today date := (now() at time zone 'America/Sao_Paulo')::date;
  v_day date;
  v_last date;
  v_current integer;
  v_longest integer;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  -- Sem data, ou data no futuro: hoje (o comportamento de sempre).
  v_day := case
    when p_activity_date is null or p_activity_date > v_today then v_today
    else p_activity_date
  end;

  insert into user_streaks (user_id) values (v_user_id)
  on conflict (user_id) do nothing;

  select u.last_activity_date, u.current_streak, u.longest_streak
    into v_last, v_current, v_longest
    from user_streaks u
    where u.user_id = v_user_id
    for update;

  -- Antigo demais, ou já coberto por um dia mais recente: não muda nada.
  if v_day < v_today - 7 or (v_last is not null and v_day < v_last) then
    return query
      select s.current_streak, s.longest_streak, s.last_activity_date,
             s.last_broken_streak, s.streak_break_version,
             s.seen_streak_break_version
      from user_streaks s
      where s.user_id = v_user_id;
    return;
  end if;

  -- A quebra é medida até o dia da atividade, não até o dia do envio.
  perform refresh_broken_streak(v_user_id, v_day);

  select u.last_activity_date, u.current_streak, u.longest_streak
    into v_last, v_current, v_longest
    from user_streaks u
    where u.user_id = v_user_id;

  v_current := case
    when v_last is null then 1
    when v_last = v_day then v_current
    when v_day - v_last = 1 then v_current + 1
    else 1
  end;
  v_longest := greatest(v_longest, v_current);

  update user_streaks
  set current_streak = v_current,
      longest_streak = v_longest,
      last_activity_date = v_day
  where user_id = v_user_id;

  return query
    select s.current_streak, s.longest_streak, s.last_activity_date,
           s.last_broken_streak, s.streak_break_version,
           s.seen_streak_break_version
    from user_streaks s
    where s.user_id = v_user_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Conferência (somente leitura): as duas funções existem com o parâmetro novo
-- e só há UMA assinatura de cada.
-- ---------------------------------------------------------------------------
-- select proname, pg_get_function_arguments(oid)
-- from pg_proc
-- where proname in ('register_question_answered', 'register_activity_completion')
--   and pronamespace = 'public'::regnamespace;
