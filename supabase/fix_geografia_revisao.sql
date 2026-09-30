-- Geografia: 28 correções aceitas da revisão externa (2026-09-30)
--
-- Nenhum gabarito deslocado, mas várias questões tinham erro de fato:
-- - as Cataratas do Iguaçu ficam na fronteira Brasil–Argentina, não com o Paraguai;
-- - o Brasil já é o 1º produtor de soja, não o 2º;
-- - o maior produtor de grãos não são os EUA (a questão passa a ser sobre arroz);
-- - a Bacia do Prata inclui a Bolívia;
-- - "originalmente" o grupo era BRIC, sem a África do Sul;
-- - a massa Tropical Continental é quente e seca, então "quentes e úmidas" falhava;
-- - a explicação dos fusos listava o Acre em UTC−4;
-- - desde 2017 o IBGE não usa mais mesorregiões.
-- Os dados novos foram conferidos na fonte: Censo 2022 (87,4% urbano) e USDA
-- 2025/26 (Índia 1ª em arroz; China, Índia, Brasil e EUA em algodão).
--
-- Recusadas: a planície "associada ao Rio Amazonas" (o enunciado entregava a
-- resposta), a troca da questão do Oceano Austral (a atual está correta) e
-- mudanças gratuitas em distratores. Geografia não tem fonte: vive só no banco.
--
-- Nas questões corrigidas só no texto, a ordem das alternativas é mantida.
-- Nas reescritas, as alternativas novas foram arrumadas para a certa cair
-- no correct_index que a questão já tinha, então o gabarito por letra não
-- muda. As três línguas usam a mesma ordem. Cada update grava o valor
-- final inteiro, então rodar de novo não muda nada.

-- deserto: o critério é a precipitação; amplitude térmica não define
update questions set options = array['Baixíssimos índices de precipitação e elevada aridez', 'Chuvas constantes o ano todo', 'Temperaturas sempre baixas', 'Umidade elevada e neblina frequente'], explanation = 'O principal critério climático dos desertos é a escassez de precipitação, que produz elevada aridez; eles podem ser quentes ou frios.'
 where id = 'eed5d6c1-1826-4f89-a625-90256fbac2a5';
update question_translations set options = array['Very low precipitation and high aridity', 'Constant rain all year round', 'Temperatures that are always low', 'High humidity and frequent fog'], explanation = 'The main climatic criterion for deserts is scarce precipitation, which produces high aridity; they can be hot or cold.'
 where question_id = 'eed5d6c1-1826-4f89-a625-90256fbac2a5' and locale = 'en';
update question_translations set options = array['Índices bajísimos de precipitación y elevada aridez', 'Lluvias constantes todo el año', 'Temperaturas siempre bajas', 'Humedad elevada y niebla frecuente'], explanation = 'El principal criterio climático de los desiertos es la escasez de precipitación, que produce una elevada aridez; pueden ser cálidos o fríos.'
 where question_id = 'eed5d6c1-1826-4f89-a625-90256fbac2a5' and locale = 'es';

-- Saara: dez Estados da ONU, e o Saara Ocidental é território disputado
update questions set explanation = 'O Saara se estende por dez Estados membros da ONU: Argélia, Chade, Egito, Líbia, Mali, Mauritânia, Marrocos, Níger, Sudão e Tunísia. O Saara Ocidental é um território disputado.'
 where id = '5a8a9404-141c-4aeb-9b45-53be165ae271';
update question_translations set explanation = 'The Sahara spans ten UN member states: Algeria, Chad, Egypt, Libya, Mali, Mauritania, Morocco, Niger, Sudan and Tunisia. Western Sahara is a disputed territory.'
 where question_id = '5a8a9404-141c-4aeb-9b45-53be165ae271' and locale = 'en';
update question_translations set explanation = 'El Sahara se extiende por diez Estados miembros de la ONU: Argelia, Chad, Egipto, Libia, Malí, Mauritania, Marruecos, Níger, Sudán y Túnez. El Sahara Occidental es un territorio en disputa.'
 where question_id = '5a8a9404-141c-4aeb-9b45-53be165ae271' and locale = 'es';

-- África do Sul: "maior economia" disputa com Nigéria e Egito; o traço firme é a diversificação
update questions set prompt = 'Na África Austral, qual país se destaca por ter uma das economias mais industrializadas e diversificadas do continente?', explanation = 'A África do Sul tem uma economia diversificada, com forte presença de mineração, indústria, finanças e serviços.'
 where id = '792828e8-5f99-4d1e-81c9-ca20a36ea9a9';
update question_translations set prompt = 'In Southern Africa, which country stands out for having one of the most industrialized and diversified economies on the continent?', explanation = 'South Africa has a diversified economy, with a strong presence of mining, industry, finance and services.'
 where question_id = '792828e8-5f99-4d1e-81c9-ca20a36ea9a9' and locale = 'en';
update question_translations set prompt = 'En África Austral, ¿qué país se destaca por tener una de las economías más industrializadas y diversificadas del continente?', explanation = 'Sudáfrica tiene una economía diversificada, con fuerte presencia de la minería, la industria, las finanzas y los servicios.'
 where question_id = '792828e8-5f99-4d1e-81c9-ca20a36ea9a9' and locale = 'es';

-- Cataratas do Iguaçu: ficam na fronteira Brasil–Argentina; o Paraguai não divide as quedas
update questions set prompt = 'As Cataratas do Iguaçu ficam no trecho do Rio Iguaçu que marca a fronteira entre quais países?', options = array['Brasil e Argentina', 'Brasil e Paraguai', 'Argentina e Paraguai', 'Brasil e Uruguai'], explanation = 'As Cataratas ficam na fronteira Brasil–Argentina. O Paraguai integra a Tríplice Fronteira da região, mas não divide as quedas com os outros dois países.'
 where id = '2fde7efc-593f-4c33-bb8a-0aaa772eb879';
update question_translations set prompt = 'The Iguazu Falls are on the stretch of the Iguazu River that marks the border between which countries?', options = array['Brazil and Argentina', 'Brazil and Paraguay', 'Argentina and Paraguay', 'Brazil and Uruguay'], explanation = 'The falls are on the Brazil–Argentina border. Paraguay is part of the region''s Triple Frontier but does not share the falls with the other two countries.'
 where question_id = '2fde7efc-593f-4c33-bb8a-0aaa772eb879' and locale = 'en';
update question_translations set prompt = 'Las Cataratas del Iguazú están en el tramo del río Iguazú que marca la frontera entre ¿qué países?', options = array['Brasil y Argentina', 'Brasil y Paraguay', 'Argentina y Paraguay', 'Brasil y Uruguay'], explanation = 'Las cataratas están en la frontera Brasil–Argentina. Paraguay forma parte de la Triple Frontera de la región, pero no comparte las caídas con los otros dos países.'
 where question_id = '2fde7efc-593f-4c33-bb8a-0aaa772eb879' and locale = 'es';

-- relevo brasileiro: a classificação atual tem planaltos, planícies e depressões
update questions set prompt = 'Na classificação moderna do relevo brasileiro, quais três grandes tipos de unidades aparecem no território?', options = array['Planaltos, planícies e depressões', 'Apenas planaltos e planícies', 'Montanhas jovens, fiordes e vulcões', 'Dunas, geleiras e fossas oceânicas'], explanation = 'As classificações modernas do relevo brasileiro distinguem planaltos, planícies e depressões; o país não tem grandes dobramentos modernos como os Andes.'
 where id = '4e509ccd-8edc-4869-abdf-5cc7a998b48d';
update question_translations set prompt = 'In the modern classification of Brazilian relief, which three major types of units appear in the territory?', options = array['Plateaus, plains and depressions', 'Only plateaus and plains', 'Young mountains, fjords and volcanoes', 'Dunes, glaciers and ocean trenches'], explanation = 'Modern classifications of Brazilian relief distinguish plateaus, plains and depressions; the country has no large young fold mountains like the Andes.'
 where question_id = '4e509ccd-8edc-4869-abdf-5cc7a998b48d' and locale = 'en';
update question_translations set prompt = 'En la clasificación moderna del relieve brasileño, ¿qué tres grandes tipos de unidades aparecen en el territorio?', options = array['Mesetas, llanuras y depresiones', 'Solo mesetas y llanuras', 'Montañas jóvenes, fiordos y volcanes', 'Dunas, glaciares y fosas oceánicas'], explanation = 'Las clasificaciones modernas del relieve brasileño distinguen mesetas, llanuras y depresiones; el país no tiene grandes plegamientos modernos como los Andes.'
 where question_id = '4e509ccd-8edc-4869-abdf-5cc7a998b48d' and locale = 'es';

-- Andes: a mais extensa CONTINENTAL (a dorsal meso-oceânica é maior)
update questions set explanation = 'Os Andes formam a cadeia montanhosa continental mais extensa do planeta, acompanhando o oeste da América do Sul por cerca de 7 mil km.'
 where id = '4dc77cb8-fb52-4917-8183-a38c4a86ee63';
update question_translations set explanation = 'The Andes are the longest continental mountain range on the planet, running along western South America for about 7,000 km.'
 where question_id = '4dc77cb8-fb52-4917-8183-a38c4a86ee63' and locale = 'en';
update question_translations set explanation = 'Los Andes forman la cadena montañosa continental más extensa del planeta y recorren el oeste de América del Sur a lo largo de unos 7 mil km.'
 where question_id = '4dc77cb8-fb52-4917-8183-a38c4a86ee63' and locale = 'es';

-- Mar Morto: o recorde é das margens como terra emersa mais baixa, não da "superfície terrestre"
update questions set prompt = 'Além da alta salinidade, qual característica geográfica se destaca nas margens do Mar Morto?', options = array['Elas formam a área de terra emersa mais baixa do planeta', 'Elas ficam exatamente no nível médio do mar', 'Elas constituem o ponto mais alto da Ásia', 'Elas são cobertas por geleiras permanentes'], explanation = 'As margens do Mar Morto ficam mais de 400 metros abaixo do nível do mar e formam a área de terra emersa mais baixa do planeta.'
 where id = 'e3a2f0b5-248c-4eb7-b638-1bb7e1381b10';
update question_translations set prompt = 'Besides its high salinity, which geographical feature stands out on the shores of the Dead Sea?', options = array['They are the lowest dry land on the planet', 'They lie exactly at mean sea level', 'They are the highest point in Asia', 'They are covered by permanent glaciers'], explanation = 'The shores of the Dead Sea lie more than 400 meters below sea level and are the lowest dry land on the planet.'
 where question_id = 'e3a2f0b5-248c-4eb7-b638-1bb7e1381b10' and locale = 'en';
update question_translations set prompt = 'Además de la alta salinidad, ¿qué característica geográfica se destaca en las orillas del mar Muerto?', options = array['Forman la zona de tierra emergida más baja del planeta', 'Están exactamente al nivel medio del mar', 'Constituyen el punto más alto de Asia', 'Están cubiertas por glaciares permanentes'], explanation = 'Las orillas del mar Muerto están a más de 400 metros bajo el nivel del mar y forman la zona de tierra emergida más baja del planeta.'
 where question_id = 'e3a2f0b5-248c-4eb7-b638-1bb7e1381b10' and locale = 'es';

-- Oriente Médio: vários países da região (Jordânia, Líbano, Israel) não vivem de petróleo
update questions set prompt = 'Vários países do Golfo Pérsico têm grande importância no comércio mundial de qual recurso energético?', options = array['Petróleo', 'Urânio enriquecido', 'Carvão vegetal', 'Lenha'], explanation = 'Os países do Golfo Pérsico concentram grandes reservas e exportações de petróleo, recurso central para a economia da região e para o comércio mundial.'
 where id = '109011bd-8de2-4d99-84b3-6723ab5b0469';
update question_translations set prompt = 'Several Persian Gulf countries play a major role in world trade in which energy resource?', options = array['Oil', 'Enriched uranium', 'Charcoal', 'Firewood'], explanation = 'The Persian Gulf countries hold large oil reserves and exports, a resource central to the regional economy and to world trade.'
 where question_id = '109011bd-8de2-4d99-84b3-6723ab5b0469' and locale = 'en';
update question_translations set prompt = 'Varios países del golfo Pérsico tienen gran importancia en el comercio mundial de ¿qué recurso energético?', options = array['Petróleo', 'Uranio enriquecido', 'Carbón vegetal', 'Leña'], explanation = 'Los países del golfo Pérsico concentran grandes reservas y exportaciones de petróleo, recurso central para la economía de la región y para el comercio mundial.'
 where question_id = '109011bd-8de2-4d99-84b3-6723ab5b0469' and locale = 'es';

-- cana: a produção está no Centro-Sul, com São Paulo à frente, e não só no Oeste Paulista
update questions set prompt = 'No Brasil, a produção de cana-de-açúcar destinada ao açúcar e ao etanol concentra-se principalmente em qual área?', options = array['Zona da Mata nordestina, exclusivamente', 'Amazônia Ocidental', 'Centro-Sul, com destaque para o estado de São Paulo', 'Extremo sul do Rio Grande do Sul'], explanation = 'A maior parte da produção canavieira brasileira está no Centro-Sul, com forte concentração em São Paulo, embora outros estados também tenham produção relevante.'
 where id = '76937c82-a314-41be-b854-405226186e0e';
update question_translations set prompt = 'In Brazil, sugarcane production for sugar and ethanol is concentrated mainly in which area?', options = array['The northeastern Zona da Mata, exclusively', 'The western Amazon', 'The Center-South, especially the state of São Paulo', 'The far south of Rio Grande do Sul'], explanation = 'Most of Brazil''s sugarcane production is in the Center-South, heavily concentrated in São Paulo, although other states also produce significant amounts.'
 where question_id = '76937c82-a314-41be-b854-405226186e0e' and locale = 'en';
update question_translations set prompt = 'En Brasil, la producción de caña de azúcar destinada al azúcar y al etanol se concentra principalmente en ¿qué zona?', options = array['La Zona da Mata del Nordeste, exclusivamente', 'La Amazonía occidental', 'El Centro-Sur, con destaque para el estado de São Paulo', 'El extremo sur de Rio Grande do Sul'], explanation = 'La mayor parte de la producción cañera brasileña está en el Centro-Sur, con fuerte concentración en São Paulo, aunque otros estados también tienen una producción relevante.'
 where question_id = '76937c82-a314-41be-b854-405226186e0e' and locale = 'es';

-- massas de ar: a Tropical Continental é quente e SECA; "quentes e úmidas" não vale para todas
update questions set prompt = 'De modo geral, as massas de ar tropicais e equatoriais que atuam no Brasil apresentam temperaturas:', options = array['Elevadas, com umidade que varia conforme a origem, continental ou oceânica', 'Sempre elevadas e obrigatoriamente muito úmidas', 'Sempre baixas e com neve', 'Sempre baixas e secas'], explanation = 'Por se formarem em baixas latitudes, essas massas são quentes; a umidade depende da área de origem. A Tropical Continental, por exemplo, é quente e seca.'
 where id = '8b815e97-3cd3-46b5-af6c-dd83075c3472';
update question_translations set prompt = 'In general, the tropical and equatorial air masses that act over Brazil have temperatures that are:', options = array['High, with humidity that varies with their origin, continental or oceanic', 'Always high and necessarily very humid', 'Always low and bringing snow', 'Always low and dry'], explanation = 'Because they form at low latitudes, these air masses are warm; their humidity depends on where they form. The Tropical Continental mass, for example, is hot and dry.'
 where question_id = '8b815e97-3cd3-46b5-af6c-dd83075c3472' and locale = 'en';
update question_translations set prompt = 'De modo general, las masas de aire tropicales y ecuatoriales que actúan en Brasil presentan temperaturas:', options = array['Elevadas, con una humedad que varía según su origen, continental u oceánico', 'Siempre elevadas y necesariamente muy húmedas', 'Siempre bajas y con nieve', 'Siempre bajas y secas'], explanation = 'Al formarse en latitudes bajas, estas masas son cálidas; la humedad depende de la zona de origen. La Tropical Continental, por ejemplo, es cálida y seca.'
 where question_id = '8b815e97-3cd3-46b5-af6c-dd83075c3472' and locale = 'es';

-- Goiás: desde 2017 o IBGE usa regiões geográficas imediatas e intermediárias
update questions set prompt = 'Desde 2017, o IBGE divide o território de Goiás, como o dos demais estados, em:', options = array['Regiões geográficas intermediárias e imediatas', 'Províncias e distritos federais', 'Zonas da Mata e do Sertão', 'Apenas regiões metropolitanas e capitais regionais'], explanation = 'Na divisão regional de 2017, o IBGE substituiu as antigas mesorregiões (em Goiás: Centro, Norte, Sul, Leste e Noroeste Goiano) e microrregiões pelas regiões geográficas intermediárias e imediatas.'
 where id = 'fab74c12-b35a-41ae-95fb-a15bc17322f6';
update question_translations set prompt = 'Since 2017, IBGE has divided the territory of Goiás, like that of the other states, into:', options = array['Intermediate and immediate geographic regions', 'Provinces and federal districts', 'Zona da Mata and Sertão zones', 'Only metropolitan areas and regional capitals'], explanation = 'In its 2017 regional division, IBGE replaced the old mesoregions (in Goiás: Central, North, South, East and Northwest Goiás) and microregions with intermediate and immediate geographic regions.'
 where question_id = 'fab74c12-b35a-41ae-95fb-a15bc17322f6' and locale = 'en';
update question_translations set prompt = 'Desde 2017, el IBGE divide el territorio de Goiás, como el de los demás estados, en:', options = array['Regiones geográficas intermedias e inmediatas', 'Provincias y distritos federales', 'Zonas da Mata y del Sertão', 'Solo regiones metropolitanas y capitales regionales'], explanation = 'En la división regional de 2017, el IBGE sustituyó las antiguas mesorregiones (en Goiás: Centro, Norte, Sur, Este y Noroeste Goiano) y microrregiones por las regiones geográficas intermedias e inmediatas.'
 where question_id = 'fab74c12-b35a-41ae-95fb-a15bc17322f6' and locale = 'es';

-- Bacia do Prata: a Bolívia faltava; são cinco países
update questions set prompt = 'A Bacia do Prata, formada principalmente pelos rios Paraná, Paraguai e Uruguai, abrange o Brasil e quais outros países?', options = array['Argentina, Bolívia, Paraguai e Uruguai', 'Argentina, Chile e Peru', 'Paraguai, Colômbia e Venezuela', 'Uruguai, Equador e Chile'], explanation = 'A Bacia do Prata se estende por cinco países: Brasil, Argentina, Bolívia, Paraguai e Uruguai.'
 where id = '0141d298-07fa-4917-9967-63417ac38507';
update question_translations set prompt = 'The Plata Basin, formed mainly by the Paraná, Paraguay and Uruguay rivers, covers Brazil and which other countries?', options = array['Argentina, Bolivia, Paraguay and Uruguay', 'Argentina, Chile and Peru', 'Paraguay, Colombia and Venezuela', 'Uruguay, Ecuador and Chile'], explanation = 'The Plata Basin spans five countries: Brazil, Argentina, Bolivia, Paraguay and Uruguay.'
 where question_id = '0141d298-07fa-4917-9967-63417ac38507' and locale = 'en';
update question_translations set prompt = 'La cuenca del Plata, formada principalmente por los ríos Paraná, Paraguay y Uruguay, abarca Brasil y ¿qué otros países?', options = array['Argentina, Bolivia, Paraguay y Uruguay', 'Argentina, Chile y Perú', 'Paraguay, Colombia y Venezuela', 'Uruguay, Ecuador y Chile'], explanation = 'La cuenca del Plata se extiende por cinco países: Brasil, Argentina, Bolivia, Paraguay y Uruguay.'
 where question_id = '0141d298-07fa-4917-9967-63417ac38507' and locale = 'es';

-- Madeira: "maior em extensão" é disputado com Purus e Juruá; em vazão ele lidera
update questions set prompt = 'Qual afluente do Amazonas se destaca por ter a maior vazão entre os tributários do rio principal?', options = array['Rio Madeira', 'Rio Juruá', 'Rio Tapajós', 'Rio Xingu'], explanation = 'O Rio Madeira, que banha Rondônia e Amazonas, é o afluente de maior vazão do Amazonas. Em extensão, a liderança é disputada com o Purus e o Juruá, conforme a medição.'
 where id = 'f60ddd62-d40d-4b0c-a520-fbf47fc0947d';
update question_translations set prompt = 'Which Amazon tributary stands out for having the greatest discharge among the main river''s tributaries?', options = array['Madeira River', 'Juruá River', 'Tapajós River', 'Xingu River'], explanation = 'The Madeira River, which flows through Rondônia and Amazonas, is the Amazon tributary with the greatest discharge. In length, first place is disputed with the Purus and the Juruá, depending on the measurement.'
 where question_id = 'f60ddd62-d40d-4b0c-a520-fbf47fc0947d' and locale = 'en';
update question_translations set prompt = '¿Qué afluente del Amazonas se destaca por tener el mayor caudal entre los tributarios del río principal?', options = array['Río Madeira', 'Río Juruá', 'Río Tapajós', 'Río Xingu'], explanation = 'El río Madeira, que baña Rondônia y Amazonas, es el afluente de mayor caudal del Amazonas. En longitud, el primer puesto se disputa con el Purus y el Juruá, según la medición.'
 where question_id = 'f60ddd62-d40d-4b0c-a520-fbf47fc0947d' and locale = 'es';

-- Bananal: "maior ilha fluvial do mundo" é título disputado
update questions set prompt = 'O Rio Araguaia forma, junto com o Rio Javaés, qual grande ilha fluvial brasileira?', explanation = 'A Ilha do Bananal, no Tocantins, fica entre os rios Araguaia e Javaés, tem cerca de 20 mil km² e está entre as maiores ilhas fluviais do mundo.'
 where id = 'c63990d1-2ab6-44b9-999e-1fd227a3a29e';
update question_translations set prompt = 'Together with the Javaés River, the Araguaia River forms which large Brazilian river island?', explanation = 'Bananal Island, in Tocantins, lies between the Araguaia and Javaés rivers, covers about 20,000 km² and is among the largest river islands in the world.'
 where question_id = 'c63990d1-2ab6-44b9-999e-1fd227a3a29e' and locale = 'en';
update question_translations set prompt = 'El río Araguaia forma, junto con el río Javaés, ¿qué gran isla fluvial brasileña?', explanation = 'La Isla del Bananal, en Tocantins, está entre los ríos Araguaia y Javaés, tiene cerca de 20 mil km² y figura entre las mayores islas fluviales del mundo.'
 where question_id = 'c63990d1-2ab6-44b9-999e-1fd227a3a29e' and locale = 'es';

-- Paraíba do Sul: o curso principal não passa por Minas; a bacia, sim
update questions set prompt = 'A bacia hidrográfica do Rio Paraíba do Sul abrange áreas de quais estados do Sudeste?', explanation = 'A bacia do Paraíba do Sul abrange São Paulo, Rio de Janeiro e Minas Gerais: o curso principal percorre São Paulo e Rio de Janeiro, e afluentes drenam áreas mineiras.'
 where id = '3a9754e7-a22a-4d62-be5d-fa2b7dbf451e';
update question_translations set prompt = 'The Paraíba do Sul River basin covers areas of which Southeast states?', explanation = 'The Paraíba do Sul basin covers São Paulo, Rio de Janeiro and Minas Gerais: the main course runs through São Paulo and Rio de Janeiro, and tributaries drain areas of Minas Gerais.'
 where question_id = '3a9754e7-a22a-4d62-be5d-fa2b7dbf451e' and locale = 'en';
update question_translations set prompt = 'La cuenca hidrográfica del río Paraíba do Sul abarca áreas de ¿qué estados del Sudeste?', explanation = 'La cuenca del Paraíba do Sul abarca São Paulo, Río de Janeiro y Minas Gerais: el curso principal recorre São Paulo y Río de Janeiro, y los afluentes drenan áreas de Minas Gerais.'
 where question_id = '3a9754e7-a22a-4d62-be5d-fa2b7dbf451e' and locale = 'es';

-- população urbana: Censo 2022, 87,4%
update questions set explanation = 'Segundo o Censo 2022 do IBGE, 87,4% da população brasileira vivia em áreas urbanas.'
 where id = '5471907a-5614-486b-8eda-1d2deef9302c';
update question_translations set explanation = 'According to IBGE''s 2022 Census, 87.4% of Brazil''s population lived in urban areas.'
 where question_id = '5471907a-5614-486b-8eda-1d2deef9302c' and locale = 'en';
update question_translations set explanation = 'Según el Censo 2022 del IBGE, el 87,4% de la población brasileña vivía en áreas urbanas.'
 where question_id = '5471907a-5614-486b-8eda-1d2deef9302c' and locale = 'es';

-- fusos: o Acre voltou ao UTC−5; a explicação listava errado
update questions set explanation = 'O Brasil tem quatro fusos oficiais: UTC−2 (Fernando de Noronha e ilhas oceânicas), UTC−3 (horário de Brasília), UTC−4 e UTC−5 (Acre e parte do oeste do Amazonas).'
 where id = 'ef9002ed-0ba3-44c9-bf19-d564e21276fb';
update question_translations set explanation = 'Brazil has four official time zones: UTC−2 (Fernando de Noronha and the oceanic islands), UTC−3 (Brasília time), UTC−4 and UTC−5 (Acre and part of western Amazonas).'
 where question_id = 'ef9002ed-0ba3-44c9-bf19-d564e21276fb' and locale = 'en';
update question_translations set explanation = 'Brasil tiene cuatro husos oficiales: UTC−2 (Fernando de Noronha y las islas oceánicas), UTC−3 (horario de Brasilia), UTC−4 y UTC−5 (Acre y parte del oeste de Amazonas).'
 where question_id = 'ef9002ed-0ba3-44c9-bf19-d564e21276fb' and locale = 'es';

-- metrópoles: "topo da hierarquia" no IBGE também inclui Brasília
update questions set prompt = 'Quais são as duas maiores metrópoles brasileiras em população?', explanation = 'São Paulo e Rio de Janeiro são as duas maiores concentrações metropolitanas do país em população. A hierarquia urbana do IBGE considera também a influência das cidades, não só o tamanho.'
 where id = 'af18dbc3-a046-4bfa-8d08-c06609901f67';
update question_translations set prompt = 'Which are the two largest Brazilian metropolises by population?', explanation = 'São Paulo and Rio de Janeiro are the country''s two largest metropolitan areas by population. IBGE''s urban hierarchy also considers cities'' influence, not just their size.'
 where question_id = 'af18dbc3-a046-4bfa-8d08-c06609901f67' and locale = 'en';
update question_translations set prompt = '¿Cuáles son las dos mayores metrópolis brasileñas en población?', explanation = 'São Paulo y Río de Janeiro son las dos mayores concentraciones metropolitanas del país en población. La jerarquía urbana del IBGE considera también la influencia de las ciudades, no solo su tamaño.'
 where question_id = 'af18dbc3-a046-4bfa-8d08-c06609901f67' and locale = 'es';

-- Nórdica ≠ Escandinávia: a Finlândia não é escandinava no sentido estrito
update questions set options = array['Europa Nórdica', 'Europa Balcânica', 'Europa Ocidental', 'Europa Mediterrânea'], explanation = 'Esses países integram a Europa Nórdica. "Escandinávia", em sentido estrito, designa Dinamarca, Noruega e Suécia, e não é sinônimo perfeito de países nórdicos.'
 where id = 'b30a610a-054b-4913-b211-f297420759b6';
update question_translations set options = array['Nordic Europe', 'Balkan Europe', 'Western Europe', 'Mediterranean Europe'], explanation = 'These countries make up Nordic Europe. "Scandinavia", in the strict sense, means Denmark, Norway and Sweden, and is not an exact synonym for the Nordic countries.'
 where question_id = 'b30a610a-054b-4913-b211-f297420759b6' and locale = 'en';
update question_translations set options = array['Europa Nórdica', 'Europa Balcánica', 'Europa Occidental', 'Europa Mediterránea'], explanation = 'Estos países integran la Europa Nórdica. "Escandinavia", en sentido estricto, designa a Dinamarca, Noruega y Suecia, y no es sinónimo exacto de países nórdicos.'
 where question_id = 'b30a610a-054b-4913-b211-f297420759b6' and locale = 'es';

-- soja: o Brasil já passou os EUA; a questão dizia que era o segundo
update questions set prompt = 'Qual país é hoje o maior produtor mundial de soja?', options = array['Argentina', 'China', 'Brasil', 'Estados Unidos'], explanation = 'O Brasil superou os Estados Unidos e lidera a produção mundial de soja; nas estimativas do USDA para 2025/26, segue à frente.'
 where id = '885de2c7-bd27-49f8-970b-bf5eff2b9a06';
update question_translations set prompt = 'Which country is currently the world''s largest soybean producer?', options = array['Argentina', 'China', 'Brazil', 'The United States'], explanation = 'Brazil has overtaken the United States and leads world soybean production; USDA''s 2025/26 estimates keep it in first place.'
 where question_id = '885de2c7-bd27-49f8-970b-bf5eff2b9a06' and locale = 'en';
update question_translations set prompt = '¿Qué país es hoy el mayor productor mundial de soja?', options = array['Argentina', 'China', 'Brasil', 'Estados Unidos'], explanation = 'Brasil superó a Estados Unidos y lidera la producción mundial de soja; en las estimaciones del USDA para 2025/26 sigue al frente.'
 where question_id = '885de2c7-bd27-49f8-970b-bf5eff2b9a06' and locale = 'es';

-- "maior produtor de grãos" = EUA estava errado (a China produz mais cereais); a questão passa a ser sobre arroz
update questions set prompt = 'Segundo o USDA, qual país lidera a produção mundial de arroz desde a safra 2024/25?', options = array['China', 'Índia', 'Brasil', 'Estados Unidos'], explanation = 'A Índia ultrapassou a China como maior produtora mundial de arroz a partir de 2024/25, segundo o USDA; as duas somam mais da metade da produção global.'
 where id = '50370826-3ab5-429a-99ec-97ae0a4a901e';
update question_translations set prompt = 'According to the USDA, which country has led world rice production since the 2024/25 season?', options = array['China', 'India', 'Brazil', 'The United States'], explanation = 'India overtook China as the world''s largest rice producer from 2024/25 on, according to the USDA; together they account for more than half of global output.'
 where question_id = '50370826-3ab5-429a-99ec-97ae0a4a901e' and locale = 'en';
update question_translations set prompt = 'Según el USDA, ¿qué país lidera la producción mundial de arroz desde la campaña 2024/25?', options = array['China', 'India', 'Brasil', 'Estados Unidos'], explanation = 'India superó a China como mayor productora mundial de arroz a partir de 2024/25, según el USDA; entre las dos suman más de la mitad de la producción mundial.'
 where question_id = '50370826-3ab5-429a-99ec-97ae0a4a901e' and locale = 'es';

-- algodão: o Brasil já passou os EUA no terceiro lugar
update questions set explanation = 'Segundo o USDA para 2025/26, a China lidera a produção mundial de algodão, seguida por Índia, Brasil e Estados Unidos.'
 where id = 'e8dff95c-8c15-4761-a0c8-7e5c2df09670';
update question_translations set explanation = 'According to the USDA for 2025/26, China leads world cotton production, followed by India, Brazil and the United States.'
 where question_id = 'e8dff95c-8c15-4761-a0c8-7e5c2df09670' and locale = 'en';
update question_translations set explanation = 'Según el USDA para 2025/26, China lidera la producción mundial de algodón, seguida por India, Brasil y Estados Unidos.'
 where question_id = 'e8dff95c-8c15-4761-a0c8-7e5c2df09670' and locale = 'es';

-- deserto: "ausência quase total de umidade" é exagero; o critério é a precipitação
update questions set options = array['Amplitude térmica sempre pequena', 'Temperaturas sempre baixas', 'Precipitação muito baixa e forte aridez', 'Chuvas constantes e regulares'], explanation = 'Climas desérticos são definidos principalmente pela escassez de precipitação e pelo déficit hídrico, não por uma temperatura específica.'
 where id = '4a41107a-374f-4716-9a12-4a57ce1546d3';
update question_translations set options = array['A temperature range that is always small', 'Temperatures that are always low', 'Very low precipitation and strong aridity', 'Constant, regular rainfall'], explanation = 'Desert climates are defined mainly by scarce precipitation and water deficit, not by any particular temperature.'
 where question_id = '4a41107a-374f-4716-9a12-4a57ce1546d3' and locale = 'en';
update question_translations set options = array['Una amplitud térmica siempre pequeña', 'Temperaturas siempre bajas', 'Precipitación muy baja y fuerte aridez', 'Lluvias constantes y regulares'], explanation = 'Los climas desérticos se definen principalmente por la escasez de precipitación y el déficit hídrico, no por una temperatura específica.'
 where question_id = '4a41107a-374f-4716-9a12-4a57ce1546d3' and locale = 'es';

-- continentes: o modelo em questão é o de sete continentes
update questions set prompt = 'No modelo de sete continentes, adotado em vários países, a América é representada por quantos continentes?', explanation = 'Nesse modelo, América do Norte e América do Sul são continentes distintos; em outros, como o mais comum no Brasil, a América é um único continente.'
 where id = '8bcaf894-c918-49ea-8a5b-5e3f1b5f2f7c';
update question_translations set prompt = 'In the seven-continent model used in several countries, the Americas are represented by how many continents?', explanation = 'In this model, North America and South America are separate continents; in others, such as the one most common in Brazil, the Americas form a single continent.'
 where question_id = '8bcaf894-c918-49ea-8a5b-5e3f1b5f2f7c' and locale = 'en';
update question_translations set prompt = 'En el modelo de siete continentes, adoptado en varios países, América está representada por ¿cuántos continentes?', explanation = 'En ese modelo, América del Norte y América del Sur son continentes distintos; en otros, como el más común en Brasil, América es un único continente.'
 where question_id = '8bcaf894-c918-49ea-8a5b-5e3f1b5f2f7c' and locale = 'es';

-- OTAN: aliança transatlântica que inclui a Turquia
update questions set explanation = 'A OTAN é uma aliança político-militar transatlântica. Seus membros incluem Estados Unidos, Canadá, dezenas de países europeus e a Turquia.'
 where id = 'c7975b15-f3ce-462c-acc9-085a37548590';
update question_translations set explanation = 'NATO is a transatlantic political and military alliance. Its members include the United States, Canada, dozens of European countries and Turkey.'
 where question_id = 'c7975b15-f3ce-462c-acc9-085a37548590' and locale = 'en';
update question_translations set explanation = 'La OTAN es una alianza político-militar transatlántica. Sus miembros incluyen a Estados Unidos, Canadá, decenas de países europeos y Turquía.'
 where question_id = 'c7975b15-f3ce-462c-acc9-085a37548590' and locale = 'es';

-- BRICS: "originalmente" era BRIC; a África do Sul entrou em 2011
update questions set prompt = 'Antes das ampliações recentes, quais cinco países formavam o grupo BRICS?', explanation = 'Nascido como BRIC (Brasil, Rússia, Índia e China), o grupo recebeu a África do Sul em 2011 e foi ampliado de novo a partir de 2024.'
 where id = '89d6e89d-8c00-4642-a5a1-ef3092c2b7c3';
update question_translations set prompt = 'Before the recent expansions, which five countries made up the BRICS group?', explanation = 'Founded as BRIC (Brazil, Russia, India and China), the group admitted South Africa in 2011 and was expanded again from 2024.'
 where question_id = '89d6e89d-8c00-4642-a5a1-ef3092c2b7c3' and locale = 'en';
update question_translations set prompt = 'Antes de las ampliaciones recientes, ¿qué cinco países formaban el grupo BRICS?', explanation = 'Nacido como BRIC (Brasil, Rusia, India y China), el grupo incorporó a Sudáfrica en 2011 y volvió a ampliarse a partir de 2024.'
 where question_id = '89d6e89d-8c00-4642-a5a1-ef3092c2b7c3' and locale = 'es';

-- Andes: a mais extensa CONTINENTAL
update questions set prompt = 'Qual é a cordilheira continental mais extensa do mundo, ao longo da costa oeste da América do Sul?', explanation = 'Os Andes são a cadeia montanhosa continental mais extensa do mundo: cerca de 7 mil km, atravessando sete países sul-americanos.'
 where id = '1c7ae39e-17c7-4f2e-b59e-bd094c864308';
update question_translations set prompt = 'What is the longest continental mountain range in the world, along the west coast of South America?', explanation = 'The Andes are the longest continental mountain range in the world: about 7,000 km, crossing seven South American countries.'
 where question_id = '1c7ae39e-17c7-4f2e-b59e-bd094c864308' and locale = 'en';
update question_translations set prompt = '¿Cuál es la cordillera continental más extensa del mundo, a lo largo de la costa oeste de América del Sur?', explanation = 'Los Andes son la cadena montañosa continental más extensa del mundo: unos 7 mil km, atravesando siete países sudamericanos.'
 where question_id = '1c7ae39e-17c7-4f2e-b59e-bd094c864308' and locale = 'es';

-- Fuji: a Agência Meteorológica do Japão o classifica como ativo
update questions set options = array['Vulcão ativo, embora não esteja em erupção', 'Vulcão extinto', 'Montanha sem origem vulcânica', 'Vulcão submarino'], explanation = 'O Fuji é um estratovulcão cuja última erupção foi em 1707–1708. A Agência Meteorológica do Japão o inclui entre os vulcões ativos; por isso não é extinto.'
 where id = '279b6451-63b6-4486-be9c-85ae6cd1a4c1';
update question_translations set options = array['An active volcano, though not currently erupting', 'An extinct volcano', 'A mountain of non-volcanic origin', 'A submarine volcano'], explanation = 'Fuji is a stratovolcano whose last eruption was in 1707–1708. The Japan Meteorological Agency lists it among the active volcanoes, so it is not extinct.'
 where question_id = '279b6451-63b6-4486-be9c-85ae6cd1a4c1' and locale = 'en';
update question_translations set options = array['Volcán activo, aunque no está en erupción', 'Volcán extinto', 'Montaña sin origen volcánico', 'Volcán submarino'], explanation = 'El Fuji es un estratovolcán cuya última erupción fue en 1707–1708. La Agencia Meteorológica de Japón lo incluye entre los volcanes activos; por eso no está extinto.'
 where question_id = '279b6451-63b6-4486-be9c-85ae6cd1a4c1' and locale = 'es';
