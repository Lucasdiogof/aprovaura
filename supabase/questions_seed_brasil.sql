-- Território (e1fc8704-0f8f-40c0-8083-b9830200e2a0)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('e1fc8704-0f8f-40c0-8083-b9830200e2a0', 'Qual é a extensão territorial aproximada do Brasil?',
  array['8,5 milhões de km²', '5,5 milhões de km²', '12 milhões de km²', '3 milhões de km²'], 0,
  'O Brasil tem cerca de 8.510.000 km², sendo o 5º maior país do mundo em área.', 1),
('e1fc8704-0f8f-40c0-8083-b9830200e2a0', 'O Brasil faz fronteira com quantos países da América do Sul?',
  array['10', '7', '12', '5'], 0,
  'O Brasil faz fronteira com todos os países sul-americanos, exceto Chile e Equador.', 2),
('e1fc8704-0f8f-40c0-8083-b9830200e2a0', 'Qual é a posição do Brasil em extensão territorial no mundo?',
  array['5º maior', '2º maior', '8º maior', '3º maior'], 0,
  'Atrás apenas de Rússia, Canadá, China e Estados Unidos.', 3),
('e1fc8704-0f8f-40c0-8083-b9830200e2a0', 'O Brasil está localizado predominantemente em quais hemisférios?',
  array['Sul e Ocidental', 'Norte e Oriental', 'Norte e Ocidental', 'Sul e Oriental'], 0,
  'A maior parte do território brasileiro está abaixo da Linha do Equador e a oeste do Meridiano de Greenwich.', 4),
('e1fc8704-0f8f-40c0-8083-b9830200e2a0', 'Quantos fusos horários oficiais o Brasil possui atualmente?',
  array['4', '2', '3', '6'], 0,
  'Fernando de Noronha (UTC-2), horário de Brasília (UTC-3), Acre e oeste do Amazonas (UTC-4) e ilhas oceânicas.', 5);

-- Relevo (c2ee332a-93df-4032-b968-8d3f4c859250)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('c2ee332a-93df-4032-b968-8d3f4c859250', 'Qual é a maior planície do Brasil?',
  array['Planície Amazônica', 'Planície do Pantanal', 'Planície Costeira', 'Planície do Paraná'], 0,
  'A Planície Amazônica acompanha o rio Amazonas e é a maior planície do território brasileiro.', 1),
('c2ee332a-93df-4032-b968-8d3f4c859250', 'As terras mais antigas do relevo brasileiro, de origem cristalina, são chamadas de?',
  array['Escudos cristalinos', 'Bacias sedimentares', 'Planaltos residuais', 'Depressões periféricas'], 0,
  'Também chamados de maciços antigos, são formações rochosas muito antigas e resistentes à erosão.', 2),
('c2ee332a-93df-4032-b968-8d3f4c859250', 'Qual é o ponto culminante (mais alto) do Brasil?',
  array['Pico da Neblina', 'Pico da Bandeira', 'Pedra da Mina', 'Monte Roraima'], 0,
  'Localizado na Serra do Imeri, no Amazonas, com cerca de 2.995 metros de altitude.', 3),
('c2ee332a-93df-4032-b968-8d3f4c859250', 'A classificação clássica de Aroldo de Azevedo divide o relevo brasileiro principalmente em planaltos e...?',
  array['Planícies', 'Montanhas', 'Chapadas', 'Serras'], 0,
  'Essa classificação, ainda muito usada didaticamente, separa o relevo em planaltos e planícies.', 4),
('c2ee332a-93df-4032-b968-8d3f4c859250', 'O Planalto Central brasileiro está localizado principalmente em qual região?',
  array['Centro-Oeste', 'Sudeste', 'Nordeste', 'Sul'], 0,
  'O Planalto Central abrange boa parte da região Centro-Oeste, incluindo o Distrito Federal.', 5);

-- Biomas e vegetação (421fb392-005c-454f-a735-8c430672cd5e)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('421fb392-005c-454f-a735-8c430672cd5e', 'Quantos biomas oficiais o Brasil possui, segundo o IBGE?',
  array['6', '4', '8', '5'], 0,
  'Amazônia, Cerrado, Mata Atlântica, Caatinga, Pampa e Pantanal.', 1),
('421fb392-005c-454f-a735-8c430672cd5e', 'Qual é o maior bioma brasileiro em extensão territorial?',
  array['Amazônia', 'Cerrado', 'Mata Atlântica', 'Caatinga'], 0,
  'A Amazônia ocupa cerca de 49% do território nacional.', 2),
('421fb392-005c-454f-a735-8c430672cd5e', 'Qual bioma tem vegetação de savana, árvores tortuosas e duas estações climáticas bem definidas?',
  array['Cerrado', 'Caatinga', 'Pampa', 'Mata Atlântica'], 0,
  'O Cerrado tem uma estação seca e uma chuvosa bem marcadas, com vegetação adaptada ao fogo e à seca.', 3),
('421fb392-005c-454f-a735-8c430672cd5e', 'A Caatinga, bioma exclusivamente brasileiro, está concentrada principalmente em qual região?',
  array['Nordeste', 'Norte', 'Sul', 'Sudeste'], 0,
  'É o único bioma que ocorre exclusivamente em território brasileiro, no interior semiárido do Nordeste.', 4),
('421fb392-005c-454f-a735-8c430672cd5e', 'Qual bioma brasileiro, encontrado no Rio Grande do Sul, é caracterizado por campos e vegetação rasteira?',
  array['Pampa', 'Pantanal', 'Cerrado', 'Caatinga'], 0,
  'O Pampa ocupa a metade sul do Rio Grande do Sul, com paisagem de campos abertos.', 5);

-- Clima (1d8e2476-b39c-452a-83ab-dc6b973c000d)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('1d8e2476-b39c-452a-83ab-dc6b973c000d', 'Qual é o tipo climático predominante na região Norte do Brasil?',
  array['Equatorial', 'Tropical', 'Semiárido', 'Subtropical'], 0,
  'Quente e úmido o ano todo, com chuvas abundantes e pouca variação de temperatura.', 1),
('1d8e2476-b39c-452a-83ab-dc6b973c000d', 'Qual região brasileira é a única a apresentar clima subtropical, com possibilidade de geadas?',
  array['Sul', 'Sudeste', 'Nordeste', 'Centro-Oeste'], 0,
  'A região Sul tem estações do ano bem definidas e é a mais fria do país.', 2),
('1d8e2476-b39c-452a-83ab-dc6b973c000d', 'O clima semiárido do sertão nordestino é caracterizado principalmente por?',
  array['Baixos índices pluviométricos e chuvas irregulares', 'Chuvas constantes o ano todo', 'Frio intenso', 'Umidade elevada constante'], 0,
  'A irregularidade das chuvas é o principal fator ligado às secas periódicas na região.', 3),
('1d8e2476-b39c-452a-83ab-dc6b973c000d', 'Qual fator é o principal responsável pelas altas temperaturas médias no Brasil ao longo do ano?',
  array['A localização predominante em baixas latitudes', 'Altitude elevada', 'Proximidade com o polo sul', 'Correntes marítimas frias'], 0,
  'Como a maior parte do território está próxima à Linha do Equador, recebe radiação solar mais intensa.', 4),
('1d8e2476-b39c-452a-83ab-dc6b973c000d', 'As massas de ar tropicais e equatoriais que atuam no Brasil são caracterizadas por serem?',
  array['Quentes e úmidas', 'Frias e secas', 'Frias e úmidas', 'Quentes e secas'], 0,
  'Essas massas trazem calor e umidade, influenciando a maior parte do território nacional.', 5);

-- Cidades (e85aad6a-8b81-41c2-8952-3010f13c5fb8)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('e85aad6a-8b81-41c2-8952-3010f13c5fb8', 'Qual é a cidade mais populosa do Brasil?',
  array['São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador'], 0,
  'São Paulo é, de longe, a cidade mais populosa do país e da América do Sul.', 1),
('e85aad6a-8b81-41c2-8952-3010f13c5fb8', 'Qual é a capital federal do Brasil?',
  array['Brasília', 'Rio de Janeiro', 'São Paulo', 'Salvador'], 0,
  'Brasília foi inaugurada em 1960 como nova capital, planejada por Lúcio Costa e Oscar Niemeyer.', 2),
('e85aad6a-8b81-41c2-8952-3010f13c5fb8', 'Rio de Janeiro foi capital do Brasil até que ano, quando foi substituída por Brasília?',
  array['1960', '1950', '1970', '1945'], 0,
  'A transferência da capital para Brasília ocorreu em 21 de abril de 1960.', 3),
('e85aad6a-8b81-41c2-8952-3010f13c5fb8', 'Qual região metropolitana brasileira é considerada a mais populosa do país?',
  array['São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Fortaleza'], 0,
  'A Região Metropolitana de São Paulo reúne mais de 20 milhões de habitantes.', 4),
('e85aad6a-8b81-41c2-8952-3010f13c5fb8', 'Manaus, uma das maiores cidades da Amazônia, é capital de qual estado?',
  array['Amazonas', 'Pará', 'Acre', 'Rondônia'], 0,
  'Manaus é a capital do estado do Amazonas e principal polo econômico da região.', 5);

-- Geografia humana (17b0d454-779f-4859-8380-470d5e4ddf23)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('17b0d454-779f-4859-8380-470d5e4ddf23', 'Segundo dados do IBGE, em qual região do Brasil está concentrada a maior parte da população?',
  array['Sudeste', 'Nordeste', 'Sul', 'Norte'], 0,
  'A região Sudeste concentra cerca de 40% da população brasileira.', 1),
('17b0d454-779f-4859-8380-470d5e4ddf23', 'O processo de concentração da população em áreas urbanas é chamado de?',
  array['Urbanização', 'Migração', 'Êxodo rural', 'Metropolização'], 0,
  'A urbanização é o crescimento da proporção de pessoas vivendo em cidades em relação ao campo.', 2),
('17b0d454-779f-4859-8380-470d5e4ddf23', 'O movimento migratório de pessoas do campo para a cidade é conhecido como?',
  array['Êxodo rural', 'Urbanização', 'Imigração', 'Emigração'], 0,
  'Foi intenso no Brasil a partir da década de 1950, impulsionado pela industrialização.', 3),
('17b0d454-779f-4859-8380-470d5e4ddf23', 'Qual é considerada a região brasileira com a menor densidade demográfica?',
  array['Norte', 'Nordeste', 'Sul', 'Sudeste'], 0,
  'Apesar de ser a maior região em área, o Norte tem a menor densidade populacional do país.', 4),
('17b0d454-779f-4859-8380-470d5e4ddf23', 'A população brasileira é resultado, sobretudo, de qual processo histórico?',
  array['Miscigenação entre povos indígenas, africanos, europeus e outros', 'Colonização exclusivamente europeia', 'Ocupação exclusivamente indígena', 'Migração exclusivamente africana'], 0,
  'A formação do povo brasileiro envolveu intensa miscigenação ao longo de séculos.', 5);

-- Geografia econômica (3da92cbb-f674-4829-ad98-d346809fcb78)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('3da92cbb-f674-4829-ad98-d346809fcb78', 'Qual é o principal produto agrícola de exportação do Brasil atualmente?',
  array['Soja', 'Café', 'Cana-de-açúcar', 'Milho'], 0,
  'A soja é hoje o principal produto do agronegócio brasileiro em valor exportado.', 1),
('3da92cbb-f674-4829-ad98-d346809fcb78', 'O Brasil é um dos maiores produtores mundiais de qual minério, extraído principalmente em Minas Gerais e no Pará?',
  array['Minério de ferro', 'Ouro', 'Bauxita', 'Carvão'], 0,
  'O Quadrilátero Ferrífero (MG) e a Serra dos Carajás (PA) são as principais regiões produtoras.', 2),
('3da92cbb-f674-4829-ad98-d346809fcb78', 'Qual setor da economia mais contribui para o PIB brasileiro atualmente?',
  array['Serviços', 'Agropecuária', 'Indústria', 'Extrativismo'], 0,
  'O setor de serviços responde pela maior fatia do PIB, como na maioria das economias desenvolvidas e emergentes.', 3),
('3da92cbb-f674-4829-ad98-d346809fcb78', 'A região Sudeste concentra historicamente qual parcela da atividade industrial do país?',
  array['A maior parte', 'Uma parcela pequena', 'Nenhuma atividade', 'Apenas atividades artesanais'], 0,
  'O Sudeste é o principal polo industrial brasileiro desde meados do século XX.', 4),
('3da92cbb-f674-4829-ad98-d346809fcb78', 'O agronegócio brasileiro se destaca mundialmente na exportação de qual proteína animal?',
  array['Carne bovina', 'Carne suína', 'Frutos do mar', 'Carne de cordeiro'], 0,
  'O Brasil é um dos maiores exportadores mundiais de carne bovina.', 5);
