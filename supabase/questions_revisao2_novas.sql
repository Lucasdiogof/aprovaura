-- Segunda rodada da revisão externa (2026-09-30): 36 questões novas, já em
-- pt-BR, en e es. O revisor mandou 42 (3 por matéria); 6 ficaram de fora por
-- serem quase iguais a questões que já existiam (antropofagia, segregação
-- socioespacial, transição demográfica, 1ª geração modernista, o sistema
-- x + y = 10 / x − y = 2 e a solidariedade orgânica de Durkheim).
--
-- Os tópicos que o revisor inventou foram trocados por folhas reais do
-- catálogo. Distratores absurdos ("Criar o Império Romano", "Deriva
-- continental" numa questão de ecologia, "Substituir água por refrigerante")
-- viraram alternativas plausíveis, e a certa da Guerra Fria foi encurtada.
-- Em Inglês o comando e as alternativas em pt seguem a regra das matérias de
-- língua: o texto de apoio fica em inglês e o resto em português.
--
-- Fonte: tool/content/materias/<matéria>_revisao2.txt, gerado por
-- tool/content/gen_new_questions.py. Um bloco por matéria abaixo.

-- ===== artes =====
-- New questions for artes: 2 questions, each already
-- with its en/es translation (4 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('a0ee7717-5d1e-5026-839d-87244acdfd58', '37d9e580-8130-5c76-ab04-0d4b4acefd6c',
   'Em uma pintura, linhas diagonais, forte contraste de luz e poses instáveis tendem a produzir qual efeito visual?',
   array['Sensação de movimento e tensão', 'Calma e repouso', 'Ausência de profundidade', 'Equilíbrio e simetria'], 0,
   'Diagonais e contrastes intensos conduzem o olhar e sugerem dinamismo.', 100, 'medio'),
  ('2902b384-47c6-5a64-8582-205ec0c5e3a3', '1608ace4-80cc-5a3d-a176-20cdf2c114a2',
   'Uma celebração tradicional transmitida entre gerações, com saberes, músicas e rituais próprios, é exemplo principalmente de:',
   array['Patrimônio cultural material', 'Patrimônio geológico', 'Patrimônio cultural imaterial', 'Patrimônio natural'], 2,
   'Práticas, saberes, celebrações e formas de expressão transmitidas socialmente integram o patrimônio cultural imaterial.', 101, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('a0ee7717-5d1e-5026-839d-87244acdfd58', 'en',
   'In a painting, diagonal lines, strong light contrast, and unstable poses tend to create which visual effect?',
   array['A sense of movement and tension', 'Calm and rest', 'Lack of depth', 'Balance and symmetry'],
   'Diagonals and strong contrasts guide the eye and suggest dynamism.'),
  ('a0ee7717-5d1e-5026-839d-87244acdfd58', 'es',
   'En una pintura, las líneas diagonales, el fuerte contraste de luz y las poses inestables tienden a producir ¿qué efecto visual?',
   array['Sensación de movimiento y tensión', 'Calma y reposo', 'Ausencia de profundidad', 'Equilibrio y simetría'],
   'Las diagonales y los contrastes intensos guían la mirada y sugieren dinamismo.'),
  ('2902b384-47c6-5a64-8582-205ec0c5e3a3', 'en',
   'A traditional celebration passed across generations, with its own knowledge, music, and rituals, is mainly an example of:',
   array['Tangible cultural heritage', 'Geological heritage', 'Intangible cultural heritage', 'Natural heritage'],
   'Practices, knowledge, celebrations, and forms of expression transmitted socially are part of intangible cultural heritage.'),
  ('2902b384-47c6-5a64-8582-205ec0c5e3a3', 'es',
   'Una celebración tradicional transmitida entre generaciones, con saberes, músicas y rituales propios, es principalmente un ejemplo de:',
   array['Patrimonio cultural material', 'Patrimonio geológico', 'Patrimonio cultural inmaterial', 'Patrimonio natural'],
   'Las prácticas, saberes, celebraciones y formas de expresión transmitidas socialmente forman parte del patrimonio cultural inmaterial.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== biologia =====
-- New questions for biologia: 3 questions, each already
-- with its en/es translation (6 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('76a49270-5131-5196-8c46-b94e4f23c961', 'c4b861cb-2247-46b7-9b38-fe2f1295d952',
   'A retirada de um predador de topo pode aumentar suas presas e, indiretamente, reduzir organismos consumidos por essas presas. Esse efeito é chamado de:',
   array['Sucessão ecológica', 'Bioacumulação', 'Competição interespecífica', 'Cascata trófica'], 3,
   'Uma cascata trófica ocorre quando uma alteração em um nível alimentar desencadeia efeitos indiretos em outros níveis.', 100, 'dificil'),
  ('cd00378c-4467-5b0b-8a2e-e304f2237432', 'f60e7769-0be0-4a8e-b2e5-bb84e9163a6f',
   'Em um cruzamento Aa × Aa, com dominância completa, qual é a probabilidade de um descendente apresentar o fenótipo recessivo?',
   array['25%', '50%', '75%', '100%'], 0,
   'Os genótipos possíveis são AA, Aa, Aa e aa. Apenas aa expressa o fenótipo recessivo: 1 em 4.', 101, 'medio'),
  ('3e83ff52-d2e2-5fcf-912c-f4b1f9a9ed3b', '18976237-e643-437e-8216-7ff0c5a09df5',
   'Uma população bacteriana já possui variantes resistentes e sensíveis antes do uso de um antibiótico. Após vários tratamentos, as resistentes se tornam mais frequentes porque:',
   array['As bactérias sensíveis passam a produzir resistência após contato repetido', 'O antibiótico seleciona variantes resistentes já presentes na população', 'As bactérias escolhem alterar seus genes', 'O antibiótico produz a mesma mutação dirigida em todas'], 1,
   'A seleção natural aumenta a frequência de variantes herdáveis que sobrevivem e se reproduzem melhor no ambiente.', 102, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('76a49270-5131-5196-8c46-b94e4f23c961', 'en',
   'Removing a top predator may increase its prey and indirectly reduce organisms eaten by those prey. This effect is called:',
   array['Ecological succession', 'Bioaccumulation', 'Interspecific competition', 'A trophic cascade'],
   'A trophic cascade occurs when a change at one feeding level triggers indirect effects across other levels.'),
  ('76a49270-5131-5196-8c46-b94e4f23c961', 'es',
   'Retirar un depredador ápice puede aumentar sus presas y, de forma indirecta, reducir organismos consumidos por ellas. Este efecto se llama:',
   array['Sucesión ecológica', 'Bioacumulación', 'Competencia interespecífica', 'Cascada trófica'],
   'Una cascada trófica ocurre cuando una alteración en un nivel alimentario desencadena efectos indirectos en otros niveles.'),
  ('cd00378c-4467-5b0b-8a2e-e304f2237432', 'en',
   'In an Aa × Aa cross with complete dominance, what is the probability that an offspring shows the recessive phenotype?',
   array['25%', '50%', '75%', '100%'],
   'The possible genotypes are AA, Aa, Aa, and aa. Only aa expresses the recessive phenotype: 1 in 4.'),
  ('cd00378c-4467-5b0b-8a2e-e304f2237432', 'es',
   'En un cruce Aa × Aa con dominancia completa, ¿cuál es la probabilidad de que un descendiente presente el fenotipo recesivo?',
   array['25%', '50%', '75%', '100%'],
   'Los genotipos posibles son AA, Aa, Aa y aa. Solo aa expresa el fenotipo recesivo: 1 de 4.'),
  ('3e83ff52-d2e2-5fcf-912c-f4b1f9a9ed3b', 'en',
   'A bacterial population already contains resistant and sensitive variants before antibiotic use. After repeated treatments, resistant variants become more frequent because:',
   array['Sensitive bacteria begin producing resistance after repeated contact', 'The antibiotic selects resistant variants already present in the population', 'Bacteria choose to alter their genes', 'The antibiotic causes the same directed mutation in all bacteria'],
   'Natural selection increases the frequency of heritable variants that survive and reproduce better in that environment.'),
  ('3e83ff52-d2e2-5fcf-912c-f4b1f9a9ed3b', 'es',
   'Una población bacteriana ya contiene variantes resistentes y sensibles antes del uso de un antibiótico. Tras varios tratamientos, las resistentes se vuelven más frecuentes porque:',
   array['Las bacterias sensibles comienzan a producir resistencia tras contactos repetidos', 'El antibiótico selecciona variantes resistentes ya presentes en la población', 'Las bacterias eligen alterar sus genes', 'El antibiótico produce la misma mutación dirigida en todas'],
   'La selección natural aumenta la frecuencia de variantes heredables que sobreviven y se reproducen mejor en ese ambiente.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== educacao_fisica =====
-- New questions for educacao_fisica: 3 questions, each already
-- with its en/es translation (6 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('5ac010e9-c20d-5fe1-8265-19458886de90', 'de64f0c8-9c09-5216-a98f-a233bf02f5a4',
   'Para melhorar a resistência cardiorrespiratória com segurança em iniciantes, qual princípio é mais adequado?',
   array['Treinar apenas uma vez por mês', 'Começar sempre na intensidade máxima', 'Aumentar gradualmente volume e intensidade', 'Ignorar recuperação e fadiga'], 2,
   'A progressão gradual permite adaptação fisiológica e reduz risco de sobrecarga.', 100, 'medio'),
  ('ca091aeb-1e26-5af4-9d4d-f7e7d98533dc', '513e1850-b4eb-55c4-a81d-026f8d56be6b',
   'Em esportes coletivos de invasão, criar superioridade numérica em uma zona serve principalmente para:',
   array['Impedir qualquer transição defensiva', 'Paralisar o jogo', 'Eliminar a necessidade de comunicação', 'Aumentar opções de passe e dificultar a marcação'], 3,
   'A superioridade numérica cria mais linhas de passe e pode facilitar progressão e finalização.', 101, 'medio'),
  ('31d4f679-8f17-5c1a-9538-8ae3de2839fe', '2bd28a7c-96e5-5449-a63d-2df7368e4940',
   'Qual atitude cotidiana ajuda a reduzir o comportamento sedentário?',
   array['Interromper longos períodos sentado com pequenas pausas ativas', 'Compensar a semana sentado com um único treino longo no fim de semana', 'Usar o elevador em vez da escada', 'Trocar trajetos a pé por trajetos de carro'], 0,
   'Quebrar períodos prolongados sentado com movimento leve reduz o tempo sedentário acumulado.', 102, 'facil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('5ac010e9-c20d-5fe1-8265-19458886de90', 'en',
   'To improve cardiorespiratory endurance safely in beginners, which principle is most appropriate?',
   array['Train only once a month', 'Always start at maximum intensity', 'Gradually increase volume and intensity', 'Ignore recovery and fatigue'],
   'Gradual progression allows physiological adaptation and reduces overload risk.'),
  ('5ac010e9-c20d-5fe1-8265-19458886de90', 'es',
   'Para mejorar de forma segura la resistencia cardiorrespiratoria en principiantes, ¿qué principio es más adecuado?',
   array['Entrenar solo una vez al mes', 'Empezar siempre con intensidad máxima', 'Aumentar gradualmente el volumen y la intensidad', 'Ignorar la recuperación y la fatiga'],
   'La progresión gradual permite la adaptación fisiológica y reduce el riesgo de sobrecarga.'),
  ('ca091aeb-1e26-5af4-9d4d-f7e7d98533dc', 'en',
   'In invasion team sports, creating a numerical advantage in one area mainly serves to:',
   array['Prevent every defensive transition', 'Stop play', 'Eliminate the need for communication', 'Increase passing options and make defending harder'],
   'A numerical advantage creates more passing lanes and can facilitate progression and finishing.'),
  ('ca091aeb-1e26-5af4-9d4d-f7e7d98533dc', 'es',
   'En deportes colectivos de invasión, crear superioridad numérica en una zona sirve principalmente para:',
   array['Impedir cualquier transición defensiva', 'Detener el juego', 'Eliminar la necesidad de comunicación', 'Aumentar las opciones de pase y dificultar la defensa'],
   'La superioridad numérica crea más líneas de pase y puede facilitar la progresión y la finalización.'),
  ('31d4f679-8f17-5c1a-9538-8ae3de2839fe', 'en',
   'Which everyday action helps reduce sedentary behavior?',
   array['Breaking up long periods of sitting with short active breaks', 'Offsetting a week of sitting with one long workout on the weekend', 'Taking the elevator instead of the stairs', 'Replacing walking trips with car trips'],
   'Breaking prolonged sitting with light movement reduces accumulated sedentary time.'),
  ('31d4f679-8f17-5c1a-9538-8ae3de2839fe', 'es',
   '¿Qué acción cotidiana ayuda a reducir el comportamiento sedentario?',
   array['Interrumpir largos períodos sentado con breves pausas activas', 'Compensar la semana sentado con un único entrenamiento largo el fin de semana', 'Usar el ascensor en lugar de la escalera', 'Cambiar los trayectos a pie por trayectos en coche'],
   'Interrumpir períodos prolongados sentado con movimiento ligero reduce el tiempo sedentario acumulado.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== espanhol =====
-- New questions for espanhol: 3 questions, each already
-- with its en/es translation (6 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('bc0bc5e2-42f9-5218-8d4e-5bd437e88503', 'e5c195b2-3092-57b4-b0f7-e4c63201159e',
   'Leia: "Aunque Marta había estudiado mucho, algunas preguntas del examen la sorprendieron." O que se pode inferir?',
   array['Marta não estudou', 'Marta se preparou, mas encontrou questões inesperadas', 'A prova foi cancelada', 'Marta conhecia todas as perguntas antes'], 1,
   'O conector "aunque" marca contraste entre ter estudado e ainda assim encontrar surpresas.', 100, 'medio'),
  ('9c72f817-abba-5f9c-88d2-d24aaf8d4fb7', '1fd15cb5-a400-516d-8cfc-5ef3992b8a3d',
   'Complete: "Cuando llegué a casa, mi hermano ya ___ la cena."',
   array['prepara', 'preparará', 'había preparado', 'prepararía'], 2,
   'O pretérito mais-que-perfeito "había preparado" indica uma ação concluída antes de outra ação passada ("llegué").', 101, 'dificil'),
  ('47af6d25-3fc0-516f-ad0e-6aca77fd773f', '7978396f-326f-5dbd-a92b-a6d6a904d78e',
   'Em espanhol, na frase "La carpeta está sobre la mesa", a palavra "carpeta" significa:',
   array['Caderno', 'Carpete', 'Carteira de dinheiro', 'Pasta ou fichário'], 3,
   'Em espanhol, "carpeta" costuma significar pasta ou fichário; "carpete" corresponde a "alfombra" ou "moqueta".', 102, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('bc0bc5e2-42f9-5218-8d4e-5bd437e88503', 'en',
   'Read: "Aunque Marta había estudiado mucho, algunas preguntas del examen la sorprendieron." What can be inferred?',
   array['Marta did not study', 'Marta prepared, but encountered unexpected questions', 'The exam was canceled', 'Marta knew all questions in advance'],
   'The connector "aunque" marks a contrast between studying and still encountering surprises.'),
  ('bc0bc5e2-42f9-5218-8d4e-5bd437e88503', 'es',
   'Lee: "Aunque Marta había estudiado mucho, algunas preguntas del examen la sorprendieron." ¿Qué se puede inferir?',
   array['Marta no estudió', 'Marta se preparó, pero encontró preguntas inesperadas', 'El examen fue cancelado', 'Marta conocía todas las preguntas de antemano'],
   'El conector "aunque" marca un contraste entre haber estudiado y aun así encontrar sorpresas.'),
  ('9c72f817-abba-5f9c-88d2-d24aaf8d4fb7', 'en',
   'Complete: "Cuando llegué a casa, mi hermano ya ___ la cena."',
   array['prepara', 'preparará', 'había preparado', 'prepararía'],
   'The Spanish pluperfect "había preparado" expresses an action completed before another past action.'),
  ('9c72f817-abba-5f9c-88d2-d24aaf8d4fb7', 'es',
   'Completa: "Cuando llegué a casa, mi hermano ya ___ la cena."',
   array['prepara', 'preparará', 'había preparado', 'prepararía'],
   'El pluscuamperfecto "había preparado" expresa una acción anterior a otra acción pasada.'),
  ('47af6d25-3fc0-516f-ad0e-6aca77fd773f', 'en',
   'In Spanish, in the sentence "La carpeta está sobre la mesa", the word "carpeta" means:',
   array['Notebook', 'Carpet', 'Wallet', 'Folder or binder'],
   'In Spanish, "carpeta" commonly means folder or binder; a carpet is "alfombra" or "moqueta".'),
  ('47af6d25-3fc0-516f-ad0e-6aca77fd773f', 'es',
   'La palabra "carpeta" en español a veces se confunde con "carpete" en portugués (alfombra). ¿Qué significa "carpeta" en español?',
   array['Cuaderno', 'Alfombra', 'Cartera', 'Objeto para guardar papeles'],
   'En español, "carpeta" es el objeto para guardar papeles; lo que en portugués se llama "carpete" en español es "alfombra" o "moqueta".')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== filosofia =====
-- New questions for filosofia: 3 questions, each already
-- with its en/es translation (6 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('749f195f-dd40-5d21-a431-7d8a0e183814', '6eb0a23e-9547-58bc-b796-bc9b105e2b92',
   'No argumento ''Se chove, a rua molha. Chove. Logo, a rua molha'', a forma lógica é:',
   array['Modus ponens', 'Afirmação do consequente', 'Petição de princípio', 'Falso dilema'], 0,
   'A estrutura é: se P então Q; P; portanto Q. Essa inferência válida é modus ponens.', 100, 'medio'),
  ('12d9c6e7-58c4-58a1-aadb-8cbffd797167', '140f3cc9-4b63-51f6-8116-fc2d90926190',
   'Uma diferença importante entre Hobbes e Locke é que:',
   array['Ambos rejeitam qualquer contrato social', 'Hobbes defende soberania mais ampla, enquanto Locke enfatiza direitos individuais e limites ao governo', 'Locke defende direito divino dos reis', 'Hobbes considera desnecessário o Estado'], 1,
   'Ambos são contratualistas, mas divergem sobre direitos, estado de natureza e extensão do poder político.', 101, 'dificil'),
  ('dda92991-78a9-5be2-9519-416d0f7df98a', '03fd0820-41a9-5f12-ae35-299579f84f9a',
   'Uma hipótese científica é especialmente forte quando:',
   array['Explica qualquer resultado possível', 'Não pode ser confrontada com evidências', 'Produz previsões testáveis e resiste a testes rigorosos', 'É aceita apenas pela autoridade de quem a propôs'], 2,
   'Testabilidade e confronto com evidências são critérios centrais da investigação científica.', 102, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('749f195f-dd40-5d21-a431-7d8a0e183814', 'en',
   'In the argument ''If it rains, the street gets wet. It rains. Therefore, the street gets wet,'' the logical form is:',
   array['Modus ponens', 'Affirming the consequent', 'Begging the question', 'False dilemma'],
   'The structure is: if P then Q; P; therefore Q. This valid inference is modus ponens.'),
  ('749f195f-dd40-5d21-a431-7d8a0e183814', 'es',
   'En el argumento ''Si llueve, la calle se moja. Llueve. Por lo tanto, la calle se moja'', la forma lógica es:',
   array['Modus ponens', 'Afirmación del consecuente', 'Petición de principio', 'Falso dilema'],
   'La estructura es: si P entonces Q; P; por lo tanto Q. Esta inferencia válida es modus ponens.'),
  ('12d9c6e7-58c4-58a1-aadb-8cbffd797167', 'en',
   'An important difference between Hobbes and Locke is that:',
   array['Both reject any social contract', 'Hobbes supports broader sovereignty, while Locke emphasizes individual rights and limits on government', 'Locke defends divine-right monarchy', 'Hobbes considers the state unnecessary'],
   'Both are contract theorists, but they differ on rights, the state of nature, and the scope of political power.'),
  ('12d9c6e7-58c4-58a1-aadb-8cbffd797167', 'es',
   'Una diferencia importante entre Hobbes y Locke es que:',
   array['Ambos rechazan cualquier contrato social', 'Hobbes defiende una soberanía más amplia, mientras Locke enfatiza derechos individuales y límites al gobierno', 'Locke defiende el derecho divino de los reyes', 'Hobbes considera innecesario el Estado'],
   'Ambos son contractualistas, pero difieren sobre los derechos, el estado de naturaleza y el alcance del poder político.'),
  ('dda92991-78a9-5be2-9519-416d0f7df98a', 'en',
   'A scientific hypothesis is especially strong when it:',
   array['Explains every possible result', 'Cannot be confronted with evidence', 'Makes testable predictions and withstands rigorous testing', 'Is accepted only because of the authority of its author'],
   'Testability and confrontation with evidence are central criteria of scientific inquiry.'),
  ('dda92991-78a9-5be2-9519-416d0f7df98a', 'es',
   'Una hipótesis científica es especialmente sólida cuando:',
   array['Explica cualquier resultado posible', 'No puede confrontarse con evidencias', 'Produce predicciones comprobables y resiste pruebas rigurosas', 'Se acepta solo por la autoridad de quien la propuso'],
   'La posibilidad de prueba y la confrontación con evidencias son criterios centrales de la investigación científica.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== fisica =====
-- New questions for fisica: 3 questions, each already
-- with its en/es translation (6 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('243892ae-56a2-5a54-8ff9-7bc6e169ea21', 'a5777654-961e-4813-9fed-c5d835825966',
   'Um passageiro tende a se projetar para a frente quando um ônibus freia bruscamente. Isso é explicado pela:',
   array['Inércia', 'Refração', 'Indução eletromagnética', 'Lei de Coulomb'], 0,
   'Por inércia, o corpo tende a manter seu estado de movimento enquanto o ônibus reduz a velocidade.', 100, 'facil'),
  ('a97d8b2c-82f9-5dbf-8021-2053ff5142bc', '89939da9-3bec-40f4-826d-514c063a9351',
   'Um aparelho de 1000 W fica ligado por 30 minutos. Qual energia consome?',
   array['0,5 kWh', '2 kWh', '30 kWh', '500 kWh'], 0,
   '1000 W = 1 kW e 30 min = 0,5 h. E = P·t = 1·0,5 = 0,5 kWh.', 101, 'medio'),
  ('08ec7809-3662-54db-acdd-60c3255ca975', '8f3b95a7-93f3-4d62-b383-d9b66d005f08',
   'Ao passar obliquamente do ar para o vidro, a luz reduz sua velocidade. O raio refratado tende a:',
   array['Não entrar no vidro', 'Manter sempre o mesmo ângulo', 'Aproximar-se da normal', 'Afastar-se da normal'], 2,
   'Ao entrar em meio de maior índice de refração, a luz se desvia em direção à normal.', 102, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('243892ae-56a2-5a54-8ff9-7bc6e169ea21', 'en',
   'A passenger tends to lurch forward when a bus brakes suddenly. This is explained by:',
   array['Inertia', 'Refraction', 'Electromagnetic induction', 'Coulomb''s law'],
   'Because of inertia, the body tends to maintain its state of motion while the bus slows down.'),
  ('243892ae-56a2-5a54-8ff9-7bc6e169ea21', 'es',
   'Un pasajero tiende a proyectarse hacia delante cuando un autobús frena bruscamente. Esto se explica por la:',
   array['Inercia', 'Refracción', 'Inducción electromagnética', 'Ley de Coulomb'],
   'Por inercia, el cuerpo tiende a mantener su estado de movimiento mientras el autobús reduce su velocidad.'),
  ('a97d8b2c-82f9-5dbf-8021-2053ff5142bc', 'en',
   'A 1000 W appliance runs for 30 minutes. How much energy does it consume?',
   array['0.5 kWh', '2 kWh', '30 kWh', '500 kWh'],
   '1000 W = 1 kW and 30 min = 0.5 h. E = P·t = 1·0.5 = 0.5 kWh.'),
  ('a97d8b2c-82f9-5dbf-8021-2053ff5142bc', 'es',
   'Un aparato de 1000 W permanece encendido durante 30 minutos. ¿Cuánta energía consume?',
   array['0,5 kWh', '2 kWh', '30 kWh', '500 kWh'],
   '1000 W = 1 kW y 30 min = 0,5 h. E = P·t = 1·0,5 = 0,5 kWh.'),
  ('08ec7809-3662-54db-acdd-60c3255ca975', 'en',
   'When light passes obliquely from air into glass, its speed decreases. The refracted ray tends to:',
   array['Not enter the glass', 'Always keep the same angle', 'Bend toward the normal', 'Bend away from the normal'],
   'When entering a medium with a higher refractive index, light bends toward the normal.'),
  ('08ec7809-3662-54db-acdd-60c3255ca975', 'es',
   'Al pasar oblicuamente del aire al vidrio, la luz reduce su velocidad. El rayo refractado tiende a:',
   array['No entrar en el vidrio', 'Mantener siempre el mismo ángulo', 'Acercarse a la normal', 'Alejarse de la normal'],
   'Al entrar en un medio con mayor índice de refracción, la luz se desvía hacia la normal.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== geografia =====
-- New questions for geografia: 1 questions, each already
-- with its en/es translation (2 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('a27155bc-31f8-5589-9b8a-756b040e07a5', 'be84da4e-f4ab-4a4a-a406-9a05e49917d4',
   'Em um mapa de escala 1:100.000, 1 cm no mapa corresponde, no terreno, a:',
   array['10 km', '100 km', '100 m', '1 km'], 3,
   '100.000 cm equivalem a 1.000 m, isto é, 1 km.', 100, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('a27155bc-31f8-5589-9b8a-756b040e07a5', 'en',
   'On a map with a scale of 1:100,000, 1 cm on the map corresponds on the ground to:',
   array['10 km', '100 km', '100 m', '1 km'],
   '100,000 cm equals 1,000 m, that is, 1 km.'),
  ('a27155bc-31f8-5589-9b8a-756b040e07a5', 'es',
   'En un mapa a escala 1:100.000, 1 cm en el mapa corresponde en el terreno a:',
   array['10 km', '100 km', '100 m', '1 km'],
   '100.000 cm equivalen a 1.000 m, es decir, 1 km.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== historia =====
-- New questions for historia: 3 questions, each already
-- with its en/es translation (6 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('9bbe3070-8d99-505a-aa47-bd3897f9bab3', 'ad10464d-0d11-4255-9fef-d341a0f856d6',
   'Os quilombos no Brasil colonial podem ser entendidos como:',
   array['Fortificações erguidas pela Coroa nas fronteiras', 'Instituições criadas pela Coroa para ampliar a escravidão', 'Comunidades de resistência à escravidão, formadas sobretudo por escravizados fugidos', 'Aldeamentos missionários organizados por jesuítas'], 2,
   'Os quilombos reuniram experiências de resistência, autonomia e organização social, com destaque histórico para Palmares.', 100, 'dificil'),
  ('676cf4ab-f554-507a-92c7-454058049619', 'e93f87be-ca79-4813-9a67-616320aa9a8a',
   'A Revolução Gloriosa de 1688 contribuiu para:',
   array['Limitar o poder monárquico e fortalecer o Parlamento inglês', 'Restaurar absolutismo sem limites', 'Instituir a república na Inglaterra', 'Abolir o Parlamento'], 0,
   'A consolidação da monarquia constitucional ampliou a centralidade do Parlamento e limitou institucionalmente a Coroa.', 101, 'dificil'),
  ('1d70b9d5-3c49-556c-957f-1f69261f0477', '9d1627ca-eade-4dcf-83dc-a1acfcd096c8',
   'A expressão ''Guerra Fria'' indica que EUA e URSS:',
   array['Disputaram influência global sem guerra direta entre si', 'Mantiveram aliança permanente', 'Abandonaram a corrida tecnológica', 'Nunca participaram de conflitos indiretos'], 0,
   'A rivalidade envolveu armas, propaganda, economia, tecnologia e guerras por procuração, sem guerra direta ampla entre as superpotências.', 102, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('9bbe3070-8d99-505a-aa47-bd3897f9bab3', 'en',
   'Quilombos in colonial Brazil can be understood as:',
   array['Fortifications built by the Crown on the frontiers', 'Institutions created by the Crown to expand slavery', 'Communities of resistance to slavery, formed mainly by people who escaped enslavement', 'Mission villages organized by Jesuits'],
   'Quilombos included diverse experiences of resistance, autonomy, and social organization, with Palmares as a major historical example.'),
  ('9bbe3070-8d99-505a-aa47-bd3897f9bab3', 'es',
   'Los quilombos en el Brasil colonial pueden entenderse como:',
   array['Fortificaciones levantadas por la Corona en las fronteras', 'Instituciones creadas por la Corona para ampliar la esclavitud', 'Comunidades de resistencia a la esclavitud, formadas sobre todo por esclavizados fugitivos', 'Reducciones misioneras organizadas por jesuitas'],
   'Los quilombos reunieron experiencias de resistencia, autonomía y organización social, con Palmares como ejemplo histórico destacado.'),
  ('676cf4ab-f554-507a-92c7-454058049619', 'en',
   'The Glorious Revolution of 1688 contributed to:',
   array['Limiting monarchical power and strengthening the English Parliament', 'Restoring unlimited absolutism', 'Establishing a republic in England', 'Abolishing Parliament'],
   'The consolidation of constitutional monarchy increased Parliament''s centrality and institutionally limited the Crown.'),
  ('676cf4ab-f554-507a-92c7-454058049619', 'es',
   'La Revolución Gloriosa de 1688 contribuyó a:',
   array['Limitar el poder monárquico y fortalecer el Parlamento inglés', 'Restaurar un absolutismo sin límites', 'Instaurar la república en Inglaterra', 'Abolir el Parlamento'],
   'La consolidación de la monarquía constitucional aumentó la centralidad del Parlamento y limitó institucionalmente a la Corona.'),
  ('1d70b9d5-3c49-556c-957f-1f69261f0477', 'en',
   'The term ''Cold War'' indicates that the US and USSR:',
   array['Competed for global influence without fighting each other directly', 'Maintained a permanent alliance', 'Abandoned technological competition', 'Never participated in proxy conflicts'],
   'The rivalry involved weapons, propaganda, economics, technology, and proxy wars without a broad direct war between the superpowers.'),
  ('1d70b9d5-3c49-556c-957f-1f69261f0477', 'es',
   'La expresión ''Guerra Fría'' indica que EE. UU. y la URSS:',
   array['Disputaron influencia global sin enfrentarse directamente', 'Mantuvieron una alianza permanente', 'Abandonaron la competencia tecnológica', 'Nunca participaron en conflictos indirectos'],
   'La rivalidad involucró armas, propaganda, economía, tecnología y guerras por intermediarios, sin una guerra directa amplia entre las superpotencias.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== ingles =====
-- New questions for ingles: 3 questions, each already
-- with its en/es translation (6 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('56fb358d-d80f-550e-b3ac-ced3e176b384', '7d710fd7-763a-5ecc-af95-128563a2cc94',
   'Leia: "The lights were off, the door was locked, and no cars were in the parking lot." Qual é a inferência mais razoável?',
   array['O lugar provavelmente está fechado', 'O lugar certamente está lotado', 'Há um show acontecendo lá dentro', 'O prédio está em reforma'], 0,
   'As pistas, em conjunto (luzes apagadas, porta trancada, estacionamento vazio), sugerem que o lugar não está funcionando naquele momento.', 100, 'medio'),
  ('7c2795d0-f7b0-55c3-ba88-7d8d736df3ce', '3b8260fc-beeb-554b-8d8c-779f743b0be7',
   'Complete: "If she had left earlier, she ___ the train."',
   array['will catch', 'would have caught', 'catches', 'would catch'], 1,
   'É um third conditional: "if + past perfect" combina com "would have + past participle", para falar de algo que não aconteceu no passado.', 101, 'dificil'),
  ('fc0e0437-e8cb-5d92-9961-1868d5fcbc01', '939e43a2-e234-5806-a380-1b4f3b6aeff4',
   'Qual opção completa a combinação usual em inglês "___ a decision" (tomar uma decisão)?',
   array['put', 'do', 'make', 'take up'], 2,
   'A combinação usual (collocation) é "make a decision"; em inglês não se diz "do a decision".', 102, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('56fb358d-d80f-550e-b3ac-ced3e176b384', 'en',
   'Read: "The lights were off, the door was locked, and no cars were in the parking lot." What is the most reasonable inference?',
   array['The place is probably closed', 'The place is definitely crowded', 'A concert is happening inside', 'The building is being renovated'],
   'The clues collectively suggest that the place is not operating at that moment.'),
  ('56fb358d-d80f-550e-b3ac-ced3e176b384', 'es',
   'Lee: "The lights were off, the door was locked, and no cars were in the parking lot." ¿Cuál es la inferencia más razonable?',
   array['El lugar probablemente está cerrado', 'El lugar está definitivamente lleno', 'Hay un concierto dentro', 'El edificio está en reformas'],
   'Las pistas, en conjunto, sugieren que el lugar no está funcionando en ese momento.'),
  ('7c2795d0-f7b0-55c3-ba88-7d8d736df3ce', 'en',
   'Complete: "If she had left earlier, she ___ the train."',
   array['will catch', 'would have caught', 'catches', 'would catch'],
   'This is a third conditional: "if + past perfect" pairs with "would have + past participle".'),
  ('7c2795d0-f7b0-55c3-ba88-7d8d736df3ce', 'es',
   'Completa: "If she had left earlier, she ___ the train."',
   array['will catch', 'would have caught', 'catches', 'would catch'],
   'Es un tercer condicional: "if + past perfect" se combina con "would have + past participle".'),
  ('fc0e0437-e8cb-5d92-9961-1868d5fcbc01', 'en',
   'Which option completes the common collocation: "___ a decision"?',
   array['put', 'do', 'make', 'take up'],
   'The standard collocation is "make a decision".'),
  ('fc0e0437-e8cb-5d92-9961-1868d5fcbc01', 'es',
   '¿Qué opción completa la colocación habitual en inglés: "___ a decision"?',
   array['put', 'do', 'make', 'take up'],
   'La colocación habitual en inglés es "make a decision".')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== literatura =====
-- New questions for literatura: 2 questions, each already
-- with its en/es translation (4 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('a6481e36-ad65-53cb-a2ae-a4abb27ae450', '47653aa7-d471-5270-9cfe-c1567fab81d2',
   'Um narrador que participa da história como personagem e relata os fatos em primeira pessoa é:',
   array['Eu lírico', 'Narrador onisciente externo', 'Autor empírico', 'Narrador-personagem'], 3,
   'O narrador-personagem pertence ao universo narrado e conta os fatos a partir de sua perspectiva.', 100, 'medio'),
  ('f8629cd7-d51a-58c8-a78c-65d4699ff94c', '568bb871-cde8-5186-83b7-c0d7f350c8a0',
   'A repetição da mesma palavra ou expressão no início de versos sucessivos é chamada de:',
   array['Metonímia', 'Anáfora', 'Onomatopeia', 'Eufemismo'], 1,
   'Anáfora é a repetição intencional de palavras ou expressões no início de segmentos sucessivos.', 101, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('a6481e36-ad65-53cb-a2ae-a4abb27ae450', 'en',
   'A narrator who takes part in the story as a character and recounts events in the first person is:',
   array['A lyrical speaker', 'An external omniscient narrator', 'The empirical author', 'A character-narrator'],
   'A character-narrator belongs to the narrated world and recounts events from their own perspective.'),
  ('a6481e36-ad65-53cb-a2ae-a4abb27ae450', 'es',
   'Un narrador que participa en la historia como personaje y relata los hechos en primera persona es:',
   array['Yo lírico', 'Narrador omnisciente externo', 'Autor empírico', 'Narrador personaje'],
   'El narrador personaje forma parte del universo narrado y cuenta los hechos desde su propia perspectiva.'),
  ('f8629cd7-d51a-58c8-a78c-65d4699ff94c', 'en',
   'Repeating the same word or phrase at the beginning of successive lines is called:',
   array['Metonymy', 'Anaphora', 'Onomatopoeia', 'Euphemism'],
   'Anaphora is the intentional repetition of words or phrases at the beginning of successive segments.'),
  ('f8629cd7-d51a-58c8-a78c-65d4699ff94c', 'es',
   'La repetición de la misma palabra o expresión al comienzo de versos sucesivos se llama:',
   array['Metonimia', 'Anáfora', 'Onomatopeya', 'Eufemismo'],
   'La anáfora es la repetición intencional de palabras o expresiones al comienzo de segmentos sucesivos.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== matematica =====
-- New questions for matematica: 2 questions, each already
-- with its en/es translation (4 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('94ae56e6-20a2-50e9-89b5-1dfe01e88217', '799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c',
   'Dois triângulos semelhantes têm razão linear 3:2. Se a área do menor é 20 cm², a área do maior é:',
   array['90 cm²', '45 cm²', '60 cm²', '30 cm²'], 1,
   'As áreas variam com o quadrado da razão linear: (3/2)² = 9/4; 20·9/4 = 45.', 100, 'dificil'),
  ('1c7c6c9c-7d58-5245-ac2a-dddbc51a8f7b', '184775e6-5bcb-4648-80d5-e7d97ee02af7',
   'Uma moeda justa é lançada duas vezes. Qual a probabilidade de sair exatamente uma cara?',
   array['3/4', '1/4', '1', '1/2'], 3,
   'Os resultados possíveis são CC, CK, KC e KK (C = cara, K = coroa). Exatamente uma cara ocorre em 2 dos 4 casos: 2/4 = 1/2.', 101, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('94ae56e6-20a2-50e9-89b5-1dfe01e88217', 'en',
   'Two similar triangles have a linear ratio of 3:2. If the smaller area is 20 cm², the larger area is:',
   array['90 cm²', '45 cm²', '60 cm²', '30 cm²'],
   'Areas scale with the square of the linear ratio: (3/2)² = 9/4; 20·9/4 = 45.'),
  ('94ae56e6-20a2-50e9-89b5-1dfe01e88217', 'es',
   'Dos triángulos semejantes tienen razón lineal 3:2. Si el área del menor es 20 cm², el área del mayor es:',
   array['90 cm²', '45 cm²', '60 cm²', '30 cm²'],
   'Las áreas varían con el cuadrado de la razón lineal: (3/2)² = 9/4; 20·9/4 = 45.'),
  ('1c7c6c9c-7d58-5245-ac2a-dddbc51a8f7b', 'en',
   'A fair coin is tossed twice. What is the probability of getting exactly one head?',
   array['3/4', '1/4', '1', '1/2'],
   'Among HH, HT, TH, and TT, exactly one head occurs in 2 of 4 cases: 1/2.'),
  ('1c7c6c9c-7d58-5245-ac2a-dddbc51a8f7b', 'es',
   'Se lanza dos veces una moneda equilibrada. ¿Cuál es la probabilidad de obtener exactamente una cara?',
   array['3/4', '1/4', '1', '1/2'],
   'Entre CC, CX, XC y XX, exactamente una cara ocurre en 2 de 4 casos: 1/2.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== portugues =====
-- New questions for portugues: 3 questions, each already
-- with its en/es translation (6 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('24774102-bbb5-537c-8399-f84922830219', 'f25a58d3-8d53-4fda-abee-4ee3cb708b26',
   'A frase "Vi o professor com o telescópio" é ambígua porque:',
   array['Não possui verbo', 'Tem duas palavras grafadas incorretamente', 'Só admite uma interpretação', 'Pode significar que eu usei o telescópio ou que o professor estava com ele'], 3,
   'O trecho "com o telescópio" pode se ligar ao verbo "vi" ou ao substantivo "professor", gerando duas leituras.', 100, 'medio'),
  ('33df1bb1-42a8-5c76-a6a7-c16b88d44df8', '6328fd95-8026-4dc2-8cdc-40bcaf543628',
   'Na frase "Embora estivesse cansado, continuou estudando", a oração iniciada por "embora" expressa:',
   array['Causa', 'Concessão', 'Finalidade', 'Conclusão'], 1,
   '"Embora" apresenta uma circunstância contrária que não impede a ação principal; a relação é concessiva.', 101, 'dificil'),
  ('8180f839-69f2-515f-a155-c7fa3d151213', '3489b617-c328-4af1-bd3d-7a84dd343f79',
   'A escolha entre uma forma mais formal e uma mais coloquial de falar depende principalmente:',
   array['Da idade de quem fala', 'Da situação comunicativa, dos interlocutores e do objetivo', 'Do domínio da norma-padrão por quem fala', 'Da região onde a pessoa nasceu'], 1,
   'Adequação linguística considera contexto, finalidade e interlocutores; registros diferentes cumprem funções diferentes.', 102, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('24774102-bbb5-537c-8399-f84922830219', 'en',
   'The Portuguese sentence "Vi o professor com o telescópio" is ambiguous because:',
   array['It has no verb', 'It contains two misspelled words', 'It allows only one interpretation', 'It may mean that I used the telescope or that the teacher had it'],
   'The phrase "com o telescópio" can attach to the verb "vi" or to the noun "professor", producing two readings.'),
  ('24774102-bbb5-537c-8399-f84922830219', 'es',
   'La frase portuguesa "Vi o professor com o telescópio" es ambigua porque:',
   array['No tiene verbo', 'Contiene dos palabras mal escritas', 'Solo admite una interpretación', 'Puede significar que yo usé el telescopio o que el profesor lo tenía'],
   'El sintagma "com o telescópio" puede vincularse al verbo "vi" o al sustantivo "professor", generando dos lecturas.'),
  ('33df1bb1-42a8-5c76-a6a7-c16b88d44df8', 'en',
   'In the Portuguese sentence "Embora estivesse cansado, continuou estudando", the clause introduced by "embora" expresses:',
   array['Cause', 'Concession', 'Purpose', 'Conclusion'],
   '"Embora" introduces a contrary circumstance that does not prevent the main action; the relation is concessive.'),
  ('33df1bb1-42a8-5c76-a6a7-c16b88d44df8', 'es',
   'En la oración portuguesa "Embora estivesse cansado, continuou estudando", la subordinada introducida por "embora" expresa:',
   array['Causa', 'Concesión', 'Finalidad', 'Conclusión'],
   '"Embora" presenta una circunstancia contraria que no impide la acción principal; la relación es concesiva.'),
  ('8180f839-69f2-515f-a155-c7fa3d151213', 'en',
   'Choosing between a more formal and a more colloquial way of speaking mainly depends on:',
   array['The speaker''s age', 'The communicative situation, the interlocutors, and the purpose', 'The speaker''s command of the standard norm', 'The region where the speaker was born'],
   'Linguistic appropriateness considers context, purpose, and interlocutors; different registers serve different functions.'),
  ('8180f839-69f2-515f-a155-c7fa3d151213', 'es',
   'La elección entre una forma más formal y otra más coloquial de hablar depende principalmente:',
   array['De la edad de quien habla', 'De la situación comunicativa, los interlocutores y el objetivo', 'Del dominio de la norma estándar por parte de quien habla', 'De la región donde nació el hablante'],
   'La adecuación lingüística considera contexto, finalidad e interlocutores; distintos registros cumplen funciones diferentes.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== quimica =====
-- New questions for quimica: 3 questions, each already
-- with its en/es translation (6 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('d5c1e88b-e79f-5a6e-9b51-3bd72199dc50', '1694b662-d892-4687-8727-9f74c2715b11',
   'Na reação 2H₂ + O₂ → 2H₂O, misturam-se 4 mol de H₂ e 1 mol de O₂. Qual é o reagente limitante?',
   array['H₂O', 'O₂', 'H₂', 'Nenhum'], 1,
   'A proporção exige 2 mol de H₂ para 1 mol de O₂. O O₂ acaba primeiro e limita a reação.', 100, 'dificil'),
  ('55e48e6f-d3d6-5fea-a58d-615221d10b0c', '2e117b4e-3e7c-492e-82dc-22b964209b9a',
   'Em um equilíbrio exotérmico, o aumento da temperatura tende a deslocar o equilíbrio:',
   array['Para o lado de maior massa molar', 'Sem alteração possível', 'No sentido endotérmico', 'Sempre para os produtos'], 2,
   'Pelo princípio de Le Châtelier, adicionar calor favorece o sentido que consome calor, ou seja, o endotérmico.', 101, 'dificil'),
  ('a167cc90-4bf2-5088-ac2f-1f7eeb458ab3', '2e117b4e-3e7c-492e-82dc-22b964209b9a',
   'Em uma pilha galvânica em funcionamento, ocorre:',
   array['Redução nos dois eletrodos', 'Oxidação no ânodo e redução no cátodo', 'Redução no ânodo e oxidação no cátodo', 'Oxidação nos dois eletrodos'], 1,
   'Em pilhas, o ânodo é o local da oxidação e o cátodo, da redução.', 102, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('d5c1e88b-e79f-5a6e-9b51-3bd72199dc50', 'en',
   'For 2H₂ + O₂ → 2H₂O, 4 mol of H₂ are mixed with 1 mol of O₂. Which is the limiting reactant?',
   array['H₂O', 'O₂', 'H₂', 'Neither'],
   'The ratio requires 2 mol of H₂ per 1 mol of O₂. O₂ is consumed first and limits the reaction.'),
  ('d5c1e88b-e79f-5a6e-9b51-3bd72199dc50', 'es',
   'En 2H₂ + O₂ → 2H₂O, se mezclan 4 mol de H₂ con 1 mol de O₂. ¿Cuál es el reactivo limitante?',
   array['H₂O', 'O₂', 'H₂', 'Ninguno'],
   'La proporción exige 2 mol de H₂ por 1 mol de O₂. El O₂ se consume primero y limita la reacción.'),
  ('55e48e6f-d3d6-5fea-a58d-615221d10b0c', 'en',
   'In an exothermic equilibrium, increasing temperature tends to shift equilibrium:',
   array['Toward the side with greater molar mass', 'With no possible change', 'Toward the endothermic direction', 'Always toward products'],
   'By Le Châtelier''s principle, adding heat favors the direction that consumes heat, namely the endothermic direction.'),
  ('55e48e6f-d3d6-5fea-a58d-615221d10b0c', 'es',
   'En un equilibrio exotérmico, aumentar la temperatura tiende a desplazar el equilibrio:',
   array['Hacia el lado de mayor masa molar', 'Sin cambio posible', 'Hacia el sentido endotérmico', 'Siempre hacia los productos'],
   'Según el principio de Le Châtelier, añadir calor favorece el sentido que consume calor, es decir, el endotérmico.'),
  ('a167cc90-4bf2-5088-ac2f-1f7eeb458ab3', 'en',
   'In an operating galvanic cell:',
   array['Reduction occurs at both electrodes', 'Oxidation occurs at the anode and reduction at the cathode', 'Reduction occurs at the anode and oxidation at the cathode', 'Oxidation occurs at both electrodes'],
   'In galvanic cells, oxidation occurs at the anode and reduction at the cathode.'),
  ('a167cc90-4bf2-5088-ac2f-1f7eeb458ab3', 'es',
   'En una pila galvánica en funcionamiento:',
   array['La reducción ocurre en ambos electrodos', 'La oxidación ocurre en el ánodo y la reducción en el cátodo', 'La reducción ocurre en el ánodo y la oxidación en el cátodo', 'La oxidación ocurre en ambos electrodos'],
   'En las pilas, la oxidación ocurre en el ánodo y la reducción en el cátodo.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== sociologia =====
-- New questions for sociologia: 2 questions, each already
-- with its en/es translation (4 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('1e22ffe4-818b-5044-8ef3-c3ddff9f3149', 'f190a7a5-5965-5715-8637-73aa29be4c26',
   'Julgar costumes de outro grupo apenas pelos padrões da própria cultura, considerando-os inferiores, é exemplo de:',
   array['Burocratização', 'Mobilidade social', 'Secularização', 'Etnocentrismo'], 3,
   'Etnocentrismo é usar a própria cultura como referência central para avaliar outras.', 100, 'medio'),
  ('62e16885-1360-5050-bcae-41e3703d28e6', '8c493578-e186-5f49-8ff8-23dcc1975da4',
   'Em redes sociais, sistemas de recomendação podem reforçar padrões de consumo porque:',
   array['Mostram a mesma sequência para todos', 'Usam sinais de comportamento para selecionar conteúdos semelhantes aos que geraram engajamento', 'Ignoram escolhas anteriores', 'Funcionam sem dados de interação'], 1,
   'Algoritmos de recomendação usam históricos e sinais de interação para estimar relevância e podem reforçar preferências observadas.', 101, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('1e22ffe4-818b-5044-8ef3-c3ddff9f3149', 'en',
   'Judging another group''s customs only by the standards of one''s own culture and treating them as inferior is an example of:',
   array['Bureaucratization', 'Social mobility', 'Secularization', 'Ethnocentrism'],
   'Ethnocentrism means using one''s own culture as the central reference for evaluating others.'),
  ('1e22ffe4-818b-5044-8ef3-c3ddff9f3149', 'es',
   'Juzgar las costumbres de otro grupo solo según los patrones de la propia cultura y considerarlas inferiores es un ejemplo de:',
   array['Burocratización', 'Movilidad social', 'Secularización', 'Etnocentrismo'],
   'El etnocentrismo consiste en usar la propia cultura como referencia central para evaluar otras.'),
  ('62e16885-1360-5050-bcae-41e3703d28e6', 'en',
   'On social networks, recommendation systems can reinforce consumption patterns because they:',
   array['Show the same sequence to everyone', 'Use behavioral signals to select content similar to what previously generated engagement', 'Ignore previous choices', 'Operate without interaction data'],
   'Recommendation algorithms use histories and interaction signals to estimate relevance and may reinforce observed preferences.'),
  ('62e16885-1360-5050-bcae-41e3703d28e6', 'es',
   'En redes sociales, los sistemas de recomendación pueden reforzar patrones de consumo porque:',
   array['Muestran la misma secuencia a todos', 'Usan señales de comportamiento para seleccionar contenidos similares a los que generaron interacción', 'Ignoran elecciones anteriores', 'Funcionan sin datos de interacción'],
   'Los algoritmos de recomendación usan historiales y señales de interacción para estimar relevancia y pueden reforzar preferencias observadas.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;
