-- Catalog of the new subject "espanhol": 8 areas, 20 topics,
-- each with its en/es translation. Idempotent (uuid5 ids).
-- Areas first (a topic references its area), in one statement: a VALUES
-- list is inserted in order, and the parent always comes before its child.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
select v.id::uuid, 'espanhol', v.parent::uuid, v.title, v.description, v.icon, v.ord
from (values
  ('0794bcb2-9049-5497-ac2c-b882e37d29cc', null, 'Estratégias de leitura', 'Skimming, scanning e localização da ideia central', '🔎', 0),
  ('16a920d6-40fe-54c3-9628-3b183ecc5cf1', '0794bcb2-9049-5497-ac2c-b882e37d29cc', 'Skimming e scanning', null, '🔎', 0),
  ('ab947161-0333-51f3-a758-a401890951a2', '0794bcb2-9049-5497-ac2c-b882e37d29cc', 'Identificando a ideia central', null, '🔎', 1),
  ('593076dc-f45f-5ee1-99c7-aff4d6511ac2', null, 'Vocabulário em contexto', 'Falsos amigos com o português e dedução de sentido', '📖', 1),
  ('7978396f-326f-5dbd-a92b-a6d6a904d78e', '593076dc-f45f-5ee1-99c7-aff4d6511ac2', 'Falsos amigos com o português', null, '📖', 0),
  ('9f32a500-3dd0-5f7c-a220-c1d17c0d7d05', '593076dc-f45f-5ee1-99c7-aff4d6511ac2', 'Deduzindo sentido pelo contexto', null, '📖', 1),
  ('646c4017-cab2-534e-8604-1a3cea954573', '593076dc-f45f-5ee1-99c7-aff4d6511ac2', 'Sinônimos e antônimos', null, '📖', 2),
  ('80d2e5e8-2045-57a7-a8f2-960e08a3d8fb', null, 'Gramática e estrutura da frase', 'Ser/estar, pretérito e comparativos', '🧩', 2),
  ('d4284e49-2e73-550b-b182-9d95e7a2c30e', '80d2e5e8-2045-57a7-a8f2-960e08a3d8fb', 'Ser e estar', null, '🧩', 0),
  ('1fd15cb5-a400-516d-8cfc-5ef3992b8a3d', '80d2e5e8-2045-57a7-a8f2-960e08a3d8fb', 'Pretérito perfeito simples e composto', null, '🧩', 1),
  ('b0227252-9bcb-5875-9db1-97e57bf272e3', '80d2e5e8-2045-57a7-a8f2-960e08a3d8fb', 'Comparativo e superlativo', null, '🧩', 2),
  ('9245975f-8be4-58c7-a9ca-ceb3e83e3bc3', null, 'Gêneros textuais', 'Anúncios, quadrinhos e notícias em espanhol', '📰', 3),
  ('05b03467-e45f-51ce-bc78-28e24cdc651f', '9245975f-8be4-58c7-a9ca-ceb3e83e3bc3', 'Anúncios e infográficos', null, '📰', 0),
  ('e5e897cc-9ad6-552b-849b-c4879953142a', '9245975f-8be4-58c7-a9ca-ceb3e83e3bc3', 'Quadrinhos e tirinhas', null, '📰', 1),
  ('654ebc24-d60e-5871-83f5-f5844aabbffe', '9245975f-8be4-58c7-a9ca-ceb3e83e3bc3', 'Notícias e textos jornalísticos', null, '📰', 2),
  ('e57a70fc-f4e6-5076-9da7-164fa0987cfd', null, 'Coesão e coerência', 'Conectores e referências pronominais', '🔗', 4),
  ('e5c195b2-3092-57b4-b0f7-e4c63201159e', 'e57a70fc-f4e6-5076-9da7-164fa0987cfd', 'Conectores e conjunções', null, '🔗', 0),
  ('669a5819-8a39-5ec9-bf39-0edf46451eb9', 'e57a70fc-f4e6-5076-9da7-164fa0987cfd', 'Referência pronominal', null, '🔗', 1),
  ('a6213ff7-d534-51e8-a385-332eee90c1da', null, 'Expressões idiomáticas', 'Modismos e perífrases verbais do cotidiano', '💬', 5),
  ('e0da6f2f-aef5-5c3d-a932-e7d8272baa08', 'a6213ff7-d534-51e8-a385-332eee90c1da', 'Modismos comuns', null, '💬', 0),
  ('925fccd2-4661-5a4f-817e-9cc5018804bb', 'a6213ff7-d534-51e8-a385-332eee90c1da', 'Perífrases verbais', null, '💬', 1),
  ('d5923bb7-7354-54ae-91c2-59e02f3fccb2', null, 'Cultura e linguagem funcional', 'Países de língua espanhola e situações do dia a dia', '🌍', 6),
  ('7fb65218-1371-5d1f-8105-d5c2af9fc3d1', 'd5923bb7-7354-54ae-91c2-59e02f3fccb2', 'Países de língua espanhola', null, '🌍', 0),
  ('3853dc00-5ba3-5424-b9ac-9b7cfff7d24f', 'd5923bb7-7354-54ae-91c2-59e02f3fccb2', 'Linguagem funcional do dia a dia', null, '🌍', 1),
  ('ac08cb38-9145-59bf-a510-2516491eb078', null, 'Interpretação de textos', 'Trechos literários, informativos e de opinião', '📚', 7),
  ('eebca2bc-5898-56fd-b719-42a5d22d830b', 'ac08cb38-9145-59bf-a510-2516491eb078', 'Trechos literários', null, '📚', 0),
  ('59fffb0a-4b6d-5f54-ac1f-db400eac0f5b', 'ac08cb38-9145-59bf-a510-2516491eb078', 'Textos informativos e científicos', null, '📚', 1),
  ('9be3d8bb-0b2d-5bf9-8759-3190bf20310a', 'ac08cb38-9145-59bf-a510-2516491eb078', 'Textos de opinião e argumentativos', null, '📚', 2)
) as v(id, parent, title, description, icon, ord)
order by v.parent nulls first
on conflict (id) do nothing;

insert into catalog_node_translations (catalog_node_id, locale, title, description)
select v.id::uuid, v.locale, v.title, v.description
from (values
  ('0794bcb2-9049-5497-ac2c-b882e37d29cc', 'en', 'Reading strategies', 'Skimming, scanning and finding the main idea'),
  ('0794bcb2-9049-5497-ac2c-b882e37d29cc', 'es', 'Estrategias de lectura', 'Skimming, scanning y localización de la idea central'),
  ('16a920d6-40fe-54c3-9628-3b183ecc5cf1', 'en', 'Skimming and scanning', null),
  ('16a920d6-40fe-54c3-9628-3b183ecc5cf1', 'es', 'Skimming y scanning', null),
  ('ab947161-0333-51f3-a758-a401890951a2', 'en', 'Identifying the main idea', null),
  ('ab947161-0333-51f3-a758-a401890951a2', 'es', 'Identificando la idea central', null),
  ('593076dc-f45f-5ee1-99c7-aff4d6511ac2', 'en', 'Vocabulary in context', 'False friends with Portuguese and guessing meaning'),
  ('593076dc-f45f-5ee1-99c7-aff4d6511ac2', 'es', 'Vocabulario en contexto', 'Falsos amigos con el portugués y deducción de sentido'),
  ('7978396f-326f-5dbd-a92b-a6d6a904d78e', 'en', 'False friends with Portuguese', null),
  ('7978396f-326f-5dbd-a92b-a6d6a904d78e', 'es', 'Falsos amigos con el portugués', null),
  ('9f32a500-3dd0-5f7c-a220-c1d17c0d7d05', 'en', 'Guessing meaning from context', null),
  ('9f32a500-3dd0-5f7c-a220-c1d17c0d7d05', 'es', 'Deduciendo el sentido por el contexto', null),
  ('646c4017-cab2-534e-8604-1a3cea954573', 'en', 'Synonyms and antonyms', null),
  ('646c4017-cab2-534e-8604-1a3cea954573', 'es', 'Sinónimos y antónimos', null),
  ('80d2e5e8-2045-57a7-a8f2-960e08a3d8fb', 'en', 'Grammar and sentence structure', 'Ser/estar, preterite and comparatives'),
  ('80d2e5e8-2045-57a7-a8f2-960e08a3d8fb', 'es', 'Gramática y estructura de la frase', 'Ser/estar, pretérito y comparativos'),
  ('d4284e49-2e73-550b-b182-9d95e7a2c30e', 'en', 'Ser and estar', null),
  ('d4284e49-2e73-550b-b182-9d95e7a2c30e', 'es', 'Ser y estar', null),
  ('1fd15cb5-a400-516d-8cfc-5ef3992b8a3d', 'en', 'Simple and compound preterite', null),
  ('1fd15cb5-a400-516d-8cfc-5ef3992b8a3d', 'es', 'Pretérito perfecto simple y compuesto', null),
  ('b0227252-9bcb-5875-9db1-97e57bf272e3', 'en', 'Comparatives and superlatives', null),
  ('b0227252-9bcb-5875-9db1-97e57bf272e3', 'es', 'Comparativo y superlativo', null),
  ('9245975f-8be4-58c7-a9ca-ceb3e83e3bc3', 'en', 'Text genres', 'Advertisements, comics and news in Spanish'),
  ('9245975f-8be4-58c7-a9ca-ceb3e83e3bc3', 'es', 'Géneros textuales', 'Anuncios, historietas y noticias en español'),
  ('05b03467-e45f-51ce-bc78-28e24cdc651f', 'en', 'Advertisements and infographics', null),
  ('05b03467-e45f-51ce-bc78-28e24cdc651f', 'es', 'Anuncios e infografías', null),
  ('e5e897cc-9ad6-552b-849b-c4879953142a', 'en', 'Comics and cartoons', null),
  ('e5e897cc-9ad6-552b-849b-c4879953142a', 'es', 'Historietas y viñetas', null),
  ('654ebc24-d60e-5871-83f5-f5844aabbffe', 'en', 'News and journalistic texts', null),
  ('654ebc24-d60e-5871-83f5-f5844aabbffe', 'es', 'Noticias y textos periodísticos', null),
  ('e57a70fc-f4e6-5076-9da7-164fa0987cfd', 'en', 'Cohesion and coherence', 'Connectors and pronoun reference'),
  ('e57a70fc-f4e6-5076-9da7-164fa0987cfd', 'es', 'Cohesión y coherencia', 'Conectores y referencias pronominales'),
  ('e5c195b2-3092-57b4-b0f7-e4c63201159e', 'en', 'Connectors and linking words', null),
  ('e5c195b2-3092-57b4-b0f7-e4c63201159e', 'es', 'Conectores y conjunciones', null),
  ('669a5819-8a39-5ec9-bf39-0edf46451eb9', 'en', 'Pronoun reference', null),
  ('669a5819-8a39-5ec9-bf39-0edf46451eb9', 'es', 'Referencia pronominal', null),
  ('a6213ff7-d534-51e8-a385-332eee90c1da', 'en', 'Idiomatic expressions', 'Everyday idioms and verbal periphrasis'),
  ('a6213ff7-d534-51e8-a385-332eee90c1da', 'es', 'Expresiones idiomáticas', 'Modismos y perífrasis verbales cotidianos'),
  ('e0da6f2f-aef5-5c3d-a932-e7d8272baa08', 'en', 'Common idioms', null),
  ('e0da6f2f-aef5-5c3d-a932-e7d8272baa08', 'es', 'Modismos comunes', null),
  ('925fccd2-4661-5a4f-817e-9cc5018804bb', 'en', 'Verbal periphrasis', null),
  ('925fccd2-4661-5a4f-817e-9cc5018804bb', 'es', 'Perífrasis verbales', null),
  ('d5923bb7-7354-54ae-91c2-59e02f3fccb2', 'en', 'Culture and functional language', 'Spanish-speaking countries and everyday situations'),
  ('d5923bb7-7354-54ae-91c2-59e02f3fccb2', 'es', 'Cultura y lenguaje funcional', 'Países de habla hispana y situaciones cotidianas'),
  ('7fb65218-1371-5d1f-8105-d5c2af9fc3d1', 'en', 'Spanish-speaking countries', null),
  ('7fb65218-1371-5d1f-8105-d5c2af9fc3d1', 'es', 'Países de habla hispana', null),
  ('3853dc00-5ba3-5424-b9ac-9b7cfff7d24f', 'en', 'Everyday functional language', null),
  ('3853dc00-5ba3-5424-b9ac-9b7cfff7d24f', 'es', 'Lenguaje funcional cotidiano', null),
  ('ac08cb38-9145-59bf-a510-2516491eb078', 'en', 'Text interpretation', 'Literary, informative and opinion excerpts'),
  ('ac08cb38-9145-59bf-a510-2516491eb078', 'es', 'Interpretación de textos', 'Fragmentos literarios, informativos y de opinión'),
  ('eebca2bc-5898-56fd-b719-42a5d22d830b', 'en', 'Literary excerpts', null),
  ('eebca2bc-5898-56fd-b719-42a5d22d830b', 'es', 'Fragmentos literarios', null),
  ('59fffb0a-4b6d-5f54-ac1f-db400eac0f5b', 'en', 'Informative and scientific texts', null),
  ('59fffb0a-4b6d-5f54-ac1f-db400eac0f5b', 'es', 'Textos informativos y científicos', null),
  ('9be3d8bb-0b2d-5bf9-8759-3190bf20310a', 'en', 'Opinion and argumentative texts', null),
  ('9be3d8bb-0b2d-5bf9-8759-3190bf20310a', 'es', 'Textos de opinión y argumentativos', null)
) as v(id, locale, title, description)
join catalog_nodes c on c.id = v.id::uuid
on conflict (catalog_node_id, locale) do update
  set title = excluded.title, description = excluded.description;
