-- Terceira rodada da revisao externa (2026-09-30): 56 questoes novas (4 por
-- materia), ja em pt-BR, en e es. Sem path novo (o revisor reusou folhas
-- reais do catalogo). Uma correcao minha por cima do revisor: a questao de
-- Referencia pronominal em Ingles ('its') tinha as alternativas em ingles
-- nas tres linguas -- corrigido para PT/ES seguirem o idioma do app (a
-- passagem em si continua fixa em ingles, que e a regra).
--
-- Fonte: tool/content/materias/<materia>_revisao3.txt, gerado por
-- tool/content/gen_new_questions.py. Um bloco por materia abaixo.

-- ===== artes =====
-- New questions for artes: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('f0894507-fac7-5ff5-95f8-0a720fd4d1aa', '1608ace4-80cc-5a3d-a176-20cdf2c114a2',
   'Ao restaurar um edifício histórico, uma intervenção acrescenta uma estrutura contemporânea claramente identificável, sem imitar falsamente a parte antiga. Essa decisão busca preservar:',
   array['A aparência de que toda a obra foi construída na mesma época', 'A substituição integral dos materiais originais', 'A legibilidade entre partes históricas e intervenções atuais', 'A eliminação de usos contemporâneos do edifício'], 2,
   'Em conservação, distinguir o que é histórico do que foi acrescentado evita falsificações e permite compreender as diferentes camadas da obra.', 100, 'medio'),
  ('8ea81547-d655-5517-bc89-51b70a1705a0', '33969e3a-5465-5004-b064-2e58846962db',
   'Uma instalação digital altera imagens e sons conforme o público se move diante de sensores. O aspecto que melhor caracteriza essa obra é:',
   array['A interatividade como parte da construção da experiência estética', 'A reprodução idêntica de uma obra física preexistente', 'A ausência de participação do espectador', 'A impossibilidade de variação durante a exibição'], 0,
   'Quando sensores fazem a obra responder às ações do público, a interação deixa de ser externa e passa a compor a própria experiência artística.', 101, 'dificil'),
  ('c4be9d9f-3956-5e2b-9f6b-67497e4638f3', 'b0d74c13-9e3c-526e-b79e-ca85527e37b4',
   'Em uma cena de suspense, a câmera mostra primeiro uma porta entreaberta e depois corta para o olhar apreensivo da personagem. A montagem cria sentido principalmente pela:',
   array['Profundidade de campo isolada', 'Relação entre planos sucessivos', 'Duração fixa de cada tomada', 'Neutralidade do ponto de vista'], 1,
   'A montagem associa planos consecutivos; o espectador relaciona a porta ao olhar e constrói uma expectativa narrativa.', 102, 'dificil'),
  ('9e4b7bf5-585f-55b3-85b5-082c3dea6e63', '37d9e580-8130-5c76-ab04-0d4b4acefd6c',
   'Em uma composição visual, um elemento pequeno e muito contrastante pode atrair mais atenção que uma área grande e uniforme. Esse efeito evidencia o uso de:',
   array['Perspectiva atmosférica', 'Textura tátil', 'Simetria bilateral', 'Hierarquia visual'], 3,
   'A hierarquia visual organiza a atenção do observador por contraste, escala, posição, cor e outros recursos.', 103, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('f0894507-fac7-5ff5-95f8-0a720fd4d1aa', 'en',
   'When restoring a historic building, a clearly identifiable contemporary structure is added without falsely imitating the old section. This choice aims to preserve:',
   array['The appearance that the entire building was made at the same time', 'The complete replacement of original materials', 'The legibility between historic parts and current interventions', 'The elimination of contemporary uses of the building'],
   'In conservation, distinguishing historic fabric from later additions avoids falsification and makes the building''s different layers understandable.'),
  ('f0894507-fac7-5ff5-95f8-0a720fd4d1aa', 'es',
   'Al restaurar un edificio histórico, se añade una estructura contemporánea claramente identificable sin imitar falsamente la parte antigua. Esta decisión busca preservar:',
   array['La apariencia de que todo el edificio fue construido en la misma época', 'La sustitución integral de los materiales originales', 'La legibilidad entre las partes históricas y las intervenciones actuales', 'La eliminación de usos contemporáneos del edificio'],
   'En conservación, distinguir lo histórico de lo añadido evita falsificaciones y permite comprender las distintas capas de la obra.'),
  ('8ea81547-d655-5517-bc89-51b70a1705a0', 'en',
   'A digital installation changes images and sounds as visitors move in front of sensors. The feature that best characterizes the work is:',
   array['Interactivity as part of the construction of the aesthetic experience', 'The identical reproduction of a preexisting physical artwork', 'The absence of audience participation', 'The impossibility of variation during display'],
   'When sensors make the work respond to visitors'' actions, interaction becomes part of the artwork''s aesthetic experience.'),
  ('8ea81547-d655-5517-bc89-51b70a1705a0', 'es',
   'Una instalación digital modifica imágenes y sonidos conforme el público se mueve frente a sensores. El aspecto que mejor caracteriza la obra es:',
   array['La interactividad como parte de la construcción de la experiencia estética', 'La reproducción idéntica de una obra física preexistente', 'La ausencia de participación del espectador', 'La imposibilidad de variación durante la exhibición'],
   'Cuando los sensores hacen que la obra responda a las acciones del público, la interacción pasa a formar parte de la experiencia artística.'),
  ('c4be9d9f-3956-5e2b-9f6b-67497e4638f3', 'en',
   'In a suspense scene, the camera first shows a half-open door and then cuts to the character''s anxious gaze. Meaning is created mainly through:',
   array['Isolated depth of field', 'The relationship between successive shots', 'A fixed duration for each take', 'A neutral point of view'],
   'Editing links consecutive shots; viewers connect the door with the gaze and build narrative expectation.'),
  ('c4be9d9f-3956-5e2b-9f6b-67497e4638f3', 'es',
   'En una escena de suspenso, la cámara muestra primero una puerta entreabierta y luego corta a la mirada inquieta del personaje. El sentido se crea principalmente por:',
   array['La profundidad de campo aislada', 'La relación entre planos sucesivos', 'La duración fija de cada toma', 'La neutralidad del punto de vista'],
   'El montaje relaciona planos consecutivos; el espectador conecta la puerta con la mirada y construye una expectativa narrativa.'),
  ('9e4b7bf5-585f-55b3-85b5-082c3dea6e63', 'en',
   'In a visual composition, a small highly contrasting element may attract more attention than a large uniform area. This effect demonstrates the use of:',
   array['Atmospheric perspective', 'Tactile texture', 'Bilateral symmetry', 'Visual hierarchy'],
   'Visual hierarchy organizes the viewer''s attention through contrast, scale, position, color, and other devices.'),
  ('9e4b7bf5-585f-55b3-85b5-082c3dea6e63', 'es',
   'En una composición visual, un elemento pequeño y muy contrastante puede atraer más atención que una zona grande y uniforme. Este efecto evidencia el uso de:',
   array['Perspectiva atmosférica', 'Textura táctil', 'Simetría bilateral', 'Jerarquía visual'],
   'La jerarquía visual organiza la atención del observador mediante contraste, escala, posición, color y otros recursos.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== biologia =====
-- New questions for biologia: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('c3232ff6-0211-5892-b4d9-5a778b3a5eed', 'ac32071e-53bb-4644-bc7e-a0dfe219e216',
   'Em um período de seca, o fechamento dos estômatos ajuda a planta a economizar água. Uma consequência imediata desse fechamento é:',
   array['Aumento da entrada de CO₂ nas folhas', 'Redução das trocas gasosas e da perda de água por transpiração', 'Aumento do transporte de seiva elaborada pelo xilema', 'Interrupção definitiva da respiração celular'], 1,
   'Estômatos fechados reduzem a saída de vapor d''água, mas também limitam a entrada de CO₂, criando um compromisso entre conservação de água e fotossíntese.', 100, 'dificil'),
  ('1a055826-eb82-5e53-a2e7-96ecd7736134', 'c4b861cb-2247-46b7-9b38-fe2f1295d952',
   'Em uma teia alimentar, uma espécie de ave consome insetos e frutos. Se a população de insetos cair, mas houver frutos abundantes, a ave poderá manter-se. Isso ilustra principalmente:',
   array['Competição intraespecífica obrigatória', 'Fluxo cíclico de energia', 'Maior estabilidade proporcionada por múltiplas relações alimentares', 'Ausência de dependência entre níveis tróficos'], 2,
   'Teias com rotas alimentares alternativas podem amortecer o efeito da redução de um único recurso.', 101, 'dificil'),
  ('23fdb083-48b8-5348-b72b-5ed064f3249b', '18976237-e643-437e-8216-7ff0c5a09df5',
   'Duas populações da mesma espécie ficam isoladas geograficamente por milhares de gerações. Após acumular diferenças, deixam de produzir descendentes férteis quando voltam a se encontrar. O processo descrito é um exemplo de:',
   array['Especiação por isolamento reprodutivo após divergência', 'Aclimatação individual reversível', 'Seleção artificial dirigida por humanos', 'Sucessão ecológica primária'], 0,
   'O isolamento reduz o fluxo gênico; a divergência acumulada pode originar barreiras reprodutivas e novas espécies.', 102, 'dificil'),
  ('a8182c03-a570-59e5-972f-bf5d0934c7cc', 'f60e7769-0be0-4a8e-b2e5-bb84e9163a6f',
   'Uma planta heterozigota Aa produz gametas. Segundo a Primeira Lei de Mendel, qual distribuição é esperada, desconsiderando distorções de segregação?',
   array['100% A', '75% A e 25% a', '25% A e 75% a', '50% A e 50% a'], 3,
   'Os dois alelos de um par segregam durante a formação dos gametas, de modo que um heterozigoto Aa tende a formar metade dos gametas com A e metade com a.', 103, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('c3232ff6-0211-5892-b4d9-5a778b3a5eed', 'en',
   'During drought, closing stomata helps a plant conserve water. An immediate consequence of stomatal closure is:',
   array['Increased CO₂ entry into leaves', 'Reduced gas exchange and water loss through transpiration', 'Increased transport of sugar-rich sap through xylem', 'Permanent interruption of cellular respiration'],
   'Closed stomata reduce water-vapor loss but also limit CO₂ entry, creating a trade-off between water conservation and photosynthesis.'),
  ('c3232ff6-0211-5892-b4d9-5a778b3a5eed', 'es',
   'Durante una sequía, el cierre de los estomas ayuda a la planta a ahorrar agua. Una consecuencia inmediata de este cierre es:',
   array['Aumento de la entrada de CO₂ en las hojas', 'Reducción del intercambio gaseoso y de la pérdida de agua por transpiración', 'Aumento del transporte de savia elaborada por el xilema', 'Interrupción definitiva de la respiración celular'],
   'Los estomas cerrados reducen la pérdida de vapor de agua, pero también limitan la entrada de CO₂, creando un compromiso entre conservar agua y realizar fotosíntesis.'),
  ('1a055826-eb82-5e53-a2e7-96ecd7736134', 'en',
   'In a food web, a bird species eats both insects and fruit. If insect numbers fall but fruit remains abundant, the bird may persist. This mainly illustrates:',
   array['Mandatory intraspecific competition', 'Cyclic energy flow', 'Greater stability provided by multiple feeding relationships', 'Absence of dependence among trophic levels'],
   'Food webs with alternative feeding routes can buffer the effect of a decline in a single resource.'),
  ('1a055826-eb82-5e53-a2e7-96ecd7736134', 'es',
   'En una red alimentaria, una especie de ave consume insectos y frutos. Si disminuyen los insectos pero abundan los frutos, el ave puede mantenerse. Esto ilustra principalmente:',
   array['Competencia intraespecífica obligatoria', 'Flujo cíclico de energía', 'Mayor estabilidad proporcionada por múltiples relaciones alimentarias', 'Ausencia de dependencia entre niveles tróficos'],
   'Las redes con rutas alimentarias alternativas pueden amortiguar el efecto de la reducción de un único recurso.'),
  ('23fdb083-48b8-5348-b72b-5ed064f3249b', 'en',
   'Two populations of the same species remain geographically isolated for thousands of generations. After accumulating differences, they can no longer produce fertile offspring when they meet again. This is an example of:',
   array['Speciation through reproductive isolation after divergence', 'Reversible individual acclimation', 'Human-directed artificial selection', 'Primary ecological succession'],
   'Isolation reduces gene flow; accumulated divergence can produce reproductive barriers and new species.'),
  ('23fdb083-48b8-5348-b72b-5ed064f3249b', 'es',
   'Dos poblaciones de la misma especie quedan aisladas geográficamente durante miles de generaciones. Tras acumular diferencias, ya no producen descendencia fértil al reencontrarse. El proceso es un ejemplo de:',
   array['Especiación por aislamiento reproductivo tras la divergencia', 'Aclimatación individual reversible', 'Selección artificial dirigida por humanos', 'Sucesión ecológica primaria'],
   'El aislamiento reduce el flujo génico; la divergencia acumulada puede originar barreras reproductivas y nuevas especies.'),
  ('a8182c03-a570-59e5-972f-bf5d0934c7cc', 'en',
   'A heterozygous Aa plant produces gametes. According to Mendel''s First Law, which distribution is expected, ignoring segregation distortion?',
   array['100% A', '75% A and 25% a', '25% A and 75% a', '50% A and 50% a'],
   'The two alleles of a pair segregate during gamete formation, so an Aa heterozygote tends to produce half A gametes and half a gametes.'),
  ('a8182c03-a570-59e5-972f-bf5d0934c7cc', 'es',
   'Una planta heterocigota Aa produce gametos. Según la Primera Ley de Mendel, ¿qué distribución se espera, sin considerar distorsiones de segregación?',
   array['100% A', '75% A y 25% a', '25% A y 75% a', '50% A y 50% a'],
   'Los dos alelos de un par se segregan durante la formación de gametos, por lo que un heterocigoto Aa tiende a producir la mitad con A y la mitad con a.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== educacao_fisica =====
-- New questions for educacao_fisica: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('522e4bba-7e2b-5a05-a5c1-4128e28d93c8', '2bd28a7c-96e5-5449-a63d-2df7368e4940',
   'Durante exercício prolongado em ambiente muito quente, uma pessoa perde grande quantidade de suor. Se repuser apenas água em excesso por várias horas, sem considerar eletrólitos, qual risco pode aumentar?',
   array['Hiperglicemia por excesso de sódio', 'Aumento extremo da concentração de sódio no sangue', 'Hiponatremia por diluição do sódio plasmático', 'Acúmulo imediato de glicogênio muscular'], 2,
   'Em situações prolongadas com muita perda de suor, ingestão excessiva de água sem reposição adequada de eletrólitos pode diluir o sódio plasmático e favorecer hiponatremia.', 100, 'dificil'),
  ('12cddecc-5421-5938-91d5-cadbe76cd046', '585e92a3-ca7d-5d22-8f77-221de40033eb',
   'A capacidade de mudar rapidamente de direção mantendo controle do corpo é denominada:',
   array['Flexibilidade', 'Resistência', 'Força máxima', 'Agilidade'], 3,
   'Agilidade envolve acelerar, desacelerar e mudar de direção com controle e eficiência.', 101, 'facil'),
  ('7f1c2337-6271-574c-9cf2-4f32e97b4b22', '04613235-1c91-5a85-a1bd-b2d1da81184b',
   'Uma transmissão esportiva apresenta o atleta paralímpico apenas como exemplo de ''superação'', sem explicar técnica, estratégia ou resultado competitivo. Uma crítica possível a esse enquadramento é que ele:',
   array['Valoriza excessivamente a análise tática da modalidade', 'Pode reduzir o atleta à deficiência e apagar sua dimensão esportiva', 'Torna a competição mais acessível ao público especializado', 'Substitui emoção por informações estatísticas'], 1,
   'Quando a narrativa se limita à ''superação'', pode reforçar estereótipos e deixar em segundo plano desempenho, técnica, treinamento e contexto esportivo.', 102, 'dificil'),
  ('785c6668-42f0-514f-807d-7fc36e325cb5', 'e5e2d32f-81bf-5c55-9f26-2544439c9328',
   'Uma equipe recupera a bola e progride rapidamente antes que o adversário reorganize sua defesa. Esse comportamento tático caracteriza:',
   array['Marcação por zona em bloco baixo', 'Transição ofensiva rápida', 'Posse posicional prolongada', 'Reposição lateral defensiva'], 1,
   'A transição ofensiva ocorre logo após a recuperação da posse e busca aproveitar o desequilíbrio momentâneo da defesa adversária.', 103, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('522e4bba-7e2b-5a05-a5c1-4128e28d93c8', 'en',
   'During prolonged exercise in very hot conditions, a person loses a large amount of sweat. If they replace it with excessive amounts of water alone for several hours without considering electrolytes, which risk may increase?',
   array['Hyperglycemia from excess sodium', 'An extreme rise in blood sodium concentration', 'Hyponatremia from dilution of plasma sodium', 'Immediate buildup of muscle glycogen'],
   'During prolonged heavy sweating, excessive water intake without adequate electrolyte replacement can dilute plasma sodium and contribute to hyponatremia.'),
  ('522e4bba-7e2b-5a05-a5c1-4128e28d93c8', 'es',
   'Durante un ejercicio prolongado en un ambiente muy caluroso, una persona pierde mucho sudor. Si durante varias horas repone solo agua en exceso sin considerar electrolitos, ¿qué riesgo puede aumentar?',
   array['Hiperglucemia por exceso de sodio', 'Aumento extremo de la concentración de sodio en sangre', 'Hiponatremia por dilución del sodio plasmático', 'Acumulación inmediata de glucógeno muscular'],
   'Con pérdidas prolongadas de sudor, ingerir demasiada agua sin una reposición adecuada de electrolitos puede diluir el sodio plasmático y favorecer la hiponatremia.'),
  ('12cddecc-5421-5938-91d5-cadbe76cd046', 'en',
   'The ability to change direction quickly while maintaining body control is called:',
   array['Flexibility', 'Endurance', 'Maximum strength', 'Agility'],
   'Agility involves accelerating, decelerating, and changing direction with control and efficiency.'),
  ('12cddecc-5421-5938-91d5-cadbe76cd046', 'es',
   'La capacidad de cambiar rápidamente de dirección manteniendo el control corporal se denomina:',
   array['Flexibilidad', 'Resistencia', 'Fuerza máxima', 'Agilidad'],
   'La agilidad implica acelerar, desacelerar y cambiar de dirección con control y eficiencia.'),
  ('7f1c2337-6271-574c-9cf2-4f32e97b4b22', 'en',
   'A sports broadcast presents a Paralympic athlete only as an example of ''overcoming adversity'' without discussing technique, strategy, or competitive performance. One criticism of this framing is that it:',
   array['Overemphasizes tactical analysis of the sport', 'Can reduce the athlete to disability and erase the sporting dimension', 'Makes the competition more accessible to specialist audiences', 'Replaces emotion with statistical information'],
   'When coverage is limited to an ''overcoming'' narrative, it can reinforce stereotypes and push performance, technique, training, and sporting context into the background.'),
  ('7f1c2337-6271-574c-9cf2-4f32e97b4b22', 'es',
   'Una transmisión deportiva presenta al atleta paralímpico solo como ejemplo de ''superación'', sin explicar técnica, estrategia ni resultado competitivo. Una crítica posible a este enfoque es que:',
   array['Valora en exceso el análisis táctico de la disciplina', 'Puede reducir al atleta a la discapacidad y borrar su dimensión deportiva', 'Vuelve la competición más accesible al público especializado', 'Sustituye la emoción por información estadística'],
   'Cuando la narrativa se limita a la ''superación'', puede reforzar estereotipos y dejar en segundo plano rendimiento, técnica, entrenamiento y contexto deportivo.'),
  ('785c6668-42f0-514f-807d-7fc36e325cb5', 'en',
   'A team wins the ball and advances quickly before the opponent reorganizes defensively. This tactical behavior is:',
   array['Low-block zonal marking', 'A quick attacking transition', 'Prolonged positional possession', 'A defensive throw-in restart'],
   'An attacking transition begins immediately after regaining possession and seeks to exploit the opponent''s temporary defensive imbalance.'),
  ('785c6668-42f0-514f-807d-7fc36e325cb5', 'es',
   'Un equipo recupera el balón y avanza rápidamente antes de que el rival reorganice su defensa. Este comportamiento táctico caracteriza:',
   array['Marcaje zonal en bloque bajo', 'Una transición ofensiva rápida', 'Posesión posicional prolongada', 'Un saque lateral defensivo'],
   'La transición ofensiva comienza tras recuperar la posesión y busca aprovechar el desequilibrio momentáneo de la defensa rival.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== espanhol =====
-- New questions for espanhol: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('4dc183d0-1a45-54ab-bc4b-64b0afa40af1', 'e5c195b2-3092-57b4-b0f7-e4c63201159e',
   'Leia: "El informe reconoce avances; sin embargo, advierte que todavía quedan problemas por resolver." Nesse contexto, "sin embargo" introduz:',
   array['Uma causa', 'Um contraste', 'Uma consequência', 'Uma condição'], 1,
   '"Sin embargo" contrapõe os avanços mencionados à permanência de problemas.', 100, 'medio'),
  ('577832c2-b620-594c-add4-842bff078da8', 'ab947161-0333-51f3-a758-a401890951a2',
   'Leia: "Cada vez más ciudades crean zonas de baja emisión. La medida no elimina el tráfico, pero busca reducir contaminantes y favorecer el transporte público." Qual é a ideia central?',
   array['As cidades pretendem proibir qualquer deslocamento privado', 'O transporte público é a única fonte de poluição urbana', 'Zonas de baixa emissão procuram reduzir poluentes e incentivar alternativas de transporte', 'A medida tem como objetivo aumentar o tráfego nas áreas centrais'], 2,
   'O texto apresenta finalidade e limite da medida: ela não elimina o tráfego, mas busca reduzir emissões e favorecer o transporte público.', 101, 'dificil'),
  ('fdece8b8-d435-56ab-b788-c6ba2fcfe5d4', '1fd15cb5-a400-516d-8cfc-5ef3992b8a3d',
   'Complete a frase: "Esta semana ___ tres capítulos; ayer ___ el último."',
   array['leí / he terminado', 'leía / terminé', 'he leído / terminaba', 'he leído / terminé'], 3,
   'Em espanhol peninsular, "esta semana" ainda inclui o presente e favorece o pretérito perfecto compuesto; "ayer" marca período concluído e favorece o pretérito indefinido.', 102, 'dificil'),
  ('61b58cea-8700-5bed-9b5b-a4ec8ae2e390', '654ebc24-d60e-5871-83f5-f5844aabbffe',
   'Leia o título: "El ayuntamiento ampliará la red de ciclovías tras aprobar el presupuesto anual." Qual informação está explicitamente apresentada?',
   array['A ampliação foi vinculada à aprovação do orçamento', 'As ciclovias serão retiradas do centro', 'O orçamento foi rejeitado', 'A obra já foi totalmente concluída'], 0,
   'O título informa que a ampliação ocorrerá após a aprovação do orçamento anual; as demais afirmações não aparecem no texto.', 103, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('4dc183d0-1a45-54ab-bc4b-64b0afa40af1', 'en',
   'Read: "El informe reconoce avances; sin embargo, advierte que todavía quedan problemas por resolver." In this context, "sin embargo" introduces:',
   array['A cause', 'A contrast', 'A consequence', 'A condition'],
   '"Sin embargo" contrasts the progress mentioned with the fact that problems still remain.'),
  ('4dc183d0-1a45-54ab-bc4b-64b0afa40af1', 'es',
   'Lee: "El informe reconoce avances; sin embargo, advierte que todavía quedan problemas por resolver." En este contexto, "sin embargo" introduce:',
   array['Una causa', 'Un contraste', 'Una consecuencia', 'Una condición'],
   '"Sin embargo" contrapone los avances mencionados con la permanencia de problemas.'),
  ('577832c2-b620-594c-add4-842bff078da8', 'en',
   'Read: "Cada vez más ciudades crean zonas de baja emisión. La medida no elimina el tráfico, pero busca reducir contaminantes y favorecer el transporte público." What is the main idea?',
   array['Cities intend to ban all private travel', 'Public transport is the only source of urban pollution', 'Low-emission zones seek to reduce pollutants and encourage transport alternatives', 'The measure aims to increase traffic in central areas'],
   'The text states both the purpose and the limit of the measure: it does not eliminate traffic, but seeks to reduce emissions and favor public transport.'),
  ('577832c2-b620-594c-add4-842bff078da8', 'es',
   'Lee: "Cada vez más ciudades crean zonas de baja emisión. La medida no elimina el tráfico, pero busca reducir contaminantes y favorecer el transporte público." ¿Cuál es la idea central?',
   array['Las ciudades pretenden prohibir todo desplazamiento privado', 'El transporte público es la única fuente de contaminación urbana', 'Las zonas de bajas emisiones buscan reducir contaminantes y favorecer alternativas de transporte', 'La medida pretende aumentar el tráfico en las zonas céntricas'],
   'El texto presenta la finalidad y el límite de la medida: no elimina el tráfico, pero busca reducir emisiones y favorecer el transporte público.'),
  ('fdece8b8-d435-56ab-b788-c6ba2fcfe5d4', 'en',
   'Complete the sentence: "Esta semana ___ tres capítulos; ayer ___ el último."',
   array['leí / he terminado', 'leía / terminé', 'he leído / terminaba', 'he leído / terminé'],
   'In Peninsular Spanish, "esta semana" still includes the present and favors the present perfect, whereas "ayer" refers to a completed period and favors the preterite.'),
  ('fdece8b8-d435-56ab-b788-c6ba2fcfe5d4', 'es',
   'Completa la frase: "Esta semana ___ tres capítulos; ayer ___ el último."',
   array['leí / he terminado', 'leía / terminé', 'he leído / terminaba', 'he leído / terminé'],
   'En el español peninsular, "esta semana" aún incluye el presente y favorece el pretérito perfecto compuesto; "ayer" señala un período concluido y favorece el pretérito indefinido.'),
  ('61b58cea-8700-5bed-9b5b-a4ec8ae2e390', 'en',
   'Read the headline: "El ayuntamiento ampliará la red de ciclovías tras aprobar el presupuesto anual." Which information is explicitly stated?',
   array['The expansion is linked to approval of the annual budget', 'Bike lanes will be removed from downtown', 'The budget was rejected', 'The project has already been fully completed'],
   'The headline states that the network will be expanded after the annual budget is approved; the other claims are not stated.'),
  ('61b58cea-8700-5bed-9b5b-a4ec8ae2e390', 'es',
   'Lee el titular: "El ayuntamiento ampliará la red de ciclovías tras aprobar el presupuesto anual." ¿Qué información aparece explícitamente?',
   array['La ampliación está vinculada a la aprobación del presupuesto anual', 'Se retirarán las ciclovías del centro', 'El presupuesto fue rechazado', 'La obra ya está completamente terminada'],
   'El titular informa que la red se ampliará tras aprobarse el presupuesto anual; las demás afirmaciones no aparecen.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== filosofia =====
-- New questions for filosofia: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('6e70d4e2-29d9-5c92-87e4-9dfd3b96c226', '0add9e0b-d6ef-5a8a-aa14-e1007eb515e6',
   'Para Aristóteles, a virtude moral é desenvolvida principalmente por:',
   array['Hábito e prática de ações orientadas pela razão', 'Conhecimento inato independente da experiência', 'Obediência automática a qualquer desejo', 'Recusa de toda participação na vida da pólis'], 0,
   'Na ética aristotélica, virtudes de caráter são adquiridas pelo hábito, buscando o meio-termo adequado orientado pela razão prática.', 100, 'medio'),
  ('c7139535-a1de-56c8-819b-bbf6ab4f8ac1', '6eb0a23e-9547-58bc-b796-bc9b105e2b92',
   'Considere: ''Se o arquivo foi salvo, então existe uma cópia. Não existe uma cópia. Logo, o arquivo não foi salvo.'' A forma do argumento é:',
   array['Afirmação do consequente', 'Negação do antecedente', 'Modus tollens', 'Generalização apressada'], 2,
   'A estrutura é: se P, então Q; não Q; logo, não P. Essa inferência válida é modus tollens.', 101, 'medio'),
  ('0fea5783-9a61-5bff-b1a3-4b85ef68d5f0', '03fd0820-41a9-5f12-ae35-299579f84f9a',
   'Uma crença pode ser verdadeira por acaso, sem que a pessoa tenha boas razões para sustentá-la. Esse exemplo mostra que, em muitas teorias do conhecimento, verdade e crença:',
   array['São suficientes por si sós para garantir conhecimento', 'São irrelevantes para definir conhecimento', 'Devem ser substituídas por opinião majoritária', 'Precisam de algum tipo de justificação ou condição epistêmica adicional'], 3,
   'O exemplo explora a diferença entre acertar por sorte e saber; por isso, teorias do conhecimento costumam exigir algo além de crença verdadeira.', 102, 'dificil'),
  ('be3bc040-a5fd-5b5d-af0f-4002bd480296', '98e54340-cdfb-599b-9763-701186b0bf62',
   'Uma pessoa decide não mentir porque considera que a regra ''não mentir'' deve valer independentemente de vantagens pessoais imediatas. Essa justificativa aproxima-se de uma ética:',
   array['Consequencialista', 'Deontológica', 'Hedonista psicológica', 'Relativista descritiva'], 1,
   'Uma ética deontológica avalia deveres e princípios que não dependem apenas das consequências particulares de cada ação.', 103, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('6e70d4e2-29d9-5c92-87e4-9dfd3b96c226', 'en',
   'For Aristotle, moral virtue is developed mainly through:',
   array['Habit and the practice of actions guided by reason', 'Innate knowledge independent of experience', 'Automatic obedience to every desire', 'Withdrawal from all participation in the polis'],
   'In Aristotelian ethics, virtues of character are acquired through habit, aiming at the appropriate mean guided by practical reason.'),
  ('6e70d4e2-29d9-5c92-87e4-9dfd3b96c226', 'es',
   'Para Aristóteles, la virtud moral se desarrolla principalmente mediante:',
   array['El hábito y la práctica de acciones orientadas por la razón', 'Un conocimiento innato independiente de la experiencia', 'La obediencia automática a cualquier deseo', 'El rechazo de toda participación en la polis'],
   'En la ética aristotélica, las virtudes del carácter se adquieren mediante el hábito, buscando el justo medio orientado por la razón práctica.'),
  ('c7139535-a1de-56c8-819b-bbf6ab4f8ac1', 'en',
   'Consider: ''If the file was saved, then a copy exists. No copy exists. Therefore, the file was not saved.'' The argument has the form:',
   array['Affirming the consequent', 'Denying the antecedent', 'Modus tollens', 'Hasty generalization'],
   'The structure is: if P, then Q; not Q; therefore not P. This valid inference is modus tollens.'),
  ('c7139535-a1de-56c8-819b-bbf6ab4f8ac1', 'es',
   'Considera: ''Si el archivo fue guardado, entonces existe una copia. No existe una copia. Por lo tanto, el archivo no fue guardado.'' La forma del argumento es:',
   array['Afirmación del consecuente', 'Negación del antecedente', 'Modus tollens', 'Generalización apresurada'],
   'La estructura es: si P, entonces Q; no Q; por lo tanto, no P. Esta inferencia válida es modus tollens.'),
  ('0fea5783-9a61-5bff-b1a3-4b85ef68d5f0', 'en',
   'A belief can be true by luck even when the person has no good reason for holding it. This shows that, in many theories of knowledge, truth and belief:',
   array['Are sufficient by themselves to guarantee knowledge', 'Are irrelevant to defining knowledge', 'Must be replaced by majority opinion', 'Need some kind of additional justification or epistemic condition'],
   'The example distinguishes being right by luck from knowing; theories of knowledge therefore often require more than true belief.'),
  ('0fea5783-9a61-5bff-b1a3-4b85ef68d5f0', 'es',
   'Una creencia puede ser verdadera por casualidad aunque la persona no tenga buenas razones para sostenerla. Esto muestra que, en muchas teorías del conocimiento, verdad y creencia:',
   array['Son suficientes por sí solas para garantizar conocimiento', 'Son irrelevantes para definir conocimiento', 'Deben ser sustituidas por la opinión mayoritaria', 'Necesitan algún tipo de justificación o condición epistémica adicional'],
   'El ejemplo distingue acertar por suerte de saber; por eso, las teorías del conocimiento suelen exigir algo más que una creencia verdadera.'),
  ('be3bc040-a5fd-5b5d-af0f-4002bd480296', 'en',
   'A person decides not to lie because they believe the rule ''do not lie'' should hold regardless of immediate personal advantages. This justification is closest to:',
   array['Consequentialism', 'Deontological ethics', 'Psychological hedonism', 'Descriptive relativism'],
   'Deontological ethics evaluates duties and principles that do not depend only on the particular consequences of each action.'),
  ('be3bc040-a5fd-5b5d-af0f-4002bd480296', 'es',
   'Una persona decide no mentir porque considera que la regla ''no mentir'' debe valer independientemente de ventajas personales inmediatas. Esta justificación se aproxima a una ética:',
   array['Consecuencialista', 'Deontológica', 'Hedonista psicológica', 'Relativista descriptiva'],
   'Una ética deontológica evalúa deberes y principios que no dependen únicamente de las consecuencias particulares de cada acción.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== fisica =====
-- New questions for fisica: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('3d6307b5-9014-50e7-9faa-12eb8d0dc1fb', '89939da9-3bec-40f4-826d-514c063a9351',
   'Duas lâmpadas ideais, de 60 W e 100 W, são projetadas para a mesma tensão de 220 V. Em funcionamento nominal, qual delas possui menor resistência elétrica?',
   array['A de 60 W', 'A de 100 W', 'As duas têm a mesma resistência', 'Não é possível comparar usando potência e tensão'], 1,
   'Para a mesma tensão, P = V²/R. Logo, maior potência corresponde a menor resistência; a lâmpada de 100 W tem menor R.', 100, 'dificil'),
  ('5f873a65-2703-5810-8560-d64e15beedee', '9df1808d-9ac5-4809-8bdb-63e12480aa97',
   'Um carrinho de 4 kg sofre força resultante horizontal de 12 N. Desprezando resistências, sua aceleração é:',
   array['48 m/s²', '3 m/s²', '8 m/s²', '0,33 m/s²'], 1,
   'Pela segunda lei de Newton, a = F/m = 12/4 = 3 m/s².', 101, 'medio'),
  ('0abf2c0f-fa3b-528e-9b10-d16c6f59c266', '8f3b95a7-93f3-4d62-b383-d9b66d005f08',
   'Uma onda passa de uma corda para outra e sua frequência permanece a mesma, mas a velocidade de propagação diminui. O comprimento de onda:',
   array['Diminui', 'Aumenta', 'Permanece necessariamente igual', 'Torna-se zero'], 0,
   'Como v = λf e a frequência é mantida pela fonte, uma redução da velocidade implica redução do comprimento de onda.', 102, 'medio'),
  ('89940014-424b-5725-8e3a-383e676e0e64', 'c11d5ba1-65e8-487a-96e0-38e15a64af15',
   'Durante a fusão de gelo puro a 0 °C e pressão constante, enquanto ainda coexistem gelo e água líquida, o calor fornecido é usado principalmente para:',
   array['Aumentar continuamente a temperatura do gelo', 'Reduzir a energia interna do sistema', 'Promover a mudança de fase sem elevar a temperatura', 'Diminuir o movimento molecular da água'], 2,
   'Durante uma mudança de fase em equilíbrio, o calor latente altera a organização/energia interna do sistema sem variar a temperatura.', 103, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('3d6307b5-9014-50e7-9faa-12eb8d0dc1fb', 'en',
   'Two ideal lamps rated 60 W and 100 W are designed for the same 220 V supply. At their rated operating conditions, which has the lower electrical resistance?',
   array['The 60 W lamp', 'The 100 W lamp', 'Both have the same resistance', 'Power and voltage are insufficient for comparison'],
   'At the same voltage, P = V²/R. Therefore, higher power corresponds to lower resistance; the 100 W lamp has the lower R.'),
  ('3d6307b5-9014-50e7-9faa-12eb8d0dc1fb', 'es',
   'Dos lámparas ideales, de 60 W y 100 W, están diseñadas para la misma tensión de 220 V. En condiciones nominales, ¿cuál tiene menor resistencia eléctrica?',
   array['La de 60 W', 'La de 100 W', 'Ambas tienen la misma resistencia', 'No es posible comparar usando potencia y tensión'],
   'Para la misma tensión, P = V²/R. Por tanto, una mayor potencia corresponde a una menor resistencia; la lámpara de 100 W tiene menor R.'),
  ('5f873a65-2703-5810-8560-d64e15beedee', 'en',
   'A 4 kg cart experiences a net horizontal force of 12 N. Neglecting resistance, its acceleration is:',
   array['48 m/s²', '3 m/s²', '8 m/s²', '0.33 m/s²'],
   'By Newton''s second law, a = F/m = 12/4 = 3 m/s².'),
  ('5f873a65-2703-5810-8560-d64e15beedee', 'es',
   'Un carrito de 4 kg recibe una fuerza horizontal resultante de 12 N. Despreciando resistencias, su aceleración es:',
   array['48 m/s²', '3 m/s²', '8 m/s²', '0,33 m/s²'],
   'Por la segunda ley de Newton, a = F/m = 12/4 = 3 m/s².'),
  ('0abf2c0f-fa3b-528e-9b10-d16c6f59c266', 'en',
   'A wave passes from one string to another; its frequency remains the same, but its propagation speed decreases. Its wavelength:',
   array['Decreases', 'Increases', 'Must remain the same', 'Becomes zero'],
   'Since v = λf and the source keeps the frequency fixed, a lower speed implies a shorter wavelength.'),
  ('0abf2c0f-fa3b-528e-9b10-d16c6f59c266', 'es',
   'Una onda pasa de una cuerda a otra; su frecuencia permanece igual, pero disminuye la velocidad de propagación. La longitud de onda:',
   array['Disminuye', 'Aumenta', 'Debe permanecer igual', 'Se vuelve cero'],
   'Como v = λf y la fuente mantiene fija la frecuencia, una menor velocidad implica una menor longitud de onda.'),
  ('89940014-424b-5725-8e3a-383e676e0e64', 'en',
   'During the melting of pure ice at 0 °C and constant pressure, while ice and liquid water still coexist, the supplied heat is used mainly to:',
   array['Continuously increase the ice temperature', 'Reduce the system''s internal energy', 'Drive the phase change without raising the temperature', 'Decrease the molecular motion of water'],
   'During an equilibrium phase change, latent heat changes the system''s internal organization/energy without changing its temperature.'),
  ('89940014-424b-5725-8e3a-383e676e0e64', 'es',
   'Durante la fusión de hielo puro a 0 °C y presión constante, mientras aún coexisten hielo y agua líquida, el calor suministrado se usa principalmente para:',
   array['Aumentar continuamente la temperatura del hielo', 'Reducir la energía interna del sistema', 'Promover el cambio de fase sin elevar la temperatura', 'Disminuir el movimiento molecular del agua'],
   'Durante un cambio de fase en equilibrio, el calor latente modifica la organización/energía interna del sistema sin cambiar su temperatura.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== geografia =====
-- New questions for geografia: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('a5da4018-a05a-5277-816e-0df0c9fd4f9e', '99b6637a-cdd8-4b7e-b3aa-67ab095831fc',
   'Uma vantagem operacional da complementaridade entre geração hidrelétrica, eólica e solar no sistema elétrico é:',
   array['Eliminar a necessidade de redes de transmissão', 'Diversificar fontes e reduzir a dependência de uma única condição natural', 'Garantir produção idêntica em todas as horas do ano', 'Tornar desnecessário o planejamento de oferta e demanda'], 1,
   'Fontes com perfis diferentes podem se complementar, reduzindo a exposição do sistema a uma única condição hidrológica ou climática.', 100, 'medio'),
  ('364ba991-9351-53dc-b5b5-5293d96897f4', '38591ed7-9d86-4b5e-9330-b8810e8ef782',
   'Em uma bacia hidrográfica urbana, a substituição de solo permeável por asfalto e concreto tende a:',
   array['Aumentar o escoamento superficial e favorecer picos de cheia', 'Aumentar a infiltração e reduzir o volume escoado', 'Eliminar a necessidade de drenagem urbana', 'Impedir que a chuva alcance os cursos d''água'], 0,
   'A impermeabilização reduz a infiltração, aumenta e acelera o escoamento superficial e pode intensificar enchentes.', 101, 'dificil'),
  ('f6acf773-eb3a-5dc4-9bba-bf1d531b1a7e', '1e13d445-2268-4d4f-abed-aeeef2db21e1',
   'Uma cidade expande sua mancha urbana para municípios vizinhos, enquanto deslocamentos diários de trabalho e estudo integram fortemente essas áreas. O fenômeno descrito aproxima-se de:',
   array['Êxodo rural', 'Verticalização isolada', 'Conurbação e integração metropolitana', 'Desconcentração industrial'], 2,
   'A continuidade ou forte integração entre áreas urbanizadas de municípios vizinhos caracteriza processos de conurbação e metropolização.', 102, 'dificil'),
  ('70945449-85ad-5ea6-8a3f-213c9e2d8329', 'c78a7a6e-b797-4f63-bc88-df1daefe4237',
   'Uma empresa projeta um produto em um país, fabrica componentes em outros três e realiza a montagem final em um quarto. Esse arranjo evidencia:',
   array['Autarquia produtiva', 'Regionalização climática', 'Fim da divisão internacional do trabalho', 'Fragmentação internacional da produção'], 3,
   'A produção distribuída em diferentes países é característica das cadeias globais de valor e da fragmentação internacional da produção.', 103, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('a5da4018-a05a-5277-816e-0df0c9fd4f9e', 'en',
   'An operational advantage of combining hydropower, wind, and solar generation in an electricity system is:',
   array['Eliminating the need for transmission networks', 'Diversifying sources and reducing dependence on a single natural condition', 'Guaranteeing identical output at every hour of the year', 'Making supply-and-demand planning unnecessary'],
   'Sources with different generation profiles can complement one another, reducing the system''s exposure to a single hydrological or climatic condition.'),
  ('a5da4018-a05a-5277-816e-0df0c9fd4f9e', 'es',
   'Una ventaja operativa de combinar generación hidroeléctrica, eólica y solar en un sistema eléctrico es:',
   array['Eliminar la necesidad de redes de transmisión', 'Diversificar las fuentes y reducir la dependencia de una sola condición natural', 'Garantizar una producción idéntica en todas las horas del año', 'Hacer innecesaria la planificación de oferta y demanda'],
   'Fuentes con perfiles distintos pueden complementarse, reduciendo la exposición del sistema a una única condición hidrológica o climática.'),
  ('364ba991-9351-53dc-b5b5-5293d96897f4', 'en',
   'In an urban watershed, replacing permeable soil with asphalt and concrete tends to:',
   array['Increase surface runoff and favor higher flood peaks', 'Increase infiltration and reduce runoff volume', 'Eliminate the need for urban drainage', 'Prevent rainfall from reaching streams'],
   'Impervious surfaces reduce infiltration, increase and accelerate runoff, and can intensify flooding.'),
  ('364ba991-9351-53dc-b5b5-5293d96897f4', 'es',
   'En una cuenca urbana, sustituir suelo permeable por asfalto y hormigón tiende a:',
   array['Aumentar la escorrentía superficial y favorecer picos de crecida', 'Aumentar la infiltración y reducir el volumen escurrido', 'Eliminar la necesidad de drenaje urbano', 'Impedir que la lluvia llegue a los cursos de agua'],
   'La impermeabilización reduce la infiltración, aumenta y acelera la escorrentía superficial y puede intensificar las inundaciones.'),
  ('f6acf773-eb3a-5dc4-9bba-bf1d531b1a7e', 'en',
   'A city expands its urban footprint into neighboring municipalities while daily commuting for work and study strongly integrates these areas. This is closest to:',
   array['Rural exodus', 'Isolated vertical growth', 'Conurbation and metropolitan integration', 'Industrial decentralization'],
   'Continuity or strong integration between urbanized areas of neighboring municipalities characterizes conurbation and metropolitan processes.'),
  ('f6acf773-eb3a-5dc4-9bba-bf1d531b1a7e', 'es',
   'Una ciudad expande su mancha urbana hacia municipios vecinos, mientras los desplazamientos diarios por trabajo y estudio integran fuertemente esas áreas. El fenómeno se aproxima a:',
   array['Éxodo rural', 'Verticalización aislada', 'Conurbación e integración metropolitana', 'Desconcentración industrial'],
   'La continuidad o fuerte integración entre áreas urbanizadas de municipios vecinos caracteriza procesos de conurbación y metropolización.'),
  ('70945449-85ad-5ea6-8a3f-213c9e2d8329', 'en',
   'A company designs a product in one country, manufactures components in three others, and performs final assembly in a fourth. This arrangement illustrates:',
   array['Productive autarky', 'Climatic regionalization', 'The end of the international division of labor', 'International fragmentation of production'],
   'Production distributed across different countries is characteristic of global value chains and international production fragmentation.'),
  ('70945449-85ad-5ea6-8a3f-213c9e2d8329', 'es',
   'Una empresa diseña un producto en un país, fabrica componentes en otros tres y realiza el montaje final en un cuarto. Este arreglo evidencia:',
   array['Autarquía productiva', 'Regionalización climática', 'Fin de la división internacional del trabajo', 'Fragmentación internacional de la producción'],
   'La producción distribuida entre distintos países es característica de las cadenas globales de valor y de la fragmentación internacional de la producción.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== historia =====
-- New questions for historia: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('6d4e8342-4e36-5649-8820-e71190a57bd9', 'b5a0f0a7-33bf-4676-86aa-073a0d0f5426',
   'Quando o historiador compara um decreto oficial com cartas, jornais e relatos de diferentes grupos sobre o mesmo evento, ele busca principalmente:',
   array['Substituir fontes escritas por fontes orais', 'Encontrar uma fonte totalmente neutra', 'Eliminar divergências entre testemunhos', 'Cruzar perspectivas e avaliar criticamente evidências'], 3,
   'Fontes têm contextos, interesses e limites; confrontá-las permite identificar convergências, divergências e silêncios.', 100, 'dificil'),
  ('34d0f676-59eb-536e-8de0-ed70dd026dfe', '43bff7ca-8f49-46a3-b757-e20105c00ad2',
   'Ao estudar sociedades africanas anteriores à colonização europeia do século XIX, é historicamente mais adequado reconhecer que:',
   array['Existiam formações políticas, redes comerciais e culturas muito diversas no continente', 'O continente possuía uma única organização política comum', 'As sociedades africanas estavam isoladas de rotas comerciais de longa distância', 'A urbanização surgiu apenas após a colonização europeia'], 0,
   'A história africana anterior ao colonialismo inclui impérios, reinos, cidades, redes comerciais e sociedades com grande diversidade política e cultural.', 101, 'dificil'),
  ('6fbb4def-8490-5d8d-8a28-640d96323d2e', 'ad10464d-0d11-4255-9fef-d341a0f856d6',
   'A mineração aurífera no século XVIII contribuiu para mudanças na América portuguesa, entre elas:',
   array['A concentração populacional exclusiva no litoral açucareiro', 'A interiorização da ocupação e o crescimento de núcleos urbanos na região mineradora', 'O fim imediato da escravidão africana', 'A redução da fiscalização metropolitana sobre a circulação de ouro'], 1,
   'A mineração deslocou parte do dinamismo econômico para o interior, estimulando caminhos, comércio e núcleos urbanos, sem eliminar a escravidão ou o controle fiscal da Coroa.', 102, 'dificil'),
  ('3bd4045e-b618-5f80-aeea-64caf7784875', '9d1627ca-eade-4dcf-83dc-a1acfcd096c8',
   'A Revolução Industrial alterou profundamente a organização do trabalho porque:',
   array['Substituiu todas as formas artesanais de uma só vez', 'Eliminou a divisão de tarefas nas manufaturas', 'Ampliou a mecanização e a concentração de trabalhadores em fábricas', 'Tornou desnecessários investimentos em energia e infraestrutura'], 2,
   'A industrialização difundiu máquinas, novas fontes de energia e o sistema fabril, reorganizando ritmos, tarefas e relações de trabalho.', 103, 'medio')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('6d4e8342-4e36-5649-8820-e71190a57bd9', 'en',
   'When a historian compares an official decree with letters, newspapers, and accounts from different groups about the same event, the main goal is to:',
   array['Replace written sources with oral ones', 'Find a completely neutral source', 'Eliminate disagreements among testimonies', 'Cross-check perspectives and critically evaluate evidence'],
   'Sources have contexts, interests, and limitations; comparing them helps reveal convergences, disagreements, and silences.'),
  ('6d4e8342-4e36-5649-8820-e71190a57bd9', 'es',
   'Cuando un historiador compara un decreto oficial con cartas, periódicos y relatos de distintos grupos sobre el mismo hecho, busca principalmente:',
   array['Sustituir fuentes escritas por fuentes orales', 'Encontrar una fuente totalmente neutral', 'Eliminar las divergencias entre testimonios', 'Cruzar perspectivas y evaluar críticamente las evidencias'],
   'Las fuentes tienen contextos, intereses y límites; confrontarlas permite identificar coincidencias, divergencias y silencios.'),
  ('34d0f676-59eb-536e-8de0-ed70dd026dfe', 'en',
   'When studying African societies before nineteenth-century European colonization, it is historically more accurate to recognize that:',
   array['The continent contained highly diverse political formations, trade networks, and cultures', 'The continent had one common political organization', 'African societies were isolated from long-distance trade routes', 'Urbanization appeared only after European colonization'],
   'Precolonial African history includes empires, kingdoms, cities, trade networks, and societies with great political and cultural diversity.'),
  ('34d0f676-59eb-536e-8de0-ed70dd026dfe', 'es',
   'Al estudiar las sociedades africanas anteriores a la colonización europea del siglo XIX, es históricamente más adecuado reconocer que:',
   array['Existían formaciones políticas, redes comerciales y culturas muy diversas en el continente', 'El continente poseía una única organización política común', 'Las sociedades africanas estaban aisladas de rutas comerciales de larga distancia', 'La urbanización surgió solo después de la colonización europea'],
   'La historia africana precolonial incluye imperios, reinos, ciudades, redes comerciales y sociedades con gran diversidad política y cultural.'),
  ('6fbb4def-8490-5d8d-8a28-640d96323d2e', 'en',
   'Gold mining in the eighteenth century contributed to changes in Portuguese America, including:',
   array['The exclusive concentration of population in coastal sugar areas', 'The expansion of settlement inland and the growth of urban centers in mining regions', 'The immediate end of African slavery', 'Reduced metropolitan control over gold circulation'],
   'Mining shifted part of economic activity inland, encouraging roads, trade, and urban centers without ending slavery or Crown taxation.'),
  ('6fbb4def-8490-5d8d-8a28-640d96323d2e', 'es',
   'La minería aurífera del siglo XVIII contribuyó a cambios en la América portuguesa, entre ellos:',
   array['La concentración exclusiva de la población en el litoral azucarero', 'La expansión de la ocupación hacia el interior y el crecimiento de núcleos urbanos en la región minera', 'El fin inmediato de la esclavitud africana', 'La reducción de la fiscalización metropolitana sobre la circulación del oro'],
   'La minería desplazó parte del dinamismo económico hacia el interior, estimulando caminos, comercio y núcleos urbanos sin eliminar la esclavitud ni el control fiscal de la Corona.'),
  ('3bd4045e-b618-5f80-aeea-64caf7784875', 'en',
   'The Industrial Revolution deeply changed the organization of work because it:',
   array['Replaced all craft production at once', 'Eliminated the division of labor in manufacturing', 'Expanded mechanization and concentrated workers in factories', 'Made investment in energy and infrastructure unnecessary'],
   'Industrialization spread machinery, new energy sources, and the factory system, reorganizing work rhythms, tasks, and labor relations.'),
  ('3bd4045e-b618-5f80-aeea-64caf7784875', 'es',
   'La Revolución Industrial transformó profundamente la organización del trabajo porque:',
   array['Sustituyó de una vez todas las formas artesanales', 'Eliminó la división de tareas en las manufacturas', 'Amplió la mecanización y concentró trabajadores en fábricas', 'Hizo innecesarias las inversiones en energía e infraestructura'],
   'La industrialización difundió máquinas, nuevas fuentes de energía y el sistema fabril, reorganizando ritmos, tareas y relaciones laborales.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== ingles =====
-- New questions for ingles: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('42b4c0fb-e7af-5f8b-998a-54c5f71790f8', '9cd73099-7e39-57df-8a4e-17329c16af61',
   'Leia: "The researchers revised the model after they found an error in its assumptions." A palavra "its" retoma:',
   array['O modelo', 'Os pesquisadores', 'O erro', 'A revisão'], 0,
   'O possessivo "its" refere-se a "the model": o erro estava nas suposições do modelo.', 100, 'medio'),
  ('d5c1cafb-ca9d-5375-b7e1-4f6aa77cb86b', 'fe307ca0-bbe3-516f-a28a-0a99f3708991',
   'Complete: "You ___ submit the form by Friday; otherwise, your application will not be considered."',
   array['might', 'could', 'must', 'would'], 2,
   '"Must" expressa obrigação forte, coerente com a consequência indicada pela segunda oração.', 101, 'medio'),
  ('f55ea09a-6b43-5615-b616-84c7f55525e1', '3b4e331e-c043-537d-8fe7-302e00a01447',
   'Leia: "City officials said the new bus lanes reduced average travel time by 12% during the pilot period, but cautioned that the result may vary by route." Qual leitura é mais fiel?',
   array['A redução de 12% ocorreu em todas as rotas sem exceção', 'O projeto aumentou o tempo médio de viagem', 'As autoridades consideram o resultado inválido', 'O piloto mostrou redução média, mas o efeito pode variar entre rotas'], 3,
   'O texto combina um resultado médio do piloto com uma ressalva explícita sobre variação por rota.', 102, 'dificil'),
  ('63603729-1bef-5ff4-b2d0-0cb91af7751d', '7d710fd7-763a-5ecc-af95-128563a2cc94',
   'Leia: "He folded the map again, although he already knew the route by heart." O uso de "although" sugere que:',
   array['Ele ainda não conhecia o caminho', 'Contraste apesar de já saber a rota', 'O mapa estava incorreto', 'Ele decidiu mudar de destino'], 1,
   '"Although" introduz contraste: mesmo conhecendo o percurso de memória, o personagem ainda manuseia o mapa.', 103, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('42b4c0fb-e7af-5f8b-998a-54c5f71790f8', 'en',
   'Read: "The researchers revised the model after they found an error in its assumptions." The word "its" refers to:',
   array['The model', 'The researchers', 'The error', 'The revision'],
   'The possessive "its" refers to "the model": the error was in the model''s assumptions.'),
  ('42b4c0fb-e7af-5f8b-998a-54c5f71790f8', 'es',
   'Lee: "The researchers revised the model after they found an error in its assumptions." La palabra "its" se refiere a:',
   array['El modelo', 'Los investigadores', 'El error', 'La revisión'],
   'El posesivo "its" se refiere a "the model": el error estaba en los supuestos del modelo.'),
  ('d5c1cafb-ca9d-5375-b7e1-4f6aa77cb86b', 'en',
   'Complete: "You ___ submit the form by Friday; otherwise, your application will not be considered."',
   array['might', 'could', 'must', 'would'],
   '"Must" expresses strong obligation, which matches the consequence stated in the second clause.'),
  ('d5c1cafb-ca9d-5375-b7e1-4f6aa77cb86b', 'es',
   'Completa: "You ___ submit the form by Friday; otherwise, your application will not be considered."',
   array['might', 'could', 'must', 'would'],
   '"Must" expresa una obligación fuerte, coherente con la consecuencia indicada en la segunda oración.'),
  ('f55ea09a-6b43-5615-b616-84c7f55525e1', 'en',
   'Read: "City officials said the new bus lanes reduced average travel time by 12% during the pilot period, but cautioned that the result may vary by route." Which interpretation is most accurate?',
   array['The 12% reduction occurred on every route without exception', 'The project increased average travel time', 'Officials consider the result invalid', 'The pilot showed an average reduction, but the effect may vary by route'],
   'The text combines an average pilot result with an explicit caution that effects may differ by route.'),
  ('f55ea09a-6b43-5615-b616-84c7f55525e1', 'es',
   'Lee: "City officials said the new bus lanes reduced average travel time by 12% during the pilot period, but cautioned that the result may vary by route." ¿Qué interpretación es más fiel?',
   array['La reducción del 12% ocurrió en todas las rutas sin excepción', 'El proyecto aumentó el tiempo medio de viaje', 'Las autoridades consideran inválido el resultado', 'El piloto mostró una reducción media, pero el efecto puede variar según la ruta'],
   'El texto combina un resultado medio del piloto con una advertencia explícita de que el efecto puede variar según la ruta.'),
  ('63603729-1bef-5ff4-b2d0-0cb91af7751d', 'en',
   'Read: "He folded the map again, although he already knew the route by heart." The use of "although" suggests that:',
   array['He still did not know the route', 'Contrast despite already knowing the route', 'The map was incorrect', 'He decided to change destinations'],
   '"Although" introduces contrast: even though the character knows the route by heart, he still handles the map.'),
  ('63603729-1bef-5ff4-b2d0-0cb91af7751d', 'es',
   'Lee: "He folded the map again, although he already knew the route by heart." El uso de "although" sugiere que:',
   array['Todavía no conocía el camino', 'Contraste pese a conocer ya la ruta', 'El mapa era incorrecto', 'Decidió cambiar de destino'],
   '"Although" introduce un contraste: aunque el personaje conoce la ruta de memoria, sigue manipulando el mapa.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== literatura =====
-- New questions for literatura: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('b3908005-56a8-5d5c-83b4-49c83209976a', 'ad409cff-6ca3-5a64-bef1-d6368c380c57',
   'A busca modernista por uma linguagem mais próxima da fala cotidiana tinha, entre seus efeitos:',
   array['Questionar normas literárias rígidas e ampliar possibilidades expressivas', 'Eliminar qualquer trabalho formal com a linguagem', 'Imitar a sintaxe clássica portuguesa com maior rigor', 'Substituir temas brasileiros por temas exclusivamente europeus'], 0,
   'A primeira geração modernista valorizou experimentação, oralidade e ruptura com convenções acadêmicas, sem abandonar o trabalho estético.', 100, 'dificil'),
  ('14cd5cc8-95ff-5ead-99d3-5517fc90b2e2', '34ef0d45-20d2-5c70-af0d-44968ad6416b',
   'Em uma narrativa, o narrador tenta justificar repetidamente suas próprias ações, mas os fatos que relata sugerem interesses e contradições. Esse recurso aproxima-se de uma característica frequente da prosa machadiana:',
   array['Descrição naturalista determinista', 'Nacionalismo idealizador', 'Narrador de confiabilidade questionável e uso de ironia', 'Objetividade documental sem ambiguidades'], 2,
   'Machado de Assis explora narradores cujas versões precisam ser lidas criticamente, muitas vezes por meio de ironia e contradições.', 101, 'dificil'),
  ('b276c4d0-54d7-5bc2-aee2-d4a30df96c4b', '568bb871-cde8-5186-83b7-c0d7f350c8a0',
   'Na frase poética "a cidade acordou tossindo fumaça", a atribuição de uma ação humana à cidade constitui:',
   array['Antítese', 'Personificação', 'Eufemismo', 'Pleonasmo'], 1,
   'A personificação atribui características ou ações humanas a seres não humanos ou entidades abstratas.', 102, 'medio'),
  ('a3e1d1bd-9c4d-5117-9fdd-64569450f2a7', '47653aa7-d471-5270-9cfe-c1567fab81d2',
   'Um texto estruturado principalmente por falas de personagens e indicações de cena pertence, em geral, ao gênero:',
   array['Lírico', 'Épico', 'Ensaístico', 'Dramático'], 3,
   'O gênero dramático é organizado para representação, com diálogos e rubricas ou indicações cênicas.', 103, 'facil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('b3908005-56a8-5d5c-83b4-49c83209976a', 'en',
   'The Modernist search for language closer to everyday speech had, among its effects:',
   array['Challenging rigid literary norms and expanding expressive possibilities', 'Eliminating any formal work with language', 'Imitating classical Portuguese syntax more strictly', 'Replacing Brazilian themes with exclusively European ones'],
   'The first Modernist generation valued experimentation, orality, and breaks with academic conventions without abandoning aesthetic craft.'),
  ('b3908005-56a8-5d5c-83b4-49c83209976a', 'es',
   'La búsqueda modernista de un lenguaje más cercano al habla cotidiana tuvo, entre sus efectos:',
   array['Cuestionar normas literarias rígidas y ampliar las posibilidades expresivas', 'Eliminar cualquier trabajo formal con el lenguaje', 'Imitar con mayor rigor la sintaxis clásica portuguesa', 'Sustituir temas brasileños por temas exclusivamente europeos'],
   'La primera generación modernista valoró la experimentación, la oralidad y la ruptura con convenciones académicas sin abandonar el trabajo estético.'),
  ('14cd5cc8-95ff-5ead-99d3-5517fc90b2e2', 'en',
   'In a narrative, the narrator repeatedly tries to justify his own actions, but the facts he recounts suggest interests and contradictions. This resembles a frequent feature of Machado de Assis''s prose:',
   array['Deterministic Naturalist description', 'Idealizing nationalism', 'A narrator of questionable reliability and the use of irony', 'Documentary objectivity without ambiguity'],
   'Machado de Assis often uses narrators whose accounts require critical reading, frequently through irony and contradictions.'),
  ('14cd5cc8-95ff-5ead-99d3-5517fc90b2e2', 'es',
   'En una narración, el narrador intenta justificar repetidamente sus propias acciones, pero los hechos que cuenta revelan intereses y contradicciones. Esto se aproxima a una característica frecuente de la prosa de Machado de Assis:',
   array['Descripción naturalista determinista', 'Nacionalismo idealizador', 'Narrador de fiabilidad cuestionable y uso de la ironía', 'Objetividad documental sin ambigüedades'],
   'Machado de Assis explora narradores cuyas versiones deben leerse críticamente, a menudo mediante ironía y contradicciones.'),
  ('b276c4d0-54d7-5bc2-aee2-d4a30df96c4b', 'en',
   'In the poetic sentence "the city woke up coughing smoke", attributing a human action to the city is:',
   array['Antithesis', 'Personification', 'Euphemism', 'Pleonasm'],
   'Personification attributes human characteristics or actions to nonhuman beings or abstract entities.'),
  ('b276c4d0-54d7-5bc2-aee2-d4a30df96c4b', 'es',
   'En la frase poética "la ciudad despertó tosiendo humo", atribuir una acción humana a la ciudad constituye:',
   array['Antítesis', 'Personificación', 'Eufemismo', 'Pleonasmo'],
   'La personificación atribuye características o acciones humanas a seres no humanos o entidades abstractas.'),
  ('a3e1d1bd-9c4d-5117-9fdd-64569450f2a7', 'en',
   'A text structured mainly through characters'' dialogue and stage directions generally belongs to the:',
   array['Lyric genre', 'Epic genre', 'Essay genre', 'Dramatic genre'],
   'Drama is organized for performance, using dialogue and stage directions.'),
  ('a3e1d1bd-9c4d-5117-9fdd-64569450f2a7', 'es',
   'Un texto estructurado principalmente por diálogos de personajes e indicaciones escénicas pertenece, por lo general, al género:',
   array['Lírico', 'Épico', 'Ensayístico', 'Dramático'],
   'El género dramático se organiza para la representación, con diálogos y acotaciones escénicas.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== matematica =====
-- New questions for matematica: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('d95757ce-98fd-54b4-abba-774f85f9abd4', '847f1a39-37fd-46ae-9005-51f6fd129221',
   'Os salários de cinco funcionários são R$ 2 mil, R$ 2 mil, R$ 2 mil, R$ 3 mil e R$ 20 mil. Para representar o valor típico do grupo sem forte influência do maior salário, é mais adequado usar:',
   array['A mediana', 'A amplitude', 'A média aritmética', 'O valor máximo'], 0,
   'A mediana é R$ 2 mil e é pouco afetada pelo valor extremo de R$ 20 mil, ao contrário da média.', 100, 'dificil'),
  ('5c979187-784c-52bf-969c-142baaa34a5f', 'a8a0b1df-a556-4d34-ac80-99f5e750921e',
   'Uma corrida de aplicativo cobra R$ 6 de taxa fixa mais R$ 2 por quilômetro percorrido. A função que representa o preço P para x quilômetros é:',
   array['P(x) = 6x + 2', 'P(x) = 2x + 6', 'P(x) = 8x', 'P(x) = 2x'], 1,
   'A taxa fixa soma 6 reais ao valor variável de 2 reais por quilômetro: P(x)=2x+6.', 101, 'medio'),
  ('5f4ed3da-ee3f-5f17-bad4-e798c959c57c', '799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c',
   'Um retângulo mede 8 cm por 5 cm. Se cada dimensão for duplicada, a nova área será:',
   array['80 cm²', '40 cm²', '120 cm²', '160 cm²'], 3,
   'A área original é 40 cm². Duplicar as duas dimensões multiplica a área por 4: 160 cm².', 102, 'medio'),
  ('cd3a0b24-3e90-5111-880e-c2eaf4f0bc3d', '184775e6-5bcb-4648-80d5-e7d97ee02af7',
   'Dois dados honestos são lançados. Sabendo que a soma obtida foi 8, qual é a probabilidade de pelo menos um dos dados mostrar 3?',
   array['1/6', '1/4', '2/5', '1/2'], 2,
   'Condicionada à soma 8, os pares ordenados possíveis são (2,6), (3,5), (4,4), (5,3) e (6,2). Dois dos cinco contêm o número 3: 2/5.', 103, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('d95757ce-98fd-54b4-abba-774f85f9abd4', 'en',
   'Five employees earn R$ 2k, R$ 2k, R$ 2k, R$ 3k, and R$ 20k. To represent a typical value without strong influence from the highest salary, the most appropriate measure is:',
   array['The median', 'The range', 'The arithmetic mean', 'The maximum'],
   'The median is R$ 2k and is little affected by the R$ 20k outlier, unlike the mean.'),
  ('d95757ce-98fd-54b4-abba-774f85f9abd4', 'es',
   'Los salarios de cinco empleados son R$ 2 mil, R$ 2 mil, R$ 2 mil, R$ 3 mil y R$ 20 mil. Para representar un valor típico sin fuerte influencia del salario más alto, conviene usar:',
   array['La mediana', 'El rango', 'La media aritmética', 'El valor máximo'],
   'La mediana es R$ 2 mil y se ve poco afectada por el valor extremo de R$ 20 mil, a diferencia de la media.'),
  ('5c979187-784c-52bf-969c-142baaa34a5f', 'en',
   'A ride-hailing trip charges a fixed R$ 6 fee plus R$ 2 per kilometer. The function representing price P for x kilometers is:',
   array['P(x) = 6x + 2', 'P(x) = 2x + 6', 'P(x) = 8x', 'P(x) = 2x'],
   'The fixed fee adds R$ 6 to the variable charge of R$ 2 per kilometer: P(x)=2x+6.'),
  ('5c979187-784c-52bf-969c-142baaa34a5f', 'es',
   'Un viaje en una aplicación cobra una tarifa fija de R$ 6 más R$ 2 por kilómetro. La función que representa el precio P para x kilómetros es:',
   array['P(x) = 6x + 2', 'P(x) = 2x + 6', 'P(x) = 8x', 'P(x) = 2x'],
   'La tarifa fija suma R$ 6 al costo variable de R$ 2 por kilómetro: P(x)=2x+6.'),
  ('5f4ed3da-ee3f-5f17-bad4-e798c959c57c', 'en',
   'A rectangle measures 8 cm by 5 cm. If each dimension is doubled, the new area will be:',
   array['80 cm²', '40 cm²', '120 cm²', '160 cm²'],
   'The original area is 40 cm². Doubling both dimensions multiplies area by 4: 160 cm².'),
  ('5f4ed3da-ee3f-5f17-bad4-e798c959c57c', 'es',
   'Un rectángulo mide 8 cm por 5 cm. Si se duplica cada dimensión, la nueva área será:',
   array['80 cm²', '40 cm²', '120 cm²', '160 cm²'],
   'El área original es 40 cm². Duplicar ambas dimensiones multiplica el área por 4: 160 cm².'),
  ('cd3a0b24-3e90-5111-880e-c2eaf4f0bc3d', 'en',
   'Two fair dice are rolled. Given that the sum is 8, what is the probability that at least one die shows 3?',
   array['1/6', '1/4', '2/5', '1/2'],
   'Given a sum of 8, the possible ordered pairs are (2,6), (3,5), (4,4), (5,3), and (6,2). Two of the five contain a 3: 2/5.'),
  ('cd3a0b24-3e90-5111-880e-c2eaf4f0bc3d', 'es',
   'Se lanzan dos dados equilibrados. Sabiendo que la suma obtenida fue 8, ¿cuál es la probabilidad de que al menos uno muestre 3?',
   array['1/6', '1/4', '2/5', '1/2'],
   'Condicionada a que la suma sea 8, los pares ordenados posibles son (2,6), (3,5), (4,4), (5,3) y (6,2). Dos de los cinco contienen un 3: 2/5.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== portugues =====
-- New questions for portugues: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('319c0472-516e-5f70-8390-8063db330345', '7715e4c7-fa79-47be-9cdf-ea20ca7b2db6',
   'Leia: "A biblioteca deveria ampliar o horário aos sábados. Nos últimos três meses, mais de 40% dos empréstimos de fim de semana ocorreram na última hora antes do fechamento." A segunda frase funciona como:',
   array['Uma definição do conceito de biblioteca', 'Uma evidência usada para sustentar a proposta', 'Uma conclusão sem relação com a tese', 'Uma objeção à ampliação do horário'], 1,
   'O dado de uso próximo ao fechamento fornece evidência para defender a ampliação do horário.', 100, 'dificil'),
  ('0fd26357-80a0-5f2d-802d-a9af37e410b7', '3489b617-c328-4af1-bd3d-7a84dd343f79',
   'Em uma redação dissertativo-argumentativa, um repertório sociocultural é produtivo quando:',
   array['Aparece como citação decorativa sem relação com o argumento', 'Substitui a explicação do autor do texto', 'É mencionado apenas para demonstrar erudição', 'É articulado ao argumento e ajuda a sustentar a tese'], 3,
   'Repertório produtivo não é enfeite: ele precisa ser pertinente e integrado ao raciocínio desenvolvido.', 101, 'dificil'),
  ('ab480f4f-b750-5ff7-beff-5a421686a82e', 'f25a58d3-8d53-4fda-abee-4ee3cb708b26',
   'Na frase "O banco estava cheio no fim da tarde", a palavra "banco" pode gerar ambiguidade porque:',
   array['É sempre um verbo', 'Só possui sentido figurado', 'Tem sentidos como banco financeiro e assento', 'Não admite variação de significado'], 2,
   'A palavra é polissêmica: o contexto precisa indicar qual de seus diferentes sentidos está sendo usado.', 102, 'medio'),
  ('a94ffb96-7f1a-59b2-9432-53c797d3f56c', '6328fd95-8026-4dc2-8cdc-40bcaf543628',
   'Na frase "Os alunos que entregaram o trabalho receberam feedback", a oração "que entregaram o trabalho" restringe o grupo de alunos. Por isso, ela é:',
   array['Oração subordinada adjetiva restritiva', 'Oração subordinada adjetiva explicativa', 'Oração subordinada substantiva objetiva', 'Oração coordenada conclusiva'], 0,
   'Sem vírgulas e com função de delimitar quais alunos receberam feedback, a oração é adjetiva restritiva.', 103, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('319c0472-516e-5f70-8390-8063db330345', 'en',
   'Read the Portuguese excerpt: "A biblioteca deveria ampliar o horário aos sábados. Nos últimos três meses, mais de 40% dos empréstimos de fim de semana ocorreram na última hora antes do fechamento." The second sentence functions as:',
   array['A definition of the concept of library', 'Evidence used to support the proposal', 'A conclusion unrelated to the thesis', 'An objection to extending opening hours'],
   'The usage data near closing time provides evidence in favor of extending opening hours.'),
  ('319c0472-516e-5f70-8390-8063db330345', 'es',
   'Lee el fragmento en portugués: "A biblioteca deveria ampliar o horário aos sábados. Nos últimos três meses, mais de 40% dos empréstimos de fim de semana ocorreram na última hora antes do fechamento." La segunda oración funciona como:',
   array['Una definición del concepto de biblioteca', 'Una evidencia utilizada para apoyar la propuesta', 'Una conclusión sin relación con la tesis', 'Una objeción a ampliar el horario'],
   'El dato de uso cerca del cierre aporta evidencia para defender la ampliación del horario.'),
  ('0fd26357-80a0-5f2d-802d-a9af37e410b7', 'en',
   'In an argumentative essay, a piece of sociocultural repertoire is productive when it:',
   array['Appears as a decorative quotation unrelated to the argument', 'Replaces the writer''s own explanation', 'Is mentioned only to display erudition', 'Is connected to the argument and helps support the thesis'],
   'Productive repertoire is not decoration: it must be relevant and integrated into the reasoning.'),
  ('0fd26357-80a0-5f2d-802d-a9af37e410b7', 'es',
   'En una redacción argumentativa, un repertorio sociocultural es productivo cuando:',
   array['Aparece como una cita decorativa sin relación con el argumento', 'Sustituye la explicación del autor del texto', 'Se menciona solo para demostrar erudición', 'Se articula con el argumento y ayuda a sostener la tesis'],
   'Un repertorio productivo no es adorno: debe ser pertinente e integrarse al razonamiento desarrollado.'),
  ('ab480f4f-b750-5ff7-beff-5a421686a82e', 'en',
   'In the Portuguese sentence "O banco estava cheio no fim da tarde", the word "banco" may be ambiguous because:',
   array['It is always a verb', 'It has only a figurative meaning', 'It may mean a bank or a seat', 'It does not allow variation in meaning'],
   'The word is polysemous: context must indicate which of its different meanings is intended.'),
  ('ab480f4f-b750-5ff7-beff-5a421686a82e', 'es',
   'En la oración portuguesa "O banco estava cheio no fim da tarde", la palabra "banco" puede ser ambigua porque:',
   array['Siempre es un verbo', 'Solo tiene sentido figurado', 'Puede significar un banco financiero o un asiento', 'No admite variación de significado'],
   'La palabra es polisémica: el contexto debe indicar cuál de sus distintos sentidos se está utilizando.'),
  ('a94ffb96-7f1a-59b2-9432-53c797d3f56c', 'en',
   'In the Portuguese sentence "Os alunos que entregaram o trabalho receberam feedback", the clause "que entregaram o trabalho" restricts which students are being referred to. Therefore, it is:',
   array['A restrictive relative clause', 'A nonrestrictive relative clause', 'A noun object clause', 'A conclusive coordinate clause'],
   'With no commas and with the function of delimiting which students received feedback, the clause is restrictive.'),
  ('a94ffb96-7f1a-59b2-9432-53c797d3f56c', 'es',
   'En la oración portuguesa "Os alunos que entregaram o trabalho receberam feedback", la proposición "que entregaram o trabalho" restringe el grupo de alumnos. Por eso, es:',
   array['Una oración subordinada adjetiva restrictiva', 'Una oración subordinada adjetiva explicativa', 'Una oración subordinada sustantiva objetiva', 'Una oración coordinada conclusiva'],
   'Sin comas y con la función de delimitar qué alumnos recibieron feedback, la oración es adjetiva restrictiva.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== quimica =====
-- New questions for quimica: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('12dee516-54ee-5006-9cee-e649153a18b8', '1694b662-d892-4687-8727-9f74c2715b11',
   'Na reação N₂ + 3H₂ → 2NH₃, quantos mol de NH₃ podem ser formados a partir de 6 mol de H₂, com N₂ em excesso?',
   array['3 mol', '6 mol', '4 mol', '12 mol'], 2,
   'A proporção é 3 mol de H₂ para 2 mol de NH₃. Assim, 6 mol de H₂ formam 4 mol de NH₃.', 100, 'medio'),
  ('4279a99e-7fc9-5793-8a16-8e401c730090', '2e117b4e-3e7c-492e-82dc-22b964209b9a',
   'Em uma reação exotérmica, a entalpia dos produtos é menor que a dos reagentes. Portanto, o ΔH da reação é:',
   array['Negativo', 'Positivo', 'Necessariamente zero', 'Igual à energia de ativação'], 0,
   'Em processos exotérmicos há liberação de energia e ΔH = Hprodutos − Hreagentes < 0.', 101, 'dificil'),
  ('3b4feabb-f075-5b0c-bd10-3e5ea46db06c', '73cac530-0e0d-4775-b9c0-ae6ce4912b8c',
   'A eutrofização de lagos e reservatórios costuma ser favorecida pelo excesso de nutrientes como nitrogênio e fósforo. Uma consequência possível é:',
   array['Aumento permanente do oxigênio dissolvido em todas as profundidades', 'Redução do crescimento de algas e cianobactérias', 'Transformação da água doce em água salgada', 'Proliferação de algas seguida de queda do oxigênio durante a decomposição'], 3,
   'O excesso de nutrientes pode estimular florações; a decomposição da biomassa consome oxigênio e pode causar hipóxia.', 102, 'medio'),
  ('43923212-f624-55f0-bc21-f4f95e8b0c39', 'f41ba2d7-4462-4a77-8362-272bb8313c47',
   'Uma solução contém 10 g de sal dissolvidos em 90 g de água. Considerando a massa total da solução, a porcentagem em massa de soluto é:',
   array['9%', '10%', '11,1%', '90%'], 1,
   'A massa da solução é 10 + 90 = 100 g. Logo, a porcentagem em massa do soluto é 10/100 × 100% = 10%.', 103, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('12dee516-54ee-5006-9cee-e649153a18b8', 'en',
   'For N₂ + 3H₂ → 2NH₃, how many moles of NH₃ can be formed from 6 mol of H₂ when N₂ is in excess?',
   array['3 mol', '6 mol', '4 mol', '12 mol'],
   'The ratio is 3 mol H₂ to 2 mol NH₃. Therefore, 6 mol H₂ forms 4 mol NH₃.'),
  ('12dee516-54ee-5006-9cee-e649153a18b8', 'es',
   'En la reacción N₂ + 3H₂ → 2NH₃, ¿cuántos mol de NH₃ pueden formarse a partir de 6 mol de H₂, con N₂ en exceso?',
   array['3 mol', '6 mol', '4 mol', '12 mol'],
   'La proporción es 3 mol de H₂ por 2 mol de NH₃. Por tanto, 6 mol de H₂ forman 4 mol de NH₃.'),
  ('4279a99e-7fc9-5793-8a16-8e401c730090', 'en',
   'In an exothermic reaction, the products have lower enthalpy than the reactants. Therefore, the reaction ΔH is:',
   array['Negative', 'Positive', 'Necessarily zero', 'Equal to the activation energy'],
   'Exothermic processes release energy, so ΔH = Hproducts − Hreactants < 0.'),
  ('4279a99e-7fc9-5793-8a16-8e401c730090', 'es',
   'En una reacción exotérmica, la entalpía de los productos es menor que la de los reactivos. Por tanto, el ΔH de la reacción es:',
   array['Negativo', 'Positivo', 'Necesariamente cero', 'Igual a la energía de activación'],
   'En los procesos exotérmicos se libera energía y ΔH = Hproductos − Hreactivos < 0.'),
  ('3b4feabb-f075-5b0c-bd10-3e5ea46db06c', 'en',
   'Eutrophication of lakes and reservoirs is often favored by excess nutrients such as nitrogen and phosphorus. One possible consequence is:',
   array['A permanent increase in dissolved oxygen at all depths', 'Reduced growth of algae and cyanobacteria', 'Conversion of fresh water into salt water', 'Algal blooms followed by oxygen depletion during decomposition'],
   'Excess nutrients can stimulate blooms; decomposition of the biomass consumes oxygen and may cause hypoxia.'),
  ('3b4feabb-f075-5b0c-bd10-3e5ea46db06c', 'es',
   'La eutrofización de lagos y embalses suele verse favorecida por el exceso de nutrientes como nitrógeno y fósforo. Una posible consecuencia es:',
   array['Aumento permanente del oxígeno disuelto en todas las profundidades', 'Reducción del crecimiento de algas y cianobacterias', 'Transformación del agua dulce en agua salada', 'Proliferación de algas seguida de disminución del oxígeno durante la descomposición'],
   'El exceso de nutrientes puede estimular floraciones; la descomposición de la biomasa consume oxígeno y puede causar hipoxia.'),
  ('43923212-f624-55f0-bc21-f4f95e8b0c39', 'en',
   'A solution contains 10 g of salt dissolved in 90 g of water. Considering the total mass of the solution, the solute mass percentage is:',
   array['9%', '10%', '11.1%', '90%'],
   'The solution mass is 10 + 90 = 100 g. Therefore, the solute mass percentage is 10/100 × 100% = 10%.'),
  ('43923212-f624-55f0-bc21-f4f95e8b0c39', 'es',
   'Una solución contiene 10 g de sal disueltos en 90 g de agua. Considerando la masa total de la solución, el porcentaje en masa de soluto es:',
   array['9%', '10%', '11,1%', '90%'],
   'La masa de la solución es 10 + 90 = 100 g. Por tanto, el porcentaje en masa del soluto es 10/100 × 100% = 10%.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

-- ===== sociologia =====
-- New questions for sociologia: 4 questions, each already
-- with its en/es translation (8 translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
  ('1dc67c9e-a4be-5915-8863-3f2fc16546ad', '213689ca-27ba-5f68-b58f-05b18725e2ee',
   'Para Durkheim, um fato social exerce coerção sobre os indivíduos e existe além de vontades particulares. Qual exemplo melhor se aproxima desse conceito?',
   array['A preferência pessoal por um sabor de sorvete', 'Um sonho lembrado por uma única pessoa', 'Normas jurídicas que regulam comportamentos na sociedade', 'Uma escolha feita sem referência a regras compartilhadas'], 2,
   'Leis e normas são exteriores ao indivíduo e podem exercer coerção, características centrais dos fatos sociais em Durkheim.', 100, 'medio'),
  ('cbd73bb7-ccf5-5aea-a9b4-69648e2aa42e', '102baef0-7528-5fdf-9e6e-b15453d9bf78',
   'Quando uma plataforma recomenda conteúdos com base no histórico de cliques, curtidas e tempo de visualização, isso mostra que:',
   array['A curadoria algorítmica pode usar rastros de comportamento para personalizar a circulação de conteúdos', 'Todos os usuários recebem necessariamente a mesma sequência de conteúdos', 'As escolhas anteriores deixam de influenciar o que é exibido', 'A personalização ocorre sem coleta de sinais de interação'], 0,
   'Sistemas de recomendação usam sinais de comportamento para estimar relevância, o que influencia quais conteúdos ganham visibilidade para cada usuário.', 101, 'dificil'),
  ('693b9470-e19a-5eb2-a344-fca5ab847704', 'c0fc2a44-cbf1-5e1d-8d28-ed6d56feb3c2',
   'Duas pessoas têm renda semelhante, mas uma dispõe de redes profissionais influentes e maior prestígio social. Uma análise multidimensional da estratificação destaca que:',
   array['A renda explica sozinha todas as posições sociais', 'Prestígio e redes não afetam oportunidades', 'Classe econômica e status são conceitos idênticos', 'Recursos econômicos, prestígio e redes geram vantagens distintas'], 3,
   'A estratificação pode envolver várias dimensões; renda, prestígio, poder e redes sociais não se distribuem de maneira idêntica.', 102, 'dificil'),
  ('6baf143e-d8b2-5c68-94e1-a8f8cdab7e89', '87495fdd-4713-57ef-ba8b-39aeb0ce8660',
   'Uma pessoa atribui o desemprego de alguém apenas à falta de esforço individual. A imaginação sociológica propõe ampliar essa análise ao considerar:',
   array['Traços psicológicos que explicariam a inserção profissional', 'Relações entre trajetórias pessoais e estruturas sociais', 'Decisões familiares independentes do mercado de trabalho', 'Preferências individuais como principal variável explicativa'], 1,
   'A imaginação sociológica conecta experiências pessoais a processos mais amplos, como mercado de trabalho, educação, crises e desigualdades.', 103, 'dificil')
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
  ('1dc67c9e-a4be-5915-8863-3f2fc16546ad', 'en',
   'For Durkheim, a social fact constrains individuals and exists beyond particular wills. Which example best fits this concept?',
   array['A personal preference for an ice-cream flavor', 'A dream remembered by one person', 'Legal norms that regulate behavior in society', 'A choice made without reference to shared rules'],
   'Laws and norms are external to individuals and can exert constraint, central features of Durkheim''s social facts.'),
  ('1dc67c9e-a4be-5915-8863-3f2fc16546ad', 'es',
   'Para Durkheim, un hecho social ejerce coerción sobre los individuos y existe más allá de voluntades particulares. ¿Qué ejemplo se aproxima mejor a este concepto?',
   array['La preferencia personal por un sabor de helado', 'Un sueño recordado por una sola persona', 'Normas jurídicas que regulan comportamientos en la sociedad', 'Una elección hecha sin referencia a reglas compartidas'],
   'Las leyes y normas son exteriores al individuo y pueden ejercer coerción, rasgos centrales de los hechos sociales en Durkheim.'),
  ('cbd73bb7-ccf5-5aea-a9b4-69648e2aa42e', 'en',
   'When a platform recommends content using click history, likes, and watch time, this shows that:',
   array['Algorithmic curation can use behavioral traces to personalize content circulation', 'All users necessarily receive the same content sequence', 'Previous choices stop influencing what is displayed', 'Personalization occurs without collecting interaction signals'],
   'Recommendation systems use behavioral signals to estimate relevance, influencing which content becomes visible to each user.'),
  ('cbd73bb7-ccf5-5aea-a9b4-69648e2aa42e', 'es',
   'Cuando una plataforma recomienda contenidos según el historial de clics, ''me gusta'' y tiempo de visualización, esto muestra que:',
   array['La curaduría algorítmica puede usar rastros de comportamiento para personalizar la circulación de contenidos', 'Todos los usuarios reciben necesariamente la misma secuencia de contenidos', 'Las elecciones anteriores dejan de influir en lo que se muestra', 'La personalización ocurre sin recopilar señales de interacción'],
   'Los sistemas de recomendación usan señales de comportamiento para estimar relevancia, influyendo en qué contenidos ganan visibilidad para cada usuario.'),
  ('693b9470-e19a-5eb2-a344-fca5ab847704', 'en',
   'Two people have similar incomes, but one has influential professional networks and greater social prestige. A multidimensional analysis of stratification highlights that:',
   array['Income alone explains every social position', 'Prestige and networks do not affect opportunities', 'Economic class and status are identical concepts', 'Economic resources, prestige, and networks create different advantages'],
   'Stratification can involve several dimensions; income, prestige, power, and social networks are not distributed identically.'),
  ('693b9470-e19a-5eb2-a344-fca5ab847704', 'es',
   'Dos personas tienen ingresos similares, pero una dispone de redes profesionales influyentes y mayor prestigio social. Un análisis multidimensional de la estratificación destaca que:',
   array['El ingreso explica por sí solo todas las posiciones sociales', 'El prestigio y las redes no afectan las oportunidades', 'Clase económica y estatus son conceptos idénticos', 'Los recursos económicos, el prestigio y las redes generan ventajas distintas'],
   'La estratificación puede implicar varias dimensiones; ingreso, prestigio, poder y redes sociales no se distribuyen de manera idéntica.'),
  ('6baf143e-d8b2-5c68-94e1-a8f8cdab7e89', 'en',
   'A person explains someone''s unemployment only as a lack of individual effort. The sociological imagination proposes broadening the analysis by considering:',
   array['Psychological traits that would explain labor-market participation', 'Connections between personal trajectories and social structures', 'Family decisions independent of labor-market conditions', 'Individual preferences as the main explanatory variable'],
   'The sociological imagination connects personal experiences to broader processes such as labor markets, education, crises, and inequality.'),
  ('6baf143e-d8b2-5c68-94e1-a8f8cdab7e89', 'es',
   'Una persona atribuye el desempleo de alguien únicamente a la falta de esfuerzo individual. La imaginación sociológica propone ampliar el análisis considerando:',
   array['Rasgos psicológicos que explicarían la inserción laboral', 'Relaciones entre trayectorias personales y estructuras sociales', 'Decisiones familiares independientes del mercado de trabajo', 'Preferencias individuales como principal variable explicativa'],
   'La imaginación sociológica conecta experiencias personales con procesos más amplios, como mercado laboral, educación, crisis y desigualdades.')
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;

