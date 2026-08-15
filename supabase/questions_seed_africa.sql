-- Lagos (83bb1fe7-ca34-46c4-8f12-9dcb0ddb7fa4)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('83bb1fe7-ca34-46c4-8f12-9dcb0ddb7fa4', 'Qual é o maior lago da África em área?',
  array['Lago Vitória', 'Lago Tanganica', 'Lago Malawi', 'Lago Chade'], 0,
  'Tem quase 70 mil km² e é o maior lago tropical do mundo.', 1),
('83bb1fe7-ca34-46c4-8f12-9dcb0ddb7fa4', 'O Lago Vitória faz fronteira com quais três países?',
  array['Tanzânia, Uganda e Quênia', 'Egito, Sudão e Etiópia', 'RD Congo, Zâmbia e Burundi', 'Moçambique, Malawi e Zâmbia'], 0,
  'É compartilhado pelos três países da África Oriental.', 2),
('83bb1fe7-ca34-46c4-8f12-9dcb0ddb7fa4', 'Qual é o lago mais profundo da África, considerado o segundo mais profundo do mundo?',
  array['Lago Tanganica', 'Lago Vitória', 'Lago Chade', 'Lago Nasser'], 0,
  'Atinge cerca de 1.470 metros de profundidade, atrás apenas do Lago Baikal, na Rússia.', 3),
('83bb1fe7-ca34-46c4-8f12-9dcb0ddb7fa4', 'O Lago Tanganica é compartilhado por quantos países?',
  array['4', '2', '6', '3'], 0,
  'Burundi, República Democrática do Congo, Tanzânia e Zâmbia.', 4),
('83bb1fe7-ca34-46c4-8f12-9dcb0ddb7fa4', 'O Lago Vitória é considerado uma das principais fontes de qual grande rio africano?',
  array['Rio Nilo', 'Rio Congo', 'Rio Níger', 'Rio Zambeze'], 0,
  'Alimenta o chamado Nilo Branco, um dos dois principais formadores do Nilo.', 5);

-- Desertos (11e4ec76-57ff-4ea6-9068-7d8cc2f9ecdc)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('11e4ec76-57ff-4ea6-9068-7d8cc2f9ecdc', 'Qual é o maior deserto quente do mundo, localizado no norte da África?',
  array['Saara', 'Kalahari', 'Namib', 'Deserto da Líbia'], 0,
  'Tem cerca de 9,4 milhões de km², quase a área do Brasil.', 1),
('11e4ec76-57ff-4ea6-9068-7d8cc2f9ecdc', 'O deserto do Saara atravessa quantos países africanos?',
  array['10', '5', '15', '3'], 0,
  'Argélia, Chade, Egito, Líbia, Mali, Mauritânia, Marrocos, Níger, Sudão e Tunísia.', 2),
('11e4ec76-57ff-4ea6-9068-7d8cc2f9ecdc', 'O deserto do Kalahari, no sul do continente, é compartilhado entre Botsuana, África do Sul e qual outro país?',
  array['Namíbia', 'Angola', 'Zâmbia', 'Zimbábue'], 0,
  'É o segundo maior deserto africano, com cerca de 600 mil km².', 3),
('11e4ec76-57ff-4ea6-9068-7d8cc2f9ecdc', 'O deserto da Namíbia (Namib) é considerado o deserto mais antigo do mundo, com condições áridas há pelo menos quantos milhões de anos?',
  array['55 milhões', '5 milhões', '500 mil', '150 milhões'], 0,
  'Fica na estreita faixa costeira atlântica da Namíbia.', 4),
('11e4ec76-57ff-4ea6-9068-7d8cc2f9ecdc', 'O que caracteriza climaticamente as regiões desérticas como o Saara e o Kalahari?',
  array['Baixíssimos índices de chuva e grande amplitude térmica', 'Chuvas constantes o ano todo', 'Temperaturas sempre baixas', 'Umidade elevada e neblina frequente'], 0,
  'A escassez de chuva é o principal fator que define um clima desértico.', 5);

-- Relevo (7b96b08c-035a-4cd7-a7b8-e071c3d22d39)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('7b96b08c-035a-4cd7-a7b8-e071c3d22d39', 'Qual é o ponto mais alto da África?',
  array['Monte Kilimanjaro', 'Monte Quênia', 'Monte Elgon', 'Montanhas Drakensberg'], 0,
  'Fica na Tanzânia, próximo à fronteira com o Quênia, com quase 5.900 m.', 1),
('7b96b08c-035a-4cd7-a7b8-e071c3d22d39', 'O Monte Kilimanjaro apresenta qual característica notável, mesmo estando perto do Equador?',
  array['Neve e gelo no topo', 'Vegetação de deserto', 'Clima extremamente úmido', 'Ausência total de vegetação'], 0,
  'Sua grande altitude permite temperaturas baixas o suficiente para manter gelo, apesar da proximidade com o Equador.', 2),
('7b96b08c-035a-4cd7-a7b8-e071c3d22d39', 'O Grande Vale do Rift, uma das maiores fraturas geológicas do planeta, atravessa principalmente qual região?',
  array['África Oriental', 'África Ocidental', 'Norte da África', 'África Central'], 0,
  'É formado pelo afastamento de placas tectônicas, criando vales profundos e vulcões.', 3),
('7b96b08c-035a-4cd7-a7b8-e071c3d22d39', 'Qual é a altitude aproximada do Monte Kilimanjaro?',
  array['Quase 5.900 metros', 'Cerca de 3.000 metros', 'Cerca de 8.000 metros', 'Quase 4.500 metros'], 0,
  'É a montanha isolada mais alta do mundo, elevando-se sozinha das planícies ao redor.', 4),
('7b96b08c-035a-4cd7-a7b8-e071c3d22d39', 'Por que a África é frequentemente descrita como o "continente dos planaltos"?',
  array['Porque grande parte de seu relevo é formado por superfícies elevadas e relativamente planas', 'Porque não existem planícies no continente', 'Porque é totalmente coberta por montanhas', 'Porque fica inteiramente abaixo do nível do mar'], 0,
  'Diferente de outros continentes, a África tem poucas grandes cadeias de montanhas e vastas áreas de planalto.', 5);

-- Regiões africanas (4764c0da-a7f1-4cea-a2f9-25a32420095e)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('4764c0da-a7f1-4cea-a2f9-25a32420095e', 'Em quantas grandes regiões a África é tradicionalmente dividida pela geografia?',
  array['5', '3', '8', '10'], 0,
  'Norte, Ocidental, Oriental, Central e Austral (Sul).', 1),
('4764c0da-a7f1-4cea-a2f9-25a32420095e', 'Qual região da África é marcada predominantemente pelo deserto do Saara e por países de maioria árabe?',
  array['África do Norte', 'África Ocidental', 'África Central', 'África Austral'], 0,
  'Inclui países como Egito, Líbia, Argélia, Marrocos e Tunísia.', 2),
('4764c0da-a7f1-4cea-a2f9-25a32420095e', 'A região da África Austral inclui qual país considerado a maior economia do continente?',
  array['África do Sul', 'Nigéria', 'Egito', 'Angola'], 0,
  'A África do Sul é historicamente a economia mais industrializada e diversificada da África.', 3),
('4764c0da-a7f1-4cea-a2f9-25a32420095e', 'As fronteiras de muitos países da África Ocidental têm origem em qual processo histórico?',
  array['A colonização europeia, que traçou fronteiras muitas vezes sem considerar os povos locais', 'Acordos comerciais recentes entre países vizinhos', 'Divisões naturais causadas por grandes rios', 'Tratados assinados após a independência'], 0,
  'As fronteiras coloniais frequentemente dividiram grupos étnicos e uniram povos diferentes num mesmo país.', 4),
('4764c0da-a7f1-4cea-a2f9-25a32420095e', 'Qual região concentra o chamado "Chifre da África", que inclui países como Etiópia e Somália?',
  array['África Oriental', 'África Ocidental', 'África Central', 'África do Norte'], 0,
  'É uma península no nordeste do continente, de grande importância geopolítica.', 5);
