-- Map-quiz versions of biomes, alongside the existing multiple-choice
-- "Biomas e vegetação" (Brasil) and "Biomas" (América do Sul) leaves --
-- kept as separate siblings rather than replacing those, since a catalog
-- node can't be both a question leaf and a map-quiz leaf at once, and the
-- existing questions stay valuable on their own.
--
-- Biome boundaries here are hand-approximated from general geography
-- knowledge (no official IBGE/Köppen shapefile was available), the same
-- spirit as the illustrative atlas maps this content was requested from --
-- good enough to click the right region, not survey-precise borders.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  '787ccefa-e009-4971-bcd0-35b20ba3b4bd',
  'geografia',
  (select id from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Brasil'),
  'Biomas do Brasil',
  'Amazônia, Cerrado, Mata Atlântica, Caatinga, Pampa e Pantanal no mapa',
  '🌳',
  23
);

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  'dddc6035-2ce5-49d6-ae2c-e902f6d14a67',
  'geografia',
  (select id from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Mundo'),
  'Biomas do mundo',
  'As principais formações vegetais do mundo no mapa',
  '🌍',
  20
);

alter table catalog_nodes
  add column if not exists region_count integer;

alter table catalog_nodes
  add column if not exists manual_difficulty text
  check (manual_difficulty in ('facil', 'medio', 'dificil'));

update catalog_nodes set region_count = 6, manual_difficulty = 'medio' where id = '787ccefa-e009-4971-bcd0-35b20ba3b4bd'; -- Biomas do Brasil
update catalog_nodes set region_count = 9, manual_difficulty = 'dificil' where id = 'dddc6035-2ce5-49d6-ae2c-e902f6d14a67'; -- Biomas do mundo
