-- HEALTH CHECK AURA — somente leitura (nao altera nada).
-- Cada linha retornada e um POSSIVEL problema. Nenhuma linha = tudo certo.
-- Colunas: categoria | materia | detalhe | info

-- 1. Pergunta DUPLICADA de verdade no mesmo topico (mesmo node + prompt + MESMAS opcoes).
--    Inclui q.options no agrupamento para nao acusar questoes distintas que so
--    compartilham um enunciado generico (ex.: "Assinale a alternativa correta quanto a...").
select '01. pergunta duplicada no mesmo topico' as categoria,
       cn.subject as materia, left(q.prompt, 90) as detalhe, count(*)::text as info
from questions q join catalog_nodes cn on cn.id = q.catalog_node_id
group by cn.subject, q.catalog_node_id, q.prompt, q.options
having count(*) > 1

union all
-- 2. Pergunta identica em topicos diferentes (mesmo prompt + mesmas opcoes)
select '02. pergunta identica em topicos diferentes',
       string_agg(distinct cn.subject, ', '), left(q.prompt, 90), count(*)::text
from questions q join catalog_nodes cn on cn.id = q.catalog_node_id
group by q.prompt, q.options
having count(distinct q.catalog_node_id) > 1

union all
-- 3. order_index duplicado dentro do mesmo topico
select '03. order_index duplicado no mesmo topico',
       cn.subject, cn.title || ' (idx ' || q.order_index::text || ')', count(*)::text
from questions q join catalog_nodes cn on cn.id = q.catalog_node_id
group by cn.subject, cn.title, q.catalog_node_id, q.order_index
having count(*) > 1

union all
-- 4. Alternativa repetida dentro da mesma pergunta
select '04. alternativa repetida na mesma pergunta',
       cn.subject, left(q.prompt, 90), 'opcoes duplicadas'
from questions q join catalog_nodes cn on cn.id = q.catalog_node_id
where array_length(q.options, 1) <> (select count(distinct o) from unnest(q.options) o)

union all
-- 5. correct_index fora do intervalo de opcoes
select '05. correct_index fora do intervalo',
       cn.subject, left(q.prompt, 90), 'correct_index=' || q.correct_index::text
from questions q join catalog_nodes cn on cn.id = q.catalog_node_id
where q.correct_index < 0 or q.correct_index >= array_length(q.options, 1)

union all
-- 6. Pergunta com menos de 2 alternativas
select '06. pergunta com menos de 2 alternativas',
       cn.subject, left(q.prompt, 90), coalesce(array_length(q.options, 1), 0)::text
from questions q join catalog_nodes cn on cn.id = q.catalog_node_id
where coalesce(array_length(q.options, 1), 0) < 2

union all
-- 7. Pergunta com alternativa em branco
select '07. pergunta com alternativa em branco',
       cn.subject, left(q.prompt, 90), 'tem opcao vazia'
from questions q join catalog_nodes cn on cn.id = q.catalog_node_id
where exists (select 1 from unnest(q.options) o where trim(o) = '')

union all
-- 8. difficulty invalida (fora de facil/medio/dificil)
select '08. difficulty invalida',
       cn.subject, left(q.prompt, 90), coalesce(q.difficulty, '(nulo)')
from questions q join catalog_nodes cn on cn.id = q.catalog_node_id
where q.difficulty is null or q.difficulty not in ('facil', 'medio', 'dificil')

union all
-- 9. Topico com questoes mas NENHUMA classificada (todas em 'medio' = provavelmente nao revisado)
select '09. topico possivelmente nao classificado (100% medio)',
       cn.subject, cn.title, count(*)::text || ' questoes'
from questions q join catalog_nodes cn on cn.id = q.catalog_node_id
group by cn.subject, cn.title, q.catalog_node_id
having count(*) filter (where q.difficulty <> 'medio') = 0

union all
-- 10. Materia sem NENHUMA questao dificil
select '10. materia sem nenhuma questao dificil',
       cn.subject, 'tier dificil vazio', count(*)::text || ' questoes no total'
from questions q join catalog_nodes cn on cn.id = q.catalog_node_id
group by cn.subject
having count(*) filter (where q.difficulty = 'dificil') = 0

union all
-- 11. Topico-folha sem conteudo: sem filhos, sem questoes e sem mapa -> nunca mostra progresso
select '11. topico-folha sem conteudo (nunca mostra progresso)',
       n.subject, n.title, 'sem questoes e sem mapa'
from catalog_nodes n
where not exists (select 1 from catalog_nodes c where c.parent_id = n.id)
  and not exists (select 1 from questions q where q.catalog_node_id = n.id)
  and n.region_count is null

union all
-- 12. Nos irmaos com o mesmo titulo (possivel no duplicado no catalogo)
select '12. nos irmaos com mesmo titulo (catalogo duplicado?)',
       n.subject, n.title, count(*)::text
from catalog_nodes n
group by n.subject, n.parent_id, n.title
having count(*) > 1

union all
-- 13. Dossie (Atualidades) sem questoes de pratica
select '13. dossie sem questoes de pratica',
       d.area, d.title, '0 questoes'
from dossiers d
where not exists (select 1 from dossier_questions dq where dq.dossier_id = d.id)

union all
-- 14. Dossies duplicados (mesma area + titulo)
select '14. dossie duplicado (area+titulo)',
       d.area, d.title, count(*)::text
from dossiers d
group by d.area, d.title
having count(*) > 1

order by categoria, materia;
