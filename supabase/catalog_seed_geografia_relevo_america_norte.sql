-- América do Norte and Oceania never got the "Relevo" theme every other
-- continent has (only Países/Rios/Capitais/Cidades/Bandeiras exist under
-- them) -- filling that gap for América do Norte here. Parent id
-- ec75dc30-24b6-4d4d-9eda-a08130cb618c is the existing América do Norte
-- node (already used by its other map-quiz children).

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  '235355d0-5d0f-47c2-a32b-b50cfcb30d07',
  'geografia',
  'ec75dc30-24b6-4d4d-9eda-a08130cb618c',
  'Relevo da América do Norte',
  'As principais cadeias de montanhas da América do Norte',
  '⛰️',
  6
);

alter table catalog_nodes
  add column if not exists region_count integer;

alter table catalog_nodes
  add column if not exists manual_difficulty text
  check (manual_difficulty in ('facil', 'medio', 'dificil'));

update catalog_nodes set region_count = 6, manual_difficulty = 'medio' where id = '235355d0-5d0f-47c2-a32b-b50cfcb30d07'; -- Relevo da América do Norte
