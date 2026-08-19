-- Daily streak ("ofensiva"): current_streak counts consecutive calendar
-- days (America/Sao_Paulo) with at least one completed activity. All writes
-- go through the RPCs below (security definer) so the client can only ever
-- say "an activity was completed" — it can never set current_streak itself.
-- Breakage is detected lazily, inside these same RPCs, the first time either
-- one runs after a gap of 2+ days: that single detection zeroes
-- current_streak and bumps streak_break_version exactly once, which is what
-- makes it safe to call get_or_refresh_user_streak() on every app open
-- without spamming break events.

create table if not exists user_streaks (
  user_id uuid primary key references auth.users (id) on delete cascade,
  current_streak integer not null default 0,
  longest_streak integer not null default 0,
  last_activity_date date,
  last_broken_streak integer,
  streak_break_version integer not null default 0,
  seen_streak_break_version integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table user_streaks enable row level security;

-- No insert/update policy on purpose: the client can only read its own row.
-- Every write happens through the security definer RPCs below.
create policy "users can read their own streak"
  on user_streaks for select
  using (auth.uid() = user_id);

create or replace function set_user_streaks_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger user_streaks_set_updated_at
before update on user_streaks
for each row execute function set_user_streaks_updated_at();

-- Zeroes current_streak and registers a break event, but only the first
-- time it's called after the streak actually went stale (current_streak > 0
-- and 2+ full calendar days since the last activity). Once current_streak
-- is 0 the guard stops matching, so calling this again is a no-op — that's
-- what keeps "10 days away = 1 lost-streak event" instead of 10 of them.
create or replace function refresh_broken_streak(p_user_id uuid, p_today date)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update user_streaks
  set last_broken_streak = current_streak,
      streak_break_version = streak_break_version + 1,
      current_streak = 0
  where user_id = p_user_id
    and current_streak > 0
    and last_activity_date is not null
    and p_today - last_activity_date >= 2;
end;
$$;

-- Called when the user opens the app / lands on Home. Detects a stale
-- streak (if any) and returns the current row, but never advances
-- current_streak itself — only register_activity_completion does that.
create or replace function get_or_refresh_user_streak()
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
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  insert into user_streaks (user_id) values (v_user_id)
  on conflict (user_id) do nothing;

  perform refresh_broken_streak(v_user_id, v_today);

  return query
    select s.current_streak, s.longest_streak, s.last_activity_date,
           s.last_broken_streak, s.streak_break_version,
           s.seen_streak_break_version
    from user_streaks s
    where s.user_id = v_user_id;
end;
$$;

-- Called once an activity is genuinely completed (never on open/start).
-- Same day again -> no-op. Yesterday -> +1. Anything older (including a
-- streak that just got zeroed by refresh_broken_streak above) -> starts a
-- fresh streak at 1. Row is locked for update so two completions firing at
-- once can't double-increment.
create or replace function register_activity_completion()
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
  v_last date;
  v_current integer;
  v_longest integer;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  insert into user_streaks (user_id) values (v_user_id)
  on conflict (user_id) do nothing;

  perform refresh_broken_streak(v_user_id, v_today);

  select u.last_activity_date, u.current_streak, u.longest_streak
    into v_last, v_current, v_longest
    from user_streaks u
    where u.user_id = v_user_id
    for update;

  v_current := case
    when v_last is null then 1
    when v_last = v_today then v_current
    when v_today - v_last = 1 then v_current + 1
    else 1
  end;
  v_longest := greatest(v_longest, v_current);

  update user_streaks
  set current_streak = v_current,
      longest_streak = v_longest,
      last_activity_date = v_today
  where user_id = v_user_id;

  return query
    select s.current_streak, s.longest_streak, s.last_activity_date,
           s.last_broken_streak, s.streak_break_version,
           s.seen_streak_break_version
    from user_streaks s
    where s.user_id = v_user_id;
end;
$$;

-- Called once the "you lost your streak" bottom sheet has been shown, so it
-- doesn't show again for the same break. Idempotent no matter how many
-- times it's called.
create or replace function mark_streak_break_seen()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  update user_streaks
  set seen_streak_break_version = streak_break_version
  where user_id = v_user_id;
end;
$$;
