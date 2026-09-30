-- Catalog of the new subject "literatura": 8 areas, 20 topics,
-- each with its en/es translation. Idempotent (uuid5 ids).
-- Areas first (a topic references its area), in one statement: a VALUES
-- list is inserted in order, and the parent always comes before its child.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
select v.id::uuid, 'literatura', v.parent::uuid, v.title, v.description, v.icon, v.ord
from (values
  ('ceca2c41-a319-502c-b613-f6018bd5c8fe', null, 'Teoria literária', 'Gêneros, figuras de linguagem e versificação', '🖋️', 0),
  ('47653aa7-d471-5270-9cfe-c1567fab81d2', 'ceca2c41-a319-502c-b613-f6018bd5c8fe', 'Gêneros literários', null, '🖋️', 0),
  ('568bb871-cde8-5186-83b7-c0d7f350c8a0', 'ceca2c41-a319-502c-b613-f6018bd5c8fe', 'Figuras de linguagem', null, '🖋️', 1),
  ('27e0122c-01a3-5bc8-8082-a9c24037a9b2', 'ceca2c41-a319-502c-b613-f6018bd5c8fe', 'Versificação', null, '🖋️', 2),
  ('c1fc4917-feb6-5eec-a984-178728002130', null, 'Era colonial', 'Quinhentismo, Barroco e Arcadismo', '⛵', 1),
  ('42581a85-9716-5813-9801-f58007f83a56', 'c1fc4917-feb6-5eec-a984-178728002130', 'Quinhentismo', null, '⛵', 0),
  ('acf068eb-2d0b-5e69-ba74-5c88b9811fee', 'c1fc4917-feb6-5eec-a984-178728002130', 'Barroco', null, '⛵', 1),
  ('66f6e4dd-3c9c-5ba0-a451-81c08a2699b2', 'c1fc4917-feb6-5eec-a984-178728002130', 'Arcadismo', null, '⛵', 2),
  ('c7aea3bb-ac9f-505c-ba70-3b2a63f1711e', null, 'Romantismo', 'Poesia e prosa românticas no Brasil', '🌹', 2),
  ('4a18b71a-456c-5938-b92a-1ef82021139e', 'c7aea3bb-ac9f-505c-ba70-3b2a63f1711e', 'Poesia romântica', null, '🌹', 0),
  ('ee4e7364-bda5-5dbd-a32e-5407faf9aa86', 'c7aea3bb-ac9f-505c-ba70-3b2a63f1711e', 'Prosa romântica', null, '🌹', 1),
  ('4a543e37-a377-5da7-8bc5-239587fcabcc', null, 'Realismo e fim do século XIX', 'Realismo, Naturalismo, Parnasianismo e Simbolismo', '🔬', 3),
  ('34ef0d45-20d2-5c70-af0d-44968ad6416b', '4a543e37-a377-5da7-8bc5-239587fcabcc', 'Realismo e Machado de Assis', null, '🔬', 0),
  ('26114e06-2bfa-5d6b-8688-a7608b4b8ded', '4a543e37-a377-5da7-8bc5-239587fcabcc', 'Naturalismo', null, '🔬', 1),
  ('67f7be69-bf9d-5207-94cf-5340b5feff2c', '4a543e37-a377-5da7-8bc5-239587fcabcc', 'Parnasianismo e Simbolismo', null, '🔬', 2),
  ('7ccf1a85-5b11-5d49-8367-c688f0d82be5', null, 'Modernismo', 'Pré-Modernismo, Semana de 22 e Geração de 30', '🎨', 4),
  ('a4b5bcff-a5c4-5c8f-a11d-42c12b5c01b3', '7ccf1a85-5b11-5d49-8367-c688f0d82be5', 'Pré-Modernismo', null, '🎨', 0),
  ('ad409cff-6ca3-5a64-bef1-d6368c380c57', '7ccf1a85-5b11-5d49-8367-c688f0d82be5', 'Semana de 22 e primeira geração', null, '🎨', 1),
  ('2fce8c11-3365-5689-9765-947155818c58', '7ccf1a85-5b11-5d49-8367-c688f0d82be5', 'Geração de 30', null, '🎨', 2),
  ('95a8e9f3-831d-599e-8533-6fb1a2d28d40', null, 'Geração de 45 e contemporâneos', 'Rosa, Clarice, João Cabral e autores atuais', '📖', 5),
  ('d68f92a1-6eba-59b2-a901-9ae06b4d916f', '95a8e9f3-831d-599e-8533-6fb1a2d28d40', 'Geração de 45', null, '📖', 0),
  ('5ad78c60-c129-541c-a61e-4523326ffffa', '95a8e9f3-831d-599e-8533-6fb1a2d28d40', 'Literatura contemporânea', null, '📖', 1),
  ('399cb037-292e-5f2f-9160-63a6675accb4', null, 'Literatura portuguesa', 'Trovadorismo, Camões e Fernando Pessoa', '🇵🇹', 6),
  ('30e9d94f-7de2-5093-a0b3-03340f44f991', '399cb037-292e-5f2f-9160-63a6675accb4', 'Trovadorismo e Classicismo', null, '🇵🇹', 0),
  ('5f6a52eb-0ac7-558a-b22c-56719fa3d978', '399cb037-292e-5f2f-9160-63a6675accb4', 'Fernando Pessoa', null, '🇵🇹', 1),
  ('6d02f8b3-a8db-5cbf-9058-868583dac39c', null, 'Vozes da literatura brasileira', 'Literatura afro-brasileira, indígena e popular', '🪶', 7),
  ('37d18ff6-a1c5-58fe-9251-bf1c9374d6c9', '6d02f8b3-a8db-5cbf-9058-868583dac39c', 'Literatura afro-brasileira e indígena', null, '🪶', 0),
  ('1ee71296-9742-5ec9-a655-ceb92a3ac8de', '6d02f8b3-a8db-5cbf-9058-868583dac39c', 'Cordel e literatura popular', null, '🪶', 1)
) as v(id, parent, title, description, icon, ord)
order by v.parent nulls first
on conflict (id) do nothing;

insert into catalog_node_translations (catalog_node_id, locale, title, description)
select v.id::uuid, v.locale, v.title, v.description
from (values
  ('ceca2c41-a319-502c-b613-f6018bd5c8fe', 'en', 'Literary theory', 'Genres, figures of speech and versification'),
  ('ceca2c41-a319-502c-b613-f6018bd5c8fe', 'es', 'Teoría literaria', 'Géneros, figuras retóricas y versificación'),
  ('47653aa7-d471-5270-9cfe-c1567fab81d2', 'en', 'Literary genres', null),
  ('47653aa7-d471-5270-9cfe-c1567fab81d2', 'es', 'Géneros literarios', null),
  ('568bb871-cde8-5186-83b7-c0d7f350c8a0', 'en', 'Figures of speech', null),
  ('568bb871-cde8-5186-83b7-c0d7f350c8a0', 'es', 'Figuras retóricas', null),
  ('27e0122c-01a3-5bc8-8082-a9c24037a9b2', 'en', 'Versification', null),
  ('27e0122c-01a3-5bc8-8082-a9c24037a9b2', 'es', 'Versificación', null),
  ('c1fc4917-feb6-5eec-a984-178728002130', 'en', 'Colonial era', 'Quinhentismo, Baroque and Arcadianism'),
  ('c1fc4917-feb6-5eec-a984-178728002130', 'es', 'Era colonial', 'Quinientismo, Barroco y Arcadismo'),
  ('42581a85-9716-5813-9801-f58007f83a56', 'en', 'Quinhentismo (16th century)', null),
  ('42581a85-9716-5813-9801-f58007f83a56', 'es', 'Quinientismo', null),
  ('acf068eb-2d0b-5e69-ba74-5c88b9811fee', 'en', 'Baroque', null),
  ('acf068eb-2d0b-5e69-ba74-5c88b9811fee', 'es', 'Barroco', null),
  ('66f6e4dd-3c9c-5ba0-a451-81c08a2699b2', 'en', 'Arcadianism', null),
  ('66f6e4dd-3c9c-5ba0-a451-81c08a2699b2', 'es', 'Arcadismo', null),
  ('c7aea3bb-ac9f-505c-ba70-3b2a63f1711e', 'en', 'Romanticism', 'Romantic poetry and prose in Brazil'),
  ('c7aea3bb-ac9f-505c-ba70-3b2a63f1711e', 'es', 'Romanticismo', 'Poesía y prosa románticas en Brasil'),
  ('4a18b71a-456c-5938-b92a-1ef82021139e', 'en', 'Romantic poetry', null),
  ('4a18b71a-456c-5938-b92a-1ef82021139e', 'es', 'Poesía romántica', null),
  ('ee4e7364-bda5-5dbd-a32e-5407faf9aa86', 'en', 'Romantic prose', null),
  ('ee4e7364-bda5-5dbd-a32e-5407faf9aa86', 'es', 'Prosa romántica', null),
  ('4a543e37-a377-5da7-8bc5-239587fcabcc', 'en', 'Realism and the late 19th century', 'Realism, Naturalism, Parnassianism and Symbolism'),
  ('4a543e37-a377-5da7-8bc5-239587fcabcc', 'es', 'Realismo y fines del siglo XIX', 'Realismo, Naturalismo, Parnasianismo y Simbolismo'),
  ('34ef0d45-20d2-5c70-af0d-44968ad6416b', 'en', 'Realism and Machado de Assis', null),
  ('34ef0d45-20d2-5c70-af0d-44968ad6416b', 'es', 'Realismo y Machado de Assis', null),
  ('26114e06-2bfa-5d6b-8688-a7608b4b8ded', 'en', 'Naturalism', null),
  ('26114e06-2bfa-5d6b-8688-a7608b4b8ded', 'es', 'Naturalismo', null),
  ('67f7be69-bf9d-5207-94cf-5340b5feff2c', 'en', 'Parnassianism and Symbolism', null),
  ('67f7be69-bf9d-5207-94cf-5340b5feff2c', 'es', 'Parnasianismo y Simbolismo', null),
  ('7ccf1a85-5b11-5d49-8367-c688f0d82be5', 'en', 'Modernism', 'Pre-Modernism, the 1922 Week and the Generation of 1930'),
  ('7ccf1a85-5b11-5d49-8367-c688f0d82be5', 'es', 'Modernismo', 'Premodernismo, Semana de 1922 y Generación del 30'),
  ('a4b5bcff-a5c4-5c8f-a11d-42c12b5c01b3', 'en', 'Pre-Modernism', null),
  ('a4b5bcff-a5c4-5c8f-a11d-42c12b5c01b3', 'es', 'Premodernismo', null),
  ('ad409cff-6ca3-5a64-bef1-d6368c380c57', 'en', 'The 1922 Week and the first generation', null),
  ('ad409cff-6ca3-5a64-bef1-d6368c380c57', 'es', 'Semana de 1922 y primera generación', null),
  ('2fce8c11-3365-5689-9765-947155818c58', 'en', 'Generation of 1930', null),
  ('2fce8c11-3365-5689-9765-947155818c58', 'es', 'Generación del 30', null),
  ('95a8e9f3-831d-599e-8533-6fb1a2d28d40', 'en', 'Generation of 1945 and contemporaries', 'Rosa, Clarice, João Cabral and current authors'),
  ('95a8e9f3-831d-599e-8533-6fb1a2d28d40', 'es', 'Generación del 45 y contemporáneos', 'Rosa, Clarice, João Cabral y autores actuales'),
  ('d68f92a1-6eba-59b2-a901-9ae06b4d916f', 'en', 'Generation of 1945', null),
  ('d68f92a1-6eba-59b2-a901-9ae06b4d916f', 'es', 'Generación del 45', null),
  ('5ad78c60-c129-541c-a61e-4523326ffffa', 'en', 'Contemporary literature', null),
  ('5ad78c60-c129-541c-a61e-4523326ffffa', 'es', 'Literatura contemporánea', null),
  ('399cb037-292e-5f2f-9160-63a6675accb4', 'en', 'Portuguese literature', 'Troubadour poetry, Camões and Fernando Pessoa'),
  ('399cb037-292e-5f2f-9160-63a6675accb4', 'es', 'Literatura portuguesa', 'Trovadorismo, Camões y Fernando Pessoa'),
  ('30e9d94f-7de2-5093-a0b3-03340f44f991', 'en', 'Troubadour poetry and Classicism', null),
  ('30e9d94f-7de2-5093-a0b3-03340f44f991', 'es', 'Trovadorismo y Clasicismo', null),
  ('5f6a52eb-0ac7-558a-b22c-56719fa3d978', 'en', 'Fernando Pessoa', null),
  ('5f6a52eb-0ac7-558a-b22c-56719fa3d978', 'es', 'Fernando Pessoa', null),
  ('6d02f8b3-a8db-5cbf-9058-868583dac39c', 'en', 'Voices of Brazilian literature', 'Afro-Brazilian, Indigenous and popular literature'),
  ('6d02f8b3-a8db-5cbf-9058-868583dac39c', 'es', 'Voces de la literatura brasileña', 'Literatura afrobrasileña, indígena y popular'),
  ('37d18ff6-a1c5-58fe-9251-bf1c9374d6c9', 'en', 'Afro-Brazilian and Indigenous literature', null),
  ('37d18ff6-a1c5-58fe-9251-bf1c9374d6c9', 'es', 'Literatura afrobrasileña e indígena', null),
  ('1ee71296-9742-5ec9-a655-ceb92a3ac8de', 'en', 'Cordel and popular literature', null),
  ('1ee71296-9742-5ec9-a655-ceb92a3ac8de', 'es', 'Cordel y literatura popular', null)
) as v(id, locale, title, description)
join catalog_nodes c on c.id = v.id::uuid
on conflict (catalog_node_id, locale) do update
  set title = excluded.title, description = excluded.description;
