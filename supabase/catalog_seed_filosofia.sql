-- Catalog of the new subject "filosofia": 8 areas, 20 topics,
-- each with its en/es translation. Idempotent (uuid5 ids).
-- Areas first (a topic references its area), in one statement: a VALUES
-- list is inserted in order, and the parent always comes before its child.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
select v.id::uuid, 'filosofia', v.parent::uuid, v.title, v.description, v.icon, v.ord
from (values
  ('398994f5-24de-5c71-a8b3-c75d696a9550', null, 'Introdução à filosofia', 'O que é filosofia e a passagem do mito à razão', '🦉', 0),
  ('67639d86-d930-5916-aae0-6836ddf062ec', '398994f5-24de-5c71-a8b3-c75d696a9550', 'O que é filosofia', null, '🦉', 0),
  ('79054d8c-aca7-5b49-a8ea-3009d4999c4e', '398994f5-24de-5c71-a8b3-c75d696a9550', 'Mito e logos', null, '🦉', 1),
  ('fae53147-6a04-57df-a12a-d5ee847ddf30', null, 'Filosofia antiga', 'Pré-socráticos, Sócrates, Platão e Aristóteles', '🏛️', 1),
  ('d8fbb194-a741-5d29-a914-55b2e2e148f3', 'fae53147-6a04-57df-a12a-d5ee847ddf30', 'Pré-socráticos', null, '🏛️', 0),
  ('3c286a12-1307-5b19-8d56-2f6843ab6ec0', 'fae53147-6a04-57df-a12a-d5ee847ddf30', 'Sócrates e os sofistas', null, '🏛️', 1),
  ('e02ad558-a198-5a7b-8d8e-8b565666f666', 'fae53147-6a04-57df-a12a-d5ee847ddf30', 'Platão', null, '🏛️', 2),
  ('0add9e0b-d6ef-5a8a-aa14-e1007eb515e6', 'fae53147-6a04-57df-a12a-d5ee847ddf30', 'Aristóteles', null, '🏛️', 3),
  ('c3e43583-ce42-5461-95c5-74450c790463', null, 'Helenismo e Idade Média', 'Estoicos, epicuristas, Agostinho e Tomás de Aquino', '⛪', 2),
  ('37a4df58-f99a-5218-b2c0-48a9e6371ddd', 'c3e43583-ce42-5461-95c5-74450c790463', 'Escolas helenísticas', null, '⛪', 0),
  ('c0001d9e-55ba-5e33-900d-fe980f5e511e', 'c3e43583-ce42-5461-95c5-74450c790463', 'Filosofia medieval', null, '⛪', 1),
  ('2c701fb2-4488-5813-887a-b072efec7341', null, 'Filosofia moderna', 'Racionalismo, empirismo e Kant', '🔭', 3),
  ('f8bb74a3-4f0f-5018-95ba-24d901e2d0e1', '2c701fb2-4488-5813-887a-b072efec7341', 'Racionalismo', null, '🔭', 0),
  ('e04660bb-584e-558f-b0ec-45c0c6d1fdd9', '2c701fb2-4488-5813-887a-b072efec7341', 'Empirismo', null, '🔭', 1),
  ('0b283daf-de23-528e-ae67-779667037a10', '2c701fb2-4488-5813-887a-b072efec7341', 'Kant e o Iluminismo', null, '🔭', 2),
  ('cfcc3b3b-f297-5069-a662-6f63b15e0830', null, 'Ética', 'Moral, virtude, dever e consequências', '⚖️', 4),
  ('9f5fa8f4-6414-5204-851f-5c3eedb44a74', 'cfcc3b3b-f297-5069-a662-6f63b15e0830', 'Ética e moral', null, '⚖️', 0),
  ('98e54340-cdfb-599b-9763-701186b0bf62', 'cfcc3b3b-f297-5069-a662-6f63b15e0830', 'Teorias éticas', null, '⚖️', 1),
  ('c230af4c-9b65-5833-8676-7e6317f142c2', null, 'Filosofia política', 'Poder, Estado e contrato social', '👑', 5),
  ('b7daaf58-ae78-5323-b4de-9734deba702f', 'c230af4c-9b65-5833-8676-7e6317f142c2', 'Maquiavel e o poder', null, '👑', 0),
  ('140f3cc9-4b63-51f6-8116-fc2d90926190', 'c230af4c-9b65-5833-8676-7e6317f142c2', 'Contratualistas', null, '👑', 1),
  ('67d8be9a-580f-54ee-ba4f-7e9fe7a850b6', null, 'Filosofia contemporânea', 'Nietzsche, existencialismo e Escola de Frankfurt', '💭', 6),
  ('dd3a9919-5d53-5c89-a0a0-e96d66435b09', '67d8be9a-580f-54ee-ba4f-7e9fe7a850b6', 'Nietzsche', null, '💭', 0),
  ('a07e6784-aeb7-594e-81e8-53b90dbe31f1', '67d8be9a-580f-54ee-ba4f-7e9fe7a850b6', 'Existencialismo', null, '💭', 1),
  ('96f3b16c-0a11-57ea-972f-15e84363cc58', '67d8be9a-580f-54ee-ba4f-7e9fe7a850b6', 'Escola de Frankfurt', null, '💭', 2),
  ('e2caf297-e7bb-52f1-9e9f-99bcfa04f3aa', null, 'Lógica e conhecimento', 'Argumentação, falácias e teoria do conhecimento', '🧠', 7),
  ('6eb0a23e-9547-58bc-b796-bc9b105e2b92', 'e2caf297-e7bb-52f1-9e9f-99bcfa04f3aa', 'Lógica e argumentação', null, '🧠', 0),
  ('03fd0820-41a9-5f12-ae35-299579f84f9a', 'e2caf297-e7bb-52f1-9e9f-99bcfa04f3aa', 'Teoria do conhecimento', null, '🧠', 1)
) as v(id, parent, title, description, icon, ord)
order by v.parent nulls first
on conflict (id) do nothing;

insert into catalog_node_translations (catalog_node_id, locale, title, description)
select v.id::uuid, v.locale, v.title, v.description
from (values
  ('398994f5-24de-5c71-a8b3-c75d696a9550', 'en', 'Introduction to philosophy', 'What philosophy is and the shift from myth to reason'),
  ('398994f5-24de-5c71-a8b3-c75d696a9550', 'es', 'Introducción a la filosofía', 'Qué es la filosofía y el paso del mito a la razón'),
  ('67639d86-d930-5916-aae0-6836ddf062ec', 'en', 'What philosophy is', null),
  ('67639d86-d930-5916-aae0-6836ddf062ec', 'es', 'Qué es la filosofía', null),
  ('79054d8c-aca7-5b49-a8ea-3009d4999c4e', 'en', 'Myth and logos', null),
  ('79054d8c-aca7-5b49-a8ea-3009d4999c4e', 'es', 'Mito y logos', null),
  ('fae53147-6a04-57df-a12a-d5ee847ddf30', 'en', 'Ancient philosophy', 'Pre-Socratics, Socrates, Plato and Aristotle'),
  ('fae53147-6a04-57df-a12a-d5ee847ddf30', 'es', 'Filosofía antigua', 'Presocráticos, Sócrates, Platón y Aristóteles'),
  ('d8fbb194-a741-5d29-a914-55b2e2e148f3', 'en', 'Pre-Socratics', null),
  ('d8fbb194-a741-5d29-a914-55b2e2e148f3', 'es', 'Presocráticos', null),
  ('3c286a12-1307-5b19-8d56-2f6843ab6ec0', 'en', 'Socrates and the Sophists', null),
  ('3c286a12-1307-5b19-8d56-2f6843ab6ec0', 'es', 'Sócrates y los sofistas', null),
  ('e02ad558-a198-5a7b-8d8e-8b565666f666', 'en', 'Plato', null),
  ('e02ad558-a198-5a7b-8d8e-8b565666f666', 'es', 'Platón', null),
  ('0add9e0b-d6ef-5a8a-aa14-e1007eb515e6', 'en', 'Aristotle', null),
  ('0add9e0b-d6ef-5a8a-aa14-e1007eb515e6', 'es', 'Aristóteles', null),
  ('c3e43583-ce42-5461-95c5-74450c790463', 'en', 'Hellenism and the Middle Ages', 'Stoics, Epicureans, Augustine and Thomas Aquinas'),
  ('c3e43583-ce42-5461-95c5-74450c790463', 'es', 'Helenismo y Edad Media', 'Estoicos, epicúreos, Agustín y Tomás de Aquino'),
  ('37a4df58-f99a-5218-b2c0-48a9e6371ddd', 'en', 'Hellenistic schools', null),
  ('37a4df58-f99a-5218-b2c0-48a9e6371ddd', 'es', 'Escuelas helenísticas', null),
  ('c0001d9e-55ba-5e33-900d-fe980f5e511e', 'en', 'Medieval philosophy', null),
  ('c0001d9e-55ba-5e33-900d-fe980f5e511e', 'es', 'Filosofía medieval', null),
  ('2c701fb2-4488-5813-887a-b072efec7341', 'en', 'Modern philosophy', 'Rationalism, empiricism and Kant'),
  ('2c701fb2-4488-5813-887a-b072efec7341', 'es', 'Filosofía moderna', 'Racionalismo, empirismo y Kant'),
  ('f8bb74a3-4f0f-5018-95ba-24d901e2d0e1', 'en', 'Rationalism', null),
  ('f8bb74a3-4f0f-5018-95ba-24d901e2d0e1', 'es', 'Racionalismo', null),
  ('e04660bb-584e-558f-b0ec-45c0c6d1fdd9', 'en', 'Empiricism', null),
  ('e04660bb-584e-558f-b0ec-45c0c6d1fdd9', 'es', 'Empirismo', null),
  ('0b283daf-de23-528e-ae67-779667037a10', 'en', 'Kant and the Enlightenment', null),
  ('0b283daf-de23-528e-ae67-779667037a10', 'es', 'Kant y la Ilustración', null),
  ('cfcc3b3b-f297-5069-a662-6f63b15e0830', 'en', 'Ethics', 'Morality, virtue, duty and consequences'),
  ('cfcc3b3b-f297-5069-a662-6f63b15e0830', 'es', 'Ética', 'Moral, virtud, deber y consecuencias'),
  ('9f5fa8f4-6414-5204-851f-5c3eedb44a74', 'en', 'Ethics and morality', null),
  ('9f5fa8f4-6414-5204-851f-5c3eedb44a74', 'es', 'Ética y moral', null),
  ('98e54340-cdfb-599b-9763-701186b0bf62', 'en', 'Ethical theories', null),
  ('98e54340-cdfb-599b-9763-701186b0bf62', 'es', 'Teorías éticas', null),
  ('c230af4c-9b65-5833-8676-7e6317f142c2', 'en', 'Political philosophy', 'Power, the State and the social contract'),
  ('c230af4c-9b65-5833-8676-7e6317f142c2', 'es', 'Filosofía política', 'Poder, Estado y contrato social'),
  ('b7daaf58-ae78-5323-b4de-9734deba702f', 'en', 'Machiavelli and power', null),
  ('b7daaf58-ae78-5323-b4de-9734deba702f', 'es', 'Maquiavelo y el poder', null),
  ('140f3cc9-4b63-51f6-8116-fc2d90926190', 'en', 'Social contract theorists', null),
  ('140f3cc9-4b63-51f6-8116-fc2d90926190', 'es', 'Contractualistas', null),
  ('67d8be9a-580f-54ee-ba4f-7e9fe7a850b6', 'en', 'Contemporary philosophy', 'Nietzsche, existentialism and the Frankfurt School'),
  ('67d8be9a-580f-54ee-ba4f-7e9fe7a850b6', 'es', 'Filosofía contemporánea', 'Nietzsche, existencialismo y Escuela de Fráncfort'),
  ('dd3a9919-5d53-5c89-a0a0-e96d66435b09', 'en', 'Nietzsche', null),
  ('dd3a9919-5d53-5c89-a0a0-e96d66435b09', 'es', 'Nietzsche', null),
  ('a07e6784-aeb7-594e-81e8-53b90dbe31f1', 'en', 'Existentialism', null),
  ('a07e6784-aeb7-594e-81e8-53b90dbe31f1', 'es', 'Existencialismo', null),
  ('96f3b16c-0a11-57ea-972f-15e84363cc58', 'en', 'Frankfurt School', null),
  ('96f3b16c-0a11-57ea-972f-15e84363cc58', 'es', 'Escuela de Fráncfort', null),
  ('e2caf297-e7bb-52f1-9e9f-99bcfa04f3aa', 'en', 'Logic and knowledge', 'Argument, fallacies and theory of knowledge'),
  ('e2caf297-e7bb-52f1-9e9f-99bcfa04f3aa', 'es', 'Lógica y conocimiento', 'Argumentación, falacias y teoría del conocimiento'),
  ('6eb0a23e-9547-58bc-b796-bc9b105e2b92', 'en', 'Logic and argument', null),
  ('6eb0a23e-9547-58bc-b796-bc9b105e2b92', 'es', 'Lógica y argumentación', null),
  ('03fd0820-41a9-5f12-ae35-299579f84f9a', 'en', 'Theory of knowledge', null),
  ('03fd0820-41a9-5f12-ae35-299579f84f9a', 'es', 'Teoría del conocimiento', null)
) as v(id, locale, title, description)
join catalog_nodes c on c.id = v.id::uuid
on conflict (catalog_node_id, locale) do update
  set title = excluded.title, description = excluded.description;
