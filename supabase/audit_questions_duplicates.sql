-- Auditoria do banco de questoes: procura duplicatas e inconsistencias.
-- Somente leitura (SELECT), nao altera nada. Se nao retornar nenhuma linha,
-- esta tudo certo.

select
  'order_index duplicado no mesmo topico' as problema,
  cn.subject,
  cn.title as topico,
  q.catalog_node_id::text as node_id,
  q.order_index::text as detalhe,
  count(*)::text as ocorrencias
from questions q
join catalog_nodes cn on cn.id = q.catalog_node_id
group by cn.subject, cn.title, q.catalog_node_id, q.order_index
having count(*) > 1

union all

select
  'pergunta repetida no mesmo topico' as problema,
  cn.subject,
  cn.title as topico,
  q.catalog_node_id::text as node_id,
  q.prompt as detalhe,
  count(*)::text as ocorrencias
from questions q
join catalog_nodes cn on cn.id = q.catalog_node_id
group by cn.subject, cn.title, q.catalog_node_id, q.prompt
having count(*) > 1

union all

select
  'pergunta identica em topicos diferentes' as problema,
  string_agg(distinct cn.subject, ', ') as subject,
  string_agg(distinct cn.title, ', ') as topico,
  null as node_id,
  q.prompt as detalhe,
  count(*)::text as ocorrencias
from questions q
join catalog_nodes cn on cn.id = q.catalog_node_id
group by q.prompt, q.options
having count(*) > 1

union all

select
  'alternativa repetida dentro da mesma pergunta' as problema,
  cn.subject,
  cn.title as topico,
  q.id::text as node_id,
  q.prompt as detalhe,
  count(*)::text as ocorrencias
from questions q
join catalog_nodes cn on cn.id = q.catalog_node_id
cross join lateral unnest(q.options) as o
group by cn.subject, cn.title, q.id, q.prompt, q.options
having count(*) <> count(distinct o)

union all

select
  'correct_index fora do intervalo de opcoes' as problema,
  cn.subject,
  cn.title as topico,
  q.id::text as node_id,
  q.prompt as detalhe,
  q.correct_index::text as ocorrencias
from questions q
join catalog_nodes cn on cn.id = q.catalog_node_id
where q.correct_index < 0 or q.correct_index >= array_length(q.options, 1)

order by problema, subject;
