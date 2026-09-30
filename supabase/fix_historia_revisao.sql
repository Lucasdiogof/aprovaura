-- História: 21 correções aceitas da revisão externa (2026-09-30)
--
-- Nenhum gabarito deslocado. Sete questões eram DUPLICATAS de outras do banco
-- e foram substituídas por temas que faltavam: AI-5 (havia duas) vira AI-2;
-- Dia do Fico (duas) vira Abertura dos Portos; Constituição Cidadã (duas) vira
-- Diretas Já e Colégio Eleitoral; reivindicação de 1932 (duas) vira os
-- interventores; Constituição de 1934 (duas) vira MMDC; João Pessoa como
-- estopim (três) vira a posse impedida de Júlio Prestes; e o paradoxo da guerra
-- contra o fascismo (duas) vira o Manifesto dos Mineiros. Interventores e MMDC
-- trocam de nível entre si (fácil/médio), então a distribuição não muda.
--
-- Uma era falsa: "como consequência de 1932, Vargas convocou a Constituinte" —
-- o Código Eleitoral e a data da eleição já estavam definidos antes da revolta.
-- Outra imprecisa: o Brasil declarou guerra à Alemanha e à Itália em 1942, não
-- ao "Eixo" (ao Japão, só em 1945). O resto é nuance historiográfica.
--
-- Recusadas: reescritas que só alongavam a alternativa certa (Intentona, Igreja
-- medieval, feudalismo, tupi-guarani, Mansa Musa). História não tem fonte.
--
-- Nas questões corrigidas só no texto, a ordem das alternativas é mantida.
-- Nas reescritas, as alternativas novas foram arrumadas para a certa cair
-- no correct_index que a questão já tinha, então o gabarito por letra não
-- muda. As três línguas usam a mesma ordem. Cada update grava o valor
-- final inteiro, então rodar de novo não muda nada.

-- Conferência de Berlim: fixou regras de ocupação; não desenhou sozinha as fronteiras
update questions set prompt = 'A Conferência de Berlim (1884–1885), no contexto do imperialismo europeu, contribuiu principalmente para:', options = array['Estabelecer regras entre as potências europeias para novas ocupações e acelerar a partilha colonial da África', 'Conceder independência imediata às colônias africanas', 'Criar fronteiras africanas por decisão conjunta dos povos locais', 'Proibir a expansão territorial europeia na África'], explanation = 'A conferência fixou regras para o reconhecimento de ocupações coloniais e intensificou a corrida europeia pela África; ela não desenhou sozinha todas as fronteiras do continente.'
 where id = '319aa131-30e0-4027-a054-9d4a0d9dfc59';
update question_translations set prompt = 'The Berlin Conference (1884–1885), in the context of European imperialism, mainly contributed to:', options = array['Setting rules among the European powers for new occupations and speeding up the colonial partition of Africa', 'Granting immediate independence to the African colonies', 'Drawing African borders by joint decision of the local peoples', 'Banning European territorial expansion in Africa'], explanation = 'The conference set rules for recognizing colonial occupations and intensified the European scramble for Africa; it did not by itself draw all the continent''s borders.'
 where question_id = '319aa131-30e0-4027-a054-9d4a0d9dfc59' and locale = 'en';
update question_translations set prompt = 'La Conferencia de Berlín (1884–1885), en el contexto del imperialismo europeo, contribuyó principalmente a:', options = array['Establecer reglas entre las potencias europeas para nuevas ocupaciones y acelerar el reparto colonial de África', 'Conceder la independencia inmediata a las colonias africanas', 'Trazar fronteras africanas por decisión conjunta de los pueblos locales', 'Prohibir la expansión territorial europea en África'], explanation = 'La conferencia fijó reglas para el reconocimiento de ocupaciones coloniales e intensificó la carrera europea por África; no trazó por sí sola todas las fronteras del continente.'
 where question_id = '319aa131-30e0-4027-a054-9d4a0d9dfc59' and locale = 'es';

-- astecas: Mesoamérica, não "América Central"; e sem hierarquia de "mais desenvolvida"
update questions set prompt = 'Antes da chegada dos europeus, uma das principais civilizações da Mesoamérica foi a dos:', explanation = 'Os astecas construíram um importante império mesoamericano com capital em Tenochtitlán, no local da atual Cidade do México.'
 where id = '50c4c0cb-9fa8-4b06-b8ff-9ba7832a96b4';
update question_translations set prompt = 'Before the arrival of the Europeans, one of the main civilizations of Mesoamerica was that of the:', explanation = 'The Aztecs built an important Mesoamerican empire with its capital at Tenochtitlan, on the site of present-day Mexico City.'
 where question_id = '50c4c0cb-9fa8-4b06-b8ff-9ba7832a96b4' and locale = 'en';
update question_translations set prompt = 'Antes de la llegada de los europeos, una de las principales civilizaciones de Mesoamérica fue la de los:', explanation = 'Los aztecas construyeron un importante imperio mesoamericano con capital en Tenochtitlan, en el lugar de la actual Ciudad de México.'
 where question_id = '50c4c0cb-9fa8-4b06-b8ff-9ba7832a96b4' and locale = 'es';

-- duplicata do AI-5 (há outra questão sobre ele) vira questão sobre o AI-2
update questions set prompt = 'O Ato Institucional nº 2 (AI-2), de 1965, teve entre suas consequências:', options = array['A extinção dos partidos existentes, que abriu caminho ao bipartidarismo entre ARENA e MDB', 'A revogação de todos os Atos Institucionais anteriores', 'A anistia ampla aos opositores do regime', 'A criação imediata de eleições diretas para presidente'], explanation = 'O AI-2 extinguiu os partidos então existentes; um ato complementar do mesmo ano organizou o sistema partidário que ficou restrito a ARENA e MDB.'
 where id = '7c08fee6-837b-4a3c-831b-543c21bd35d4';
update question_translations set prompt = 'Among the consequences of Institutional Act No. 2 (AI-2), of 1965, was:', options = array['The abolition of the existing parties, which paved the way for the two-party system of ARENA and MDB', 'The repeal of all previous Institutional Acts', 'A broad amnesty for opponents of the regime', 'The immediate creation of direct presidential elections'], explanation = 'AI-2 abolished the parties that existed at the time; a complementary act that same year set up the party system restricted to ARENA and MDB.'
 where question_id = '7c08fee6-837b-4a3c-831b-543c21bd35d4' and locale = 'en';
update question_translations set prompt = 'El Acto Institucional n.º 2 (AI-2), de 1965, tuvo entre sus consecuencias:', options = array['La extinción de los partidos existentes, que abrió el camino al bipartidismo entre ARENA y MDB', 'La revocación de todos los Actos Institucionales anteriores', 'Una amnistía amplia a los opositores del régimen', 'La creación inmediata de elecciones directas para presidente'], explanation = 'El AI-2 extinguió los partidos existentes en la época; un acto complementario del mismo año organizó el sistema partidario restringido a ARENA y MDB.'
 where question_id = '7c08fee6-837b-4a3c-831b-543c21bd35d4' and locale = 'es';

-- 1942: a guerra foi declarada à Alemanha e à Itália; ao Japão, só em 1945
update questions set prompt = 'O Brasil declarou guerra à Alemanha e à Itália em 1942, principalmente após:', explanation = 'O afundamento de navios brasileiros por submarinos do Eixo, sobretudo alemães, em 1942 gerou forte comoção popular e antecedeu a declaração de guerra. Ao Japão, o Brasil só declarou guerra em 1945.'
 where id = 'd964b4f8-7c6c-4ced-b653-fe477a65fa54';
update question_translations set prompt = 'Brazil declared war on Germany and Italy in 1942, mainly after:', explanation = 'The sinking of Brazilian ships by Axis submarines, mostly German, in 1942 caused great public outrage and preceded the declaration of war. Brazil only declared war on Japan in 1945.'
 where question_id = 'd964b4f8-7c6c-4ced-b653-fe477a65fa54' and locale = 'en';
update question_translations set prompt = 'Brasil declaró la guerra a Alemania e Italia en 1942, principalmente tras:', explanation = 'El hundimiento de buques brasileños por submarinos del Eje, sobre todo alemanes, en 1942 causó una fuerte conmoción popular y precedió a la declaración de guerra. A Japón, Brasil solo le declaró la guerra en 1945.'
 where question_id = 'd964b4f8-7c6c-4ced-b653-fe477a65fa54' and locale = 'es';

-- DIP: nomeia a "Hora do Brasil" e tira o juízo "pai dos pobres" da explicação
update questions set explanation = 'O DIP centralizou a censura e a propaganda do Estado Novo em jornais, rádio, cinema e artes, e usava transmissões oficiais, como a "Hora do Brasil", para divulgar o regime.'
 where id = '1d518a42-9c1a-5f48-907e-c0d2b3bdeda3';
update question_translations set explanation = 'The DIP centralized the Estado Novo''s censorship and propaganda in newspapers, radio, cinema and the arts, and used official broadcasts such as "A Hora do Brasil" to promote the regime.'
 where question_id = '1d518a42-9c1a-5f48-907e-c0d2b3bdeda3' and locale = 'en';
update question_translations set explanation = 'El DIP centralizó la censura y la propaganda del Estado Novo en periódicos, radio, cine y artes, y usaba transmisiones oficiales, como "A Hora do Brasil", para divulgar el régimen.'
 where question_id = '1d518a42-9c1a-5f48-907e-c0d2b3bdeda3' and locale = 'es';

-- duplicata (há outra sobre o paradoxo da guerra e o fim do Estado Novo) vira questão sobre o Manifesto dos Mineiros
update questions set prompt = 'O Manifesto dos Mineiros, divulgado em 1943, é lembrado por:', options = array['Defender a redemocratização e criticar a continuidade do Estado Novo', 'Propor a entrada do Brasil na guerra ao lado do Eixo', 'Defender a restauração da monarquia', 'Pedir a ampliação dos poderes ditatoriais de Vargas'], explanation = 'Assinado por figuras da oposição em Minas Gerais, o Manifesto dos Mineiros foi a primeira manifestação pública importante das pressões pela redemocratização.'
 where id = '3b8ec499-beb3-47ec-8c1a-446f6b9c389b';
update question_translations set prompt = 'The Manifesto dos Mineiros (Manifesto of the Mineiros), released in 1943, is remembered for:', options = array['Defending redemocratization and criticizing the continuation of the Estado Novo', 'Proposing that Brazil enter the war on the side of the Axis', 'Defending the restoration of the monarchy', 'Asking for an expansion of Vargas''s dictatorial powers'], explanation = 'Signed by opposition figures in Minas Gerais, the Manifesto dos Mineiros was the first major public expression of the pressure for redemocratization.'
 where question_id = '3b8ec499-beb3-47ec-8c1a-446f6b9c389b' and locale = 'en';
update question_translations set prompt = 'El Manifiesto de los Mineros (Manifesto dos Mineiros), divulgado en 1943, es recordado por:', options = array['Defender la redemocratización y criticar la continuidad del Estado Novo', 'Proponer la entrada de Brasil en la guerra del lado del Eje', 'Defender la restauración de la monarquía', 'Pedir la ampliación de los poderes dictatoriales de Vargas'], explanation = 'Firmado por figuras de la oposición en Minas Gerais, el Manifiesto de los Mineros fue la primera manifestación pública importante de las presiones por la redemocratización.'
 where question_id = '3b8ec499-beb3-47ec-8c1a-446f6b9c389b' and locale = 'es';

-- integralismo: tira a origem tupi de "Anauê", que é contestada
update questions set explanation = 'Os integralistas usavam a letra grega sigma (Σ) como símbolo e a saudação "Anauê!" como cumprimento característico do movimento.'
 where id = '4d7eee47-acc4-4a33-ade0-bd06a385aa23';
update question_translations set explanation = 'The Integralists used the Greek letter sigma (Σ) as their symbol and the salute "Anauê!" as the movement''s characteristic greeting.'
 where question_id = '4d7eee47-acc4-4a33-ade0-bd06a385aa23' and locale = 'en';
update question_translations set explanation = 'Los integralistas usaban la letra griega sigma (Σ) como símbolo y el saludo "¡Anauê!" como saludo característico del movimiento.'
 where question_id = '4d7eee47-acc4-4a33-ade0-bd06a385aa23' and locale = 'es';

-- duplicata (há outra sobre a reivindicação de 1932) vira questão sobre os interventores
update questions set prompt = 'Uma medida de centralização adotada por Vargas no Governo Provisório, após 1930, foi:', options = array['Nomear interventores para governar os estados, no lugar das antigas autoridades estaduais', 'Devolver a Presidência às oligarquias de São Paulo e Minas Gerais', 'Restaurar a autonomia plena dos estados prevista na Constituição de 1891', 'Abolir todos os ministérios federais'], explanation = 'O Governo Provisório nomeou interventores nos estados, reduzindo a autonomia das antigas oligarquias e fortalecendo o poder central.'
 where id = '132a0fe2-1c4e-4c6e-8d08-c9d182f8ceca';
update question_translations set prompt = 'A centralizing measure adopted by Vargas in the Provisional Government, after 1930, was:', options = array['Appointing interventors to govern the states, replacing the former state authorities', 'Returning the presidency to the oligarchies of São Paulo and Minas Gerais', 'Restoring the full state autonomy provided for in the 1891 Constitution', 'Abolishing all federal ministries'], explanation = 'The Provisional Government appointed interventors in the states, reducing the autonomy of the old oligarchies and strengthening central power.'
 where question_id = '132a0fe2-1c4e-4c6e-8d08-c9d182f8ceca' and locale = 'en';
update question_translations set prompt = 'Una medida de centralización adoptada por Vargas en el Gobierno Provisional, después de 1930, fue:', options = array['Nombrar interventores para gobernar los estados, en lugar de las antiguas autoridades estatales', 'Devolver la Presidencia a las oligarquías de São Paulo y Minas Gerais', 'Restaurar la plena autonomía de los estados prevista en la Constitución de 1891', 'Abolir todos los ministerios federales'], explanation = 'El Gobierno Provisional nombró interventores en los estados, reduciendo la autonomía de las antiguas oligarquías y fortaleciendo el poder central.'
 where question_id = '132a0fe2-1c4e-4c6e-8d08-c9d182f8ceca' and locale = 'es';
update questions set difficulty = 'facil'
 where id = '132a0fe2-1c4e-4c6e-8d08-c9d182f8ceca';

-- duplicata (há outra sobre a Constituição de 1934) vira questão sobre o MMDC
update questions set prompt = 'A sigla MMDC, associada à mobilização paulista de 1932, homenageava:', options = array['Martins, Miragaia, Dráusio e Camargo, jovens mortos em confronto com forças ligadas ao governo', 'Quatro comandantes da Coluna Prestes', 'Quatro ministros responsáveis pela Constituição de 1934', 'Os quatro primeiros interventores nomeados por Vargas'], explanation = 'MMDC reúne as iniciais de Martins, Miragaia, Dráusio e Camargo, mortos em maio de 1932 e transformados em símbolos do movimento constitucionalista paulista.'
 where id = 'd61f305a-7dd6-4dcd-b2b1-97fa272dac80';
update question_translations set prompt = 'The acronym MMDC, associated with the 1932 São Paulo mobilization, honored:', options = array['Martins, Miragaia, Dráusio and Camargo, young men killed in a clash with pro-government forces', 'Four commanders of the Prestes Column', 'Four ministers responsible for the 1934 Constitution', 'The first four interventors appointed by Vargas'], explanation = 'MMDC gathers the initials of Martins, Miragaia, Dráusio and Camargo, killed in May 1932 and turned into symbols of the São Paulo constitutionalist movement.'
 where question_id = 'd61f305a-7dd6-4dcd-b2b1-97fa272dac80' and locale = 'en';
update question_translations set prompt = 'La sigla MMDC, asociada a la movilización paulista de 1932, homenajeaba a:', options = array['Martins, Miragaia, Dráusio y Camargo, jóvenes muertos en un enfrentamiento con fuerzas afines al gobierno', 'Cuatro comandantes de la Columna Prestes', 'Cuatro ministros responsables de la Constitución de 1934', 'Los cuatro primeros interventores nombrados por Vargas'], explanation = 'MMDC reúne las iniciales de Martins, Miragaia, Dráusio y Camargo, muertos en mayo de 1932 y convertidos en símbolos del movimiento constitucionalista paulista.'
 where question_id = 'd61f305a-7dd6-4dcd-b2b1-97fa272dac80' and locale = 'es';
update questions set difficulty = 'medio'
 where id = 'd61f305a-7dd6-4dcd-b2b1-97fa272dac80';

-- 1932: a data da Constituinte já estava marcada antes da revolta; "como consequência, convocou" era falso
update questions set prompt = 'Depois de derrotar militarmente a Revolução Constitucionalista de 1932, o governo Vargas:', options = array['Manteve a eleição da Assembleia Nacional Constituinte, realizada em 1933', 'Renunciou ao poder imediatamente', 'Anexou o estado de São Paulo à Argentina', 'Aboliu todos os estados federativos'], explanation = 'O Código Eleitoral e a data da eleição constituinte já estavam definidos antes da revolta. Vencida a guerra, o governo manteve o calendário, e a nova Constituição foi promulgada em 1934.'
 where id = 'fa86774e-cd1c-4137-886d-126a7538d720';
update question_translations set prompt = 'After militarily defeating the Constitutionalist Revolution of 1932, the Vargas government:', options = array['Kept the election of the National Constituent Assembly, held in 1933', 'Resigned from power immediately', 'Annexed the state of São Paulo to Argentina', 'Abolished all the federal states'], explanation = 'The Electoral Code and the date of the constituent election had been set before the revolt. Having won the war, the government kept the schedule, and the new Constitution was enacted in 1934.'
 where question_id = 'fa86774e-cd1c-4137-886d-126a7538d720' and locale = 'en';
update question_translations set prompt = 'Tras derrotar militarmente a la Revolución Constitucionalista de 1932, el gobierno de Vargas:', options = array['Mantuvo la elección de la Asamblea Nacional Constituyente, realizada en 1933', 'Renunció al poder inmediatamente', 'Anexó el estado de São Paulo a Argentina', 'Abolió todos los estados federativos'], explanation = 'El Código Electoral y la fecha de la elección constituyente ya estaban definidos antes de la revuelta. Ganada la guerra, el gobierno mantuvo el calendario, y la nueva Constitución se promulgó en 1934.'
 where question_id = 'fa86774e-cd1c-4137-886d-126a7538d720' and locale = 'es';

-- duplicata (há mais duas sobre João Pessoa como estopim) vira questão sobre Júlio Prestes
update questions set prompt = 'Nas eleições presidenciais de 1930, Júlio Prestes venceu oficialmente o pleito, mas:', options = array['Não tomou posse, porque a Revolução de 1930 depôs Washington Luís', 'Renunciou espontaneamente antes da apuração', 'Morreu antes da posse', 'Foi derrotado por Getúlio Vargas no segundo turno'], explanation = 'Júlio Prestes foi declarado vencedor, mas o movimento de outubro de 1930 depôs Washington Luís e impediu sua posse.'
 where id = 'd5185922-cc6c-46d9-883a-de58f0cd96fe';
update question_translations set prompt = 'In the 1930 presidential election, Júlio Prestes officially won, but:', options = array['He never took office, because the 1930 Revolution deposed Washington Luís', 'He resigned of his own accord before the count', 'He died before taking office', 'He was defeated by Getúlio Vargas in a runoff'], explanation = 'Júlio Prestes was declared the winner, but the October 1930 movement deposed Washington Luís and prevented him from taking office.'
 where question_id = 'd5185922-cc6c-46d9-883a-de58f0cd96fe' and locale = 'en';
update question_translations set prompt = 'En las elecciones presidenciales de 1930, Júlio Prestes ganó oficialmente, pero:', options = array['No asumió el cargo, porque la Revolución de 1930 depuso a Washington Luís', 'Renunció por voluntad propia antes del escrutinio', 'Murió antes de asumir', 'Fue derrotado por Getúlio Vargas en la segunda vuelta'], explanation = 'Júlio Prestes fue declarado vencedor, pero el movimiento de octubre de 1930 depuso a Washington Luís e impidió que asumiera.'
 where question_id = 'd5185922-cc6c-46d9-883a-de58f0cd96fe' and locale = 'es';

-- reconhecimento de 1825: o valor da indenização
update questions set explanation = 'O tratado de reconhecimento previa o pagamento de 2 milhões de libras a Portugal, operação viabilizada por um empréstimo britânico.'
 where id = '0d49f708-532a-4a4b-a9a5-ff372e779537';
update question_translations set explanation = 'The recognition treaty provided for the payment of 2 million pounds to Portugal, made possible by a British loan.'
 where question_id = '0d49f708-532a-4a4b-a9a5-ff372e779537' and locale = 'en';
update question_translations set explanation = 'El tratado de reconocimiento preveía el pago de 2 millones de libras a Portugal, operación posible gracias a un préstamo británico.'
 where question_id = '0d49f708-532a-4a4b-a9a5-ff372e779537' and locale = 'es';

-- duplicata do Dia do Fico vira questão sobre a Abertura dos Portos (1808)
update questions set prompt = 'A Abertura dos Portos às Nações Amigas, decretada em 1808, representou:', options = array['O fim, na prática, do exclusivo comercial metropolitano, com comércio direto com nações amigas', 'O fechamento definitivo dos portos portugueses', 'A independência política imediata do Brasil', 'A proibição de produtos britânicos no território brasileiro'], explanation = 'A medida rompeu na prática o exclusivo colonial ao permitir o comércio direto com nações amigas, sobretudo a Inglaterra.'
 where id = '2ca0deef-c02a-491d-bcfb-c78d7deea8e7';
update question_translations set prompt = 'The Opening of the Ports to Friendly Nations, decreed in 1808, meant:', options = array['The practical end of the metropolitan trade monopoly, with direct trade with friendly nations', 'The permanent closure of Portuguese ports', 'Brazil''s immediate political independence', 'A ban on British goods in Brazilian territory'], explanation = 'The measure broke the colonial monopoly in practice by allowing direct trade with friendly nations, above all England.'
 where question_id = '2ca0deef-c02a-491d-bcfb-c78d7deea8e7' and locale = 'en';
update question_translations set prompt = 'La Apertura de los Puertos a las Naciones Amigas, decretada en 1808, representó:', options = array['El fin, en la práctica, del monopolio comercial metropolitano, con comercio directo con naciones amigas', 'El cierre definitivo de los puertos portugueses', 'La independencia política inmediata de Brasil', 'La prohibición de productos británicos en el territorio brasileño'], explanation = 'La medida rompió en la práctica el monopolio colonial al permitir el comercio directo con naciones amigas, sobre todo Inglaterra.'
 where question_id = '2ca0deef-c02a-491d-bcfb-c78d7deea8e7' and locale = 'es';

-- duplicata da Constituição Cidadã vira questão sobre as Diretas Já e o Colégio Eleitoral
update questions set prompt = 'A campanha das Diretas Já (1983–1984) não conseguiu aprovar a Emenda Dante de Oliveira. Como foi, então, a eleição presidencial de 1985?', options = array['Indireta, pelo Colégio Eleitoral, que escolheu Tancredo Neves', 'Por indicação exclusiva das Forças Armadas', 'Direta, em dois turnos, com vitória de José Sarney', 'Por plebiscito nacional'], explanation = 'Como a emenda das eleições diretas não alcançou os votos necessários, a eleição de 1985 continuou indireta, e Tancredo Neves venceu no Colégio Eleitoral.'
 where id = '9815fd3c-bc5d-4c5d-859e-413f9fa6e655';
update question_translations set prompt = 'The Diretas Já campaign (1983–1984) failed to pass the Dante de Oliveira Amendment. How, then, was the 1985 presidential election held?', options = array['Indirectly, by the Electoral College, which chose Tancredo Neves', 'By appointment of the Armed Forces alone', 'Directly, in two rounds, won by José Sarney', 'By national plebiscite'], explanation = 'Since the direct-election amendment did not get the votes it needed, the 1985 election remained indirect, and Tancredo Neves won in the Electoral College.'
 where question_id = '9815fd3c-bc5d-4c5d-859e-413f9fa6e655' and locale = 'en';
update question_translations set prompt = 'La campaña de las Diretas Já (1983–1984) no logró aprobar la Enmienda Dante de Oliveira. ¿Cómo fue, entonces, la elección presidencial de 1985?', options = array['Indirecta, por el Colegio Electoral, que eligió a Tancredo Neves', 'Por designación exclusiva de las Fuerzas Armadas', 'Directa, en dos vueltas, con victoria de José Sarney', 'Por plebiscito nacional'], explanation = 'Como la enmienda de las elecciones directas no alcanzó los votos necesarios, la elección de 1985 siguió siendo indirecta, y Tancredo Neves ganó en el Colegio Electoral.'
 where question_id = '9815fd3c-bc5d-4c5d-859e-413f9fa6e655' and locale = 'es';

-- café com leite: predominância, não alternância automática
update questions set options = array['A predominância das oligarquias de São Paulo (café) e Minas Gerais (leite) na política federal', 'Um acordo comercial entre Brasil e Argentina', 'A política de incentivo à produção de laticínios no Sul do país', 'Um imposto cobrado sobre a exportação de café'], explanation = 'A expressão resume a predominância política das elites paulista e mineira; a ideia de uma alternância automática e perfeita entre os dois estados simplifica a Primeira República.'
 where id = '5629fd8d-2f81-47d2-bd06-77c62756c12d';
update question_translations set options = array['The dominance of the oligarchies of São Paulo (coffee) and Minas Gerais (milk) in federal politics', 'A trade agreement between Brazil and Argentina', 'A policy to encourage dairy production in the South', 'A tax on coffee exports'], explanation = 'The expression sums up the political dominance of the São Paulo and Minas Gerais elites; the idea of an automatic, perfect alternation between the two states oversimplifies the First Republic.'
 where question_id = '5629fd8d-2f81-47d2-bd06-77c62756c12d' and locale = 'en';
update question_translations set options = array['El predominio de las oligarquías de São Paulo (café) y Minas Gerais (leche) en la política federal', 'Un acuerdo comercial entre Brasil y Argentina', 'La política de incentivo a la producción láctea en el Sur del país', 'Un impuesto sobre la exportación de café'], explanation = 'La expresión resume el predominio político de las élites paulista y minera; la idea de una alternancia automática y perfecta entre los dos estados simplifica la Primera República.'
 where question_id = '5629fd8d-2f81-47d2-bd06-77c62756c12d' and locale = 'es';

-- Congresso de Viena: o equilíbrio veio da negociação entre potências, não da Santa Aliança
update questions set explanation = 'O princípio da legitimidade defendia a volta das dinastias depostas pelas guerras revolucionárias e napoleônicas, como os Bourbon na França. O equilíbrio foi buscado em negociações entre as grandes potências; a Santa Aliança veio depois e não o garantiu sozinha.'
 where id = '9f3e9ad2-1d2d-515d-ab6e-fa4e5f3bc550';
update question_translations set explanation = 'The principle of legitimacy called for the return of the dynasties deposed by the revolutionary and Napoleonic wars, such as the Bourbons in France. The balance was sought through negotiations among the great powers; the Holy Alliance came later and did not secure it on its own.'
 where question_id = '9f3e9ad2-1d2d-515d-ab6e-fa4e5f3bc550' and locale = 'en';
update question_translations set explanation = 'El principio de legitimidad defendía el regreso de las dinastías depuestas por las guerras revolucionarias y napoleónicas, como los Borbones en Francia. El equilibrio se buscó en negociaciones entre las grandes potencias; la Santa Alianza vino después y no lo garantizó por sí sola.'
 where question_id = '9f3e9ad2-1d2d-515d-ab6e-fa4e5f3bc550' and locale = 'es';

-- 1917: fevereiro derruba o czar; outubro derruba o Governo Provisório
update questions set explanation = 'Em fevereiro de 1917 o czarismo caiu e formou-se um Governo Provisório; em outubro, os bolcheviques liderados por Lenin o derrubaram e abriram caminho para a União Soviética.'
 where id = '5d9cb94b-177f-4cd4-969a-a751b2d930b3';
update question_translations set explanation = 'In February 1917 tsarism fell and a Provisional Government was formed; in October, the Bolsheviks led by Lenin overthrew it and paved the way for the Soviet Union.'
 where question_id = '5d9cb94b-177f-4cd4-969a-a751b2d930b3' and locale = 'en';
update question_translations set explanation = 'En febrero de 1917 cayó el zarismo y se formó un Gobierno Provisional; en octubre, los bolcheviques liderados por Lenin lo derrocaron y abrieron el camino a la Unión Soviética.'
 where question_id = '5d9cb94b-177f-4cd4-969a-a751b2d930b3' and locale = 'es';

-- Peste Negra: estimativas atuais ficam em torno de um terço ou mais
update questions set explanation = 'A Peste Negra matou uma parcela enorme dos europeus — estimativas atuais falam em cerca de um terço ou mais da população —, causando escassez de mão de obra e crise do feudalismo.'
 where id = '489dea3f-8a39-48c9-b684-3391b281ce3e';
update question_translations set explanation = 'The Black Death killed a huge share of Europeans — current estimates put it at about a third of the population or more — causing labor shortages and the crisis of feudalism.'
 where question_id = '489dea3f-8a39-48c9-b684-3391b281ce3e' and locale = 'en';
update question_translations set explanation = 'La Peste Negra mató a una parte enorme de los europeos —las estimaciones actuales hablan de cerca de un tercio de la población o más—, causando escasez de mano de obra y la crisis del feudalismo.'
 where question_id = '489dea3f-8a39-48c9-b684-3391b281ce3e' and locale = 'es';

-- califados: governaram povos que continuaram diversos, não "uma mesma fé e cultura"
update questions set prompt = 'A expansão dos primeiros califados islâmicos, a partir do século VII, colocou vastos territórios do Oriente Médio e do Mediterrâneo sob:', options = array['Governos muçulmanos, em sociedades que continuaram religiosa e culturalmente diversas', 'O domínio direto do Império Bizantino', 'O controle da Igreja Católica romana', 'Uma federação de reinos cristãos'], explanation = 'Os califados expandiram o domínio político islâmico e favoreceram a difusão do árabe e do Islã, mas governaram populações de diferentes religiões, línguas e tradições.'
 where id = '2e584625-090b-420a-8317-8dec6259ddfb';
update question_translations set prompt = 'The expansion of the first Islamic caliphates, from the 7th century, placed vast territories of the Middle East and the Mediterranean under:', options = array['Muslim governments, over societies that remained religiously and culturally diverse', 'The direct rule of the Byzantine Empire', 'The control of the Roman Catholic Church', 'A federation of Christian kingdoms'], explanation = 'The caliphates expanded Islamic political rule and helped spread Arabic and Islam, but they governed populations of different religions, languages and traditions.'
 where question_id = '2e584625-090b-420a-8317-8dec6259ddfb' and locale = 'en';
update question_translations set prompt = 'La expansión de los primeros califatos islámicos, a partir del siglo VII, puso vastos territorios de Oriente Medio y del Mediterráneo bajo:', options = array['Gobiernos musulmanes, en sociedades que siguieron siendo religiosa y culturalmente diversas', 'El dominio directo del Imperio bizantino', 'El control de la Iglesia católica romana', 'Una federación de reinos cristianos'], explanation = 'Los califatos expandieron el dominio político islámico y favorecieron la difusión del árabe y del islam, pero gobernaron poblaciones de distintas religiones, lenguas y tradiciones.'
 where question_id = '2e584625-090b-420a-8317-8dec6259ddfb' and locale = 'es';

-- Vestfália: a leitura de 1648 como nascimento da soberania moderna é hoje discutida
update questions set explanation = 'Os tratados reconheceram a soberania dos Estados sobre seu território e sua religião, a independência das Províncias Unidas e da Suíça, e enfraqueceram o Sacro Império. Tratar 1648 como o nascimento do sistema moderno de Estados soberanos é leitura tradicional, hoje discutida pela historiografia.'
 where id = '1112fdf5-f4c1-5875-a710-b6e69ae9487f';
update question_translations set explanation = 'The treaties recognized states'' sovereignty over their territory and religion and the independence of the United Provinces and Switzerland, and weakened the Holy Roman Empire. Treating 1648 as the birth of the modern system of sovereign states is a traditional reading, now debated by historians.'
 where question_id = '1112fdf5-f4c1-5875-a710-b6e69ae9487f' and locale = 'en';
update question_translations set explanation = 'Los tratados reconocieron la soberanía de los Estados sobre su territorio y su religión y la independencia de las Provincias Unidas y de Suiza, y debilitaron al Sacro Imperio. Tratar 1648 como el nacimiento del sistema moderno de Estados soberanos es una lectura tradicional, hoy discutida por la historiografía.'
 where question_id = '1112fdf5-f4c1-5875-a710-b6e69ae9487f' and locale = 'es';

-- Renascimento: valorizar o humano não foi abandonar a fé
update questions set explanation = 'O humanismo renascentista valorizou a razão, as capacidades humanas e os textos clássicos; isso conviveu com intensa produção religiosa e não significou abandono da fé cristã.'
 where id = '83762997-ab04-4034-a443-065985421ed7';
update question_translations set explanation = 'Renaissance humanism valued reason, human abilities and classical texts; this coexisted with intense religious output and did not mean abandoning the Christian faith.'
 where question_id = '83762997-ab04-4034-a443-065985421ed7' and locale = 'en';
update question_translations set explanation = 'El humanismo renacentista valoró la razón, las capacidades humanas y los textos clásicos; esto convivió con una intensa producción religiosa y no significó abandonar la fe cristiana.'
 where question_id = '83762997-ab04-4034-a443-065985421ed7' and locale = 'es';
