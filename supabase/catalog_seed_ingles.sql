-- Catalog of the new subject "ingles": 8 areas, 20 topics,
-- each with its en/es translation. Idempotent (uuid5 ids).
-- Areas first (a topic references its area), in one statement: a VALUES
-- list is inserted in order, and the parent always comes before its child.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
select v.id::uuid, 'ingles', v.parent::uuid, v.title, v.description, v.icon, v.ord
from (values
  ('91282543-8116-522d-aa8c-66c592edc2da', null, 'Estratégias de leitura', 'Skimming, scanning e localização da ideia central', '🔎', 0),
  ('20149979-c8e8-519b-8754-c2474aa9e0c7', '91282543-8116-522d-aa8c-66c592edc2da', 'Skimming e scanning', null, '🔎', 0),
  ('2198192a-bd33-5899-bc08-dd7c58218454', '91282543-8116-522d-aa8c-66c592edc2da', 'Identificando a ideia central', null, '🔎', 1),
  ('51fef5bc-9d78-5e31-b604-2483c183e2e7', null, 'Vocabulário em contexto', 'Cognatos, falsos cognatos e dedução de sentido', '📖', 1),
  ('a57af5bb-ccbe-5754-bce0-8ca0451a17e9', '51fef5bc-9d78-5e31-b604-2483c183e2e7', 'Cognatos e falsos cognatos', null, '📖', 0),
  ('fd5cc029-6f6c-51da-b719-6aef03de3531', '51fef5bc-9d78-5e31-b604-2483c183e2e7', 'Deduzindo sentido pelo contexto', null, '📖', 1),
  ('345edff3-028b-5292-a160-84f624ee889f', '51fef5bc-9d78-5e31-b604-2483c183e2e7', 'Sinônimos e antônimos', null, '📖', 2),
  ('3f95c192-a29b-563e-ab53-0a2b69990c0e', null, 'Gramática e estrutura da frase', 'Tempos verbais, modais e comparativos', '🧩', 2),
  ('3b8260fc-beeb-554b-8d8c-779f743b0be7', '3f95c192-a29b-563e-ab53-0a2b69990c0e', 'Tempos verbais', null, '🧩', 0),
  ('fe307ca0-bbe3-516f-a28a-0a99f3708991', '3f95c192-a29b-563e-ab53-0a2b69990c0e', 'Verbos modais', null, '🧩', 1),
  ('92150496-78ae-5eac-9403-32f44778c2b6', '3f95c192-a29b-563e-ab53-0a2b69990c0e', 'Comparativo e superlativo', null, '🧩', 2),
  ('f8bc1096-1228-528a-9626-60576f6ab42e', null, 'Gêneros textuais', 'Anúncios, quadrinhos e notícias em inglês', '📰', 3),
  ('78c871f0-f3fe-5532-ad3c-ca9ee05fe081', 'f8bc1096-1228-528a-9626-60576f6ab42e', 'Anúncios e infográficos', null, '📰', 0),
  ('8701d681-8ea7-52c3-8f71-ed21429c5d76', 'f8bc1096-1228-528a-9626-60576f6ab42e', 'Quadrinhos e tirinhas', null, '📰', 1),
  ('3b4e331e-c043-537d-8fe7-302e00a01447', 'f8bc1096-1228-528a-9626-60576f6ab42e', 'Notícias e textos jornalísticos', null, '📰', 2),
  ('efc8ee36-1308-525c-bf76-4426b2730dd3', null, 'Coesão e coerência', 'Conectores e referências pronominais', '🔗', 4),
  ('db903a21-31ed-5c7a-83b1-6d23877412b3', 'efc8ee36-1308-525c-bf76-4426b2730dd3', 'Conectores e conjunções', null, '🔗', 0),
  ('9cd73099-7e39-57df-8a4e-17329c16af61', 'efc8ee36-1308-525c-bf76-4426b2730dd3', 'Referência pronominal', null, '🔗', 1),
  ('88e8a133-2fdf-59b3-adb1-decc7cd1831c', null, 'Expressões idiomáticas', 'Idioms e phrasal verbs do cotidiano', '💬', 5),
  ('939e43a2-e234-5806-a380-1b4f3b6aeff4', '88e8a133-2fdf-59b3-adb1-decc7cd1831c', 'Idioms comuns', null, '💬', 0),
  ('8d1ff729-e7b5-5ec2-a14d-5d60c2e28284', '88e8a133-2fdf-59b3-adb1-decc7cd1831c', 'Phrasal verbs', null, '💬', 1),
  ('1d10a6ce-a088-500f-bec5-f7e97d08e4dd', null, 'Cultura e linguagem funcional', 'Países de língua inglesa e situações do dia a dia', '🌍', 6),
  ('8c77e9b9-9809-5fcd-8a36-43ec358ed6f7', '1d10a6ce-a088-500f-bec5-f7e97d08e4dd', 'Países de língua inglesa', null, '🌍', 0),
  ('d8a836e8-fc68-51e1-b2fd-486a2a7a6861', '1d10a6ce-a088-500f-bec5-f7e97d08e4dd', 'Linguagem funcional do dia a dia', null, '🌍', 1),
  ('67cfc2e9-486c-5e23-8c1b-05bd7697ce1f', null, 'Interpretação de textos', 'Trechos literários, informativos e de opinião', '📚', 7),
  ('7d710fd7-763a-5ecc-af95-128563a2cc94', '67cfc2e9-486c-5e23-8c1b-05bd7697ce1f', 'Trechos literários', null, '📚', 0),
  ('254f6fb1-fd22-5afc-97c3-7a19a51afa88', '67cfc2e9-486c-5e23-8c1b-05bd7697ce1f', 'Textos informativos e científicos', null, '📚', 1),
  ('1220cd73-b8f1-5b69-8b4e-cf902171bfe5', '67cfc2e9-486c-5e23-8c1b-05bd7697ce1f', 'Textos de opinião e argumentativos', null, '📚', 2)
) as v(id, parent, title, description, icon, ord)
order by v.parent nulls first
on conflict (id) do nothing;

insert into catalog_node_translations (catalog_node_id, locale, title, description)
select v.id::uuid, v.locale, v.title, v.description
from (values
  ('91282543-8116-522d-aa8c-66c592edc2da', 'en', 'Reading strategies', 'Skimming, scanning and finding the main idea'),
  ('91282543-8116-522d-aa8c-66c592edc2da', 'es', 'Estrategias de lectura', 'Skimming, scanning y localización de la idea central'),
  ('20149979-c8e8-519b-8754-c2474aa9e0c7', 'en', 'Skimming and scanning', null),
  ('20149979-c8e8-519b-8754-c2474aa9e0c7', 'es', 'Skimming y scanning', null),
  ('2198192a-bd33-5899-bc08-dd7c58218454', 'en', 'Identifying the main idea', null),
  ('2198192a-bd33-5899-bc08-dd7c58218454', 'es', 'Identificando la idea central', null),
  ('51fef5bc-9d78-5e31-b604-2483c183e2e7', 'en', 'Vocabulary in context', 'Cognates, false friends and guessing meaning'),
  ('51fef5bc-9d78-5e31-b604-2483c183e2e7', 'es', 'Vocabulario en contexto', 'Cognados, falsos cognados y deducción de sentido'),
  ('a57af5bb-ccbe-5754-bce0-8ca0451a17e9', 'en', 'Cognates and false friends', null),
  ('a57af5bb-ccbe-5754-bce0-8ca0451a17e9', 'es', 'Cognados y falsos cognados', null),
  ('fd5cc029-6f6c-51da-b719-6aef03de3531', 'en', 'Guessing meaning from context', null),
  ('fd5cc029-6f6c-51da-b719-6aef03de3531', 'es', 'Deduciendo el sentido por el contexto', null),
  ('345edff3-028b-5292-a160-84f624ee889f', 'en', 'Synonyms and antonyms', null),
  ('345edff3-028b-5292-a160-84f624ee889f', 'es', 'Sinónimos y antónimos', null),
  ('3f95c192-a29b-563e-ab53-0a2b69990c0e', 'en', 'Grammar and sentence structure', 'Verb tenses, modals and comparatives'),
  ('3f95c192-a29b-563e-ab53-0a2b69990c0e', 'es', 'Gramática y estructura de la frase', 'Tiempos verbales, modales y comparativos'),
  ('3b8260fc-beeb-554b-8d8c-779f743b0be7', 'en', 'Verb tenses', null),
  ('3b8260fc-beeb-554b-8d8c-779f743b0be7', 'es', 'Tiempos verbales', null),
  ('fe307ca0-bbe3-516f-a28a-0a99f3708991', 'en', 'Modal verbs', null),
  ('fe307ca0-bbe3-516f-a28a-0a99f3708991', 'es', 'Verbos modales', null),
  ('92150496-78ae-5eac-9403-32f44778c2b6', 'en', 'Comparatives and superlatives', null),
  ('92150496-78ae-5eac-9403-32f44778c2b6', 'es', 'Comparativo y superlativo', null),
  ('f8bc1096-1228-528a-9626-60576f6ab42e', 'en', 'Text genres', 'Advertisements, comics and news in English'),
  ('f8bc1096-1228-528a-9626-60576f6ab42e', 'es', 'Géneros textuales', 'Anuncios, historietas y noticias en inglés'),
  ('78c871f0-f3fe-5532-ad3c-ca9ee05fe081', 'en', 'Advertisements and infographics', null),
  ('78c871f0-f3fe-5532-ad3c-ca9ee05fe081', 'es', 'Anuncios e infografías', null),
  ('8701d681-8ea7-52c3-8f71-ed21429c5d76', 'en', 'Comics and cartoons', null),
  ('8701d681-8ea7-52c3-8f71-ed21429c5d76', 'es', 'Historietas y viñetas', null),
  ('3b4e331e-c043-537d-8fe7-302e00a01447', 'en', 'News and journalistic texts', null),
  ('3b4e331e-c043-537d-8fe7-302e00a01447', 'es', 'Noticias y textos periodísticos', null),
  ('efc8ee36-1308-525c-bf76-4426b2730dd3', 'en', 'Cohesion and coherence', 'Connectors and pronoun reference'),
  ('efc8ee36-1308-525c-bf76-4426b2730dd3', 'es', 'Cohesión y coherencia', 'Conectores y referencias pronominales'),
  ('db903a21-31ed-5c7a-83b1-6d23877412b3', 'en', 'Connectors and linking words', null),
  ('db903a21-31ed-5c7a-83b1-6d23877412b3', 'es', 'Conectores y conjunciones', null),
  ('9cd73099-7e39-57df-8a4e-17329c16af61', 'en', 'Pronoun reference', null),
  ('9cd73099-7e39-57df-8a4e-17329c16af61', 'es', 'Referencia pronominal', null),
  ('88e8a133-2fdf-59b3-adb1-decc7cd1831c', 'en', 'Idiomatic expressions', 'Everyday idioms and phrasal verbs'),
  ('88e8a133-2fdf-59b3-adb1-decc7cd1831c', 'es', 'Expresiones idiomáticas', 'Idioms y phrasal verbs cotidianos'),
  ('939e43a2-e234-5806-a380-1b4f3b6aeff4', 'en', 'Common idioms', null),
  ('939e43a2-e234-5806-a380-1b4f3b6aeff4', 'es', 'Idioms comunes', null),
  ('8d1ff729-e7b5-5ec2-a14d-5d60c2e28284', 'en', 'Phrasal verbs', null),
  ('8d1ff729-e7b5-5ec2-a14d-5d60c2e28284', 'es', 'Phrasal verbs', null),
  ('1d10a6ce-a088-500f-bec5-f7e97d08e4dd', 'en', 'Culture and functional language', 'English-speaking countries and everyday situations'),
  ('1d10a6ce-a088-500f-bec5-f7e97d08e4dd', 'es', 'Cultura y lenguaje funcional', 'Países de habla inglesa y situaciones cotidianas'),
  ('8c77e9b9-9809-5fcd-8a36-43ec358ed6f7', 'en', 'English-speaking countries', null),
  ('8c77e9b9-9809-5fcd-8a36-43ec358ed6f7', 'es', 'Países de habla inglesa', null),
  ('d8a836e8-fc68-51e1-b2fd-486a2a7a6861', 'en', 'Everyday functional language', null),
  ('d8a836e8-fc68-51e1-b2fd-486a2a7a6861', 'es', 'Lenguaje funcional cotidiano', null),
  ('67cfc2e9-486c-5e23-8c1b-05bd7697ce1f', 'en', 'Text interpretation', 'Literary, informative and opinion excerpts'),
  ('67cfc2e9-486c-5e23-8c1b-05bd7697ce1f', 'es', 'Interpretación de textos', 'Fragmentos literarios, informativos y de opinión'),
  ('7d710fd7-763a-5ecc-af95-128563a2cc94', 'en', 'Literary excerpts', null),
  ('7d710fd7-763a-5ecc-af95-128563a2cc94', 'es', 'Fragmentos literarios', null),
  ('254f6fb1-fd22-5afc-97c3-7a19a51afa88', 'en', 'Informative and scientific texts', null),
  ('254f6fb1-fd22-5afc-97c3-7a19a51afa88', 'es', 'Textos informativos y científicos', null),
  ('1220cd73-b8f1-5b69-8b4e-cf902171bfe5', 'en', 'Opinion and argumentative texts', null),
  ('1220cd73-b8f1-5b69-8b4e-cf902171bfe5', 'es', 'Textos de opinión y argumentativos', null)
) as v(id, locale, title, description)
join catalog_nodes c on c.id = v.id::uuid
on conflict (catalog_node_id, locale) do update
  set title = excluded.title, description = excluded.description;
