-- Completes the Relevo gap for Oceania (see
-- catalog_seed_geografia_relevo_america_norte.sql). Parent id
-- 66a2cb34-89b3-4d86-89e1-e1f3ffaa9b85 is the existing Oceania node
-- (already used by its other map-quiz children).

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  '4f1631c5-7b29-418f-93aa-8eb82ab150ee',
  'geografia',
  '66a2cb34-89b3-4d86-89e1-e1f3ffaa9b85',
  'Relevo da Oceania',
  'As principais cadeias de montanhas da Oceania',
  '⛰️',
  5
);

alter table catalog_nodes
  add column if not exists region_count integer;

alter table catalog_nodes
  add column if not exists manual_difficulty text
  check (manual_difficulty in ('facil', 'medio', 'dificil'));

update catalog_nodes set region_count = 4, manual_difficulty = 'dificil' where id = '4f1631c5-7b29-418f-93aa-8eb82ab150ee'; -- Relevo da Oceania
