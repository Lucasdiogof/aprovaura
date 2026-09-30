-- Física: 10 correções aceitas da revisão externa (2026-09-30)
--
-- Nenhum gabarito estava errado. Física não tem arquivo fonte: a correção
-- vive só no banco. Os ganhos: a normal não é a reação ao peso (o par dela
-- age sobre a superfície); 45° só maximiza o alcance com saída e chegada no
-- mesmo nível; o som é longitudinal no ar, mas não em todo meio; na emissão
-- gama o núcleo não vira outro; K = °C + 273,15; a entropia fica constante
-- só no processo reversível ideal; o limite da máquina térmica vem de ter de
-- rejeitar calor à fonte fria; e a óptica de miopia e hipermetropia.
--
-- Recusado: "obrigatoriamente" enxertado num distrator de radioatividade.
--
-- Só o texto muda: a ORDEM das alternativas é preservada, para o gabarito
-- não se mexer e as traduções seguirem alinhadas por posição. Cada
-- update grava o valor final inteiro, então rodar de novo não muda nada.

-- radioatividade: na emissão gama o núcleo não vira outro
update questions set options = array['Emitem espontaneamente partículas ou radiação, buscando estados mais estáveis', 'Permanecem sempre estáveis, sem qualquer alteração', 'Absorvem elétrons do ambiente, tornando-se neutros', 'Perdem toda sua massa instantaneamente'], explanation = 'Núcleos instáveis emitem partículas ou radiação espontaneamente. Nos decaimentos alfa e beta o núcleo se transforma em outro; na emissão gama ele só perde energia.'
 where id = '9861277b-3bf0-4573-9a84-88e47adf8e7f';
update question_translations set options = array['Spontaneously emit particles or radiation, moving toward more stable states', 'Always remain stable, with no change', 'Absorb electrons from the environment, becoming neutral', 'Instantly lose all their mass'], explanation = 'Unstable nuclei emit particles or radiation spontaneously. In alpha and beta decay the nucleus turns into another one; in gamma emission it only loses energy.'
 where question_id = '9861277b-3bf0-4573-9a84-88e47adf8e7f' and locale = 'en';
update question_translations set options = array['Emiten espontáneamente partículas o radiación, buscando estados más estables', 'Permanecen siempre estables, sin ninguna alteración', 'Absorben electrones del ambiente y se vuelven neutros', 'Pierden toda su masa instantáneamente'], explanation = 'Los núcleos inestables emiten partículas o radiación espontáneamente. En los decaimientos alfa y beta el núcleo se transforma en otro; en la emisión gamma solo pierde energía.'
 where question_id = '9861277b-3bf0-4573-9a84-88e47adf8e7f' and locale = 'es';

-- ímã: monopolos isolados nunca foram observados
update questions set explanation = 'Todo ímã comum tem polos norte e sul; ao dividi-lo, cada pedaço vira um ímã menor, também com dois polos. Monopolos magnéticos isolados nunca foram observados.'
 where id = '018e8d33-dbea-4c22-b17e-9c28bf2580bc';
update question_translations set explanation = 'Every ordinary magnet has a north and a south pole; when it is broken, each piece becomes a smaller magnet, also with two poles. Isolated magnetic monopoles have never been observed.'
 where question_id = '018e8d33-dbea-4c22-b17e-9c28bf2580bc' and locale = 'en';
update question_translations set explanation = 'Todo imán común tiene polos norte y sur; al dividirlo, cada trozo se convierte en un imán más pequeño, también con dos polos. Nunca se han observado monopolos magnéticos aislados.'
 where question_id = '018e8d33-dbea-4c22-b17e-9c28bf2580bc' and locale = 'es';

-- lançamento oblíquo: 45° só vale com saída e chegada no mesmo nível
update questions set prompt = 'Em um lançamento oblíquo que começa e termina na mesma altura, qual ângulo proporciona o maior alcance horizontal para uma mesma velocidade inicial, desprezando a resistência do ar?', explanation = 'Com lançamento e chegada no mesmo nível e sem resistência do ar, o alcance é máximo para 45°.'
 where id = '3c910d36-78fd-4033-a081-ced5fba04d9b';
update question_translations set prompt = 'In an oblique launch that starts and ends at the same height, which angle gives the greatest horizontal range for the same initial speed, neglecting air resistance?', explanation = 'With launch and landing at the same level and no air resistance, the range is greatest at 45°.'
 where question_id = '3c910d36-78fd-4033-a081-ced5fba04d9b' and locale = 'en';
update question_translations set prompt = 'En un lanzamiento oblicuo que empieza y termina a la misma altura, ¿qué ángulo proporciona el mayor alcance horizontal para una misma velocidad inicial, despreciando la resistencia del aire?', explanation = 'Con lanzamiento y llegada al mismo nivel y sin resistencia del aire, el alcance es máximo para 45°.'
 where question_id = '3c910d36-78fd-4033-a081-ced5fba04d9b' and locale = 'es';

-- normal não é a reação ao peso: o par de ação e reação da normal age sobre a superfície
update questions set explanation = 'A normal é a força de contato perpendicular que a superfície exerce sobre o corpo. Pela 3ª Lei de Newton, seu par de ação e reação é a força que o corpo exerce sobre a superfície, e não o peso.'
 where id = '1dbd2b10-f437-42bf-8010-d77c231d3ea1';
update question_translations set explanation = 'The normal force is the perpendicular contact force the surface exerts on the body. By Newton''s third law, its action-reaction pair is the force the body exerts on the surface, not the weight.'
 where question_id = '1dbd2b10-f437-42bf-8010-d77c231d3ea1' and locale = 'en';
update question_translations set explanation = 'La normal es la fuerza de contacto perpendicular que la superficie ejerce sobre el cuerpo. Por la 3.ª ley de Newton, su par de acción y reacción es la fuerza que el cuerpo ejerce sobre la superficie, y no el peso.'
 where question_id = '1dbd2b10-f437-42bf-8010-d77c231d3ea1' and locale = 'es';

-- som: em sólidos também há ondas transversais; a pergunta passa a ser sobre o ar
update questions set prompt = 'No ar, o som é classificado como uma onda:', explanation = 'No ar, o som é uma onda mecânica (precisa de meio material) e longitudinal (a vibração ocorre na mesma direção da propagação).'
 where id = '46418d77-8ff9-49c9-8ae5-c1e374f3c10d';
update question_translations set prompt = 'In air, sound is classified as a wave that is:', explanation = 'In air, sound is a mechanical wave (it needs a material medium) and longitudinal (the vibration happens in the same direction as the propagation).'
 where question_id = '46418d77-8ff9-49c9-8ae5-c1e374f3c10d' and locale = 'en';
update question_translations set prompt = 'En el aire, el sonido se clasifica como una onda:', explanation = 'En el aire, el sonido es una onda mecánica (necesita un medio material) y longitudinal (la vibración ocurre en la misma dirección de la propagación).'
 where question_id = '46418d77-8ff9-49c9-8ae5-c1e374f3c10d' and locale = 'es';

-- hipermetropia: a lente convergente aumenta a convergência dos raios
update questions set options = array['Convergentes, que aumentam a convergência dos raios antes de entrarem no olho', 'Divergentes, que afastam o ponto de convergência', 'Apenas cirurgicamente, sem uso de lentes', 'De qualquer tipo, sem diferença significativa'], explanation = 'A hipermetropia é corrigida com lentes convergentes, que acrescentam potência ao sistema óptico e levam a imagem a se formar sobre a retina.'
 where id = 'e67c9741-d9c1-4ac7-ac9f-f8d86e4e0655';
update question_translations set options = array['Converging, which increase the convergence of the rays before they enter the eye', 'Diverging, moving the convergence point back', 'Only surgery, with no lenses', 'Of any type, with no significant difference'], explanation = 'Hyperopia is corrected with converging lenses, which add power to the optical system so the image forms on the retina.'
 where question_id = 'e67c9741-d9c1-4ac7-ac9f-f8d86e4e0655' and locale = 'en';
update question_translations set options = array['Convergentes, que aumentan la convergencia de los rayos antes de entrar en el ojo', 'Divergentes, que alejan el punto de convergencia', 'Solo con cirugía, sin uso de lentes', 'De cualquier tipo, sin diferencia significativa'], explanation = 'La hipermetropía se corrige con lentes convergentes, que añaden potencia al sistema óptico y hacen que la imagen se forme sobre la retina.'
 where question_id = 'e67c9741-d9c1-4ac7-ac9f-f8d86e4e0655' and locale = 'es';

-- miopia: a lente divergente reduz a convergência do sistema
update questions set options = array['Divergentes, que reduzem a convergência do sistema óptico', 'Convergentes, que aproximam o ponto de convergência', 'Apenas cirurgicamente, sem uso de lentes', 'De qualquer tipo, sem diferença significativa'], explanation = 'A miopia é corrigida com lentes divergentes, que reduzem a potência convergente do sistema e deslocam o foco para a retina.'
 where id = '35f896b3-3a2c-4a69-b56c-73de07766dd2';
update question_translations set options = array['Diverging, which reduce the convergence of the optical system', 'Converging, bringing the convergence point forward', 'Only surgery, with no lenses', 'Of any type, with no significant difference'], explanation = 'Myopia is corrected with diverging lenses, which reduce the converging power of the system and move the focus onto the retina.'
 where question_id = '35f896b3-3a2c-4a69-b56c-73de07766dd2' and locale = 'en';
update question_translations set options = array['Divergentes, que reducen la convergencia del sistema óptico', 'Convergentes, que acercan el punto de convergencia', 'Solo con cirugía, sin uso de lentes', 'De cualquier tipo, sin diferencia significativa'], explanation = 'La miopía se corrige con lentes divergentes, que reducen la potencia convergente del sistema y desplazan el foco hacia la retina.'
 where question_id = '35f896b3-3a2c-4a69-b56c-73de07766dd2' and locale = 'es';

-- 2ª Lei: a entropia fica constante só no processo reversível ideal
update questions set explanation = 'Pela Segunda Lei, em um sistema isolado a entropia não diminui: aumenta nos processos espontâneos e permanece constante apenas em um processo reversível ideal.'
 where id = 'b36783c6-ecb8-430c-8295-d3280916b119';
update question_translations set explanation = 'By the Second Law, the entropy of an isolated system does not decrease: it increases in spontaneous processes and stays constant only in an ideal reversible process.'
 where question_id = 'b36783c6-ecb8-430c-8295-d3280916b119' and locale = 'en';
update question_translations set explanation = 'Por la Segunda Ley, en un sistema aislado la entropía no disminuye: aumenta en los procesos espontáneos y solo permanece constante en un proceso reversible ideal.'
 where question_id = 'b36783c6-ecb8-430c-8295-d3280916b119' and locale = 'es';

-- máquina térmica: o limite vem de ter de rejeitar calor à fonte fria, não de "perdas"
update questions set options = array['100%, pois uma máquina que opera em ciclo precisa rejeitar parte do calor para uma fonte fria', 'Mais de 50%, em qualquer condição', 'Menos de 10%, obrigatoriamente', 'Zero, tornando qualquer máquina térmica inútil'], explanation = 'Uma máquina térmica operando em ciclo não pode converter todo o calor recebido em trabalho: parte dele tem de ser rejeitada para uma fonte fria.'
 where id = 'a5972887-6b4c-4971-822b-85820871647c';
update question_translations set options = array['100%, since an engine working in a cycle must reject part of the heat to a cold reservoir', 'More than 50%, under any conditions', 'Less than 10%, necessarily', 'Zero, which would make any heat engine useless'], explanation = 'A heat engine working in a cycle cannot turn all the heat it receives into work: part of it must be rejected to a cold reservoir.'
 where question_id = 'a5972887-6b4c-4971-822b-85820871647c' and locale = 'en';
update question_translations set options = array['100%, pues una máquina que funciona en ciclo debe ceder parte del calor a una fuente fría', 'Más del 50%, en cualquier condición', 'Menos del 10%, obligatoriamente', 'Cero, lo que volvería inútil a cualquier máquina térmica'], explanation = 'Una máquina térmica que funciona en ciclo no puede convertir todo el calor recibido en trabajo: parte de él debe cederse a una fuente fría.'
 where question_id = 'a5972887-6b4c-4971-822b-85820871647c' and locale = 'es';

-- Kelvin: o valor exato é 273,15
update questions set options = array['Somar aproximadamente 273,15 ao valor em Celsius', 'Multiplicar o valor em Celsius por 1,8', 'Subtrair 32 do valor em Celsius', 'Dividir o valor em Celsius por 2'], explanation = 'A conversão é K = °C + 273,15; em exercícios escolares, costuma-se usar 273 como aproximação.'
 where id = '399fc7f2-175d-4c3e-882c-df6ab0154480';
update question_translations set options = array['Add approximately 273.15 to the Celsius value', 'Multiply the Celsius value by 1.8', 'Subtract 32 from the Celsius value', 'Divide the Celsius value by 2'], explanation = 'The conversion is K = °C + 273.15; school exercises often use 273 as an approximation.'
 where question_id = '399fc7f2-175d-4c3e-882c-df6ab0154480' and locale = 'en';
update question_translations set options = array['Sumar aproximadamente 273,15 al valor en Celsius', 'Multiplicar el valor en Celsius por 1,8', 'Restar 32 al valor en Celsius', 'Dividir el valor en Celsius por 2'], explanation = 'La conversión es K = °C + 273,15; en los ejercicios escolares se suele usar 273 como aproximación.'
 where question_id = '399fc7f2-175d-4c3e-882c-df6ab0154480' and locale = 'es';
