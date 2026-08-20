-- 3 more map-quiz topics, same pattern as the previous batch
-- (catalog_seed_geografia_relevo_solos.sql): no `questions` rows,
-- region_count carries their total for progress, manual_difficulty
-- carries their level for the difficulty filter.
--
-- "Relevo do Brasil" and "Indústria do Brasil" are new top-level children
-- of Brasil (siblings of the existing "Estados", "Relevo",
-- "Geografia econômica" theme nodes) -- not nested under those existing
-- theme nodes, since this script doesn't know their live ids. Their
-- parent is resolved by title lookup instead of a hardcoded uuid.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  '3e6171a4-2d01-4fe7-8aed-f86614908ea9',
  'geografia',
  (select id from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Brasil'),
  'Relevo do Brasil',
  'As principais serras, planaltos, chapadas e planícies do Brasil',
  '⛰️',
  20
);

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  '91b59525-7426-4918-835d-0a12afe2c688',
  'geografia',
  (select id from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Brasil'),
  'Indústria do Brasil',
  'Os principais polos industriais e portos do Brasil',
  '🏭',
  21
);

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  '36f310e8-f7c0-4dd2-9151-cec01f4bee5c',
  'geografia',
  (select id from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Mundo'),
  'Correntes marítimas',
  'As principais correntes marítimas quentes e frias do mundo',
  '🌊',
  17
);

alter table catalog_nodes
  add column if not exists region_count integer;

alter table catalog_nodes
  add column if not exists manual_difficulty text
  check (manual_difficulty in ('facil', 'medio', 'dificil'));

update catalog_nodes set region_count = 17, manual_difficulty = 'dificil' where id = '3e6171a4-2d01-4fe7-8aed-f86614908ea9'; -- Relevo do Brasil
update catalog_nodes set region_count = 12, manual_difficulty = 'dificil' where id = '91b59525-7426-4918-835d-0a12afe2c688'; -- Indústria do Brasil
update catalog_nodes set region_count = 9, manual_difficulty = 'dificil' where id = '36f310e8-f7c0-4dd2-9151-cec01f4bee5c'; -- Correntes marítimas
