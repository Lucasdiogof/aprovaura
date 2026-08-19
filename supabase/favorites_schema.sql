-- Favoriting a question is plain user-owned CRUD (no atomicity/anti-cheat
-- concern like XP or streaks), so unlike those features this allows direct
-- insert/delete from the client under RLS instead of routing through an
-- RPC -- same posture as the "profiles" table.

create table if not exists user_question_favorites (
  user_id uuid not null references auth.users (id) on delete cascade,
  question_id uuid not null references questions (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, question_id)
);

alter table user_question_favorites enable row level security;

create policy "users can read their own favorites"
  on user_question_favorites for select
  using (auth.uid() = user_id);

create policy "users can add their own favorites"
  on user_question_favorites for insert
  with check (auth.uid() = user_id);

create policy "users can remove their own favorites"
  on user_question_favorites for delete
  using (auth.uid() = user_id);

-- Groups favorites by their leaf topic, same shape as
-- list_pending_error_topics() in error_review_schema.sql.
create or replace function list_favorite_topics()
returns table (
  catalog_node_id uuid,
  subject text,
  title text,
  parent_title text,
  favorite_count integer,
  last_favorited_at timestamptz
)
language sql
stable
as $$
  select q.catalog_node_id,
         cn.subject,
         cn.title,
         parent.title as parent_title,
         count(*)::int as favorite_count,
         max(f.created_at) as last_favorited_at
  from user_question_favorites f
  join questions q on q.id = f.question_id
  join catalog_nodes cn on cn.id = q.catalog_node_id
  left join catalog_nodes parent on parent.id = cn.parent_id
  where f.user_id = auth.uid()
  group by q.catalog_node_id, cn.subject, cn.title, parent.title
  order by last_favorited_at desc;
$$;

-- The question list for a single "practice my favorites" session.
create or replace function get_favorite_questions_for_node(p_catalog_node_id uuid)
returns setof questions
language sql
stable
as $$
  select q.*
  from questions q
  join user_question_favorites f on f.question_id = q.id
  where q.catalog_node_id = p_catalog_node_id
    and f.user_id = auth.uid()
  order by q.order_index;
$$;
