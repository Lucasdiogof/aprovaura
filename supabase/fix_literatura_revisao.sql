-- Literatura: 6 correções aceitas da revisão externa (2026-09-30)
--
-- Nenhum gabarito estava errado. Mensagem é o único LIVRO em português de
-- Pessoa em vida; O Cortiço é "um dos principais" romances naturalistas;
-- "antecipa o Realismo" é leitura contestada das Memórias de um Sargento de
-- Milícias; há teatro com narrador, então o traço do gênero dramático é a
-- representação; e o nome "literatura de cordel" veio de Portugal e só se
-- difundiu no Brasil no século XX (dossiê do IPHAN).
--
-- Só o texto muda: a ORDEM das alternativas é preservada, para o gabarito
-- não se mexer e as traduções seguirem alinhadas por posição. Cada
-- update grava o valor final inteiro, então rodar de novo não muda nada.

-- Mensagem: único LIVRO em português (Pessoa publicou poemas avulsos em revistas)
update questions set prompt = 'Mensagem (1934), único livro em português publicado por Fernando Pessoa em vida, trata:', explanation = 'Mensagem revisita figuras e episódios da história portuguesa e o sebastianismo, em tom simbólico, místico e patriótico; nela está o poema "Mar Português".'
 where id = 'b5708da4-32bf-57a3-ba6c-5730faa07579';
update question_translations set prompt = 'Mensagem (1934), the only book in Portuguese that Fernando Pessoa published in his lifetime, deals with:', explanation = 'Mensagem revisits figures and episodes of Portuguese history and Sebastianism, in a symbolic, mystical and patriotic tone; it contains the poem "Portuguese Sea".'
 where question_id = 'b5708da4-32bf-57a3-ba6c-5730faa07579' and locale = 'en';
update question_translations set prompt = 'Mensagem (1934), único libro en portugués publicado por Fernando Pessoa en vida, trata:', explanation = 'Mensagem revisita figuras y episodios de la historia portuguesa y el sebastianismo, en tono simbólico, místico y patriótico; en él está el poema "Mar portugués".'
 where question_id = 'b5708da4-32bf-57a3-ba6c-5730faa07579' and locale = 'es';

-- O Cortiço: "um dos principais", não "o principal"
update questions set prompt = 'O Cortiço (1890), de Aluísio Azevedo, é um dos principais romances do:', explanation = 'Obra central do Naturalismo brasileiro, retrata a vida coletiva de um cortiço carioca e mostra o meio como força que determina as personagens.'
 where id = '9d205da7-631c-5141-ab0b-f169f88395eb';
update question_translations set prompt = 'O Cortiço (The Slum, 1890), by Aluísio Azevedo, is one of the main novels of:', explanation = 'A central work of Brazilian Naturalism, it portrays collective life in a Rio tenement and shows the environment as a force that determines the characters.'
 where question_id = '9d205da7-631c-5141-ab0b-f169f88395eb' and locale = 'en';
update question_translations set prompt = 'O Cortiço (El conventillo, 1890), de Aluísio Azevedo, es una de las principales novelas del:', explanation = 'Obra central del Naturalismo brasileño, retrata la vida colectiva de un conventillo de Río y muestra el ambiente como fuerza que determina a los personajes.'
 where question_id = '9d205da7-631c-5141-ab0b-f169f88395eb' and locale = 'es';

-- Memórias de um Sargento de Milícias: "antecipa o Realismo" é leitura contestada
update questions set explanation = 'A obra se afasta da idealização dominante no Romantismo ao retratar com humor personagens populares do Rio do início do século XIX e o anti-herói Leonardo.'
 where id = 'bdd9d3c0-93c3-5393-bb23-31c11c740d3c';
update question_translations set explanation = 'The work departs from the idealization dominant in Romanticism by humorously portraying ordinary people of early 19th-century Rio and the anti-hero Leonardo.'
 where question_id = 'bdd9d3c0-93c3-5393-bb23-31c11c740d3c' and locale = 'en';
update question_translations set explanation = 'La obra se aparta de la idealización dominante en el Romanticismo al retratar con humor a personajes populares del Río de inicios del siglo XIX y al antihéroe Leonardo.'
 where question_id = 'bdd9d3c0-93c3-5393-bb23-31c11c740d3c' and locale = 'es';

-- gênero dramático: há peças com narrador (Brecht); o traço é a representação
update questions set options = array['Dos diálogos e ações das personagens, pensados para a representação', 'Da voz de um narrador onisciente', 'De versos que expressam só sentimentos', 'De notas de rodapé'], explanation = 'No gênero dramático, a ação se apresenta sobretudo pelas falas e ações das personagens, pensadas para a cena; as rubricas orientam cenário, gestos e movimentos.'
 where id = '33bdecee-4de1-5924-b2cf-ecbef5835759';
update question_translations set options = array['The characters'' dialogues and actions, meant to be performed', 'The voice of an omniscient narrator', 'Verses that express only feelings', 'Footnotes'], explanation = 'In the dramatic genre, the action comes mainly through what the characters say and do, meant for the stage; stage directions guide setting, gestures and movement.'
 where question_id = '33bdecee-4de1-5924-b2cf-ecbef5835759' and locale = 'en';
update question_translations set options = array['Los diálogos y acciones de los personajes, pensados para la representación', 'La voz de un narrador omnisciente', 'Versos que expresan solo sentimientos', 'Notas al pie'], explanation = 'En el género dramático, la acción se presenta sobre todo por las palabras y acciones de los personajes, pensadas para la escena; las acotaciones orientan el escenario, los gestos y los movimientos.'
 where question_id = '33bdecee-4de1-5924-b2cf-ecbef5835759' and locale = 'es';

-- cordel: data e livro do registro no IPHAN
update questions set explanation = 'Em 19 de setembro de 2018, o IPHAN inscreveu a Literatura de Cordel no Livro de Registro das Formas de Expressão, reconhecendo-a como expressão cultural viva, ligada à oralidade e às feiras.'
 where id = 'ba71cd31-09d4-5e73-bb1e-5e4f32de3dc2';
update question_translations set explanation = 'On 19 September 2018, IPHAN entered cordel literature in its Register of Forms of Expression, recognizing it as a living cultural expression linked to orality and fairs.'
 where question_id = 'ba71cd31-09d4-5e73-bb1e-5e4f32de3dc2' and locale = 'en';
update question_translations set explanation = 'El 19 de septiembre de 2018, el IPHAN inscribió la Literatura de Cordel en el Libro de Registro de las Formas de Expresión, reconociéndola como expresión cultural viva, ligada a la oralidad y a las ferias.'
 where question_id = 'ba71cd31-09d4-5e73-bb1e-5e4f32de3dc2' and locale = 'es';

-- cordel: o nome veio de Portugal e só se difundiu no Brasil no século XX
update questions set explanation = 'O nome vem de Portugal, onde os folhetos eram vendidos pendurados em cordões. No Brasil, os poetas chamavam suas obras de folhetos ou romances; "literatura de cordel" se difundiu a partir de meados do século XX.'
 where id = '06ceab65-0b38-525d-9db0-93e981b0f16c';
update question_translations set explanation = 'The name comes from Portugal, where the booklets were sold hanging on strings. In Brazil, poets called their works folhetos or romances; "cordel literature" spread from the mid-20th century on.'
 where question_id = '06ceab65-0b38-525d-9db0-93e981b0f16c' and locale = 'en';
update question_translations set explanation = 'El nombre viene de Portugal, donde los folletos se vendían colgados de cordeles. En Brasil, los poetas llamaban a sus obras folhetos o romances; "literatura de cordel" se difundió a partir de mediados del siglo XX.'
 where question_id = '06ceab65-0b38-525d-9db0-93e981b0f16c' and locale = 'es';
