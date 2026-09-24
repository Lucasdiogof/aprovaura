-- Replaces the flat "+10 XP per finished activity" rule
-- (award_activity_xp(), supabase/xp_schema.sql) with "+10 XP per correct
-- answer, 0 for wrong ones": award_quiz_xp(p_attempt_id, p_correct_count).
--
-- Why a ledger table instead of just incrementing user_xp again: the old
-- function had no way to tell "the client called this twice for the same
-- attempt" from "two different attempts finished". Rebuilds, a slow
-- request the client retries, or the result screen somehow mounting twice
-- would all have quietly doubled XP. xp_awards gives each attempt a
-- single row (unique on user_id + attempt_id, the id the client generates
-- once per deck via generateAttemptId()): the first call inserts and
-- credits user_xp, every later call for that same attempt_id hits the
-- unique constraint, does nothing, and just returns the current total.
-- A genuine retry ("Tentar novamente" / "Refazer atividade") deals a new
-- attempt_id, so it is credited on its own merits -- never blocked, never
-- double-counted with the attempt before it.
--
-- Existing user_xp.total_xp rows are untouched: this only changes how
-- future XP gets added, not what's already on the books.
--
-- Run once against a database that already has xp_schema.sql applied.

create table if not exists xp_awards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  attempt_id uuid not null,
  amount integer not null,
  created_at timestamptz not null default now(),
  unique (user_id, attempt_id)
);

create index if not exists xp_awards_user_idx on xp_awards (user_id);

alter table xp_awards enable row level security;

drop policy if exists "users can read their own xp awards" on xp_awards;
create policy "users can read their own xp awards"
  on xp_awards for select
  using (auth.uid() = user_id);

-- No insert/update policy on purpose, same as user_xp: writes only happen
-- through award_quiz_xp() below.

drop function if exists award_activity_xp();

create or replace function award_quiz_xp(
  p_attempt_id uuid,
  p_correct_count integer
) returns table (total_xp integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_amount integer := greatest(p_correct_count, 0) * 10;
  v_awarded integer;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  insert into xp_awards (user_id, attempt_id, amount)
  values (v_user_id, p_attempt_id, v_amount)
  on conflict (user_id, attempt_id) do nothing
  returning amount into v_awarded;

  -- v_awarded is null when this attempt_id was already credited -- skip
  -- the user_xp update entirely rather than adding a second time.
  if v_awarded is not null then
    insert into user_xp (user_id, total_xp)
    values (v_user_id, v_awarded)
    on conflict (user_id)
    do update set total_xp = user_xp.total_xp + v_awarded, updated_at = now();
  end if;

  return query select u.total_xp from user_xp u where u.user_id = v_user_id;
end;
$$;
