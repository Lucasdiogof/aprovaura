-- Gabarito de 2 questões de Espanhol e 3 de Inglês (2026-09-30)
--
-- Mesmo defeito de Artes, Educação Física e das 18 de Espanhol: ao distribuir
-- os c= para fechar 30 por letra, a alternativa certa não foi junto, e a
-- explicação passou a contradizer o que estava marcado. As duas de Espanhol
-- escaparam da correção anterior; as três de Inglês foram apontadas pela
-- revisão externa.
--
-- Corrige trocando as alternativas de posição nas três línguas, nunca o
-- correct_index: assim os 30 por letra continuam de pé.
--
-- De brinde, uma de Inglês com resposta agramatical: "The kids ___ in the
-- pool right now" tinha "swimming" como certa; o Present Continuous pede
-- "are swimming".
--
-- Idempotente: cada update grava o array inteiro, então rodar de novo
-- escreve o mesmo valor.

-- pescador: "Solidão e rotina" estava na posição 0 com c=3
update questions set options = array['Raiva', 'Alegria e festa', 'Medo intenso', 'Solidão e rotina']
 where id = '86b9e901-295d-5d6e-b9e6-e0ce7b2b5558';
update question_translations set options = array['Anger', 'Joy and celebration', 'Intense fear', 'Loneliness and routine']
 where question_id = '86b9e901-295d-5d6e-b9e6-e0ce7b2b5558' and locale = 'en';
update question_translations set options = array['Rabia', 'Alegría y fiesta', 'Miedo intenso', 'Soledad y rutina']
 where question_id = '86b9e901-295d-5d6e-b9e6-e0ce7b2b5558' and locale = 'es';

-- sono e memória: a associação estava na posição 0 com c=3
update questions set options = array['Não há nenhuma relação mencionada', 'Dormir muito causa insônia', 'A memória causa sono', 'Dormir pouco está associado a maior risco de problemas de memória']
 where id = '002f90a1-db79-56e7-a108-2d6d1433b3ba';
update question_translations set options = array['No relationship is mentioned at all', 'Sleeping too much causes insomnia', 'Memory causes sleep', 'Sleeping little is associated with a higher risk of memory problems']
 where question_id = '002f90a1-db79-56e7-a108-2d6d1433b3ba' and locale = 'en';
update question_translations set options = array['No se menciona ninguna relación', 'Dormir demasiado causa insomnio', 'La memoria causa sueño', 'Dormir poco está asociado a un mayor riesgo de problemas de memoria']
 where question_id = '002f90a1-db79-56e7-a108-2d6d1433b3ba' and locale = 'es';

-- "keep it down": abaixar o volume estava na posição 0 com c=3
update questions set options = array['Para que saiam da sala', 'Para que aumentem o volume da música', 'Para que a ajudem a estudar', 'Para que abaixem o volume/façam menos barulho']
 where id = 'cf9ec963-a6d5-5e6b-9ac8-2ea72b457d7a';
update question_translations set options = array['To leave the room', 'To turn up the music', 'To help them study', 'To lower the volume/make less noise']
 where question_id = 'cf9ec963-a6d5-5e6b-9ac8-2ea72b457d7a' and locale = 'en';
update question_translations set options = array['Que salgan de la habitación', 'Que suban el volumen de la música', 'Que la ayuden a estudiar', 'Que bajen el volumen/hagan menos ruido']
 where question_id = 'cf9ec963-a6d5-5e6b-9ac8-2ea72b457d7a' and locale = 'es';

-- "won't be able to make it": o cancelamento estava na posição 1 com c=2
update questions set options = array['Confirmando presença em uma reunião', 'Marcando uma nova reunião', 'Cancelando/avisando que não poderá comparecer a uma reunião', 'Elogiando uma reunião passada']
 where id = '0a989165-e90d-564c-b4f2-d4db56d731b7';
update question_translations set options = array['Confirming attendance at a meeting', 'Scheduling a new meeting', 'Canceling/letting someone know they can''t attend a meeting', 'Praising a past meeting']
 where question_id = '0a989165-e90d-564c-b4f2-d4db56d731b7' and locale = 'en';
update question_translations set options = array['Confirmando su asistencia a una reunión', 'Programando una nueva reunión', 'Cancelando/avisando que no podrá asistir a una reunión', 'Elogiando una reunión pasada']
 where question_id = '0a989165-e90d-564c-b4f2-d4db56d731b7' and locale = 'es';

-- skimming: a ideia central estava na posição 0 com c=1
update questions set options = array['Pesquisadores recomendam dietas sem açúcar', 'Caminhadas curtas após as refeições podem ajudar a controlar o açúcar no sangue', 'Caminhar é melhor que correr', 'O estudo foi feito com crianças']
 where id = 'ffb7a67c-fb6b-5e7c-92b3-ca45f96e5260';
update question_translations set options = array['Researchers recommend sugar-free diets', 'Short walks after meals may help control blood sugar levels', 'Walking is better than running', 'The study was done with children']
 where question_id = 'ffb7a67c-fb6b-5e7c-92b3-ca45f96e5260' and locale = 'en';
update question_translations set options = array['Los investigadores recomiendan dietas sin azúcar', 'Las caminatas cortas después de las comidas pueden ayudar a controlar el azúcar en la sangre', 'Caminar es mejor que correr', 'El estudio se hizo con niños']
 where question_id = 'ffb7a67c-fb6b-5e7c-92b3-ca45f96e5260' and locale = 'es';

-- "The kids ___ right now": "swimming" sozinho não forma o Present Continuous
update questions set options = array['swim', 'swam', 'swims', 'are swimming'], explanation = '"Right now" indica uma ação em andamento; com sujeito plural, o Present Continuous é "are" + verbo com "-ing": "are swimming".'
 where id = '21451bfa-c406-59f2-81dd-67c829259bc7';
update question_translations set options = array['swim', 'swam', 'swims', 'are swimming'], explanation = '"Right now" indicates an action in progress; with a plural subject, the Present Continuous is "are" + verb + "-ing": "are swimming".'
 where question_id = '21451bfa-c406-59f2-81dd-67c829259bc7' and locale = 'en';
update question_translations set options = array['swim', 'swam', 'swims', 'are swimming'], explanation = '"Right now" indica una acción en curso; con sujeto plural, el Present Continuous es "are" + verbo con "-ing": "are swimming".'
 where question_id = '21451bfa-c406-59f2-81dd-67c829259bc7' and locale = 'es';
