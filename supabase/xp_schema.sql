-- Account XP + level. Level is always derived from total_xp (100 XP per
-- level) and never stored, so there's only one source of truth.

create table if not exists user_xp (
  user_id uuid primary key references auth.users (id) on delete cascade,
  total_xp integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table user_xp enable row level security;

-- No insert/update policy on purpose, same as user_streaks: writes only
-- happen through award_activity_xp() below.
create policy "users can read their own xp"
  on user_xp for select
  using (auth.uid() = user_id);

-- Atomic +10 XP for a completed activity. The insert...on conflict...do
-- update is a single statement, so two calls landing at once can't race
-- each other into losing an increment.
create or replace function award_activity_xp()
returns table (total_xp integer)
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

  insert into user_xp (user_id, total_xp)
  values (v_user_id, 10)
  on conflict (user_id)
  do update set total_xp = user_xp.total_xp + 10, updated_at = now();

  return query select u.total_xp from user_xp u where u.user_id = v_user_id;
end;
$$;
