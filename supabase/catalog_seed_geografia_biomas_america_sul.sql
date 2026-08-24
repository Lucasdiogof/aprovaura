-- Map-quiz version of biomes for América do Sul, sibling of the existing
-- "Biomas" question leaf (16effb57-67b7-4aa0-9d12-9c77a863097b) -- same
-- 4 regions that leaf already quizzes on (Amazônia, Atacama, Patagônia,
-- Pampa), same hand-approximated-boundary caveat as the Brazil/world
-- biome maps.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  'd9e7a22c-03de-4849-ad6d-3420107e4805',
  'geografia',
  (select id from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'América do Sul'),
  'Biomas da América do Sul',
  'Amazônia, Atacama, Patagônia e Pampa no mapa',
  '🌎',
  10
);

alter table catalog_nodes
  add column if not exists region_count integer;

alter table catalog_nodes
  add column if not exists manual_difficulty text
  check (manual_difficulty in ('facil', 'medio', 'dificil'));

update catalog_nodes set region_count = 4, manual_difficulty = 'medio' where id = 'd9e7a22c-03de-4849-ad6d-3420107e4805'; -- Biomas da América do Sul
