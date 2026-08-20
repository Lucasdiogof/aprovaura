-- New leaf under Geografia > Brasil (sibling of "Indústria do Brasil"):
-- crop belts are broad regions, not discrete map-clickable points, so
-- this is multiple-choice questions instead -- see
-- project_aura_atlas_pdf_content_pipeline memory.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  '72caea53-82f0-4f9a-ac0c-b8b834587043',
  'geografia',
  (select id from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Brasil'),
  'Agricultura do Brasil',
  'Soja, cana-de-açúcar, café, laranja e as principais fronteiras agrícolas do país',
  '🌱',
  22
);

insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('72caea53-82f0-4f9a-ac0c-b8b834587043', 'A expansão da soja no Brasil começou, entre as décadas de 1960 e 1970, em qual região?',
  array['Nordeste', 'Sul (RS e PR)', 'Norte', 'MATOPIBA'], 1,
  'O Rio Grande do Sul e o Paraná foram o berço da soja no Brasil, antes da expansão para o Centro-Oeste.', 1),
('72caea53-82f0-4f9a-ac0c-b8b834587043', 'O que é a MATOPIBA?',
  array['Uma bacia hidrográfica do Centro-Oeste', 'A mais recente fronteira agrícola do país, entre Maranhão, Tocantins, Piauí e Bahia', 'Uma região metropolitana de Minas Gerais', 'O nome de uma cooperativa de café'], 1,
  'MATOPIBA reúne as iniciais de Maranhão, Tocantins, Piauí e Bahia, área de expansão recente do agronegócio.', 2),
('72caea53-82f0-4f9a-ac0c-b8b834587043', 'O primeiro grande ciclo histórico da cana-de-açúcar no Brasil, nos séculos XVI e XVII, se concentrou em qual região?',
  array['Nordeste (Zona da Mata)', 'Sul', 'Centro-Oeste', 'Oeste Paulista'], 0,
  'A Zona da Mata nordestina foi o berço da cana-de-açúcar no período colonial.', 3),
('72caea53-82f0-4f9a-ac0c-b8b834587043', 'Atualmente, qual região concentra a produção de cana-de-açúcar voltada à produção de etanol?',
  array['Zona da Mata nordestina', 'Vale do São Francisco', 'Oeste Paulista', 'Sul do Brasil'], 2,
  'O Oeste Paulista é hoje o principal polo canavieiro do país, ligado à indústria do etanol.', 4),
('72caea53-82f0-4f9a-ac0c-b8b834587043', 'O cultivo de laranja no Brasil é fortemente concentrado em qual estado?',
  array['Minas Gerais', 'Bahia', 'São Paulo', 'Paraná'], 2,
  'São Paulo concentra a maior parte da produção nacional de laranja, favorecido por clima, tecnologia e infraestrutura.', 5);
