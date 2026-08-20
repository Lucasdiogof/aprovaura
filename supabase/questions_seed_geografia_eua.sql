-- New leaf under Geografia > América do Norte (id ec75dc30-24b6-4d4d-9eda-
-- a08130cb618c, same node used by the existing map-quiz children): economic
-- belts and industrial regions aren't discrete map-clickable points, so
-- this is multiple-choice questions instead -- see
-- project_aura_atlas_pdf_content_pipeline memory.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  '181684b0-7fa9-46bd-84e5-734978827037',
  'geografia',
  'ec75dc30-24b6-4d4d-9eda-a08130cb618c',
  'Estados Unidos',
  'Agricultura, indústria e os principais cinturões econômicos dos EUA',
  '🇺🇸',
  6
);

insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('181684b0-7fa9-46bd-84e5-734978827037', 'Qual cinturão agrícola dos EUA, na faixa central do país, é famoso pela produção de trigo?',
  array['Corn Belt', 'Dairy Belt', 'Wheat Belt', 'Cotton Belt'], 2,
  'O Wheat Belt ocupa a faixa central dos EUA, entre o Dairy Belt ao norte e o Corn Belt mais ao sul.', 1),
('181684b0-7fa9-46bd-84e5-734978827037', 'O "Corn Belt", cinturão do milho no centro-norte dos EUA, também é um importante produtor de qual outro grão?',
  array['Arroz', 'Soja', 'Café', 'Algodão'], 1,
  'Milho e soja costumam ser cultivados em rotação na mesma região do Corn Belt.', 2),
('181684b0-7fa9-46bd-84e5-734978827037', 'A antiga região industrial dos EUA ao redor dos Grandes Lagos, marcada pelo declínio da indústria pesada (como a automobilística de Detroit), ficou conhecida como?',
  array['Sun Belt', 'Rust Belt', 'Silicon Valley', 'Cotton Belt'], 1,
  'Rust Belt ("Cinturão da Ferrugem") é o nome dado a essa região industrial em declínio desde o fim do século XX.', 3),
('181684b0-7fa9-46bd-84e5-734978827037', 'A partir da década de 1970, parte da indústria dos EUA migrou do Rust Belt para uma região mais ao sul, com incentivos fiscais e mão de obra mais barata. Como essa região é conhecida?',
  array['Sun Belt', 'Grain Belt', 'Manufacturing Belt', 'Snow Belt'], 0,
  'O Sun Belt ("Cinturão do Sol") atraiu indústrias com incentivos fiscais, principalmente a partir dos anos 1970.', 4),
('181684b0-7fa9-46bd-84e5-734978827037', 'Quais são os três principais polos metropolitanos citados como centros econômicos dos EUA?',
  array['Nova York (Boswash), Chicago e Califórnia (São Francisco/Los Angeles)', 'Miami, Houston e Seattle', 'Washington, Dallas e Denver', 'Boston, Atlanta e Phoenix'], 0,
  'Esses três polos concentram grande parte do peso econômico e populacional dos Estados Unidos.', 5);
