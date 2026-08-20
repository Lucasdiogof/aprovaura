-- New leaf under Geografia > Mundo: didn't fit the map-quiz point/line
-- format (production rankings, not locations), so it's multiple-choice
-- questions instead -- see project_aura_atlas_pdf_content_pipeline memory.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  '28c6f408-1614-4e86-b8b2-c0ddad137ff4',
  'geografia',
  (select id from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Mundo'),
  'Agricultura mundial',
  'Os principais países produtores de grãos, soja, milho, algodão e produtos tropicais',
  '🌾',
  18
);

insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('28c6f408-1614-4e86-b8b2-c0ddad137ff4', 'Qual país é o maior produtor mundial de grãos?',
  array['China', 'Estados Unidos', 'Índia', 'Brasil'], 1,
  'Os EUA lideram a produção mundial de grãos, seguidos por Índia e China.', 1),
('28c6f408-1614-4e86-b8b2-c0ddad137ff4', 'Depois dos Estados Unidos, qual país é o segundo maior produtor mundial de soja?',
  array['Argentina', 'China', 'Brasil', 'Índia'], 2,
  'O Brasil é o segundo maior produtor de soja do mundo, atrás apenas dos EUA.', 2),
('28c6f408-1614-4e86-b8b2-c0ddad137ff4', 'Qual país lidera a produção mundial de algodão?',
  array['Índia', 'Estados Unidos', 'Brasil', 'China'], 3,
  'A China é a maior produtora mundial de algodão, seguida por Índia e EUA.', 3),
('28c6f408-1614-4e86-b8b2-c0ddad137ff4', 'A produção mundial de milho é liderada por quais dois países, nessa ordem?',
  array['Brasil e Argentina', 'China e Índia', 'Estados Unidos e China', 'EUA e Brasil'], 2,
  'Estados Unidos e China são, nessa ordem, os dois maiores produtores mundiais de milho.', 4),
('28c6f408-1614-4e86-b8b2-c0ddad137ff4', 'Produtos como cacau, café, banana, amendoim e sorgo são característicos de qual tipo de agricultura, típica de regiões tropicais como a América Central?',
  array['Agricultura de subsistência', 'Agricultura de produtos tropicais', 'Agricultura de precisão', 'Agricultura de clima temperado'], 1,
  'Esses produtos tropicais são típicos de regiões de clima quente e úmido, como a América Central.', 5);
