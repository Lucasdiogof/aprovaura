-- Catalog of the new subject "sociologia": 8 areas, 20 topics,
-- each with its en/es translation. Idempotent (uuid5 ids).
-- Areas first (a topic references its area), in one statement: a VALUES
-- list is inserted in order, and the parent always comes before its child.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
select v.id::uuid, 'sociologia', v.parent::uuid, v.title, v.description, v.icon, v.ord
from (values
  ('faccb578-f6d1-5447-955f-6d3bd9d9cda7', null, 'Introdução à sociologia', 'O surgimento da sociologia e o olhar sociológico', '🔎', 0),
  ('127d36c9-d8b5-5ed9-9e60-5c366738fc54', 'faccb578-f6d1-5447-955f-6d3bd9d9cda7', 'Surgimento da sociologia', null, '🔎', 0),
  ('87495fdd-4713-57ef-ba8b-39aeb0ce8660', 'faccb578-f6d1-5447-955f-6d3bd9d9cda7', 'Senso comum e imaginação sociológica', null, '🔎', 1),
  ('5622812e-30cc-526b-ac59-70bfaac1f497', null, 'Clássicos da sociologia', 'Durkheim, Weber e Marx', '📚', 1),
  ('213689ca-27ba-5f68-b58f-05b18725e2ee', '5622812e-30cc-526b-ac59-70bfaac1f497', 'Émile Durkheim', null, '📚', 0),
  ('4d145211-b6d8-5e9f-ab2c-c7a21a1c8832', '5622812e-30cc-526b-ac59-70bfaac1f497', 'Max Weber', null, '📚', 1),
  ('adfe17bf-d4bf-5102-ba03-7d02415e4efe', '5622812e-30cc-526b-ac59-70bfaac1f497', 'Karl Marx', null, '📚', 2),
  ('b93f683d-8a92-5b78-95ca-d4ddf69ced2e', null, 'Cultura e sociedade', 'Cultura, socialização, instituições e mídia', '🎭', 2),
  ('f190a7a5-5965-5715-8637-73aa29be4c26', 'b93f683d-8a92-5b78-95ca-d4ddf69ced2e', 'Cultura e etnocentrismo', null, '🎭', 0),
  ('a2c96a7d-1839-5ccf-bb6c-efaa0aff336f', 'b93f683d-8a92-5b78-95ca-d4ddf69ced2e', 'Socialização e instituições', null, '🎭', 1),
  ('102baef0-7528-5fdf-9e6e-b15453d9bf78', 'b93f683d-8a92-5b78-95ca-d4ddf69ced2e', 'Indústria cultural e mídia', null, '🎭', 2),
  ('bfb36ea5-596c-513d-ae2b-40972969edc1', null, 'Trabalho e sociedade', 'Trabalho, produção e transformações do mundo do trabalho', '🏭', 3),
  ('3fc29b35-d45e-5054-bea8-ca78cc04fd68', 'bfb36ea5-596c-513d-ae2b-40972969edc1', 'Trabalho e modos de produção', null, '🏭', 0),
  ('d3aafd83-12c1-56fe-852f-a5577a1f2dc6', 'bfb36ea5-596c-513d-ae2b-40972969edc1', 'Taylorismo, fordismo e toyotismo', null, '🏭', 1),
  ('16ea4c52-53ab-505c-9e5b-ddf1c4f7e293', null, 'Desigualdades sociais', 'Classes, raça e gênero', '📊', 4),
  ('c0fc2a44-cbf1-5e1d-8d28-ed6d56feb3c2', '16ea4c52-53ab-505c-9e5b-ddf1c4f7e293', 'Classes e estratificação', null, '📊', 0),
  ('212fb8f1-cbfb-5238-bdf1-d3b58a0a6275', '16ea4c52-53ab-505c-9e5b-ddf1c4f7e293', 'Desigualdade racial', null, '📊', 1),
  ('795e171f-7a92-5286-baef-75fa6427e532', '16ea4c52-53ab-505c-9e5b-ddf1c4f7e293', 'Gênero e desigualdade', null, '📊', 2),
  ('76e4c0a1-802c-5fc0-b953-f446ac2c3129', null, 'Poder, Estado e política', 'Estado, poder e democracia', '🗳️', 5),
  ('074e6886-ce5f-5d66-b6e5-963223bfc9f1', '76e4c0a1-802c-5fc0-b953-f446ac2c3129', 'Estado e poder', null, '🗳️', 0),
  ('707cd664-f314-5787-a7ed-933ae66429cf', '76e4c0a1-802c-5fc0-b953-f446ac2c3129', 'Democracia e participação', null, '🗳️', 1),
  ('f96200fc-c51c-57ae-a3df-e12454a31f79', null, 'Cidadania e movimentos sociais', 'Direitos, cidadania e ação coletiva', '✊', 6),
  ('2d4ebc05-2744-554c-9d49-0f29a264d720', 'f96200fc-c51c-57ae-a3df-e12454a31f79', 'Cidadania e direitos', null, '✊', 0),
  ('a3e2a06b-f2b9-5b36-be1c-3b2df163d517', 'f96200fc-c51c-57ae-a3df-e12454a31f79', 'Movimentos sociais', null, '✊', 1),
  ('c45b8273-30ca-51a1-b9ba-76184ae7d91d', null, 'Sociedade contemporânea', 'Globalização, consumo e pensamento social brasileiro', '🌐', 7),
  ('e87550e4-3652-5a73-b751-ba7914b58be6', 'c45b8273-30ca-51a1-b9ba-76184ae7d91d', 'Globalização', null, '🌐', 0),
  ('8c493578-e186-5f49-8ff8-23dcc1975da4', 'c45b8273-30ca-51a1-b9ba-76184ae7d91d', 'Consumo e sociedade em rede', null, '🌐', 1),
  ('aa365e8d-a315-5429-b22b-cfff6213a465', 'c45b8273-30ca-51a1-b9ba-76184ae7d91d', 'Pensamento social brasileiro', null, '🌐', 2)
) as v(id, parent, title, description, icon, ord)
order by v.parent nulls first
on conflict (id) do nothing;

insert into catalog_node_translations (catalog_node_id, locale, title, description)
select v.id::uuid, v.locale, v.title, v.description
from (values
  ('faccb578-f6d1-5447-955f-6d3bd9d9cda7', 'en', 'Introduction to sociology', 'The rise of sociology and the sociological perspective'),
  ('faccb578-f6d1-5447-955f-6d3bd9d9cda7', 'es', 'Introducción a la sociología', 'El surgimiento de la sociología y la mirada sociológica'),
  ('127d36c9-d8b5-5ed9-9e60-5c366738fc54', 'en', 'The rise of sociology', null),
  ('127d36c9-d8b5-5ed9-9e60-5c366738fc54', 'es', 'Surgimiento de la sociología', null),
  ('87495fdd-4713-57ef-ba8b-39aeb0ce8660', 'en', 'Common sense and the sociological imagination', null),
  ('87495fdd-4713-57ef-ba8b-39aeb0ce8660', 'es', 'Sentido común e imaginación sociológica', null),
  ('5622812e-30cc-526b-ac59-70bfaac1f497', 'en', 'Classical sociology', 'Durkheim, Weber and Marx'),
  ('5622812e-30cc-526b-ac59-70bfaac1f497', 'es', 'Clásicos de la sociología', 'Durkheim, Weber y Marx'),
  ('213689ca-27ba-5f68-b58f-05b18725e2ee', 'en', 'Émile Durkheim', null),
  ('213689ca-27ba-5f68-b58f-05b18725e2ee', 'es', 'Émile Durkheim', null),
  ('4d145211-b6d8-5e9f-ab2c-c7a21a1c8832', 'en', 'Max Weber', null),
  ('4d145211-b6d8-5e9f-ab2c-c7a21a1c8832', 'es', 'Max Weber', null),
  ('adfe17bf-d4bf-5102-ba03-7d02415e4efe', 'en', 'Karl Marx', null),
  ('adfe17bf-d4bf-5102-ba03-7d02415e4efe', 'es', 'Karl Marx', null),
  ('b93f683d-8a92-5b78-95ca-d4ddf69ced2e', 'en', 'Culture and society', 'Culture, socialization, institutions and media'),
  ('b93f683d-8a92-5b78-95ca-d4ddf69ced2e', 'es', 'Cultura y sociedad', 'Cultura, socialización, instituciones y medios'),
  ('f190a7a5-5965-5715-8637-73aa29be4c26', 'en', 'Culture and ethnocentrism', null),
  ('f190a7a5-5965-5715-8637-73aa29be4c26', 'es', 'Cultura y etnocentrismo', null),
  ('a2c96a7d-1839-5ccf-bb6c-efaa0aff336f', 'en', 'Socialization and institutions', null),
  ('a2c96a7d-1839-5ccf-bb6c-efaa0aff336f', 'es', 'Socialización e instituciones', null),
  ('102baef0-7528-5fdf-9e6e-b15453d9bf78', 'en', 'Culture industry and media', null),
  ('102baef0-7528-5fdf-9e6e-b15453d9bf78', 'es', 'Industria cultural y medios', null),
  ('bfb36ea5-596c-513d-ae2b-40972969edc1', 'en', 'Work and society', 'Work, production and changes in the world of work'),
  ('bfb36ea5-596c-513d-ae2b-40972969edc1', 'es', 'Trabajo y sociedad', 'Trabajo, producción y transformaciones del mundo laboral'),
  ('3fc29b35-d45e-5054-bea8-ca78cc04fd68', 'en', 'Work and modes of production', null),
  ('3fc29b35-d45e-5054-bea8-ca78cc04fd68', 'es', 'Trabajo y modos de producción', null),
  ('d3aafd83-12c1-56fe-852f-a5577a1f2dc6', 'en', 'Taylorism, Fordism and Toyotism', null),
  ('d3aafd83-12c1-56fe-852f-a5577a1f2dc6', 'es', 'Taylorismo, fordismo y toyotismo', null),
  ('16ea4c52-53ab-505c-9e5b-ddf1c4f7e293', 'en', 'Social inequalities', 'Class, race and gender'),
  ('16ea4c52-53ab-505c-9e5b-ddf1c4f7e293', 'es', 'Desigualdades sociales', 'Clases, raza y género'),
  ('c0fc2a44-cbf1-5e1d-8d28-ed6d56feb3c2', 'en', 'Class and stratification', null),
  ('c0fc2a44-cbf1-5e1d-8d28-ed6d56feb3c2', 'es', 'Clases y estratificación', null),
  ('212fb8f1-cbfb-5238-bdf1-d3b58a0a6275', 'en', 'Racial inequality', null),
  ('212fb8f1-cbfb-5238-bdf1-d3b58a0a6275', 'es', 'Desigualdad racial', null),
  ('795e171f-7a92-5286-baef-75fa6427e532', 'en', 'Gender and inequality', null),
  ('795e171f-7a92-5286-baef-75fa6427e532', 'es', 'Género y desigualdad', null),
  ('76e4c0a1-802c-5fc0-b953-f446ac2c3129', 'en', 'Power, the State and politics', 'The State, power and democracy'),
  ('76e4c0a1-802c-5fc0-b953-f446ac2c3129', 'es', 'Poder, Estado y política', 'Estado, poder y democracia'),
  ('074e6886-ce5f-5d66-b6e5-963223bfc9f1', 'en', 'The State and power', null),
  ('074e6886-ce5f-5d66-b6e5-963223bfc9f1', 'es', 'Estado y poder', null),
  ('707cd664-f314-5787-a7ed-933ae66429cf', 'en', 'Democracy and participation', null),
  ('707cd664-f314-5787-a7ed-933ae66429cf', 'es', 'Democracia y participación', null),
  ('f96200fc-c51c-57ae-a3df-e12454a31f79', 'en', 'Citizenship and social movements', 'Rights, citizenship and collective action'),
  ('f96200fc-c51c-57ae-a3df-e12454a31f79', 'es', 'Ciudadanía y movimientos sociales', 'Derechos, ciudadanía y acción colectiva'),
  ('2d4ebc05-2744-554c-9d49-0f29a264d720', 'en', 'Citizenship and rights', null),
  ('2d4ebc05-2744-554c-9d49-0f29a264d720', 'es', 'Ciudadanía y derechos', null),
  ('a3e2a06b-f2b9-5b36-be1c-3b2df163d517', 'en', 'Social movements', null),
  ('a3e2a06b-f2b9-5b36-be1c-3b2df163d517', 'es', 'Movimientos sociales', null),
  ('c45b8273-30ca-51a1-b9ba-76184ae7d91d', 'en', 'Contemporary society', 'Globalization, consumption and Brazilian social thought'),
  ('c45b8273-30ca-51a1-b9ba-76184ae7d91d', 'es', 'Sociedad contemporánea', 'Globalización, consumo y pensamiento social brasileño'),
  ('e87550e4-3652-5a73-b751-ba7914b58be6', 'en', 'Globalization', null),
  ('e87550e4-3652-5a73-b751-ba7914b58be6', 'es', 'Globalización', null),
  ('8c493578-e186-5f49-8ff8-23dcc1975da4', 'en', 'Consumption and the network society', null),
  ('8c493578-e186-5f49-8ff8-23dcc1975da4', 'es', 'Consumo y sociedad red', null),
  ('aa365e8d-a315-5429-b22b-cfff6213a465', 'en', 'Brazilian social thought', null),
  ('aa365e8d-a315-5429-b22b-cfff6213a465', 'es', 'Pensamiento social brasileño', null)
) as v(id, locale, title, description)
join catalog_nodes c on c.id = v.id::uuid
on conflict (catalog_node_id, locale) do update
  set title = excluded.title, description = excluded.description;
