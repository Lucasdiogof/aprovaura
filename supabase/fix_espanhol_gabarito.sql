-- Espanhol: gabarito apontando a alternativa errada em 18 questoes
--
-- Mesmo defeito ja corrigido em Artes e Educacao Fisica: ao distribuir
-- os indices para fechar 30 por letra, a alternativa correta nao foi
-- movida junto, e a explicacao passou a contradizer o que estava
-- marcado. A explicacao arbitra -- ela sempre descreveu a resposta certa.
--
-- A correcao troca as duas alternativas de lugar, nas tres linguas, em
-- vez de mexer no correct_index: assim os 30 por letra continuam de pe.
--
-- Idempotente: rodar de novo escreve o mesmo valor.

update questions set options = array['Oye, ¿me ayudas con esto?', 'Perdone, ¿podría ayudarme con esto?', 'Hola, ¿qué onda con esto?', 'Eh, ¿me das una mano?']
 where id = 'cce18a51-e1ee-5cc0-83c5-ace2ef7e50d9';
update question_translations set options = array['Oye, ¿me ayudas con esto?', 'Perdone, ¿podría ayudarme con esto?', 'Hola, ¿qué onda con esto?', 'Eh, ¿me das una mano?']
 where question_id = 'cce18a51-e1ee-5cc0-83c5-ace2ef7e50d9' and locale = 'en';
update question_translations set options = array['Oye, ¿me ayudas con esto?', 'Perdone, ¿podría ayudarme con esto?', 'Hola, ¿qué onda con esto?', 'Eh, ¿me das una mano?']
 where question_id = 'cce18a51-e1ee-5cc0-83c5-ace2ef7e50d9' and locale = 'es';

update questions set options = array['El pasaporte, por favor', 'La cuenta, por favor', 'La maleta, por favor', 'El boleto, por favor']
 where id = '469cf474-db27-5a51-8853-4a43aed901df';
update question_translations set options = array['El pasaporte, por favor', 'La cuenta, por favor', 'La maleta, por favor', 'El boleto, por favor']
 where question_id = '469cf474-db27-5a51-8853-4a43aed901df' and locale = 'en';
update question_translations set options = array['El pasaporte, por favor', 'La cuenta, por favor', 'La maleta, por favor', 'El boleto, por favor']
 where question_id = '469cf474-db27-5a51-8853-4a43aed901df' and locale = 'es';

update questions set options = array['¿Puede esperar, por favor?', '¿Puede pagar, por favor?', '¿Puede firmar, por favor?', '¿Puede repetir, por favor?']
 where id = 'd772e2a6-9af5-5966-a821-0784d9dbea11';
update question_translations set options = array['¿Puede esperar, por favor?', '¿Puede pagar, por favor?', '¿Puede firmar, por favor?', '¿Puede repetir, por favor?']
 where question_id = 'd772e2a6-9af5-5966-a821-0784d9dbea11' and locale = 'en';
update question_translations set options = array['¿Puede esperar, por favor?', '¿Puede pagar, por favor?', '¿Puede firmar, por favor?', '¿Puede repetir, por favor?']
 where question_id = 'd772e2a6-9af5-5966-a821-0784d9dbea11' and locale = 'es';

update questions set options = array['Necesito una habitación doble', 'Necesito un billete de tren', 'Necesito algo para el dolor de cabeza', 'Necesito cambiar dinero']
 where id = '69e5a44d-3982-5a0a-9ceb-d4a3c5c4c4f0';
update question_translations set options = array['Necesito una habitación doble', 'Necesito un billete de tren', 'Necesito algo para el dolor de cabeza', 'Necesito cambiar dinero']
 where question_id = '69e5a44d-3982-5a0a-9ceb-d4a3c5c4c4f0' and locale = 'en';
update question_translations set options = array['Necesito una habitación doble', 'Necesito un billete de tren', 'Necesito algo para el dolor de cabeza', 'Necesito cambiar dinero']
 where question_id = '69e5a44d-3982-5a0a-9ceb-d4a3c5c4c4f0' and locale = 'es';

update questions set options = array['França', 'España', 'Itália', 'Alemanha']
 where id = '80df5f6a-91fe-5ac6-b8e9-7d09bcfc4697';
update question_translations set options = array['France', 'España (Spain)', 'Italy', 'Germany']
 where question_id = '80df5f6a-91fe-5ac6-b8e9-7d09bcfc4697' and locale = 'en';
update question_translations set options = array['Francia', 'España', 'Italia', 'Alemania']
 where question_id = '80df5f6a-91fe-5ac6-b8e9-7d09bcfc4697' and locale = 'es';

update questions set options = array['Pesquisadores recomendam dietas sem açúcar', 'Caminhar após as refeições pode ajudar a controlar o açúcar no sangue', 'Caminhar é melhor que correr', 'O estudo foi feito com crianças']
 where id = '0773325e-a77c-53b7-b70f-d0135abf1cff';
update question_translations set options = array['Researchers recommend sugar-free diets', 'Walking after meals may help control blood sugar levels', 'Walking is better than running', 'The study was done with children']
 where question_id = '0773325e-a77c-53b7-b70f-d0135abf1cff' and locale = 'en';
update question_translations set options = array['Los investigadores recomiendan dietas sin azúcar', 'Caminar después de las comidas puede ayudar a controlar el azúcar en la sangre', 'Caminar es mejor que correr', 'El estudio se hizo con niños']
 where question_id = '0773325e-a77c-53b7-b70f-d0135abf1cff' and locale = 'es';

update questions set options = array['Introduzir um exemplo da ideia anterior', 'Confirmar totalmente a ideia anterior', 'Introduzir um contra-argumento que qualifica a ideia anterior', 'Encerrar o texto sem mais argumentos']
 where id = 'fd3be451-392e-5670-94f9-6ce25eb1c740';
update question_translations set options = array['To introduce an example of the previous idea', 'To fully confirm the previous idea', 'To introduce a counter-argument that qualifies the previous idea', 'To end the text with no further argument']
 where question_id = 'fd3be451-392e-5670-94f9-6ce25eb1c740' and locale = 'en';
update question_translations set options = array['Introducir un ejemplo de la idea anterior', 'Confirmar totalmente la idea anterior', 'Introducir un contraargumento que matiza la idea anterior', 'Cerrar el texto sin más argumentos']
 where question_id = 'fd3be451-392e-5670-94f9-6ce25eb1c740' and locale = 'es';

update questions set options = array['Não apresenta nenhuma posição, apenas fatos neutros', 'Defende a proibição sem ressalvas', 'Rejeita totalmente qualquer forma de proteção aos jovens', 'Reconhece o argumento a favor da proibição, mas alerta para um risco associado a ela']
 where id = '5a5d4dbc-c838-5385-aefd-2019a38a4d92';
update question_translations set options = array['Presents no position at all, only neutral facts', 'Fully defends the ban with no reservations', 'Completely rejects any form of protection for young people', 'Acknowledges the argument in favor of the ban, but warns of an associated risk']
 where question_id = '5a5d4dbc-c838-5385-aefd-2019a38a4d92' and locale = 'en';
update question_translations set options = array['No presenta ninguna posición, solo hechos neutrales', 'Defiende la prohibición sin reservas', 'Rechaza totalmente cualquier forma de protección para los jóvenes', 'Reconoce el argumento a favor de la prohibición, pero advierte sobre un riesgo asociado']
 where question_id = '5a5d4dbc-c838-5385-aefd-2019a38a4d92' and locale = 'es';

update questions set options = array['O transporte público já é suficiente', 'As cidades deveriam proibir carros totalmente', 'As cidades deveriam investir mais em transporte público', 'A poluição não está relacionada ao tráfico']
 where id = '103449bd-88e8-5944-bc12-ee456d282189';
update question_translations set options = array['Public transportation is already sufficient', 'Cities should completely ban cars', 'Cities should invest more in public transportation', 'Pollution is unrelated to traffic']
 where question_id = '103449bd-88e8-5944-bc12-ee456d282189' and locale = 'en';
update question_translations set options = array['El transporte público ya es suficiente', 'Las ciudades deberían prohibir los autos totalmente', 'Las ciudades deberían invertir más en transporte público', 'La contaminación no está relacionada con el tráfico']
 where question_id = '103449bd-88e8-5944-bc12-ee456d282189' and locale = 'es';

update questions set options = array['É uma exigência legal', 'Custa menos para o governo', 'É mais rápido que o carro em qualquer situação', 'Reduz o tráfico e a poluição']
 where id = 'd28736ab-bcb4-5d2a-b9b9-746f3fbb6240';
update question_translations set options = array['It is a legal requirement', 'It costs the government less', 'It is always faster than a car', 'It reduces traffic and pollution']
 where question_id = 'd28736ab-bcb4-5d2a-b9b9-746f3fbb6240' and locale = 'en';
update question_translations set options = array['Es una exigencia legal', 'Cuesta menos para el gobierno', 'Es más rápido que el auto en cualquier situación', 'Reduce el tráfico y la contaminación']
 where question_id = 'd28736ab-bcb4-5d2a-b9b9-746f3fbb6240' and locale = 'es';

update questions set options = array['A tecnologia nos isola completamente', 'A tecnologia nos permite manter conexões que seriam impossíveis de outra forma', 'A tecnologia deveria ser abolida', 'A tecnologia não tem nenhum efeito social']
 where id = 'ddd46dcf-2fd4-54b4-93ef-04637511e6e7';
update question_translations set options = array['Technology completely isolates us', 'Technology allows us to maintain connections that would otherwise be impossible', 'Technology should be abolished', 'Technology has no social effect at all']
 where question_id = 'ddd46dcf-2fd4-54b4-93ef-04637511e6e7' and locale = 'en';
update question_translations set options = array['La tecnología nos aísla por completo', 'La tecnología nos permite mantener conexiones que de otro modo serían imposibles', 'La tecnología debería abolirse', 'La tecnología no tiene ningún efecto social']
 where question_id = 'ddd46dcf-2fd4-54b4-93ef-04637511e6e7' and locale = 'es';

update questions set options = array['Uma causa direta entre exercício e debate científico', 'Uma concessão: reconhece um fato conhecido antes de apresentar um ponto ainda incerto', 'Uma negação total do benefício do exercício', 'Uma conclusão final sem ressalvas']
 where id = 'a6931bc5-6e1e-5f2e-9f10-23a891411fb1';
update question_translations set options = array['A direct cause between exercise and scientific debate', 'A concession: it acknowledges a known fact before presenting a still uncertain point', 'A total denial of exercise''s benefit', 'A final conclusion with no reservations']
 where question_id = 'a6931bc5-6e1e-5f2e-9f10-23a891411fb1' and locale = 'en';
update question_translations set options = array['Una causa directa entre el ejercicio y el debate científico', 'Una concesión: reconoce un hecho conocido antes de presentar un punto aún incierto', 'Una negación total del beneficio del ejercicio', 'Una conclusión final sin reservas']
 where question_id = 'a6931bc5-6e1e-5f2e-9f10-23a891411fb1' and locale = 'es';

update questions set options = array['Produzir apenas mel', 'Polinizar grande parte dos cultivos que consumimos', 'Destruir plantações', 'Espantar outros insetos']
 where id = 'b50feb86-efc5-55da-b6e5-8f6b7f288157';
update question_translations set options = array['Producing only honey', 'Pollinating much of the crops we consume', 'Destroying crops', 'Scaring away other insects']
 where question_id = 'b50feb86-efc5-55da-b6e5-8f6b7f288157' and locale = 'en';
update question_translations set options = array['Producir solo miel', 'Polinizar gran parte de los cultivos que consumimos', 'Destruir cultivos', 'Ahuyentar a otros insectos']
 where question_id = 'b50feb86-efc5-55da-b6e5-8f6b7f288157' and locale = 'es';

update questions set options = array['Nenhum efeito sobre a memória', 'Uma melhora na memória', 'Um maior risco de problemas de memória a longo prazo', 'Um aumento da energia física']
 where id = '490f2bdf-bbe1-5aa7-b135-59ee3a7d78f5';
update question_translations set options = array['No effect on memory', 'An improvement in memory', 'A higher risk of long-term memory problems', 'An increase in physical energy']
 where question_id = '490f2bdf-bbe1-5aa7-b135-59ee3a7d78f5' and locale = 'en';
update question_translations set options = array['Ningún efecto sobre la memoria', 'Una mejora en la memoria', 'Un mayor riesgo de problemas de memoria a largo plazo', 'Un aumento de la energía física']
 where question_id = '490f2bdf-bbe1-5aa7-b135-59ee3a7d78f5' and locale = 'es';

update questions set options = array['Aliteração', 'Onomatopeia', 'Símile/comparação', 'Hipérbole']
 where id = '8ff840e2-75be-592a-b2f9-5bfa68c9f29e';
update question_translations set options = array['Alliteration', 'Onomatopoeia', 'Simile', 'Hyperbole']
 where question_id = '8ff840e2-75be-592a-b2f9-5bfa68c9f29e' and locale = 'en';
update question_translations set options = array['Aliteración', 'Onomatopeya', 'Símil/comparación', 'Hipérbole']
 where question_id = '8ff840e2-75be-592a-b2f9-5bfa68c9f29e' and locale = 'es';

update questions set options = array['Que é uma dor inexistente, fingida', 'Que é uma dor que já foi totalmente resolvida', 'Que é uma dor compartilhada abertamente com todos', 'Que é uma dor guardada, contida, nunca expressa/compartilhada']
 where id = '71f66fb2-cc16-5bc0-9847-cd405f4e33d7';
update question_translations set options = array['That it is a nonexistent, fake pain', 'That it is a pain already fully resolved', 'That it is a pain openly shared with everyone', 'That it is a pain kept inside, contained, never expressed/shared']
 where question_id = '71f66fb2-cc16-5bc0-9847-cd405f4e33d7' and locale = 'en';
update question_translations set options = array['Que es un dolor inexistente, fingido', 'Que es un dolor ya totalmente resuelto', 'Que es un dolor compartido abiertamente con todos', 'Que es un dolor guardado, contenido, nunca expresado/compartido']
 where question_id = '71f66fb2-cc16-5bc0-9847-cd405f4e33d7' and locale = 'es';

update questions set options = array['Um grupo de pescadores jovens', 'Um pescador que nunca saiu ao mar', 'Um pescador que sai ao mar sozinho todas as manhãs há muitos anos', 'Um pescador que parou de pescar']
 where id = 'cddde117-bddf-5fb9-a2bd-080641312969';
update question_translations set options = array['A group of young fishermen', 'A fisherman who never went out to sea', 'An old fisherman who goes out to sea alone every morning for many years', 'A fisherman who stopped fishing']
 where question_id = 'cddde117-bddf-5fb9-a2bd-080641312969' and locale = 'en';
update question_translations set options = array['Un grupo de pescadores jóvenes', 'Un pescador que nunca salió al mar', 'Un pescador viejo que sale al mar solo todas las mañanas desde hace muchos años', 'Un pescador que dejó de pescar']
 where question_id = 'cddde117-bddf-5fb9-a2bd-080641312969' and locale = 'es';

update questions set options = array['Que a fonte está exatamente na porta da frente', 'Que a fonte é incerta/não identificada, apenas em algum canto', 'Que não existe nenhuma fonte', 'Que a fonte é um animal de estimação conhecido']
 where id = 'b5c18fd9-cbab-5d72-9eba-1d8063ed3d18';
update question_translations set options = array['That the source is exactly at the front door', 'That the source is uncertain/unidentified, just somewhere in a corner', 'That there is no source at all', 'That the source is a familiar pet']
 where question_id = 'b5c18fd9-cbab-5d72-9eba-1d8063ed3d18' and locale = 'en';
update question_translations set options = array['Que la fuente está exactamente en la puerta principal', 'Que la fuente es incierta/no identificada, solo en algún rincón', 'Que no existe ninguna fuente', 'Que la fuente es una mascota conocida']
 where question_id = 'b5c18fd9-cbab-5d72-9eba-1d8063ed3d18' and locale = 'es';

