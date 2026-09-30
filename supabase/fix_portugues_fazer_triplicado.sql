-- Desfaz a triplicata do verbo "fazer" impessoal em Portugues
--
-- Metade do topico de concordancia verbal (3 de 6) cobrava a mesma
-- regra. Uma fica com ela e so ganha um enunciado que diz qual e; as
-- outras duas passam a cobrir casos que o topico nao tinha, cada uma no
-- seu nivel: "cada um dos" (medio) e a concordancia com o antecedente
-- do relativo "que" (dificil).
--
-- Foram escolhidas regras sem divergencia normativa: "a maioria dos" e
-- "um dos que" admitem as duas concordancias e virariam questao
-- ambigua.
--
-- Em Portugues as alternativas sao as mesmas nas tres linguas: so
-- enunciado e explicacao se traduzem.
--
-- Idempotente: rodar de novo escreve o mesmo valor.

update questions set prompt = 'Assinale a alternativa em que o verbo "fazer", indicando tempo decorrido, está corretamente flexionado:'
 where id = '49b1d3b4-6874-4ef6-9ad9-8621dfbd2c99';
update question_translations set prompt = 'Choose the option in which the Portuguese verb "fazer", indicating elapsed time, is correctly inflected:'
 where question_id = '49b1d3b4-6874-4ef6-9ad9-8621dfbd2c99' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa en la que el verbo portugués "fazer", indicando tiempo transcurrido, está correctamente flexionado:'
 where question_id = '49b1d3b4-6874-4ef6-9ad9-8621dfbd2c99' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a concordância com a expressão "cada um dos" está correta:', options = array['Cada um dos alunos receberam seu boletim.', 'Cada um dos aluno recebeu seu boletim.', 'Cada um dos alunos recebeu seu boletim.', 'Cada um dos alunos receberam seus boletins.'], correct_index = 2, explanation = 'O núcleo do sujeito é "cada um", que é singular; o verbo fica no singular mesmo seguido de "dos alunos".'
 where id = 'c103f29b-f274-4afd-a8a3-90e0f82bbe5c';
update question_translations set prompt = 'Choose the option with the correct agreement for the Portuguese expression "cada um dos":', options = array['Cada um dos alunos receberam seu boletim.', 'Cada um dos aluno recebeu seu boletim.', 'Cada um dos alunos recebeu seu boletim.', 'Cada um dos alunos receberam seus boletins.'], explanation = 'The head of the subject is "cada um", which is singular, so the verb stays singular even when followed by "dos alunos".'
 where question_id = 'c103f29b-f274-4afd-a8a3-90e0f82bbe5c' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa con la concordancia correcta para la expresión portuguesa "cada um dos":', options = array['Cada um dos alunos receberam seu boletim.', 'Cada um dos aluno recebeu seu boletim.', 'Cada um dos alunos recebeu seu boletim.', 'Cada um dos alunos receberam seus boletins.'], explanation = 'El núcleo del sujeto es "cada um", que es singular, así que el verbo queda en singular aunque le siga "dos alunos".'
 where question_id = 'c103f29b-f274-4afd-a8a3-90e0f82bbe5c' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que o verbo concorda corretamente com o antecedente do pronome relativo "que":', options = array['Fui eu que resolveu o problema.', 'Fomos nós que resolveu o problema.', 'Foram eles que resolvi o problema.', 'Fui eu que resolvi o problema.'], correct_index = 3, explanation = 'Depois de "que", o verbo concorda com o antecedente do pronome — aqui, "eu": "fui eu que resolvi". Com "quem", iria para a 3ª pessoa do singular.'
 where id = 'd10ab15e-5b80-51cf-8ed6-f707807735dc';
update question_translations set prompt = 'Choose the option in which the verb correctly agrees with the antecedent of the Portuguese relative pronoun "que":', options = array['Fui eu que resolveu o problema.', 'Fomos nós que resolveu o problema.', 'Foram eles que resolvi o problema.', 'Fui eu que resolvi o problema.'], explanation = 'After "que", the verb agrees with the pronoun''s antecedent — here "eu": "fui eu que resolvi". With "quem" it would go to the 3rd person singular.'
 where question_id = 'd10ab15e-5b80-51cf-8ed6-f707807735dc' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa en la que el verbo concuerda correctamente con el antecedente del pronombre relativo portugués "que":', options = array['Fui eu que resolveu o problema.', 'Fomos nós que resolveu o problema.', 'Foram eles que resolvi o problema.', 'Fui eu que resolvi o problema.'], explanation = 'Tras "que", el verbo concuerda con el antecedente del pronombre — aquí "eu": "fui eu que resolvi". Con "quem" iría a la 3.ª persona del singular.'
 where question_id = 'd10ab15e-5b80-51cf-8ed6-f707807735dc' and locale = 'es';

