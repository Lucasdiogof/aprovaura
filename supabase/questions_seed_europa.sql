-- Lagos e mares (024a3408-7afd-4ae5-87a7-d01e94a4cc5d)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('024a3408-7afd-4ae5-87a7-d01e94a4cc5d', 'Qual é o maior lago inteiramente europeu, localizado no noroeste da Rússia?',
  array['Lago Ladoga', 'Lago Baikal', 'Lago Balaton', 'Lago Genebra'], 0,
  'Fica próximo a São Petersburgo e tem quase 18 mil km².', 1),
('024a3408-7afd-4ae5-87a7-d01e94a4cc5d', 'O Mar Mediterrâneo separa a Europa de quais outros dois continentes?',
  array['África e Ásia', 'América e África', 'Ásia e Oceania', 'Apenas da África'], 0,
  'É um mar intercontinental cercado por três continentes.', 2),
('024a3408-7afd-4ae5-87a7-d01e94a4cc5d', 'Veneza, cidade italiana famosa por seus canais, foi construída sobre uma lagoa às margens de qual mar?',
  array['Mar Adriático', 'Mar Tirreno', 'Mar Egeu', 'Mar Jônico'], 0,
  'A Lagoa de Veneza fica na costa nordeste da Itália.', 3),
('024a3408-7afd-4ae5-87a7-d01e94a4cc5d', 'O Mar Báltico é cercado principalmente por países do norte e centro da Europa, como Suécia, Finlândia e?',
  array['Alemanha', 'Espanha', 'Itália', 'Portugal'], 0,
  'O Báltico também banha a Polônia, os países bálticos e a Rússia.', 4),
('024a3408-7afd-4ae5-87a7-d01e94a4cc5d', 'O Estreito de Gibraltar liga o Oceano Atlântico a qual mar?',
  array['Mar Mediterrâneo', 'Mar do Norte', 'Mar Báltico', 'Mar Negro'], 0,
  'Separa a Espanha, na Europa, de Marrocos, na África.', 5);

-- Montanhas e cordilheiras (39cd3699-9134-4ae4-a810-bf5854cc893e)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('39cd3699-9134-4ae4-a810-bf5854cc893e', 'Qual é a principal cordilheira da Europa Ocidental, entre França, Itália e Suíça?',
  array['Alpes', 'Pirenéus', 'Cárpatos', 'Apeninos'], 0,
  'É uma das cadeias montanhosas mais famosas do mundo, com grande importância turística.', 1),
('39cd3699-9134-4ae4-a810-bf5854cc893e', 'Qual é o ponto mais alto dos Alpes?',
  array['Monte Branco (Mont Blanc)', 'Matterhorn', 'Monte Rosa', 'Grande Jorasses'], 0,
  'Fica na fronteira entre França e Itália, com 4.808 metros de altitude.', 2),
('39cd3699-9134-4ae4-a810-bf5854cc893e', 'O Monte Elbrus, considerado o ponto mais alto de toda a Europa, está localizado em qual cordilheira?',
  array['Cáucaso', 'Alpes', 'Montes Urais', 'Cárpatos'], 0,
  'Fica no sul da Rússia, próximo à fronteira com a Geórgia, com 5.642 metros.', 3),
('39cd3699-9134-4ae4-a810-bf5854cc893e', 'Os Montes Cárpatos formam um grande arco montanhoso que atravessa principalmente qual região da Europa?',
  array['Europa Central e Oriental', 'Europa Ocidental', 'Europa Nórdica', 'Sul da Europa'], 0,
  'Passam por países como República Tcheca, Eslováquia, Polônia, Ucrânia e Romênia.', 4),
('39cd3699-9134-4ae4-a810-bf5854cc893e', 'Os Montes Urais, que também marcam o limite entre Europa e Ásia, ficam majoritariamente em qual país?',
  array['Rússia', 'Cazaquistão', 'Ucrânia', 'Finlândia'], 0,
  'Cortam o território russo de norte a sul.', 5);

-- Regiões (317fe9ba-4cc0-45be-8f55-89b8ac9f951d)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('317fe9ba-4cc0-45be-8f55-89b8ac9f951d', 'Qual região da Europa inclui países como Suécia, Noruega, Finlândia e Dinamarca?',
  array['Europa Nórdica (Escandinávia)', 'Europa Balcânica', 'Europa Ocidental', 'Europa Mediterrânea'], 0,
  'Esses países compartilham características climáticas, históricas e culturais.', 1),
('317fe9ba-4cc0-45be-8f55-89b8ac9f951d', 'Qual região da Europa foi historicamente marcada pela influência soviética durante a Guerra Fria?',
  array['Europa Oriental', 'Europa Ocidental', 'Europa Nórdica', 'Sul da Europa'], 0,
  'Países como Polônia, Hungria e Romênia ficaram sob influência da URSS até 1989-1991.', 2),
('317fe9ba-4cc0-45be-8f55-89b8ac9f951d', 'Os países da Europa Mediterrânea, como Itália, Espanha e Grécia, têm em comum qual característica climática?',
  array['Clima mediterrâneo, com verões secos e invernos amenos', 'Clima polar, com neve o ano todo', 'Clima equatorial, quente e úmido', 'Clima desértico, extremamente seco'], 0,
  'É um dos tipos climáticos mais distintos e reconhecíveis do mundo.', 3),
('317fe9ba-4cc0-45be-8f55-89b8ac9f951d', 'Qual região da Europa é conhecida por abrigar os países dos Bálcãs, marcados por grande diversidade étnica?',
  array['Europa Balcânica (Sudeste Europeu)', 'Europa Ocidental', 'Europa Nórdica', 'Europa Central'], 0,
  'Inclui países como Sérvia, Croácia, Bósnia e Herzegovina e Albânia.', 4),
('317fe9ba-4cc0-45be-8f55-89b8ac9f951d', 'A Europa Ocidental é tradicionalmente associada a qual característica econômica, em comparação com boa parte da Europa Oriental?',
  array['Maior industrialização histórica e economias mais desenvolvidas', 'Total ausência de indústrias', 'Economia baseada exclusivamente na agricultura', 'Isolamento total do comércio internacional'], 0,
  'Países como França, Alemanha e Reino Unido lideraram a industrialização europeia.', 5);

-- Geografia histórica (cfe523b9-6edd-4b76-85ac-76bcbf1b49ba)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('cfe523b9-6edd-4b76-85ac-76bcbf1b49ba', 'A "Cortina de Ferro", termo usado durante a Guerra Fria, dividia a Europa em blocos liderados por quais duas potências?',
  array['Estados Unidos e União Soviética', 'França e Alemanha', 'Reino Unido e Rússia', 'Estados Unidos e China'], 0,
  'A expressão foi popularizada por Winston Churchill em 1946.', 1),
('cfe523b9-6edd-4b76-85ac-76bcbf1b49ba', 'Em que ano caiu o Muro de Berlim, símbolo da divisão da Alemanha durante a Guerra Fria?',
  array['1989', '1991', '1975', '1961'], 0,
  'A queda do muro foi seguida pela reunificação alemã em 1990.', 2),
('cfe523b9-6edd-4b76-85ac-76bcbf1b49ba', 'O Tratado de Maastricht, que criou oficialmente a União Europeia, foi assinado em que ano?',
  array['1992', '1957', '2000', '1985'], 0,
  'O tratado entrou em vigor em 1993, formalizando o bloco europeu como o conhecemos hoje.', 3),
('cfe523b9-6edd-4b76-85ac-76bcbf1b49ba', 'O Império Romano, uma das maiores civilizações da história europeia, teve sua capital em qual cidade?',
  array['Roma', 'Atenas', 'Constantinopla', 'Cartago'], 0,
  'Roma foi o centro político do império por séculos, antes da divisão em Império Romano do Oriente e do Ocidente.', 4),
('cfe523b9-6edd-4b76-85ac-76bcbf1b49ba', 'Qual país surgiu como um novo Estado independente após a dissolução da União Soviética, em 1991?',
  array['Ucrânia', 'Polônia', 'Alemanha', 'Grécia'], 0,
  'A Ucrânia, junto com outras repúblicas soviéticas, tornou-se independente com o fim da URSS.', 5);

-- Pontos turísticos (a68d37cf-fbfd-421f-b4ee-0345138f868c)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('a68d37cf-fbfd-421f-b4ee-0345138f868c', 'A Torre Eiffel, um dos monumentos mais visitados do mundo, está localizada em qual cidade?',
  array['Paris', 'Londres', 'Roma', 'Madrid'], 0,
  'Foi construída em 1889 para a Exposição Universal de Paris.', 1),
('a68d37cf-fbfd-421f-b4ee-0345138f868c', 'O Coliseu, anfiteatro da Roma Antiga, está localizado em qual país?',
  array['Itália', 'Grécia', 'França', 'Espanha'], 0,
  'É um dos monumentos mais icônicos do Império Romano.', 2),
('a68d37cf-fbfd-421f-b4ee-0345138f868c', 'A Torre de Pisa, famosa por sua inclinação, fica em qual país?',
  array['Itália', 'Espanha', 'Portugal', 'Grécia'], 0,
  'A inclinação começou ainda durante sua construção, devido ao solo instável.', 3),
('a68d37cf-fbfd-421f-b4ee-0345138f868c', 'O "Big Ben", símbolo de Londres, é na verdade o nome de qual elemento da torre do Parlamento britânico?',
  array['O sino', 'O relógio', 'A torre inteira', 'O ponteiro das horas'], 0,
  'A torre em si se chama Elizabeth Tower; "Big Ben" é o apelido do grande sino.', 4),
('a68d37cf-fbfd-421f-b4ee-0345138f868c', 'A Sagrada Família, obra inacabada do arquiteto Gaudí, está localizada em qual cidade espanhola?',
  array['Barcelona', 'Madrid', 'Sevilha', 'Valência'], 0,
  'A construção começou em 1882 e segue em andamento até hoje.', 5);
