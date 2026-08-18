-- Dificuldade por questao + RPC que filtra os topicos por nivel.

-- 1) Coluna de dificuldade (todas as questoes existentes viram 'medio').
alter table questions
  add column if not exists difficulty text not null default 'medio'
  check (difficulty in ('facil', 'medio', 'dificil'));

create index if not exists questions_node_difficulty_idx
  on questions (catalog_node_id, difficulty);

-- 2) RPC: dado subject + parent + dificuldade, retorna apenas os nos-filhos
--    cuja subarvore contem ao menos uma questao naquela dificuldade.
--    (SECURITY INVOKER: respeita as policies de leitura publicas ja existentes.)
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
    and exists (
      select 1
      from descendants d
      join questions q on q.catalog_node_id = d.id
      where d.branch_root = cn.id
        and q.difficulty = p_difficulty
    )
  order by cn.order_index;
$$;
