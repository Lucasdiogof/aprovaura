-- LIMPEZA DE DUPLICATAS AURA — idempotente (seguro rodar mais de uma vez).
-- 1) dossiers: mantem, por (area+title), a linha que tem MAIS questoes atreladas
--    (evita apagar dossier_questions em cascata).
-- 2) dossier_questions: remove repeticoes por (dossier_id + prompt).
-- 3) questions: remove repeticoes por (catalog_node_id + prompt).

begin;

with ranked as (
  select d.id,
         row_number() over (
           partition by d.area, d.title
           order by (select count(*) from dossier_questions q where q.dossier_id = d.id) desc, d.id
         ) as rn
  from dossiers d
)
delete from dossiers where id in (select id from ranked where rn > 1);

with ranked as (
  select id,
         row_number() over (partition by dossier_id, prompt order by order_index, id) as rn
  from dossier_questions
)
delete from dossier_questions where id in (select id from ranked where rn > 1);

with ranked as (
  select id,
         row_number() over (partition by catalog_node_id, prompt order by order_index, id) as rn
  from questions
)
delete from questions where id in (select id from ranked where rn > 1);

commit;

-- Conferencia final (a coluna "duplicados" deve dar 0 em tudo):
select 'dossiers' as tabela, count(*) as total,
       count(*) - count(distinct (area, title)) as duplicados
from dossiers
union all
select 'dossier_questions', count(*),
       count(*) - count(distinct (dossier_id, prompt))
from dossier_questions
union all
select 'questions', count(*),
       count(*) - count(distinct (catalog_node_id, prompt))
from questions;
