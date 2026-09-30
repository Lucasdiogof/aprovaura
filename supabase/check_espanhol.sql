-- Checkup (só leitura) de catalog_seed_espanhol.sql + questions_espanhol.sql.
select
  (select count(*) from catalog_nodes where subject = 'espanhol' and parent_id is null) as areas,
  (select count(*) from catalog_nodes where subject = 'espanhol' and parent_id is not null) as topicos,
  (select count(*) from catalog_node_translations t join catalog_nodes c on c.id = t.catalog_node_id where c.subject = 'espanhol') as traducoes_catalogo,
  (select count(*) from questions q join catalog_nodes c on c.id = q.catalog_node_id where c.subject = 'espanhol') as questoes,
  (select count(*) from question_translations t join questions q on q.id = t.question_id join catalog_nodes c on c.id = q.catalog_node_id where c.subject = 'espanhol') as traducoes_questoes,
  (select json_object_agg(difficulty, n) from (select q.difficulty, count(*) n from questions q join catalog_nodes c on c.id = q.catalog_node_id where c.subject = 'espanhol' group by 1) d) as por_nivel,
  (select count(*) from questions q join catalog_nodes c on c.id = q.catalog_node_id
     where c.subject = 'espanhol' and (cardinality(q.options) <> 4 or q.correct_index not between 0 and 3)) as questoes_invalidas;
