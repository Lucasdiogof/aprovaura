-- Goias > Rios: conteudo das 6 folhas de rios (estavam vazias).
-- Resolve os node ids por titulo+pai (sao gerados dinamicamente no catalog_seed).
-- Idempotente: apaga as questoes desses nos antes de reinserir.

do $$
declare
  v_goias uuid := (select id from catalog_nodes
                   where subject = 'geografia' and title = 'Goiás' limit 1);
  v_rios uuid := (select id from catalog_nodes
                  where subject = 'geografia' and title = 'Rios' and parent_id = v_goias);
  v_araguaia uuid := (select id from catalog_nodes where title = 'Rio Araguaia'  and parent_id = v_rios);
  v_paranaiba uuid := (select id from catalog_nodes where title = 'Rio Paranaíba' and parent_id = v_rios);
  v_meia uuid := (select id from catalog_nodes where title = 'Rio Meia Ponte'     and parent_id = v_rios);
  v_corumba uuid := (select id from catalog_nodes where title = 'Rio Corumbá'     and parent_id = v_rios);
  v_almas uuid := (select id from catalog_nodes where title = 'Rio das Almas'     and parent_id = v_rios);
  v_vermelho uuid := (select id from catalog_nodes where title = 'Rio Vermelho'   and parent_id = v_rios);
begin
  delete from questions where catalog_node_id in
    (v_araguaia, v_paranaiba, v_meia, v_corumba, v_almas, v_vermelho);

  insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty) values

  -- Rio Araguaia
  (v_araguaia, 'O Rio Araguaia forma trechos da divisa natural de Goiás com quais estados?',
   array['Mato Grosso e Tocantins', 'Bahia e Minas Gerais', 'Mato Grosso do Sul e Sao Paulo', 'Para e Maranhao'], 0,
   'O Araguaia separa Goias de Mato Grosso (a oeste) e do Tocantins (ao norte).', 1, 'facil'),
  (v_araguaia, 'A qual grande bacia hidrografica pertence o Rio Araguaia?',
   array['Bacia do Sao Francisco', 'Bacia do Parana', 'Bacia Tocantins-Araguaia', 'Bacia Amazonica'], 2,
   'O Araguaia e um dos principais rios da bacia Tocantins-Araguaia.', 2, 'medio'),
  (v_araguaia, 'No periodo de seca, o Araguaia e famoso por um fenomeno que atrai turismo, sobretudo na cidade goiana de Aruana. Que fenomeno e esse?',
   array['O congelamento das margens', 'A formacao de extensas praias fluviais de areia branca', 'O desaparecimento total do leito', 'A inversao do sentido da correnteza'], 1,
   'Na estiagem, o nivel baixa e surgem grandes praias de areia, como as de Aruana.', 3, 'medio'),
  (v_araguaia, 'O Rio Vermelho, que passa pela Cidade de Goias, deságua em qual rio?',
   array['No Rio Araguaia', 'No Rio Sao Francisco', 'No Rio Meia Ponte', 'No Rio Parana'], 0,
   'O Rio Vermelho e afluente do Araguaia, dentro da bacia Tocantins-Araguaia.', 4, 'medio'),

  -- Rio Paranaiba
  (v_paranaiba, 'O Rio Paranaiba forma a divisa de Goias principalmente com quais estados?',
   array['Tocantins e Bahia', 'Minas Gerais e Mato Grosso do Sul', 'Mato Grosso e Para', 'Sao Paulo e Parana'], 1,
   'O Paranaiba separa Goias de Minas Gerais (a leste/sul) e do Mato Grosso do Sul (a sudoeste).', 1, 'facil'),
  (v_paranaiba, 'O Rio Paranaiba pertence a qual bacia hidrografica?',
   array['Bacia Tocantins-Araguaia', 'Bacia Amazonica', 'Bacia do Parana', 'Bacia do Sao Francisco'], 2,
   'O Paranaiba integra a bacia do Parana (bacia do Prata).', 2, 'medio'),
  (v_paranaiba, 'Ao se encontrar com o Rio Grande, o Rio Paranaiba da origem a qual rio?',
   array['Rio Parana', 'Rio Tocantins', 'Rio Araguaia', 'Rio Paraguai'], 0,
   'A juncao do Paranaiba com o Rio Grande forma o Rio Parana.', 3, 'dificil'),
  (v_paranaiba, 'O curso do Rio Paranaiba se destaca economicamente, sobretudo, pela presenca de:',
   array['Grandes usinas hidreletricas, como Itumbiara e Sao Simao', 'Geleiras usadas para turismo', 'Portos de navios oceanicos', 'Minas de carvao mineral no leito'], 0,
   'O Paranaiba e muito aproveitado para geracao de energia, com usinas como Itumbiara, Cachoeira Dourada e Sao Simao.', 4, 'medio'),

  -- Rio Meia Ponte
  (v_meia, 'O Rio Meia Ponte e o principal rio que corta qual cidade goiana?',
   array['Anapolis', 'Goiania', 'Rio Verde', 'Catalao'], 1,
   'O Meia Ponte atravessa a regiao de Goiania, capital do estado.', 1, 'facil'),
  (v_meia, 'Qual e um dos principais problemas ambientais associados ao Rio Meia Ponte?',
   array['Excesso de gelo nas margens', 'Elevado grau de poluicao por esgoto e ocupacao urbana', 'Salinizacao por agua do mar', 'Ausencia completa de vida aquatica desde a nascente'], 1,
   'Por atravessar a area metropolitana de Goiania, o Meia Ponte sofre com lancamento de esgoto e degradacao.', 2, 'medio'),
  (v_meia, 'O Rio Meia Ponte e afluente de qual rio maior?',
   array['Rio Araguaia', 'Rio Tocantins', 'Rio Paranaiba', 'Rio Sao Francisco'], 2,
   'O Meia Ponte desagua no Paranaiba, integrando a bacia do Parana.', 3, 'medio'),
  (v_meia, 'Alem da importancia ambiental, o Rio Meia Ponte e estrategico para a Regiao Metropolitana de Goiania porque:',
   array['Participa do abastecimento de agua da regiao', 'E uma rota de navios de carga', 'Serve de fronteira internacional', 'Abriga a maior geleira do Brasil'], 0,
   'O Meia Ponte e uma das fontes de agua para o abastecimento da regiao metropolitana.', 4, 'medio'),

  -- Rio Corumba
  (v_corumba, 'O Rio Corumba e afluente de qual rio, integrando a bacia do Parana?',
   array['Rio Araguaia', 'Rio Paranaiba', 'Rio Tocantins', 'Rio Sao Francisco'], 1,
   'O Corumba desagua no Paranaiba, dentro da bacia do Parana.', 1, 'medio'),
  (v_corumba, 'No Rio Corumba localiza-se um importante aproveitamento energetico. Qual?',
   array['A Usina Hidreletrica de Corumba', 'A Usina Nuclear de Corumba', 'O Porto de Corumba', 'A Represa do Castanhao'], 0,
   'O Corumba abriga usinas hidreletricas, com destaque para a UHE Corumba.', 2, 'medio'),
  (v_corumba, 'A regiao banhada pelo Rio Corumba fica proxima a qual destino goiano conhecido por suas aguas termais?',
   array['Caldas Novas', 'Pirenopolis', 'Chapada dos Veadeiros', 'Cidade de Goias'], 0,
   'A regiao do Corumba, no sul goiano, esta proxima de Caldas Novas, famosa pelas aguas termais.', 3, 'medio'),

  -- Rio das Almas
  (v_almas, 'Diferentemente do Meia Ponte (bacia do Parana), o Rio das Almas corre para qual bacia?',
   array['Bacia do Sao Francisco', 'Bacia Tocantins-Araguaia', 'Bacia do Parana', 'Bacia do Uruguai'], 1,
   'O Rio das Almas pertence a bacia Tocantins-Araguaia; junto ao Rio Maranhao ajuda a formar o Rio Tocantins.', 1, 'dificil'),
  (v_almas, 'O Rio das Almas banha o norte goiano, passando por regioes de municipios como:',
   array['Goianesia, Barro Alto e Niquelandia', 'Rio Verde e Jatai', 'Catalao e Ipameri', 'Aparecida de Goiania e Trindade'], 0,
   'O das Almas percorre o norte do estado, proximo a Goianesia, Barro Alto e Niquelandia.', 2, 'medio'),
  (v_almas, 'O nome do Rio das Almas aparece ligado a historia de povoamento do:',
   array['Litoral goiano', 'Norte/centro de Goias, regiao de mineracao antiga', 'Pantanal goiano', 'Sertao nordestino'], 1,
   'O das Almas corta o centro-norte goiano, area ligada a antiga mineracao e ao povoamento colonial.', 3, 'medio'),

  -- Rio Vermelho
  (v_vermelho, 'O Rio Vermelho banha qual cidade historica goiana, antiga capital do estado?',
   array['Cidade de Goias (Goias Velho)', 'Pirenopolis', 'Corumba de Goias', 'Cristalina'], 0,
   'O Rio Vermelho atravessa a Cidade de Goias, primeira capital do estado e patrimonio historico.', 1, 'facil'),
  (v_vermelho, 'Em 2001, o Rio Vermelho ficou marcado por qual evento na Cidade de Goias?',
   array['Uma seca que secou totalmente o leito', 'Uma grande enchente que atingiu o centro historico', 'A construcao de uma usina nuclear', 'A descoberta de petroleo'], 1,
   'A enchente de 2001 invadiu o centro historico da Cidade de Goias, causando grandes danos ao patrimonio.', 2, 'dificil'),
  (v_vermelho, 'O Rio Vermelho pertence a mesma bacia de qual grande rio goiano, do qual e afluente?',
   array['Rio Paranaiba', 'Rio Araguaia', 'Rio Sao Francisco', 'Rio Parana'], 1,
   'O Rio Vermelho e afluente do Araguaia, integrando a bacia Tocantins-Araguaia.', 3, 'medio');
end $$;
