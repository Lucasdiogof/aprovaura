-- Map-quiz leaves (Estreitos, Países do mundo, etc.) have no rows in
-- `questions`, so catalog_children_with_difficulty never had a way to
-- place them under a difficulty filter -- they only ever showed up under
-- "Todos". manual_difficulty lets a specific catalog_node opt into a
-- level directly, for content where difficulty can't be derived from
-- questions. Leave it null for everything else; question-based difficulty
-- keeps working exactly as before.

alter table catalog_nodes
  add column if not exists manual_difficulty text
  check (manual_difficulty in ('facil', 'medio', 'dificil'));

create or replace function catalog_children_with_difficulty(
  p_subject text,
  p_parent uuid,
  p_difficulty text
) returns setof catalog_nodes
language sql
stable
as $$
  with recursive descendants as (
    select n.id, n.id as branch_root
    from catalog_nodes n
    where n.subject = p_subject
      and n.parent_id is not distinct from p_parent
    union all
    select c.id, d.branch_root
    from catalog_nodes c
    join descendants d on c.parent_id = d.id
  )
  select cn.*
  from catalog_nodes cn
  where cn.subject = p_subject
    and cn.parent_id is not distinct from p_parent
    and (
      cn.manual_difficulty = p_difficulty
      or exists (
        select 1
        from descendants d
        join questions q on q.catalog_node_id = d.id
        where d.branch_root = cn.id
          and q.difficulty = p_difficulty
      )
    )
  order by cn.order_index;
$$;

-- Estreitos is genuinely more obscure than the other world map quizzes, so
-- it's the one flagged as "dificil" for now -- not a blanket change to
-- every map activity.
update catalog_nodes
set manual_difficulty = 'dificil'
where id = 'b7d3c950-9f2b-4206-9bb7-74263dacc6e7';
