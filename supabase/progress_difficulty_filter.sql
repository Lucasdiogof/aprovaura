-- Makes catalog_node_progress respect the currently selected difficulty
-- filter, so e.g. answering the single "dificil" question in a topic shows
-- 100% while that filter is active, instead of always counting against the
-- topic's full (unfiltered) question count. Run once against a database
-- that already has the original progress_schema.sql applied.

drop function if exists catalog_node_progress(uuid[]);

create or replace function catalog_node_progress(
  p_node_ids uuid[],
  p_difficulty text default null
)
returns table (node_id uuid, total integer, completed integer)
language sql
stable
as $$
  with recursive descendants as (
    select n.id, n.id as branch_root
    from catalog_nodes n
    where n.id = any(p_node_ids)
    union all
    select c.id, d.branch_root
    from catalog_nodes c
    join descendants d on c.parent_id = d.id
  )
  select d.branch_root as node_id,
         count(q.id)::int as total,
         count(up.question_id)::int as completed
  from descendants d
  join questions q on q.catalog_node_id = d.id
  left join user_question_progress up
    on up.question_id = q.id and up.user_id = auth.uid()
  where p_difficulty is null or q.difficulty = p_difficulty
  group by d.branch_root;
$$;
