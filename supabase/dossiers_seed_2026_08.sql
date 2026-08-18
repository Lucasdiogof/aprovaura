-- Atualidades — primeiro lote de dossiês (1 por área), pesquisado e datado em agosto de 2026.
-- Rode dossiers_schema.sql antes, se ainda não tiver rodado.
insert into dossiers (
  area, title, summary, context, what_happened, why_it_happened, who_is_involved,
  consequences, key_takeaways, sources, read_minutes, status,
  reference_period_start, reference_period_end, order_index
) values

('brasil',
 'Eleições 2026: a disputa pela Presidência começa oficialmente',
 'Em agosto de 2026, os candidatos à Presidência da República deram início oficialmente às campanhas eleitorais, marcando o começo de um dos períodos mais decisivos do calendário político brasileiro.',
 '2026 é ano de eleições gerais no Brasil, quando são escolhidos o presidente da República, governadores, senadores, deputados federais e estaduais. O primeiro turno da eleição presidencial deve ocorrer em outubro, seguindo o calendário eleitoral fixado pela Constituição.',
 'Em 16 de agosto de 2026, o presidente Luiz Inácio Lula da Silva realizou seu primeiro grande ato de campanha em um estádio em São Bernardo do Campo (SP), buscando a reeleição. No mesmo dia, o senador Flávio Bolsonaro lançou sua pré-candidatura à Presidência em um evento no Rio de Janeiro. A propaganda eleitoral nas ruas e na internet também foi liberada a partir dessa data, conforme as regras do Tribunal Superior Eleitoral (TSE).',
 'O calendário eleitoral brasileiro determina datas específicas para o início das campanhas, geralmente a partir de agosto do ano eleitoral, após a definição das candidaturas nas convenções partidárias.',
 'Luiz Inácio Lula da Silva (buscando a reeleição), Flávio Bolsonaro (pré-candidato de oposição), o TSE (responsável por fiscalizar o processo eleitoral) e os principais partidos políticos do país.',
 'O resultado da eleição presidencial de 2026 deve definir os rumos da política econômica, social e externa do Brasil pelos próximos anos, além de influenciar a composição do Congresso Nacional eleito no mesmo pleito.',
 '• 2026 é ano de eleições gerais no Brasil (presidente, governadores, senadores e deputados).
• As campanhas foram oficialmente liberadas em 16 de agosto de 2026.
• O TSE fiscaliza o uso de tecnologia e desinformação nas campanhas.
• O primeiro turno da eleição presidencial deve ocorrer em outubro de 2026.',
 array['https://agenciabrasil.ebc.com.br/politica', 'https://www.cnnbrasil.com.br/politica/', 'https://en.wikipedia.org/wiki/2026_Brazilian_gubernatorial_elections'],
 5, 'current', '2026-08-01', null, 1),

('mundoGeopolitica',
 'Os principais conflitos armados do mundo em 2026',
 'O ano de 2026 chegou com o mundo lidando com múltiplos conflitos armados simultâneos, de guerras prolongadas a tensões com risco de escalada.',
 'Analistas internacionais apontam 2026 como um ano de instabilidade geopolítica elevada, com conflitos que vão da Europa Oriental ao Oriente Médio, passando pela África e pela Ásia.',
 'Entre os principais conflitos monitorados em 2026 estão a guerra na Ucrânia (que se consolidou como um conflito de atrito, com uso massivo de drones e ataques a infraestrutura), o conflito entre Israel e grupos palestinos na Faixa de Gaza, a guerra civil no Sudão (intensificada em regiões como Darfur), a crise na República Democrática do Congo, o conflito interno em Mianmar e a guerra no Iêmen. A tensão entre China e Taiwan também segue como um dos pontos mais observados pela comunidade internacional.',
 'Cada conflito tem causas próprias e específicas — disputas territoriais, tensões étnicas, religiosas ou políticas, e disputas por recursos — mas todos compartilham o pano de fundo de uma ordem internacional cada vez mais fragmentada, com menor capacidade de mediação por organismos multilaterais como a ONU.',
 'Governos nacionais, forças rebeldes e milícias, organizações internacionais (como ONU e OTAN) e potências regionais e globais que apoiam diferentes lados, direta ou indiretamente.',
 'Esses conflitos geram crises humanitárias, deslocamento de populações, impactos econômicos globais (em rotas comerciais e preços de commodities) e frequentemente aparecem como tema de provas de atualidades em vestibulares e concursos.',
 '• Os principais conflitos armados de 2026 incluem Ucrânia, Gaza, Sudão, RDC, Mianmar e Iêmen.
• A tensão entre China e Taiwan é um dos pontos mais observados globalmente.
• Conflitos regionais têm causas específicas, mas refletem uma ordem internacional mais fragmentada.
• O tema é recorrente em provas de atualidades de vestibulares e concursos.',
 array['https://www.poder360.com.br/poder-internacional/mundo-tem-cerca-de-30-possibilidades-de-conflitos-em-2026/', 'https://planetageo.com.br/principais-conflitos-do-mundo/', 'https://blog.mackenzie.br/vestibular/disputas-geopoliticas-o-que-voce-precisa-entender-sobre-o-cenario-global-em-2026/'],
 6, 'current', '2026-01-01', null, 1),

('economia',
 'Selic recua para 14% em meio à queda da expectativa de inflação',
 'Em agosto de 2026, o Comitê de Política Monetária (Copom) reduziu a taxa básica de juros, a Selic, para 14% ao ano, enquanto o mercado financeiro revisou para baixo suas projeções de inflação para o ano.',
 'A Selic é o principal instrumento do Banco Central para controlar a inflação: quando ela sobe, o crédito fica mais caro e o consumo tende a desacelerar, reduzindo a pressão sobre os preços; quando ela cai, o efeito é o oposto.',
 'Na reunião encerrada em 5 de agosto de 2026, o Copom reduziu a Selic em 0,25 ponto percentual, de 14,25% para 14% ao ano. Segundo o Boletim Focus, publicado semanalmente pelo Banco Central com a mediana das projeções do mercado financeiro, a expectativa de inflação (medida pelo IPCA) para o fechamento de 2026 recuou para 5,02%, e a projeção de crescimento do PIB para o ano ficou em torno de 1,98%.',
 'A redução da Selic ocorre quando o Banco Central avalia que a inflação está em trajetória de queda e que a economia pode suportar juros um pouco mais baixos sem reacender a alta de preços.',
 'O Banco Central do Brasil (responsável pela decisão), o Copom (comitê que define a taxa) e o mercado financeiro (que produz as projeções do Boletim Focus).',
 'Juros mais baixos tendem a estimular o crédito, o consumo e os investimentos, mas o Banco Central segue cauteloso, já que a inflação projetada (5,02%) ainda está acima do centro da meta oficial perseguida pelo país.',
 '• A Selic foi reduzida para 14% ao ano na reunião do Copom de 5 de agosto de 2026.
• A inflação projetada (IPCA) para 2026 é de 5,02%, segundo o Boletim Focus.
• A projeção de crescimento do PIB para 2026 é de cerca de 1,98%.
• Juros e inflação são temas centrais e recorrentes em provas de atualidades e economia.',
 array['https://agenciabrasil.ebc.com.br/economia/noticia/2026-08/expectativa-do-mercado-para-inflacao-de-2026-cai-para-502', 'https://www.brasil247.com/economia/relatorio-focus-mantem-projecao-de-inflacao-a-502-para-2026-e-selic-em-1375/'],
 5, 'current', '2026-08-05', null, 1),

('meioAmbiente',
 'Depois da COP30, o mundo se prepara para a COP31 na Turquia',
 'Com a COP30 já encerrada, a atenção da agenda climática internacional se volta para a COP31, marcada para novembro de 2026 em Antália, na Turquia.',
 'A COP (Conferência das Partes) é o principal encontro anual da ONU sobre mudanças climáticas, reunindo praticamente todos os países do mundo para negociar metas e compromissos de redução de emissões de gases de efeito estufa.',
 'A COP31 será realizada em Antália, na Turquia, entre 9 e 20 de novembro de 2026, em um formato inédito de presidência compartilhada: a Turquia como país anfitrião e a Austrália liderando as negociações. O Dia Mundial do Meio Ambiente de 2026, celebrado em 5 de junho, teve como tema as mudanças climáticas, com a campanha "Agora Pelo Clima" promovida pelo PNUMA (Programa das Nações Unidas para o Meio Ambiente).',
 'Os últimos onze anos foram os mais quentes já registrados globalmente, e o mundo caminha para ultrapassar temporariamente o limite de 1,5°C de aquecimento estabelecido pelo Acordo de Paris, o que mantém a pressão internacional por novas metas e ações mais efetivas.',
 'A ONU (por meio da UNFCCC, a convenção-quadro sobre mudança do clima), os governos nacionais, o PNUMA, organizações da sociedade civil e o setor privado.',
 'A COP31 deve discutir o avanço dos compromissos assumidos em conferências anteriores, financiamento climático para países em desenvolvimento e estratégias de adaptação a eventos climáticos extremos, cada vez mais frequentes.',
 '• A COP31 ocorre em Antália, na Turquia, de 9 a 20 de novembro de 2026.
• Pela primeira vez, a conferência terá presidência compartilhada entre dois países (Turquia e Austrália).
• Os últimos onze anos foram os mais quentes já registrados no planeta.
• O mundo está próximo de ultrapassar temporariamente o limite de 1,5°C do Acordo de Paris.',
 array['https://exame.com/esg/a-cop30-passou-e-agora-os-eventos-climaticos-para-ficar-de-olho-em-2026/', 'https://brasil.un.org/pt-br/317139-dia-do-meio-ambiente-2026-onu-intensifica-campanha-por-a%C3%A7%C3%A3o-clim%C3%A1tica'],
 5, 'current', '2026-11-09', '2026-11-20', 1),

('cienciaTecnologia',
 'Inteligência artificial em 2026: da novidade à maturidade',
 'Em 2026, a inteligência artificial deixa de ser apenas uma novidade tecnológica para assumir um papel mais pragmático, focado em resultados mensuráveis para empresas e governos.',
 'Depois de anos de rápida evolução dos modelos de IA generativa, 2026 é apontado como um ano de amadurecimento do setor, com foco em aplicações práticas em vez de apenas demonstrações de capacidade.',
 'Entre as principais tendências de 2026 estão a evolução de assistentes digitais para "agentes autônomos", capazes de executar tarefas completas com menor intervenção humana, e o avanço de modelos multimodais, que combinam texto, imagem, áudio e dados estruturados. O setor global de inteligência artificial deve superar US$ 900 bilhões em valor ainda em 2026, enquanto o Brasil prevê R$ 23 bilhões em investimentos em IA até 2028, por meio do Plano Brasileiro de Inteligência Artificial.',
 'O amadurecimento reflete tanto o avanço técnico dos modelos quanto a pressão de empresas e governos por retorno financeiro concreto sobre os grandes investimentos feitos em IA nos últimos anos.',
 'Grandes empresas de tecnologia, governos nacionais (incluindo o governo brasileiro, por meio de seu plano de IA) e o Fórum Econômico Mundial, que monitora os impactos da tecnologia no mercado de trabalho.',
 'Segundo o Fórum Econômico Mundial, mais de 40% das habilidades demandadas no mercado de trabalho devem mudar até o fim da década, com o surgimento de novas funções ligadas à integração, governança e uso estratégico da inteligência artificial.',
 '• 2026 marca a transição da IA de "novidade" para uma fase de maturidade e resultados práticos.
• Agentes autônomos e modelos multimodais são as principais tendências tecnológicas do ano.
• O setor global de IA deve superar US$ 900 bilhões em 2026.
• O Brasil prevê R$ 23 bilhões em investimentos em IA até 2028.',
 array['https://news.microsoft.com/source/latam/features/noticias-da-microsoft/o-que-vem-por-ai-na-ia-7-tendencias-para-ficar-de-olho-em-2026/?lang=pt-br', 'https://scansource.com.br/blog/tendencias-inteligencia-artificial-2026/'],
 5, 'current', '2026-01-01', null, 1),

('sociedade',
 'Educação política passa a integrar o currículo das escolas brasileiras',
 'Em 2026, o ensino de educação política e direitos de cidadania passou a ser obrigatório na educação básica brasileira, segundo mudanças na legislação educacional.',
 'A Lei de Diretrizes e Bases da Educação Nacional (LDB) define os conteúdos obrigatórios ensinados nas escolas do país. Historicamente, temas como o funcionamento do Estado e a participação democrática eram tratados de forma pontual, sem obrigatoriedade formal e unificada.',
 'Segundo reportagem da Agência Brasil, uma mudança na LDB tornou obrigatória a abordagem de educação política e direitos da cidadania nas escolas, integrando esses conteúdos às disciplinas que tratam da realidade social e política do país. O objetivo declarado é garantir que os estudantes tenham acesso a ensinamentos práticos sobre a organização do Estado, os canais de participação democrática e o funcionamento geral da sociedade.',
 'A medida é apresentada como resposta à necessidade de fortalecer a formação cidadã dos estudantes, em um contexto de baixa participação política de jovens e de preocupação com o combate à desinformação.',
 'O Congresso Nacional (responsável por aprovar a mudança na legislação), o Ministério da Educação e as redes de ensino públicas e privadas, que precisam adaptar seus currículos.',
 'A expectativa é que a medida contribua para formar estudantes mais preparados para participar do debate público e do processo eleitoral, embora sua efetividade dependa da forma como será implementada em sala de aula.',
 '• A educação política e os direitos de cidadania passaram a ser conteúdos obrigatórios na educação básica.
• A mudança foi incorporada à LDB (Lei de Diretrizes e Bases da Educação Nacional).
• O objetivo é fortalecer a formação cidadã e a participação democrática dos estudantes.
• O tema se soma a outras pautas obrigatórias no currículo, como a história e cultura afro-brasileira e indígena.',
 array['https://agenciabrasil.ebc.com.br/educacao/noticia/2026-07/educacao-politica-passa-integrar-curriculo-escolar-brasileiro', 'https://agenciabrasil.ebc.com.br/politica/noticia/2026-06/congresso-inclui-politica-e-direitos-da-cidadania-no-curriculo-escolar'],
 4, 'current', '2026-06-01', null, 1),

('saude',
 'Brasil monitora surto de Ebola na África e avança na criação de um centro de emergências em saúde',
 'Em 2026, autoridades de saúde brasileiras acompanham de perto um surto de Ebola identificado na República Democrática do Congo, enquanto o país avança na criação de uma estrutura nacional para emergências sanitárias.',
 'Depois da pandemia de covid-19, países ao redor do mundo passaram a investir em estruturas permanentes de vigilância e resposta a emergências de saúde pública, para evitar repetir falhas de coordenação observadas entre 2020 e 2022.',
 'Um surto de Ebola foi identificado em maio de 2026 na província de Ituri, na República Democrática do Congo. No Brasil, dois casos suspeitos foram notificados pelas autoridades de saúde, embora o risco de introdução e disseminação da doença no país seja considerado baixo. Paralelamente, o Brasil trabalha para criar, até o fim de 2026, o Centro Brasileiro de Emergências em Saúde Pública (Cbesp), estrutura nacional voltada ao enfrentamento de epidemias, surtos e outras emergências, incluindo eventos climáticos com impacto direto na saúde da população.',
 'A criação do Cbesp busca justamente evitar que o país repita as falhas de coordenação observadas durante a pandemia de covid-19, centralizando a resposta a diferentes tipos de emergência sanitária em uma única estrutura.',
 'O Ministério da Saúde, o SUS (Sistema Único de Saúde), organizações internacionais de saúde (que monitoram o surto na África) e as autoridades sanitárias da República Democrática do Congo.',
 'Ainda que o risco imediato ao Brasil seja considerado baixo, o episódio reforça a importância de sistemas de vigilância epidemiológica preparados para identificar e conter rapidamente potenciais ameaças, além de acelerar discussões sobre a criação do novo centro de emergências.',
 '• Um surto de Ebola foi identificado em maio de 2026 na República Democrática do Congo.
• O Brasil notificou casos suspeitos, mas o risco de disseminação no país é considerado baixo.
• O Brasil planeja criar o Cbesp (Centro Brasileiro de Emergências em Saúde Pública) até o fim de 2026.
• A iniciativa busca evitar falhas de coordenação como as vistas durante a pandemia de covid-19.',
 array['https://portal.wemeds.com.br/surto-de-ebola-atualizacao-epidemiologica/', 'https://sincofarmasp.com.br/2026/06/29/sus-pede-para-que-brasileiros-se-preparem-para-nova-epidemia-que-deve-chegar/'],
 5, 'current', '2026-05-01', null, 1);
