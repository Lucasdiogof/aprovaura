-- Mares (6f5b44f6-3f1f-462f-a9e3-c34c2c8b0620)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('6f5b44f6-3f1f-462f-a9e3-c34c2c8b0620', 'Qual é o maior lago do mundo, chamado de "mar" e localizado entre a Europa e a Ásia?',
  array['Mar Cáspio', 'Mar de Aral', 'Mar Negro', 'Mar Morto'], 0,
  'Apesar do nome, é tecnicamente um lago, com quase 400 mil km² e costa em cinco países.', 1),
('6f5b44f6-3f1f-462f-a9e3-c34c2c8b0620', 'O Mar Vermelho separa a Península Arábica de qual continente?',
  array['África', 'Europa', 'Oceania', 'América'], 0,
  'É uma importante rota marítima que liga o Mediterrâneo ao Oceano Índico via Canal de Suez.', 2),
('6f5b44f6-3f1f-462f-a9e3-c34c2c8b0620', 'O Mar Morto faz fronteira com Israel, a Cisjordânia e qual outro país?',
  array['Jordânia', 'Egito', 'Síria', 'Líbano'], 0,
  'É conhecido por sua altíssima salinidade, que permite flutuar facilmente na água.', 3),
('6f5b44f6-3f1f-462f-a9e3-c34c2c8b0620', 'Além da alta salinidade, o que torna o Mar Morto único no mundo?',
  array['É o ponto mais baixo da superfície terrestre', 'É o mar mais quente do planeta', 'É o único mar sem nenhuma vida aquática comprovada', 'É o mar mais profundo do mundo'], 0,
  'Suas margens estão a cerca de 430 metros abaixo do nível do mar.', 4),
('6f5b44f6-3f1f-462f-a9e3-c34c2c8b0620', 'Quais países têm costa no Mar Cáspio?',
  array['Cazaquistão, Rússia, Irã, Turcomenistão e Azerbaijão', 'China, Mongólia e Rússia', 'Índia, Paquistão e Irã', 'Turquia, Grécia e Bulgária'], 0,
  'Esses cinco países compartilham suas águas ricas em petróleo e gás natural.', 5);

-- Cordilheiras (f9ddd491-8916-4c61-89ec-55ef3394ede1)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('f9ddd491-8916-4c61-89ec-55ef3394ede1', 'Qual é a maior cordilheira do mundo em altitude média, localizada na Ásia?',
  array['Himalaia', 'Montes Urais', 'Cordilheira do Cáucaso', 'Montes Altai'], 0,
  'Abriga os picos mais altos do planeta, incluindo o Monte Everest.', 1),
('f9ddd491-8916-4c61-89ec-55ef3394ede1', 'O Monte Everest, ponto mais alto do mundo, fica na fronteira entre quais dois territórios?',
  array['Nepal e China (Tibete)', 'Índia e Paquistão', 'Butão e Índia', 'China e Mongólia'], 0,
  'Tem 8.848,86 metros de altitude, na subcordilheira Mahalangur Himal.', 2),
('f9ddd491-8916-4c61-89ec-55ef3394ede1', 'A cordilheira do Himalaia foi formada pela colisão de quais duas placas tectônicas?',
  array['Placa Indiana e Placa Eurasiática', 'Placa Africana e Placa Euroasiática', 'Placa do Pacífico e Placa Norte-Americana', 'Placa Sul-Americana e Placa de Nazca'], 0,
  'A colisão, iniciada há dezenas de milhões de anos, continua elevando as montanhas até hoje.', 3),
('f9ddd491-8916-4c61-89ec-55ef3394ede1', 'Qual cordilheira é tradicionalmente considerada o limite natural entre a Europa e a Ásia?',
  array['Montes Urais', 'Himalaia', 'Montes Altai', 'Cárpatos'], 0,
  'Fica majoritariamente na Rússia, cortando o continente de norte a sul.', 4),
('f9ddd491-8916-4c61-89ec-55ef3394ede1', 'O planalto do Tibete, conhecido como "Teto do Mundo", está associado a qual grande cordilheira?',
  array['Himalaia', 'Montes Urais', 'Cordilheira do Cáucaso', 'Montes Zagros'], 0,
  'É o planalto mais alto e extenso do planeta, com média de mais de 4.500 m de altitude.', 5);

-- Desertos (4aaed524-89fd-452f-bfd3-b85e6ba7bbcd)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('4aaed524-89fd-452f-bfd3-b85e6ba7bbcd', 'Qual deserto ocupa grande parte da Mongólia e do norte da China, conhecido por seu clima frio?',
  array['Deserto de Gobi', 'Rub al-Khali', 'Deserto de Thar', 'Deserto de Karakum'], 0,
  'Diferente da maioria dos desertos, o Gobi tem invernos extremamente rigorosos.', 1),
('4aaed524-89fd-452f-bfd3-b85e6ba7bbcd', 'O Rub al-Khali, uma das maiores áreas contínuas de areia do mundo, está localizado em qual região?',
  array['Península Arábica', 'Ásia Central', 'Sul da Índia', 'Norte da China'], 0,
  'Abrange partes da Arábia Saudita, Omã, Emirados Árabes Unidos e Iêmen.', 2),
('4aaed524-89fd-452f-bfd3-b85e6ba7bbcd', 'O nome "Rub al-Khali" significa, em árabe, algo como?',
  array['Quarto vazio', 'Mar de areia', 'Terra sem fim', 'Vale seco'], 0,
  'Uma referência à vastidão praticamente desabitada da região.', 3),
('4aaed524-89fd-452f-bfd3-b85e6ba7bbcd', 'Diferente da maioria dos desertos quentes, o que caracteriza o clima do deserto de Gobi?',
  array['Grandes variações de temperatura, com invernos muito frios', 'Chuvas constantes durante todo o ano', 'Umidade elevada o ano todo', 'Ausência total de estações do ano'], 0,
  'As temperaturas podem variar drasticamente entre o dia e a noite, e entre verão e inverno.', 4),
('4aaed524-89fd-452f-bfd3-b85e6ba7bbcd', 'Os desertos da Ásia, como o Gobi e o da Arábia, têm em comum qual característica climática básica?',
  array['Baixíssimos índices de precipitação', 'Chuvas abundantes o ano todo', 'Temperaturas sempre estáveis', 'Umidade relativa muito alta'], 0,
  'A escassez de chuva é o que define um clima desértico, independente da temperatura.', 5);

-- Oriente Médio (54e2d513-1aca-4dcb-919c-c701ae13b47b)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('54e2d513-1aca-4dcb-919c-c701ae13b47b', 'Qual é o principal produto de exportação da maioria dos países do Oriente Médio?',
  array['Petróleo', 'Café', 'Trigo', 'Algodão'], 0,
  'A região concentra algumas das maiores reservas de petróleo do mundo.', 1),
('54e2d513-1aca-4dcb-919c-c701ae13b47b', 'Qual país do Oriente Médio não é árabe e tem maioria da população judaica?',
  array['Israel', 'Líbano', 'Jordânia', 'Síria'], 0,
  'Israel se diferencia culturalmente da maior parte de seus vizinhos na região.', 2),
('54e2d513-1aca-4dcb-919c-c701ae13b47b', 'O Estreito de Ormuz, importante rota de transporte de petróleo, liga o Golfo Pérsico a qual outro corpo d’água?',
  array['Golfo de Omã', 'Mar Vermelho', 'Mar Cáspio', 'Mar Mediterrâneo'], 0,
  'É uma das passagens marítimas mais estratégicas do mundo para o comércio de petróleo.', 3),
('54e2d513-1aca-4dcb-919c-c701ae13b47b', 'Qual país é considerado transcontinental, com território tanto na Ásia quanto na Europa?',
  array['Turquia', 'Irã', 'Iraque', 'Arábia Saudita'], 0,
  'O Estreito de Bósforo, em Istambul, é o limite entre as porções asiática e europeia do país.', 4),
('54e2d513-1aca-4dcb-919c-c701ae13b47b', 'Qual religião é predominante na maioria dos países do Oriente Médio?',
  array['Islamismo', 'Cristianismo', 'Judaísmo', 'Budismo'], 0,
  'A região é o berço histórico do Islã.', 5);

-- Sudeste Asiático (ed3c676d-d6e4-45e7-937b-c3e4178be67e)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('ed3c676d-d6e4-45e7-937b-c3e4178be67e', 'Qual é o país mais populoso do Sudeste Asiático?',
  array['Indonésia', 'Filipinas', 'Vietnã', 'Tailândia'], 0,
  'A Indonésia é também o quarto país mais populoso do mundo.', 1),
('ed3c676d-d6e4-45e7-937b-c3e4178be67e', 'A Indonésia é formada por milhares de ilhas, sendo o maior país arquipelágico do mundo. Aproximadamente quantas ilhas ela possui?',
  array['Mais de 17 mil', 'Cerca de mil', 'Cerca de 500', 'Mais de 50 mil'], 0,
  'Isso faz da Indonésia o maior arquipélago do mundo formado por um único país.', 2),
('ed3c676d-d6e4-45e7-937b-c3e4178be67e', 'Qual país do Sudeste Asiático nunca foi colonizado por potências europeias?',
  array['Tailândia', 'Vietnã', 'Filipinas', 'Indonésia'], 0,
  'A Tailândia (antigo Sião) serviu como zona-tampão entre a Birmânia britânica e a Indochina francesa.', 3),
('ed3c676d-d6e4-45e7-937b-c3e4178be67e', 'O Sudeste Asiático é dividido entre uma porção continental e uma insular. A qual delas pertence a Indonésia?',
  array['Porção insular', 'Porção continental', 'Nenhuma das duas', 'Ambas igualmente'], 0,
  'A Indonésia é formada inteiramente por ilhas, ao contrário de países como Tailândia e Vietnã.', 4),
('ed3c676d-d6e4-45e7-937b-c3e4178be67e', 'Como se chama a organização regional que reúne os países do Sudeste Asiático para cooperação econômica e política?',
  array['ASEAN', 'União Europeia', 'Mercosul', 'OPEP'], 0,
  'A Associação de Nações do Sudeste Asiático foi fundada em 1967.', 5);

-- Sul da Ásia (0610487b-0326-483f-9176-e0f3e54f5b12)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('0610487b-0326-483f-9176-e0f3e54f5b12', 'Qual é o país mais populoso do Sul da Ásia, e um dos mais populosos do mundo?',
  array['Índia', 'Paquistão', 'Bangladesh', 'Nepal'], 0,
  'A Índia é hoje o país mais populoso do planeta.', 1),
('0610487b-0326-483f-9176-e0f3e54f5b12', 'A Cordilheira do Himalaia forma uma barreira natural entre o Sul da Ásia e qual outra grande região?',
  array['O Planalto do Tibete (China)', 'A Ásia Central', 'O Sudeste Asiático', 'O Oriente Médio'], 0,
  'O Himalaia separa o subcontinente indiano do planalto tibetano.', 2),
('0610487b-0326-483f-9176-e0f3e54f5b12', 'Qual religião tem origem no Sul da Ásia e é predominante na Índia?',
  array['Hinduísmo', 'Islamismo', 'Budismo', 'Cristianismo'], 0,
  'O Hinduísmo é uma das religiões mais antigas do mundo, originada na região.', 3),
('0610487b-0326-483f-9176-e0f3e54f5b12', 'Índia e Paquistão mantêm uma disputa territorial histórica sobre qual região?',
  array['Caxemira', 'Punjab', 'Bengala', 'Sindh'], 0,
  'A disputa pela Caxemira é uma das mais antigas e tensas do mundo.', 4),
('0610487b-0326-483f-9176-e0f3e54f5b12', 'Bangladesh, um dos países mais densamente povoados do mundo, ocupa majoritariamente qual tipo de terreno?',
  array['Um extenso delta de rios', 'Um planalto elevado', 'Uma cadeia de montanhas', 'Um deserto árido'], 0,
  'O delta dos rios Ganges e Brahmaputra torna o país muito fértil, mas vulnerável a enchentes.', 5);

-- Ásia Central (a27dfbf2-4b16-442c-a302-7a47d7eae57a)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('a27dfbf2-4b16-442c-a302-7a47d7eae57a', 'Quantos países formam a região da Ásia Central?',
  array['5', '3', '7', '4'], 0,
  'Cazaquistão, Uzbequistão, Turcomenistão, Quirguistão e Tajiquistão.', 1),
('a27dfbf2-4b16-442c-a302-7a47d7eae57a', 'A Ásia Central era, até 1991, formada por repúblicas de qual país?',
  array['União Soviética', 'Império Otomano', 'China', 'Império Persa'], 0,
  'Todos os cinco países se tornaram independentes com a dissolução da URSS.', 2),
('a27dfbf2-4b16-442c-a302-7a47d7eae57a', 'A Ásia Central fez parte de qual grande rota histórica de comércio entre a Ásia e a Europa?',
  array['Rota da Seda', 'Rota das Especiarias', 'Rota do Âmbar', 'Rota do Incenso'], 0,
  'A região conectava a China ao Mediterrâneo, sendo essencial para o comércio antigo.', 3),
('a27dfbf2-4b16-442c-a302-7a47d7eae57a', 'O Cazaquistão, maior país da Ásia Central, também é conhecido por qual característica geográfica rara?',
  array['É o maior país do mundo sem litoral', 'Fica inteiramente abaixo do nível do mar', 'É o país mais ao norte da Ásia', 'Não possui nenhum deserto'], 0,
  'Apesar do tamanho, o Cazaquistão não tem acesso direto a um oceano.', 4),
('a27dfbf2-4b16-442c-a302-7a47d7eae57a', 'Grande parte da Ásia Central é caracterizada por qual tipo de clima?',
  array['Continental/árido, com grande amplitude térmica', 'Equatorial, quente e úmido', 'Polar, extremamente frio o ano todo', 'Tropical, com chuvas constantes'], 0,
  'A distância do mar contribui para grandes variações de temperatura entre estações.', 5);
