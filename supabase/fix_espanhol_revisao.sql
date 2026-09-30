-- Espanhol: 10 correções aceitas da revisão externa (2026-09-30)
--
-- Complementa fix_espanhol_gabarito.sql e fix_gabarito_espanhol_ingles.sql.
-- Aqui nenhum gabarito muda: "tener mucho en el plato" era calco do inglês
-- (o idiomático é "tener mucho entre manos"); "por si acaso" pede indicativo;
-- "tirar de la lengua" pede objeto; a Argentina não declara idioma oficial;
-- profissão pede "ser" sem precisar ser permanente; o texto sobre sono mostra
-- associação, não causa; e três questões de pretérito perfecto compuesto
-- passam a dizer que valem para o uso da Espanha, porque na América "hice",
-- "tuve" e "estuve" também são corretos.
--
-- Recusadas: a reescrita do trecho do pescador (a pergunta de sentimento
-- predominante continua válida) e "Reticente ou relutante" em português numa
-- alternativa em espanhol (entrou "Reticente", que é espanhol).
--
-- Só o texto muda: a ORDEM das alternativas é preservada, para o gabarito
-- não se mexer e as traduções seguirem alinhadas por posição. Cada
-- update grava o valor final inteiro, então rodar de novo não muda nada.

-- "por si acaso" pede indicativo: "llueve"
update questions set prompt = 'Complete: "Deberías llevar un paraguas ___ llueve más tarde." (condição/precaução)', explanation = '"Por si acaso" expressa precaução diante de uma possibilidade futura; nessa construção, o natural é o indicativo: "llueve".'
 where id = '482fa829-99b1-5509-af0a-3d2e4d95510b';
update question_translations set prompt = 'Complete: "Deberías llevar un paraguas ___ llueve más tarde." (condition/precaution)', explanation = '"Por si acaso" expresses precaution against a future possibility; in this construction the indicative is the natural choice: "llueve".'
 where question_id = '482fa829-99b1-5509-af0a-3d2e4d95510b' and locale = 'en';
update question_translations set prompt = 'Completa: "Deberías llevar un paraguas ___ llueve más tarde." (condición/precaución)', explanation = '"Por si acaso" expresa precaución ante una posibilidad futura; en esta construcción lo natural es el indicativo: "llueve".'
 where question_id = '482fa829-99b1-5509-af0a-3d2e4d95510b' and locale = 'es';

-- Argentina não declara idioma oficial em lei nacional
update questions set prompt = 'Qual desses países é predominantemente hispanofalante?', explanation = 'Na Argentina, o espanhol é a língua predominante de uso nacional, embora a Constituição não declare um idioma oficial.'
 where id = '58b3ff84-a861-55ab-9cae-39444859c090';
update question_translations set prompt = 'Which of these countries is predominantly Spanish-speaking?', explanation = 'In Argentina, Spanish is the predominant national language, although the Constitution does not declare an official language.'
 where question_id = '58b3ff84-a861-55ab-9cae-39444859c090' and locale = 'en';
update question_translations set prompt = '¿Cuál de estos países es predominantemente hispanohablante?', explanation = 'En Argentina, el español es la lengua predominante de uso nacional, aunque la Constitución no declara un idioma oficial.'
 where question_id = '58b3ff84-a861-55ab-9cae-39444859c090' and locale = 'es';

-- "tener mucho en el plato" é calco do inglês; o idiomático é "tener mucho entre manos"
update questions set prompt = 'Leia: "Tengo mucho entre manos este mes, así que no puedo asumir nuevos proyectos." O que "tener mucho entre manos" significa?', options = array['Ter várias possibilidades para escolher', 'Estar preocupado especificamente com alimentação', 'Ter pouco trabalho ou poucas obrigações', 'Ter muitas tarefas ou responsabilidades em andamento'], explanation = '"Tener mucho entre manos" é a expressão idiomática para dizer que alguém tem muitas tarefas, assuntos ou responsabilidades em andamento.'
 where id = '6b4b559a-511c-5f49-a5bf-09d09b5a9d59';
update question_translations set prompt = 'Read: "Tengo mucho entre manos este mes, así que no puedo asumir nuevos proyectos." What does "tener mucho entre manos" mean?', options = array['Having several options to choose from', 'Being worried specifically about food', 'Having little work or few obligations', 'Having many tasks or responsibilities underway'], explanation = '"Tener mucho entre manos" is the idiom for saying someone has many tasks, matters or responsibilities underway.'
 where question_id = '6b4b559a-511c-5f49-a5bf-09d09b5a9d59' and locale = 'en';
update question_translations set prompt = 'Lee: "Tengo mucho entre manos este mes, así que no puedo asumir nuevos proyectos." ¿Qué significa "tener mucho entre manos"?', options = array['Tener varias opciones para elegir', 'Estar preocupado específicamente por la comida', 'Tener poco trabajo o pocas obligaciones', 'Tener muchas tareas o responsabilidades en curso'], explanation = '"Tener mucho entre manos" es la expresión idiomática para decir que alguien tiene muchas tareas, asuntos o responsabilidades en curso.'
 where question_id = '6b4b559a-511c-5f49-a5bf-09d09b5a9d59' and locale = 'es';

-- "tirar de la lengua" pede objeto: "tirarle de la lengua a alguien"
update questions set prompt = 'Leia: "Creo que deberíamos tirarle de la lengua para que nos cuente lo que sabe." O que "tirarle de la lengua a alguien" significa?', explanation = '"Tirarle de la lengua a alguien" significa induzir ou estimular essa pessoa a contar algo que não diria espontaneamente.'
 where id = '09bcd2bf-1f65-5ac6-bf24-bd158466c25b';
update question_translations set prompt = 'Read: "Creo que deberíamos tirarle de la lengua para que nos cuente lo que sabe." What does "tirarle de la lengua a alguien" mean?', explanation = '"Tirarle de la lengua a alguien" means to coax that person into telling something they would not say on their own.'
 where question_id = '09bcd2bf-1f65-5ac6-bf24-bd158466c25b' and locale = 'en';
update question_translations set prompt = 'Lee: "Creo que deberíamos tirarle de la lengua para que nos cuente lo que sabe." ¿Qué significa "tirarle de la lengua a alguien"?', explanation = '"Tirarle de la lengua a alguien" significa inducir o animar a esa persona a contar algo que no diría espontáneamente.'
 where question_id = '09bcd2bf-1f65-5ac6-bf24-bd158466c25b' and locale = 'es';

-- "todavía no": "hice" também é correto na América; o enunciado fixa o uso peninsular
update questions set prompt = 'No uso da Espanha, complete destacando o resultado atual de uma ação recente: "Todavía no ___ la tarea."', explanation = 'Na Espanha, "todavía no" com relevância no presente pede o pretérito perfecto compuesto: "he hecho". Em muitas variedades americanas, "todavía no hice" também é natural.'
 where id = 'ecff00e2-5d06-5ad6-9fd5-6c2e9659cee0';
update question_translations set prompt = 'In Spain''s usage, complete highlighting the current result of a recent action: "Todavía no ___ la tarea."', explanation = 'In Spain, "todavía no" with present relevance calls for the pretérito perfecto compuesto: "he hecho". In many Latin American varieties, "todavía no hice" is also natural.'
 where question_id = 'ecff00e2-5d06-5ad6-9fd5-6c2e9659cee0' and locale = 'en';
update question_translations set prompt = 'En el uso de España, completa destacando el resultado actual de una acción reciente: "Todavía no ___ la tarea."', explanation = 'En España, "todavía no" con relevancia en el presente pide el pretérito perfecto compuesto: "he hecho". En muchas variedades americanas, "todavía no hice" también es natural.'
 where question_id = 'ecff00e2-5d06-5ad6-9fd5-6c2e9659cee0' and locale = 'es';

-- "esta semana": a explicação registra que "tuve" é comum na América
update questions set explanation = '"Esta semana" (período ainda não encerrado) pede o pretérito perfecto compuesto, como o enunciado indica: "he tenido". Em muitas variedades americanas, "tuve" também é frequente.'
 where id = '6bf5913b-2216-5a2b-9d2c-127a0b3e87e6';
update question_translations set explanation = '"Esta semana" (a period not yet over) calls for the pretérito perfecto compuesto, as the prompt asks: "he tenido". In many Latin American varieties, "tuve" is also common.'
 where question_id = '6bf5913b-2216-5a2b-9d2c-127a0b3e87e6' and locale = 'en';
update question_translations set explanation = '"Esta semana" (periodo aún no terminado) pide el pretérito perfecto compuesto, como indica el enunciado: "he tenido". En muchas variedades americanas, "tuve" también es frecuente.'
 where question_id = '6bf5913b-2216-5a2b-9d2c-127a0b3e87e6' and locale = 'es';

-- "nunca": "estuve" também é correto na América; o enunciado fixa o uso peninsular
update questions set prompt = 'No uso da Espanha, complete com uma experiência de vida sem tempo específico: "Nunca ___ en España."', explanation = 'Na Espanha, uma experiência de vida até o presente pede o pretérito perfecto compuesto: "he estado". Em muitas variedades americanas, "nunca estuve" também é natural.'
 where id = '68cdc09f-13d8-545a-bbc8-6c688c465bae';
update question_translations set prompt = 'In Spain''s usage, complete with a life experience with no specific time: "Nunca ___ en España."', explanation = 'In Spain, a life experience up to now calls for the pretérito perfecto compuesto: "he estado". In many Latin American varieties, "nunca estuve" is also natural.'
 where question_id = '68cdc09f-13d8-545a-bbc8-6c688c465bae' and locale = 'en';
update question_translations set prompt = 'En el uso de España, completa con una experiencia de vida sin tiempo específico: "Nunca ___ en España."', explanation = 'En España, una experiencia de vida hasta ahora pide el pretérito perfecto compuesto: "he estado". En muchas variedades americanas, "nunca estuve" también es natural.'
 where question_id = '68cdc09f-13d8-545a-bbc8-6c688c465bae' and locale = 'es';

-- profissão pede "ser" sem precisar ser permanente
update questions set prompt = 'Complete: "Ella ___ médica." (profissão)', explanation = 'Para indicar profissão, usa-se "ser": "ella es médica". A profissão não precisa ser permanente para pedir esse verbo.'
 where id = '27088ee5-0d84-5099-bb5a-2681d2edf448';
update question_translations set prompt = 'Complete: "Ella ___ médica." (profession)', explanation = 'To state a profession, Spanish uses "ser": "ella es médica". The profession need not be permanent to take this verb.'
 where question_id = '27088ee5-0d84-5099-bb5a-2681d2edf448' and locale = 'en';
update question_translations set prompt = 'Completa: "Ella ___ médica." (profesión)', explanation = 'Para indicar profesión se usa "ser": "ella es médica". La profesión no necesita ser permanente para llevar este verbo.'
 where question_id = '27088ee5-0d84-5099-bb5a-2681d2edf448' and locale = 'es';

-- sono e memória: o texto mostra associação, não causa
update questions set prompt = 'No mesmo texto sobre sono e memória, qual relação é apresentada entre dormir menos de seis horas e a memória?', explanation = 'O texto apresenta uma associação entre dormir menos de seis horas por noite e maior risco de problemas de memória; não afirma, por si só, uma relação de causa.'
 where id = '002f90a1-db79-56e7-a108-2d6d1433b3ba';
update question_translations set prompt = 'In the same text about sleep and memory, what relationship is presented between sleeping less than six hours and memory?', explanation = 'The text presents an association between sleeping less than six hours a night and a higher risk of memory problems; on its own, it does not claim a causal link.'
 where question_id = '002f90a1-db79-56e7-a108-2d6d1433b3ba' and locale = 'en';
update question_translations set prompt = 'En el mismo texto sobre sueño y memoria, ¿qué relación se presenta entre dormir menos de seis horas y la memoria?', explanation = 'El texto presenta una asociación entre dormir menos de seis horas por noche y un mayor riesgo de problemas de memoria; por sí solo, no afirma una relación causal.'
 where question_id = '002f90a1-db79-56e7-a108-2d6d1433b3ba' and locale = 'es';

-- "reacia": "reticente" é sinônimo mais direto que "indispuesta"
update questions set options = array['Reticente', 'Ansiosa', 'Segura', 'Agradecida'], explanation = '"Reacia" significa relutante, pouco disposta a aceitar algo; o sinônimo mais direto é "reticente". O contexto mostra hesitação diante da oferta.'
 where id = '60b35589-9bae-5ba4-9b01-44b0c116a4b0';
update question_translations set options = array['Reticente', 'Ansiosa', 'Segura', 'Agradecida'], explanation = '"Reacia" means reluctant, unwilling to accept something; the most direct synonym is "reticente". The context shows hesitation about the offer.'
 where question_id = '60b35589-9bae-5ba4-9b01-44b0c116a4b0' and locale = 'en';
update question_translations set options = array['Reticente', 'Ansiosa', 'Segura', 'Agradecida'], explanation = '"Reacia" significa poco dispuesta a aceptar algo; el sinónimo más directo es "reticente". El contexto muestra vacilación ante la oferta.'
 where question_id = '60b35589-9bae-5ba4-9b01-44b0c116a4b0' and locale = 'es';
