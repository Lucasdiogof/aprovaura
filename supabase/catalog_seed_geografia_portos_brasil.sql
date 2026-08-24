-- New map quiz under Geografia > Brasil: the "Portos brasileiros" atlas
-- PDF the user originally sent was an unfilled template (map outline,
-- no annotations), so this is authored from general geography knowledge
-- instead -- major ports along the whole coastline plus the Amazon river
-- port, not the specific subset a particular course slide would have
-- emphasized.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  '668506de-7073-4f06-b633-ec983a590b79',
  'geografia',
  (select id from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Brasil'),
  'Portos do Brasil',
  'Os principais portos brasileiros no mapa',
  '⚓',
  24
);

alter table catalog_nodes
  add column if not exists region_count integer;

alter table catalog_nodes
  add column if not exists manual_difficulty text
  check (manual_difficulty in ('facil', 'medio', 'dificil'));

update catalog_nodes set region_count = 12, manual_difficulty = 'medio' where id = '668506de-7073-4f06-b633-ec983a590b79'; -- Portos do Brasil
