-- Continentes (b836a0bd-abe7-4cdb-bcd4-6f8f6468d569)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('b836a0bd-abe7-4cdb-bcd4-6f8f6468d569', 'Quantos continentes existem, segundo o modelo mais adotado no Brasil?',
  array['6', '5', '7', '4'], 0,
  'América, Europa, Ásia, África, Oceania e Antártida.', 1),
('b836a0bd-abe7-4cdb-bcd4-6f8f6468d569', 'Qual é o maior continente do mundo em área e população?',
  array['Ásia', 'África', 'América', 'Europa'], 0,
  'A Ásia concentra mais da metade da população mundial.', 2),
('b836a0bd-abe7-4cdb-bcd4-6f8f6468d569', 'Qual é o menor continente do mundo em área?',
  array['Oceania', 'Europa', 'Antártida', 'América do Sul'], 0,
  'A Oceania inclui a Austrália e milhares de pequenas ilhas do Pacífico.', 3),
('b836a0bd-abe7-4cdb-bcd4-6f8f6468d569', 'A Antártida se diferencia dos outros continentes principalmente por não ter?',
  array['População fixa e países soberanos', 'Nenhuma montanha', 'Nenhum litoral', 'Nenhum tipo de gelo'], 0,
  'É ocupada apenas por bases científicas de diferentes países, sem soberania nacional definida.', 4),
('b836a0bd-abe7-4cdb-bcd4-6f8f6468d569', 'Segundo modelos geográficos usados em outros países, a América é dividida em quantos continentes?',
  array['2', '3', '4', '1'], 0,
  'Nesses modelos, América do Norte e América do Sul são tratadas como continentes separados.', 5);

-- Oceanos (ea820801-fbfb-4e37-adad-d3183549f66b)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('ea820801-fbfb-4e37-adad-d3183549f66b', 'Qual é o maior e mais profundo oceano do mundo?',
  array['Oceano Pacífico', 'Oceano Atlântico', 'Oceano Índico', 'Oceano Ártico'], 0,
  'Ocupa cerca de um terço da superfície da Terra.', 1),
('ea820801-fbfb-4e37-adad-d3183549f66b', 'Qual oceano fica entre o continente americano e a Europa/África?',
  array['Oceano Atlântico', 'Oceano Pacífico', 'Oceano Índico', 'Oceano Austral'], 0,
  'É historicamente um dos mais importantes para o comércio e a navegação mundial.', 2),
('ea820801-fbfb-4e37-adad-d3183549f66b', 'Qual é o oceano mais raso e frio do mundo, ao redor do Polo Norte?',
  array['Oceano Ártico', 'Oceano Atlântico', 'Oceano Índico', 'Oceano Austral'], 0,
  'Boa parte de sua superfície é coberta por gelo durante todo o ano.', 3),
('ea820801-fbfb-4e37-adad-d3183549f66b', 'O Oceano Índico banha qual continente por seu lado oeste?',
  array['África', 'América', 'Europa', 'América do Norte'], 0,
  'Também banha a Ásia (sul) e a Oceania (oeste da Austrália).', 4),
('ea820801-fbfb-4e37-adad-d3183549f66b', 'Em 2021, qual organização passou a reconhecer oficialmente o Oceano Austral como o quinto oceano do mundo?',
  array['National Geographic', 'ONU', 'UNESCO', 'NASA'], 0,
  'As águas frias ao redor da Antártida foram reconhecidas como uma região oceânica distinta.', 5);

-- Mares (cf19dc0c-5419-4c3a-adb5-3110aab30085)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('cf19dc0c-5419-4c3a-adb5-3110aab30085', 'O Mar Egeu, com suas milhares de ilhas, fica entre a Grécia e qual outro país?',
  array['Turquia', 'Itália', 'Egito', 'Bulgária'], 0,
  'É famoso por seu grande número de ilhas gregas e turcas.', 1),
('cf19dc0c-5419-4c3a-adb5-3110aab30085', 'O Mar do Norte, importante para pesca e petróleo, fica entre o Reino Unido e qual outro país nórdico?',
  array['Noruega', 'Espanha', 'Grécia', 'Portugal'], 0,
  'Também banha Dinamarca, Alemanha e Holanda.', 2),
('cf19dc0c-5419-4c3a-adb5-3110aab30085', 'O Estreito de Bering, que separa dois continentes, liga o Oceano Pacífico a qual outro oceano?',
  array['Oceano Ártico', 'Oceano Atlântico', 'Oceano Índico', 'Oceano Austral'], 0,
  'Separa também a Ásia (Rússia) da América do Norte (Alasca).', 3),
('cf19dc0c-5419-4c3a-adb5-3110aab30085', 'O Mar da China Meridional é uma área de intensa disputa territorial entre a China e países como Vietnã e?',
  array['Filipinas', 'Japão', 'Índia', 'Austrália'], 0,
  'A região é estratégica por suas rotas comerciais e reservas de petróleo e gás.', 4),
('cf19dc0c-5419-4c3a-adb5-3110aab30085', 'Qual mar, entre a Península Arábica e a Índia, é uma extensão do Oceano Índico?',
  array['Mar Arábico', 'Mar Cáspio', 'Mar Vermelho', 'Mar Negro'], 0,
  'É uma importante rota marítima entre o Oriente Médio e o Sul da Ásia.', 5);

-- Grandes cordilheiras (fecad808-3cd6-4ddd-818b-e3d612641ee5)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('fecad808-3cd6-4ddd-818b-e3d612641ee5', 'Qual é a cordilheira mais extensa do mundo, ao longo da costa oeste da América?',
  array['Cordilheira dos Andes', 'Montanhas Rochosas', 'Himalaia', 'Cordilheira do Atlas'], 0,
  'Tem cerca de 7 mil km, atravessando sete países sul-americanos.', 1),
('fecad808-3cd6-4ddd-818b-e3d612641ee5', 'Qual é a cordilheira com a maior altitude média do planeta, na Ásia?',
  array['Himalaia', 'Andes', 'Montanhas Rochosas', 'Alpes'], 0,
  'Abriga os 14 picos mais altos do mundo, todos acima de 8 mil metros.', 2),
('fecad808-3cd6-4ddd-818b-e3d612641ee5', 'As Montanhas Rochosas são a principal cordilheira de qual continente?',
  array['América do Norte', 'América do Sul', 'Ásia', 'Europa'], 0,
  'Atravessam o oeste dos Estados Unidos e do Canadá.', 3),
('fecad808-3cd6-4ddd-818b-e3d612641ee5', 'A Cordilheira do Atlas, no noroeste da África, atravessa principalmente quais países?',
  array['Marrocos, Argélia e Tunísia', 'Egito, Líbia e Sudão', 'Quênia e Tanzânia', 'África do Sul e Namíbia'], 0,
  'Separa o litoral mediterrâneo do deserto do Saara.', 4),
('fecad808-3cd6-4ddd-818b-e3d612641ee5', 'As Montanhas Apalaches, mais antigas e erodidas que as Rochosas, ficam em qual região dos Estados Unidos?',
  array['Leste', 'Oeste', 'Norte extremo', 'Sul extremo'], 0,
  'Formaram-se há centenas de milhões de anos, por isso têm relevo mais suave.', 5);

-- Desertos (219bc852-f7c0-4ba9-9c29-4bc6339eae7d)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('219bc852-f7c0-4ba9-9c29-4bc6339eae7d', 'Qual é considerado o maior deserto do mundo em área total, apesar de ser coberto de gelo?',
  array['Deserto Antártico', 'Deserto do Saara', 'Deserto da Arábia', 'Deserto de Gobi'], 0,
  'Um deserto é definido pela baixa precipitação, não necessariamente pelo calor.', 1),
('219bc852-f7c0-4ba9-9c29-4bc6339eae7d', 'O Deserto de Mojave, que abriga o Vale da Morte, está localizado em qual país?',
  array['Estados Unidos', 'México', 'Canadá', 'Austrália'], 0,
  'Fica no sudoeste dos Estados Unidos.', 2),
('219bc852-f7c0-4ba9-9c29-4bc6339eae7d', 'O Grande Deserto de Vitória, um dos maiores do mundo, está localizado em qual país?',
  array['Austrália', 'Estados Unidos', 'China', 'Argentina'], 0,
  'Fica no sudoeste da Austrália, com dunas vermelhas e lagos salgados secos.', 3),
('219bc852-f7c0-4ba9-9c29-4bc6339eae7d', 'O que diferencia um "deserto polar", como a Antártida, de um deserto quente tradicional?',
  array['A baixíssima precipitação, mesmo com temperaturas extremamente baixas', 'A ausência total de vento', 'A presença constante de vegetação', 'A proximidade com o mar'], 0,
  'Ambos os tipos de deserto compartilham a característica de pouquíssima chuva.', 4),
('219bc852-f7c0-4ba9-9c29-4bc6339eae7d', 'O Vale da Morte, no deserto de Mojave, é conhecido por registrar qual característica extrema?',
  array['Uma das temperaturas mais altas já medidas na Terra', 'A menor temperatura já registrada', 'A maior altitude entre os desertos', 'O maior índice de chuva entre os desertos'], 0,
  'É um dos lugares mais quentes do planeta.', 5);

-- Ilhas (4f527027-310f-4c38-8269-328fb6741d06)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('4f527027-310f-4c38-8269-328fb6741d06', 'Qual é a maior ilha do mundo (sem contar os continentes)?',
  array['Groenlândia', 'Madagascar', 'Nova Guiné', 'Bornéu'], 0,
  'Tem cerca de 2,16 milhões de km², a maior parte coberta por gelo.', 1),
('4f527027-310f-4c38-8269-328fb6741d06', 'A Groenlândia é um território autônomo que pertence a qual país europeu?',
  array['Dinamarca', 'Noruega', 'Suécia', 'Islândia'], 0,
  'Apesar de geograficamente próxima da América do Norte, é um território dinamarquês.', 2),
('4f527027-310f-4c38-8269-328fb6741d06', 'Madagascar, uma das maiores ilhas do mundo, fica na costa de qual continente?',
  array['África', 'Ásia', 'Oceania', 'América do Sul'], 0,
  'Fica no Oceano Índico, ao sudeste do continente africano.', 3),
('4f527027-310f-4c38-8269-328fb6741d06', 'O Japão é formado por milhares de ilhas. Qual é a maior e mais populosa delas, onde fica Tóquio?',
  array['Honshu', 'Hokkaido', 'Kyushu', 'Shikoku'], 0,
  'Honshu concentra a maior parte da população e das grandes cidades japonesas.', 4),
('4f527027-310f-4c38-8269-328fb6741d06', 'As Ilhas Galápagos, famosas por sua biodiversidade estudada por Charles Darwin, pertencem a qual país?',
  array['Equador', 'Peru', 'Chile', 'Colômbia'], 0,
  'Ficam no Oceano Pacífico, a cerca de mil km da costa equatoriana.', 5);

-- Vulcões (458454b8-1e00-4241-9f27-9f072ba586fe)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('458454b8-1e00-4241-9f27-9f072ba586fe', 'O "Anel de Fogo do Pacífico" é uma extensa faixa conhecida por concentrar o quê?',
  array['Grande parte dos vulcões e terremotos do mundo', 'As maiores reservas de petróleo do planeta', 'Os maiores desertos do mundo', 'As maiores geleiras do planeta'], 0,
  'Contorna praticamente todo o Oceano Pacífico, passando por várias placas tectônicas.', 1),
('458454b8-1e00-4241-9f27-9f072ba586fe', 'O Monte Vesúvio, vulcão que destruiu a cidade romana de Pompeia em 79 d.C., está localizado em qual país?',
  array['Itália', 'Grécia', 'Turquia', 'Espanha'], 0,
  'A erupção soterrou Pompeia e Herculano sob cinzas e pedra-pomes.', 2),
('458454b8-1e00-4241-9f27-9f072ba586fe', 'O Monte Fuji, vulcão mais alto e símbolo do Japão, está atualmente classificado como?',
  array['Vulcão adormecido (não extinto)', 'Vulcão extinto', 'Vulcão permanentemente ativo', 'Vulcão submarino'], 0,
  'Sua última erupção registrada foi em 1707.', 3),
('458454b8-1e00-4241-9f27-9f072ba586fe', 'O Krakatoa, vulcão de uma das maiores erupções já registradas (1883), está localizado em qual país?',
  array['Indonésia', 'Filipinas', 'Japão', 'Papua-Nova Guiné'], 0,
  'A explosão foi ouvida a milhares de quilômetros de distância e gerou tsunamis devastadores.', 4),
('458454b8-1e00-4241-9f27-9f072ba586fe', 'O arquipélago do Havaí, no meio do Oceano Pacífico, foi formado inteiramente por qual tipo de atividade geológica?',
  array['Atividade vulcânica', 'Erosão fluvial', 'Movimento de geleiras', 'Depósitos de coral apenas'], 0,
  'As ilhas se formaram sobre um "ponto quente" vulcânico no meio da placa do Pacífico.', 5);

-- Linhas imaginárias (be84da4e-f4ab-4a4a-a406-9a05e49917d4)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('be84da4e-f4ab-4a4a-a406-9a05e49917d4', 'A Linha do Equador divide a Terra em quais dois hemisférios?',
  array['Hemisfério Norte e Hemisfério Sul', 'Hemisfério Oriental e Ocidental', 'Hemisfério Leste e Oeste', 'Hemisfério Alto e Baixo'], 0,
  'É a linha imaginária de latitude zero.', 1),
('be84da4e-f4ab-4a4a-a406-9a05e49917d4', 'O Meridiano de Greenwich, referência para os fusos horários, divide o planeta em quais dois hemisférios?',
  array['Ocidental e Oriental', 'Norte e Sul', 'Alto e Baixo', 'Quente e Frio'], 0,
  'É a linha de longitude zero, que passa por Greenwich, na Inglaterra.', 2),
('be84da4e-f4ab-4a4a-a406-9a05e49917d4', 'Quais são as duas linhas imaginárias que delimitam a Zona Intertropical, uma ao norte e outra ao sul do Equador?',
  array['Trópico de Câncer e Trópico de Capricórnio', 'Círculo Polar Ártico e Antártico', 'Meridiano de Greenwich e Linha do Equador', 'Paralelo 45 Norte e Sul'], 0,
  'Marcam os limites onde o sol pode incidir diretamente sobre a cabeça (perpendicular) ao longo do ano.', 3),
('be84da4e-f4ab-4a4a-a406-9a05e49917d4', 'A Linha Internacional de Data, usada para marcar a mudança de dia no calendário, segue aproximadamente qual meridiano?',
  array['Meridiano de 180°', 'Meridiano de Greenwich (0°)', 'Meridiano de 90° Oeste', 'Meridiano de 45° Leste'], 0,
  'Fica no Oceano Pacífico, do lado oposto ao Meridiano de Greenwich.', 4),
('be84da4e-f4ab-4a4a-a406-9a05e49917d4', 'Os Círculos Polares Ártico e Antártico marcam o limite de qual fenômeno, em que o sol pode não se pôr por dias seguidos?',
  array['O sol da meia-noite', 'Os eclipses solares', 'As auroras boreais', 'As marés altas'], 0,
  'Dentro desses círculos, há períodos do ano com luz do dia contínua ou noite contínua.', 5);
