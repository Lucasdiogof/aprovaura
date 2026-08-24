-- Diagnóstico read-only -- não altera nada, só SELECTs. Roda cada bloco
-- (ou o arquivo inteiro) e me manda o resultado de volta.

-- 1) Dois nós de catálogo com o mesmo título sob o mesmo pai (pode ser
--    intencional -- ex.: "Biomas e vegetação" com perguntas x "Biomas do
--    Brasil" com mapa NÃO cai aqui por terem títulos diferentes -- mas
--    ajuda a achar caso eu tenha duplicado algo por engano).
select subject, parent_id, title, count(*) as ocorrencias, array_agg(id) as ids
from catalog_nodes
group by subject, parent_id, title
having count(*) > 1
order by subject, parent_id;

-- 2) Dois nós irmãos (mesmo pai) com o mesmo order_index -- não quebra
--    nada, mas a ordem de exibição fica ambígua entre eles.
select subject, parent_id, order_index, count(*) as ocorrencias, array_agg(title) as titulos
from catalog_nodes
group by subject, parent_id, order_index
having count(*) > 1
order by subject, parent_id, order_index;

-- 3) Duas perguntas com o mesmo texto (prompt) no mesmo tópico --
--    indicaria pergunta inserida duas vezes.
select catalog_node_id, prompt, count(*) as ocorrencias
from questions
group by catalog_node_id, prompt
having count(*) > 1
order by catalog_node_id;

-- 4) Duas perguntas com o mesmo order_index no mesmo tópico.
select catalog_node_id, order_index, count(*) as ocorrencias
from questions
group by catalog_node_id, order_index
having count(*) > 1
order by catalog_node_id, order_index;

-- 5) Nós "beco sem saída": sem filhos, sem perguntas e sem region_count
--    (ou seja, teoricamente não abrem nada -- candidatos a tópico
--    esquecido/vazio, tipo o "Relevo" e "Geografia econômica" que já
--    existiam vazios antes de eu começar a mexer).
select cn.subject, cn.title, cn.id
from catalog_nodes cn
where not exists (select 1 from catalog_nodes child where child.parent_id = cn.id)
  and not exists (select 1 from questions q where q.catalog_node_id = cn.id)
  and cn.region_count is null
order by cn.subject, cn.title;

-- 6) catalog_nodes cujo region_count não bate com a contagem real de
--    user_region_progress possíveis (não dá pra validar o total exato
--    sem reler os .geojson, mas isso pelo menos mostra os valores atuais
--    lado a lado pra eu conferir manualmente contra o que sei que
--    cadastrei).
select id, title, region_count, manual_difficulty
from catalog_nodes
where region_count is not null
order by title;
