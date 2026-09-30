-- Checkup (só leitura) de catalog_seed_literatura.sql + questions_literatura.sql.
select
  (select count(*) from catalog_nodes where subject = 'literatura' and parent_id is null) as areas,
  (select count(*) from catalog_nodes where subject = 'literatura' and parent_id is not null) as topicos,
  (select count(*) from catalog_node_translations t join catalog_nodes c on c.id = t.catalog_node_id where c.subject = 'literatura') as traducoes_catalogo,
  (select count(*) from questions q join catalog_nodes c on c.id = q.catalog_node_id where c.subject = 'literatura') as questoes,
  (select count(*) from question_translations t join questions q on q.id = t.question_id join catalog_nodes c on c.id = q.catalog_node_id where c.subject = 'literatura') as traducoes_questoes,
  (select json_object_agg(difficulty, n) from (select q.difficulty, count(*) n from questions q join catalog_nodes c on c.id = q.catalog_node_id where c.subject = 'literatura' group by 1) d) as por_nivel,
  (select count(*) from questions q join catalog_nodes c on c.id = q.catalog_node_id
     where c.subject = 'literatura' and (cardinality(q.options) <> 4 or q.correct_index not between 0 and 3)) as questoes_invalidas;
