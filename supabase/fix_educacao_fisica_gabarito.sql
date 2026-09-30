-- Educação Física: conserta o gabarito de 7 questões
--
-- Ao escrever a matéria, em 7 questões a alternativa correta não ficou na
-- posição que o índice do gabarito apontava -- o índice seguia a
-- distribuição de 30 por letra, e a alternativa certa ficou noutro lugar.
-- A correção reordena as alternativas (pt, en e es), mantendo o índice,
-- de modo que o gabarito continue com 30 questões por letra.
--
-- Precisa ser UPDATE: as questões entram com `on conflict do nothing`, e
-- estas já existem. Idempotente: rodar de novo escreve o mesmo valor.

update questions set options = array['A reposição de carboidratos e proteínas favorece a recuperação muscular e do glicogênio', 'Nenhum alimento deve ser ingerido', 'O corpo elimina toda a gordura acumulada', 'O treino deve ser repetido imediatamente']
 where id = 'e1a387e0-6d6f-596e-84d8-75bca2a05322';
update question_translations set options = array['Taking in carbohydrate and protein supports muscle and glycogen recovery', 'No food should be eaten', 'The body burns off all stored fat', 'Training must be repeated immediately']
 where question_id = 'e1a387e0-6d6f-596e-84d8-75bca2a05322' and locale = 'en';
update question_translations set options = array['La reposición de carbohidratos y proteínas favorece la recuperación muscular y del glucógeno', 'No debe ingerirse ningún alimento', 'El cuerpo elimina toda la grasa acumulada', 'El entrenamiento debe repetirse de inmediato']
 where question_id = 'e1a387e0-6d6f-596e-84d8-75bca2a05322' and locale = 'es';

update questions set options = array['Recusa completa de qualquer atividade física', 'Preocupação excessiva em parecer insuficientemente musculoso, mesmo com corpo desenvolvido', 'Perda total de apetite por motivos hormonais', 'Necessidade de dormir mais de doze horas por dia']
 where id = '400410e7-bf61-5179-a6e5-c8ebfddeada7';
update question_translations set options = array['Complete refusal of any physical activity', 'Excessive concern with looking insufficiently muscular, even with a developed body', 'Total loss of appetite for hormonal reasons', 'Needing more than twelve hours of sleep a day']
 where question_id = '400410e7-bf61-5179-a6e5-c8ebfddeada7' and locale = 'en';
update question_translations set options = array['Rechazo completo de cualquier actividad física', 'Preocupación excesiva por parecer insuficientemente musculoso, incluso con un cuerpo desarrollado', 'Pérdida total del apetito por motivos hormonales', 'Necesidad de dormir más de doce horas al día']
 where question_id = '400410e7-bf61-5179-a6e5-c8ebfddeada7' and locale = 'es';

update questions set options = array['Um mesmo programa de treino produz respostas diferentes em pessoas diferentes', 'Pessoas com a mesma idade respondem de forma idêntica ao mesmo treino', 'Só atletas podem melhorar o condicionamento físico', 'A carga de treino deve ser copiada de atletas profissionais']
 where id = 'c1900def-f092-5c5f-8a49-2eb4f3eae902';
update question_translations set options = array['The same training programme produces different responses in different people', 'People of the same age respond identically to the same training', 'Only athletes can improve their fitness', 'Training loads should be copied from professional athletes']
 where question_id = 'c1900def-f092-5c5f-8a49-2eb4f3eae902' and locale = 'en';
update question_translations set options = array['Un mismo programa de entrenamiento produce respuestas diferentes en personas diferentes', 'Las personas de la misma edad responden de forma idéntica al mismo entrenamiento', 'Solo los atletas pueden mejorar su condición física', 'La carga de entrenamiento debe copiarse de los atletas profesionales']
 where question_id = 'c1900def-f092-5c5f-8a49-2eb4f3eae902' and locale = 'es';

update questions set options = array['Usar duas bolas simultaneamente', 'Permitir que qualquer jogador enxergue normalmente', 'Ser jogado exclusivamente em quadra coberta e sem goleiro', 'Ser disputado com bola sonora, e o goleiro pode ser vidente']
 where id = '76c6166d-08d9-544e-b061-779d20aa3a62';
update question_translations set options = array['Using two balls at the same time', 'Allowing any player to see normally', 'Being played only indoors and without a goalkeeper', 'Being played with a sound ball, with a sighted goalkeeper allowed']
 where question_id = '76c6166d-08d9-544e-b061-779d20aa3a62' and locale = 'en';
update question_translations set options = array['Usar dos balones simultáneamente', 'Permitir que cualquier jugador vea normalmente', 'Jugarse exclusivamente en pista cubierta y sin portero', 'Disputarse con balón sonoro, y el portero puede ser vidente']
 where question_id = '76c6166d-08d9-544e-b061-779d20aa3a62' and locale = 'es';

update questions set options = array['Atinge o direito à moradia de populações vulneráveis em nome de um evento temporário', 'Reduz o número de turistas na cidade', 'Impede a construção de arenas modernas', 'Aumenta o custo dos ingressos']
 where id = '9a69438b-d53d-5bd4-960f-1a3f52370c96';
update question_translations set options = array['It affects the housing rights of vulnerable people in the name of a temporary event', 'It reduces the number of tourists in the city', 'It prevents modern arenas from being built', 'It raises ticket prices']
 where question_id = '9a69438b-d53d-5bd4-960f-1a3f52370c96' and locale = 'en';
update question_translations set options = array['Afecta el derecho a la vivienda de poblaciones vulnerables en nombre de un evento temporal', 'Reduce el número de turistas en la ciudad', 'Impide la construcción de arenas modernas', 'Aumenta el costo de las entradas']
 where question_id = '9a69438b-d53d-5bd4-960f-1a3f52370c96' and locale = 'es';

update questions set options = array['Definir quem vai sacar no próximo rodízio', 'Marcar os pontos na súmula da partida', 'Escolher o atacante com base na formação do bloqueio adversário', 'Escolher o uniforme da equipe']
 where id = 'f98a3e5c-68e0-57e2-befe-a3ec2100a064';
update question_translations set options = array['Deciding who will serve in the next rotation', 'Recording the points on the match sheet', 'Choosing the attacker based on how the opposing block is set up', 'Choosing the team''s kit']
 where question_id = 'f98a3e5c-68e0-57e2-befe-a3ec2100a064' and locale = 'en';
update question_translations set options = array['Definir quién sacará en la próxima rotación', 'Anotar los puntos en el acta del partido', 'Elegir al atacante según la formación del bloqueo rival', 'Elegir el uniforme del equipo']
 where question_id = 'f98a3e5c-68e0-57e2-befe-a3ec2100a064' and locale = 'es';

update questions set options = array['A valorização das práticas corporais tradicionais e do encontro entre etnias', 'A disputa por medalhas entre países', 'A exclusão de modalidades tradicionais', 'A participação apenas de atletas profissionais']
 where id = '4ca8d9d7-39a7-5201-9b8f-7690c675b582';
update question_translations set options = array['Valuing traditional bodily practices and the meeting between ethnic groups', 'A dispute for medals between countries', 'The exclusion of traditional modalities', 'Participation by professional athletes only']
 where question_id = '4ca8d9d7-39a7-5201-9b8f-7690c675b582' and locale = 'en';
update question_translations set options = array['La valoración de las prácticas corporales tradicionales y del encuentro entre etnias', 'La disputa por medallas entre países', 'La exclusión de modalidades tradicionales', 'La participación solo de atletas profesionales']
 where question_id = '4ca8d9d7-39a7-5201-9b8f-7690c675b582' and locale = 'es';

