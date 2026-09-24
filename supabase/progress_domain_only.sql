-- FASE 7 QA: catalog_node_progress() counted ANY row in
-- user_question_progress -- right or wrong -- as "completed". That's
-- attempt, not domain: a topic showed 100% even if every question in it
-- had been gotten wrong. This makes it count only is_correct = true rows,
-- matching the rule confirmed for the visual refresh (errar não conta
-- como domínio; acertar depois em Revisar Erros passa a contar,
-- automaticamente, since that's the same upsert flipping is_correct to
-- true for the same row).
--
-- This changes what the existing progress bars show (topics with wrong
-- answers on record will show a lower percentage than before), which is
-- the point -- it's a correctness fix, not a new feature.
--
-- Run once against a database that already has progress_difficulty_filter.sql
-- applied.

drop function if exists catalog_node_progress(uuid[], text);

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
         count(*) filter (where up.is_correct)::int as completed
  from descendants d
  join questions q on q.catalog_node_id = d.id
  left join user_question_progress up
    on up.question_id = q.id and up.user_id = auth.uid()
  where p_difficulty is null or q.difficulty = p_difficulty
  group by d.branch_root;
$$;
