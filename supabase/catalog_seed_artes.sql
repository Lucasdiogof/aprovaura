-- Catalog of the new subject "artes": 8 areas, 20 topics,
-- each with its en/es translation. Idempotent (uuid5 ids).
-- Areas first (a topic references its area), in one statement: a VALUES
-- list is inserted in order, and the parent always comes before its child.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
select v.id::uuid, 'artes', v.parent::uuid, v.title, v.description, v.icon, v.ord
from (values
  ('090cd00b-9f4d-5220-ac13-0684997da334', null, 'Linguagens artísticas', 'As diferentes formas de expressão artística', '🎨', 0),
  ('37d9e580-8130-5c76-ab04-0d4b4acefd6c', '090cd00b-9f4d-5220-ac13-0684997da334', 'Artes visuais', null, '🎨', 0),
  ('166f274f-3863-5cb8-bb20-b79096f09443', '090cd00b-9f4d-5220-ac13-0684997da334', 'Artes cênicas', null, '🎨', 1),
  ('c31fea6f-1bb8-525e-b0ef-ecea6ae290f5', null, 'Movimentos artísticos brasileiros', 'Barroco, Modernismo e arte contemporânea no Brasil', '🇧🇷', 1),
  ('7a2b5f15-00df-55ed-872d-eef6f551eb5c', 'c31fea6f-1bb8-525e-b0ef-ecea6ae290f5', 'Barroco', null, '🇧🇷', 0),
  ('675670cd-ab82-5dc2-aec8-687a9611bbd3', 'c31fea6f-1bb8-525e-b0ef-ecea6ae290f5', 'Modernismo', null, '🇧🇷', 1),
  ('5b392dd9-91e1-5e0c-8e5d-40b6faf5fa83', 'c31fea6f-1bb8-525e-b0ef-ecea6ae290f5', 'Arte contemporânea brasileira', null, '🇧🇷', 2),
  ('da29f47a-a6c8-5f04-8808-4a2dcaaeea94', null, 'Movimentos artísticos internacionais', 'Renascimento, Impressionismo e vanguardas europeias', '🖼️', 2),
  ('e2684c27-820b-5927-a711-edacfee6782d', 'da29f47a-a6c8-5f04-8808-4a2dcaaeea94', 'Renascimento', null, '🖼️', 0),
  ('dd2eec3f-dac9-5094-bdbc-3dd7f38a6cf9', 'da29f47a-a6c8-5f04-8808-4a2dcaaeea94', 'Impressionismo', null, '🖼️', 1),
  ('f5a94830-f726-5aa9-978c-da678c3ac1d1', 'da29f47a-a6c8-5f04-8808-4a2dcaaeea94', 'Vanguardas europeias', null, '🖼️', 2),
  ('72d482b5-0e9f-5d99-8fe6-31a3157f21c4', null, 'Música', 'Elementos musicais e história da música popular brasileira', '🎵', 3),
  ('7ddc29ff-5087-5702-bd48-8e7bb9591fbb', '72d482b5-0e9f-5d99-8fe6-31a3157f21c4', 'Elementos da música', null, '🎵', 0),
  ('7ebb4529-9c5b-544e-ab5e-dfe27cfdbf29', '72d482b5-0e9f-5d99-8fe6-31a3157f21c4', 'História da música popular brasileira', null, '🎵', 1),
  ('ad0d9558-7f00-5c2b-9595-e668c31ab10e', null, 'Arquitetura e patrimônio', 'Arquitetura brasileira e preservação do patrimônio cultural', '🏛️', 4),
  ('69fbcd7f-0b83-5d6f-83af-83e3f3a6c132', 'ad0d9558-7f00-5c2b-9595-e668c31ab10e', 'Arquitetura brasileira', null, '🏛️', 0),
  ('1608ace4-80cc-5a3d-a176-20cdf2c114a2', 'ad0d9558-7f00-5c2b-9595-e668c31ab10e', 'Patrimônio cultural e preservação', null, '🏛️', 1),
  ('8002cc5b-ded6-5828-899c-83096ff94389', null, 'Cultura popular e folclore', 'Festas, tradições e artesanato do povo brasileiro', '🎭', 5),
  ('3b3dd255-115b-5331-aefd-fd8689860639', '8002cc5b-ded6-5828-899c-83096ff94389', 'Festas e tradições populares', null, '🎭', 0),
  ('97aba5f9-8d98-57d1-93cf-5e251ce0bcbe', '8002cc5b-ded6-5828-899c-83096ff94389', 'Artesanato e cultura material', null, '🎭', 1),
  ('2f516f68-b9cd-53a0-b4ff-b6999ac3a7c9', null, 'Cinema e audiovisual', 'História, linguagem e cinema brasileiro', '🎬', 6),
  ('6d5a69b1-3084-5045-9f4c-08e508996a62', '2f516f68-b9cd-53a0-b4ff-b6999ac3a7c9', 'História do cinema', null, '🎬', 0),
  ('b0d74c13-9e3c-526e-b79e-ca85527e37b4', '2f516f68-b9cd-53a0-b4ff-b6999ac3a7c9', 'Linguagem cinematográfica', null, '🎬', 1),
  ('f5728245-4677-5c48-932a-12a75ad23e4d', '2f516f68-b9cd-53a0-b4ff-b6999ac3a7c9', 'Cinema brasileiro', null, '🎬', 2),
  ('e94ead28-e278-5fc4-96dc-76261ead9190', null, 'Arte e sociedade', 'Arte engajada, indústria cultural e novas mídias', '💻', 7),
  ('9b282ef1-d0e5-5588-a1d7-9af2418e6071', 'e94ead28-e278-5fc4-96dc-76261ead9190', 'Arte engajada e política', null, '💻', 0),
  ('aaf38868-aae3-5f17-92bc-a13badb1e64b', 'e94ead28-e278-5fc4-96dc-76261ead9190', 'Indústria cultural', null, '💻', 1),
  ('33969e3a-5465-5004-b064-2e58846962db', 'e94ead28-e278-5fc4-96dc-76261ead9190', 'Arte digital e novas mídias', null, '💻', 2)
) as v(id, parent, title, description, icon, ord)
order by v.parent nulls first
on conflict (id) do nothing;

insert into catalog_node_translations (catalog_node_id, locale, title, description)
select v.id::uuid, v.locale, v.title, v.description
from (values
  ('090cd00b-9f4d-5220-ac13-0684997da334', 'en', 'Artistic languages', 'The different forms of artistic expression'),
  ('090cd00b-9f4d-5220-ac13-0684997da334', 'es', 'Lenguajes artísticos', 'Las diferentes formas de expresión artística'),
  ('37d9e580-8130-5c76-ab04-0d4b4acefd6c', 'en', 'Visual arts', null),
  ('37d9e580-8130-5c76-ab04-0d4b4acefd6c', 'es', 'Artes visuales', null),
  ('166f274f-3863-5cb8-bb20-b79096f09443', 'en', 'Performing arts', null),
  ('166f274f-3863-5cb8-bb20-b79096f09443', 'es', 'Artes escénicas', null),
  ('c31fea6f-1bb8-525e-b0ef-ecea6ae290f5', 'en', 'Brazilian artistic movements', 'Baroque, Modernism and contemporary art in Brazil'),
  ('c31fea6f-1bb8-525e-b0ef-ecea6ae290f5', 'es', 'Movimientos artísticos brasileños', 'Barroco, Modernismo y arte contemporáneo en Brasil'),
  ('7a2b5f15-00df-55ed-872d-eef6f551eb5c', 'en', 'Baroque', null),
  ('7a2b5f15-00df-55ed-872d-eef6f551eb5c', 'es', 'Barroco', null),
  ('675670cd-ab82-5dc2-aec8-687a9611bbd3', 'en', 'Modernism', null),
  ('675670cd-ab82-5dc2-aec8-687a9611bbd3', 'es', 'Modernismo', null),
  ('5b392dd9-91e1-5e0c-8e5d-40b6faf5fa83', 'en', 'Contemporary Brazilian art', null),
  ('5b392dd9-91e1-5e0c-8e5d-40b6faf5fa83', 'es', 'Arte contemporáneo brasileño', null),
  ('da29f47a-a6c8-5f04-8808-4a2dcaaeea94', 'en', 'International artistic movements', 'Renaissance, Impressionism and European avant-gardes'),
  ('da29f47a-a6c8-5f04-8808-4a2dcaaeea94', 'es', 'Movimientos artísticos internacionales', 'Renacimiento, Impresionismo y vanguardias europeas'),
  ('e2684c27-820b-5927-a711-edacfee6782d', 'en', 'Renaissance', null),
  ('e2684c27-820b-5927-a711-edacfee6782d', 'es', 'Renacimiento', null),
  ('dd2eec3f-dac9-5094-bdbc-3dd7f38a6cf9', 'en', 'Impressionism', null),
  ('dd2eec3f-dac9-5094-bdbc-3dd7f38a6cf9', 'es', 'Impresionismo', null),
  ('f5a94830-f726-5aa9-978c-da678c3ac1d1', 'en', 'European avant-gardes', null),
  ('f5a94830-f726-5aa9-978c-da678c3ac1d1', 'es', 'Vanguardias europeas', null),
  ('72d482b5-0e9f-5d99-8fe6-31a3157f21c4', 'en', 'Music', 'Musical elements and the history of Brazilian popular music'),
  ('72d482b5-0e9f-5d99-8fe6-31a3157f21c4', 'es', 'Música', 'Elementos musicales e historia de la música popular brasileña'),
  ('7ddc29ff-5087-5702-bd48-8e7bb9591fbb', 'en', 'Elements of music', null),
  ('7ddc29ff-5087-5702-bd48-8e7bb9591fbb', 'es', 'Elementos de la música', null),
  ('7ebb4529-9c5b-544e-ab5e-dfe27cfdbf29', 'en', 'History of Brazilian popular music', null),
  ('7ebb4529-9c5b-544e-ab5e-dfe27cfdbf29', 'es', 'Historia de la música popular brasileña', null),
  ('ad0d9558-7f00-5c2b-9595-e668c31ab10e', 'en', 'Architecture and heritage', 'Brazilian architecture and cultural heritage preservation'),
  ('ad0d9558-7f00-5c2b-9595-e668c31ab10e', 'es', 'Arquitectura y patrimonio', 'Arquitectura brasileña y preservación del patrimonio cultural'),
  ('69fbcd7f-0b83-5d6f-83af-83e3f3a6c132', 'en', 'Brazilian architecture', null),
  ('69fbcd7f-0b83-5d6f-83af-83e3f3a6c132', 'es', 'Arquitectura brasileña', null),
  ('1608ace4-80cc-5a3d-a176-20cdf2c114a2', 'en', 'Cultural heritage and preservation', null),
  ('1608ace4-80cc-5a3d-a176-20cdf2c114a2', 'es', 'Patrimonio cultural y preservación', null),
  ('8002cc5b-ded6-5828-899c-83096ff94389', 'en', 'Popular culture and folklore', 'Festivals, traditions and craftsmanship of the Brazilian people'),
  ('8002cc5b-ded6-5828-899c-83096ff94389', 'es', 'Cultura popular y folclore', 'Fiestas, tradiciones y artesanía del pueblo brasileño'),
  ('3b3dd255-115b-5331-aefd-fd8689860639', 'en', 'Popular festivals and traditions', null),
  ('3b3dd255-115b-5331-aefd-fd8689860639', 'es', 'Fiestas y tradiciones populares', null),
  ('97aba5f9-8d98-57d1-93cf-5e251ce0bcbe', 'en', 'Crafts and material culture', null),
  ('97aba5f9-8d98-57d1-93cf-5e251ce0bcbe', 'es', 'Artesanía y cultura material', null),
  ('2f516f68-b9cd-53a0-b4ff-b6999ac3a7c9', 'en', 'Cinema and audiovisual', 'History, language and Brazilian cinema'),
  ('2f516f68-b9cd-53a0-b4ff-b6999ac3a7c9', 'es', 'Cine y audiovisual', 'Historia, lenguaje y cine brasileño'),
  ('6d5a69b1-3084-5045-9f4c-08e508996a62', 'en', 'History of cinema', null),
  ('6d5a69b1-3084-5045-9f4c-08e508996a62', 'es', 'Historia del cine', null),
  ('b0d74c13-9e3c-526e-b79e-ca85527e37b4', 'en', 'Film language', null),
  ('b0d74c13-9e3c-526e-b79e-ca85527e37b4', 'es', 'Lenguaje cinematográfico', null),
  ('f5728245-4677-5c48-932a-12a75ad23e4d', 'en', 'Brazilian cinema', null),
  ('f5728245-4677-5c48-932a-12a75ad23e4d', 'es', 'Cine brasileño', null),
  ('e94ead28-e278-5fc4-96dc-76261ead9190', 'en', 'Art and society', 'Engaged art, cultural industry and new media'),
  ('e94ead28-e278-5fc4-96dc-76261ead9190', 'es', 'Arte y sociedad', 'Arte comprometido, industria cultural y nuevos medios'),
  ('9b282ef1-d0e5-5588-a1d7-9af2418e6071', 'en', 'Engaged and political art', null),
  ('9b282ef1-d0e5-5588-a1d7-9af2418e6071', 'es', 'Arte comprometido y político', null),
  ('aaf38868-aae3-5f17-92bc-a13badb1e64b', 'en', 'Cultural industry', null),
  ('aaf38868-aae3-5f17-92bc-a13badb1e64b', 'es', 'Industria cultural', null),
  ('33969e3a-5465-5004-b064-2e58846962db', 'en', 'Digital art and new media', null),
  ('33969e3a-5465-5004-b064-2e58846962db', 'es', 'Arte digital y nuevos medios', null)
) as v(id, locale, title, description)
join catalog_nodes c on c.id = v.id::uuid
on conflict (catalog_node_id, locale) do update
  set title = excluded.title, description = excluded.description;
