-- Two new map-quiz topics under Geografia > Mundo, same pattern as Estreitos
-- (catalog_seed_geografia_estreitos.sql): no `questions` rows, region_count
-- carries their total for progress, manual_difficulty carries their level
-- for the difficulty filter.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index) values
  ('8bf588de-aad5-4871-b0f5-fdf1bc4083c0', 'geografia', '3d8ed012-2fd0-49b8-b238-294f80dcec07', 'Relevo do mundo', 'As principais cadeias de montanhas e planaltos do mundo', '⛰️', 15),
  ('1fa3c3e7-b2b1-4530-a356-4240e157644f', 'geografia', '3d8ed012-2fd0-49b8-b238-294f80dcec07', 'Solos do mundo', 'Os principais tipos de solo pelo mundo', '🟤', 16);

alter table catalog_nodes
  add column if not exists region_count integer;

alter table catalog_nodes
  add column if not exists manual_difficulty text
  check (manual_difficulty in ('facil', 'medio', 'dificil'));

update catalog_nodes set region_count = 15, manual_difficulty = 'dificil' where id = '8bf588de-aad5-4871-b0f5-fdf1bc4083c0'; -- Relevo do mundo
update catalog_nodes set region_count = 12, manual_difficulty = 'dificil' where id = '1fa3c3e7-b2b1-4530-a356-4240e157644f'; -- Solos do mundo

-- Rios do mundo gained 3 rivers (Sena, Níger, Indo) -- region_count moves
-- from 12 to 15. Only touches this one row; every other map-quiz total
-- from map_quiz_progress.sql is unaffected.
update catalog_nodes set region_count = 15 where id = 'a5731187-0c27-4a85-85fc-a82650ac35ac'; -- Grandes rios do mundo
