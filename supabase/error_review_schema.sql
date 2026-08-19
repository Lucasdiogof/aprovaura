-- "Revisar erros" is built entirely on top of user_question_progress
-- (from progress_schema.sql) instead of a new table: a wrong answer is
-- just a row where is_correct = false, and re-answering it (normal
-- activity or review) already upserts that same row via
-- register_question_answered(). That single fact gives resolve/reactivate
-- semantics for free -- no separate "errors" table to keep in sync.

-- Groups pending errors by their leaf topic (the catalog_node a question
-- actually belongs to -- there's no deeper level to walk to, since
-- questions.catalog_node_id already points at the leaf). Ordered by the
-- most recent wrong answer in each topic.
create or replace function list_pending_error_topics()
returns table (
  catalog_node_id uuid,
  subject text,
  title text,
  parent_title text,
  wrong_count integer,
  last_wrong_at timestamptz
)
language sql
stable
as $$
  select q.catalog_node_id,
         cn.subject,
         cn.title,
         parent.title as parent_title,
         count(*)::int as wrong_count,
         max(up.updated_at) as last_wrong_at
  from user_question_progress up
  join questions q on q.id = up.question_id
  join catalog_nodes cn on cn.id = q.catalog_node_id
  left join catalog_nodes parent on parent.id = cn.parent_id
  where up.user_id = auth.uid()
    and up.is_correct = false
  group by q.catalog_node_id, cn.subject, cn.title, parent.title
  order by last_wrong_at desc;
$$;

-- The question list for a single review session: only the questions in
-- this topic the caller currently has wrong, not the topic's full bank.
create or replace function get_wrong_questions_for_node(p_catalog_node_id uuid)
returns setof questions
language sql
stable
as $$
  select q.*
  from questions q
  join user_question_progress up on up.question_id = q.id
  where q.catalog_node_id = p_catalog_node_id
    and up.user_id = auth.uid()
    and up.is_correct = false
  order by q.order_index;
$$;
