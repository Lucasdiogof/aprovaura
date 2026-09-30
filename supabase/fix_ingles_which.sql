-- Inglês: questão de referência pronominal com resposta ambígua (2026-09-30)
--
-- Achada na revisão de gabarito de Sociologia, Literatura e Inglês (as 360
-- lidas uma a uma; nenhum outro gabarito errado além dos três já corrigidos em
-- fix_gabarito_espanhol_ingles.sql). Em "The scientists published their
-- findings, which surprised many researchers", o "which" retoma "their
-- findings" com toda a naturalidade, e essa resposta nem estava entre as
-- alternativas. A frase nova só admite a leitura de oração inteira. O id
-- continua o mesmo (id= fixado no fonte).
--
-- Nas questões corrigidas só no texto, a ordem das alternativas é mantida.
-- Nas reescritas, as alternativas novas foram arrumadas para a certa cair
-- no correct_index que a questão já tinha, então o gabarito por letra não
-- muda. As três línguas usam a mesma ordem. Cada update grava o valor
-- final inteiro, então rodar de novo não muda nada.

-- "which" ambíguo: em "published their findings, which surprised", ele retoma "their findings" com naturalidade, e essa resposta nem estava entre as alternativas
update questions set prompt = 'Leia: "The team finished the project two weeks early, which surprised everyone in the company." A que se refere "which"?', options = array['A equipe', 'O fato de a equipe ter terminado o projeto duas semanas antes', 'O projeto', 'A empresa'], explanation = '"Which", depois da vírgula, retoma toda a oração anterior: o que surpreendeu todos não foi a equipe nem o projeto, mas o fato de terem terminado duas semanas antes.'
 where id = 'c33050ce-bff1-57cd-a258-9a60d2549ba6';
update question_translations set prompt = 'Read: "The team finished the project two weeks early, which surprised everyone in the company." What does "which" refer to?', options = array['The team', 'The fact that the team finished the project two weeks early', 'The project', 'The company'], explanation = '"Which", after the comma, refers back to the whole previous clause: what surprised everyone was not the team or the project, but the fact that they finished two weeks early.'
 where question_id = 'c33050ce-bff1-57cd-a258-9a60d2549ba6' and locale = 'en';
update question_translations set prompt = 'Lee: "The team finished the project two weeks early, which surprised everyone in the company." ¿A qué se refiere "which"?', options = array['El equipo', 'El hecho de que el equipo terminara el proyecto dos semanas antes', 'El proyecto', 'La empresa'], explanation = '"Which", después de la coma, retoma toda la oración anterior: lo que sorprendió a todos no fue el equipo ni el proyecto, sino el hecho de que terminaran dos semanas antes.'
 where question_id = 'c33050ce-bff1-57cd-a258-9a60d2549ba6' and locale = 'es';
