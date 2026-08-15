-- Relevo (651d1ca4-bfd4-48a2-802b-15fd15786685)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('651d1ca4-bfd4-48a2-802b-15fd15786685', 'Qual é a principal cordilheira que atravessa o lado oeste da América do Sul?',
  array['Cordilheira dos Andes', 'Serra do Mar', 'Cordilheira Central', 'Maciço das Guianas'], 0,
  'Os Andes são a cadeia montanhosa mais extensa do mundo, com cerca de 7 mil km.', 1),
('651d1ca4-bfd4-48a2-802b-15fd15786685', 'A Cordilheira dos Andes atravessa quantos países sul-americanos?',
  array['7', '4', '10', '12'], 0,
  'Venezuela, Colômbia, Equador, Peru, Bolívia, Chile e Argentina.', 2),
('651d1ca4-bfd4-48a2-802b-15fd15786685', 'Qual é o ponto mais alto da América do Sul?',
  array['Aconcágua, na Argentina', 'Pico da Neblina, no Brasil', 'Chimborazo, no Equador', 'Huascarán, no Peru'], 0,
  'O Aconcágua tem 6.960 m e também é o pico mais alto dos hemisférios ocidental e sul.', 3),
('651d1ca4-bfd4-48a2-802b-15fd15786685', 'As grandes planícies sul-americanas, como a Amazônica, costumam acompanhar principalmente qual elemento do relevo?',
  array['Os grandes vales fluviais', 'As grandes cordilheiras', 'Os planaltos cristalinos', 'Os desertos costeiros'], 0,
  'As planícies se formam nas áreas baixas ao redor dos grandes rios.', 4),
('651d1ca4-bfd4-48a2-802b-15fd15786685', 'O relevo do Brasil, país que ocupa a maior parte da plataforma sul-americana, é formado principalmente por?',
  array['Planaltos e planícies', 'Apenas grandes montanhas', 'Apenas desertos', 'Apenas planícies costeiras'], 0,
  'Diferente dos países andinos, o relevo brasileiro é predominantemente suave, sem grandes cadeias montanhosas.', 5);

-- Biomas (16effb57-67b7-4aa0-9d12-9c77a863097b)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('16effb57-67b7-4aa0-9d12-9c77a863097b', 'Qual é o maior bioma da América do Sul, compartilhado por vários países além do Brasil?',
  array['Amazônia', 'Pampa', 'Atacama', 'Patagônia'], 0,
  'A floresta amazônica se estende também por Peru, Colômbia, Bolívia, Equador, Venezuela, Guiana e Suriname.', 1),
('16effb57-67b7-4aa0-9d12-9c77a863097b', 'O deserto do Atacama, um dos mais secos do mundo, está localizado em qual país?',
  array['Chile', 'Peru', 'Bolívia', 'Argentina'], 0,
  'Fica na costa norte do Chile, entre os Andes e o Oceano Pacífico.', 2),
('16effb57-67b7-4aa0-9d12-9c77a863097b', 'A região da Patagônia, no extremo sul do continente, é compartilhada por quais dois países?',
  array['Argentina e Chile', 'Argentina e Uruguai', 'Chile e Bolívia', 'Argentina e Paraguai'], 0,
  'É uma região de clima frio e paisagens de estepe, dividida entre os dois países.', 3),
('16effb57-67b7-4aa0-9d12-9c77a863097b', 'O bioma Pampa, com vegetação de campos, está presente no Brasil, no Uruguai e em qual outro país?',
  array['Argentina', 'Chile', 'Paraguai', 'Bolívia'], 0,
  'O Pampa argentino é uma das regiões agrícolas mais produtivas do continente.', 4),
('16effb57-67b7-4aa0-9d12-9c77a863097b', 'Por que o deserto do Atacama é considerado um dos lugares mais secos do planeta?',
  array['A Corrente de Humboldt e o efeito de sombra de chuva dos Andes bloqueiam a umidade', 'Fica muito distante do mar', 'Recebe ventos quentes vindos da Amazônia', 'Está localizado em altitude extrema'], 0,
  'A combinação da corrente fria do Pacífico com a barreira montanhosa impede a chegada de chuvas.', 5);

-- Divisões administrativas (9d06b616-e4e7-4d43-9526-719c3e8a6d1c)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('9d06b616-e4e7-4d43-9526-719c3e8a6d1c', 'Quantos países independentes existem na América do Sul?',
  array['12', '9', '15', '10'], 0,
  'Argentina, Bolívia, Brasil, Chile, Colômbia, Equador, Guiana, Paraguai, Peru, Suriname, Uruguai e Venezuela.', 1),
('9d06b616-e4e7-4d43-9526-719c3e8a6d1c', 'Quais são os dois países sul-americanos que não têm litoral (são interiores)?',
  array['Bolívia e Paraguai', 'Uruguai e Chile', 'Peru e Equador', 'Colômbia e Venezuela'], 0,
  'Ambos dependem de acordos com países vizinhos para acesso ao mar.', 2),
('9d06b616-e4e7-4d43-9526-719c3e8a6d1c', 'Qual é o maior país da América do Sul em extensão territorial?',
  array['Brasil', 'Argentina', 'Peru', 'Colômbia'], 0,
  'O Brasil ocupa quase metade da área total do continente sul-americano.', 3),
('9d06b616-e4e7-4d43-9526-719c3e8a6d1c', 'Qual é o menor país independente da América do Sul em extensão territorial?',
  array['Suriname', 'Uruguai', 'Equador', 'Guiana'], 0,
  'O Suriname tem cerca de 163 mil km², o menor entre os países soberanos do continente.', 4),
('9d06b616-e4e7-4d43-9526-719c3e8a6d1c', 'A Guiana Francesa, território no continente sul-americano, pertence a qual país europeu?',
  array['França', 'Reino Unido', 'Países Baixos', 'Portugal'], 0,
  'É um departamento ultramarino francês, não um país independente.', 5);

-- Pontos turísticos (81783211-0d77-45eb-9444-94b49ec16201)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('81783211-0d77-45eb-9444-94b49ec16201', 'Qual famoso monumento no Rio de Janeiro é uma das Sete Maravilhas do Mundo Moderno?',
  array['Cristo Redentor', 'Torre Eiffel', 'Coliseu', 'Muralha da China'], 0,
  'Está localizado no topo do Corcovado, com vista para a cidade.', 1),
('81783211-0d77-45eb-9444-94b49ec16201', 'As Cataratas do Iguaçu ficam na fronteira entre Brasil, Argentina e qual outro país?',
  array['Paraguai', 'Bolívia', 'Uruguai', 'Chile'], 0,
  'A região é conhecida como Tríplice Fronteira.', 2),
('81783211-0d77-45eb-9444-94b49ec16201', 'Machu Picchu, importante sítio arqueológico inca, está localizado em qual país?',
  array['Peru', 'Bolívia', 'Equador', 'Chile'], 0,
  'A cidadela inca fica nos Andes peruanos, a cerca de 2.400 m de altitude.', 3),
('81783211-0d77-45eb-9444-94b49ec16201', 'O Salar de Uyuni, o maior deserto de sal do mundo, está localizado em qual país?',
  array['Bolívia', 'Chile', 'Peru', 'Argentina'], 0,
  'Tem mais de 10 mil km² e é uma das maiores atrações turísticas da Bolívia.', 4),
('81783211-0d77-45eb-9444-94b49ec16201', 'As Linhas de Nazca, enormes geoglifos vistos apenas do alto, são um famoso sítio arqueológico de qual país?',
  array['Peru', 'Bolívia', 'Equador', 'Colômbia'], 0,
  'Foram feitas por povos pré-colombianos e são Patrimônio Mundial da UNESCO.', 5);
