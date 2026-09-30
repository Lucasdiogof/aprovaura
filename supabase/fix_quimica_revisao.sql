-- Química: 14 correções aceitas da revisão externa (2026-09-30)
--
-- Nenhum gabarito deslocado, mas três alternativas certas estavam erradas no
-- conteúdo: nêutrons não "neutralizam a repulsão" (não têm carga; atuam pela
-- força nuclear forte); a baixa reatividade dos éteres não vem da falta de O–H
-- (isso explica o ponto de ebulição); e o fenol se define pelo –OH ligado
-- direto ao anel, não por "ter anel" (o álcool benzílico tem anel e é álcool).
-- Também: creme dental leva fluoreto, não flúor elementar; pilhas variam de
-- composição. O resto é nuance de explicação.
--
-- Recusadas: alternativas certas alongadas (elétrons, octeto, ureia, isomeria,
-- polímeros, soluções) e o Arrhenius do revisor, cujas alternativas não
-- combinavam com o enunciado. Química não tem fonte: vive só no banco.
--
-- Só o texto muda: a ORDEM das alternativas é preservada, para o gabarito
-- não se mexer e as traduções seguirem alinhadas por posição. Cada
-- update grava o valor final inteiro, então rodar de novo não muda nada.

-- elétrons: no modelo atual há orbitais, não órbitas
update questions set explanation = 'Os elétrons têm carga negativa e ocupam a eletrosfera, ao redor do núcleo. No modelo quântico atual, sua distribuição é descrita por orbitais, e não por órbitas bem definidas.'
 where id = '28487de7-ac1e-466c-8be6-2c3195eceb62';
update question_translations set explanation = 'Electrons have a negative charge and occupy the electron cloud around the nucleus. In the current quantum model, their distribution is described by orbitals, not by well-defined orbits.'
 where question_id = '28487de7-ac1e-466c-8be6-2c3195eceb62' and locale = 'en';
update question_translations set explanation = 'Los electrones tienen carga negativa y ocupan la corteza electrónica, alrededor del núcleo. En el modelo cuántico actual, su distribución se describe mediante orbitales, y no mediante órbitas bien definidas.'
 where question_id = '28487de7-ac1e-466c-8be6-2c3195eceb62' and locale = 'es';

-- nêutrons: não "neutralizam" repulsão nenhuma (não têm carga); atuam pela força nuclear forte
update questions set options = array['Participam da força nuclear forte, que mantém os núcleons unidos, sem somar repulsão elétrica', 'Atraem eletricamente os prótons', 'Repelem os elétrons da eletrosfera', 'Não têm qualquer papel na estabilidade nuclear'], explanation = 'Os nêutrons não neutralizam a carga dos prótons, pois não têm carga. Eles participam da força nuclear forte entre os núcleons e, sem acrescentar repulsão elétrica, contribuem para a estabilidade do núcleo.'
 where id = '0048f8df-12e1-42b4-bb9f-679d1d0505b4';
update question_translations set options = array['Take part in the strong nuclear force that holds the nucleons together, without adding electric repulsion', 'Attract protons electrically', 'Repel the electrons in the electron cloud', 'Play no role in nuclear stability'], explanation = 'Neutrons do not neutralize the protons'' charge, since they have none. They take part in the strong nuclear force between nucleons and, without adding electric repulsion, contribute to the nucleus''s stability.'
 where question_id = '0048f8df-12e1-42b4-bb9f-679d1d0505b4' and locale = 'en';
update question_translations set options = array['Participan de la fuerza nuclear fuerte, que mantiene unidos a los nucleones, sin sumar repulsión eléctrica', 'Atraen eléctricamente a los protones', 'Repelen a los electrones de la corteza', 'No tienen ningún papel en la estabilidad nuclear'], explanation = 'Los neutrones no neutralizan la carga de los protones, pues no tienen carga. Participan de la fuerza nuclear fuerte entre los nucleones y, sin añadir repulsión eléctrica, contribuyen a la estabilidad del núcleo.'
 where question_id = '0048f8df-12e1-42b4-bb9f-679d1d0505b4' and locale = 'es';

-- hélio: seguro em balões não quer dizer seguro de inalar
update questions set explanation = 'O hélio é menos denso que o ar, quimicamente pouco reativo e não inflamável, por isso é usado em balões. Isso não significa que inalá-lo seja seguro.'
 where id = 'c80a3852-3335-4a4b-84d0-7c3b7725d005';
update question_translations set explanation = 'Helium is less dense than air, chemically unreactive and nonflammable, which is why it is used in balloons. That does not mean inhaling it is safe.'
 where question_id = 'c80a3852-3335-4a4b-84d0-7c3b7725d005' and locale = 'en';
update question_translations set explanation = 'El helio es menos denso que el aire, químicamente poco reactivo y no inflamable, por eso se usa en globos. Eso no significa que inhalarlo sea seguro.'
 where question_id = 'c80a3852-3335-4a4b-84d0-7c3b7725d005' and locale = 'es';

-- creme dental leva FLUORETO, não flúor elementar (o halogênio reativo)
update questions set prompt = 'Compostos com fluoreto são adicionados a muitos produtos de higiene bucal principalmente para:', explanation = 'Cremes dentais usam fluoretos, não o flúor elementar. Em concentração adequada, o íon fluoreto reduz a desmineralização e favorece a remineralização do esmalte, prevenindo cáries.'
 where id = '857ebce5-e6f1-48b5-8cf7-2c992b27c7e3';
update question_translations set prompt = 'Fluoride compounds are added to many oral hygiene products mainly because fluoride:', explanation = 'Toothpastes use fluorides, not elemental fluorine. At the right concentration, the fluoride ion reduces demineralization and promotes remineralization of the enamel, preventing cavities.'
 where question_id = '857ebce5-e6f1-48b5-8cf7-2c992b27c7e3' and locale = 'en';
update question_translations set prompt = 'Los compuestos con fluoruro se añaden a muchos productos de higiene bucal principalmente porque el fluoruro:', explanation = 'Las pastas dentales usan fluoruros, no flúor elemental. En la concentración adecuada, el ion fluoruro reduce la desmineralización y favorece la remineralización del esmalte, previniendo caries.'
 where question_id = '857ebce5-e6f1-48b5-8cf7-2c992b27c7e3' and locale = 'es';

-- octeto: regra útil com exceções importantes
update questions set explanation = 'A regra do octeto descreve a tendência de muitos átomos a alcançar oito elétrons de valência, como os gases nobres; há exceções importantes, como H, He, B e espécies hipervalentes.'
 where id = 'da85b405-37fa-417f-9191-2a9d5d5dd3d4';
update question_translations set explanation = 'The octet rule describes the tendency of many atoms to reach eight valence electrons, like the noble gases; there are important exceptions, such as H, He, B and hypervalent species.'
 where question_id = 'da85b405-37fa-417f-9191-2a9d5d5dd3d4' and locale = 'en';
update question_translations set explanation = 'La regla del octeto describe la tendencia de muchos átomos a alcanzar ocho electrones de valencia, como los gases nobles; hay excepciones importantes, como H, He, B y las especies hipervalentes.'
 where question_id = 'da85b405-37fa-417f-9191-2a9d5d5dd3d4' and locale = 'es';

-- pilhas: a composição varia; as alcalinas atuais quase não têm mercúrio
update questions set options = array['Metais e compostos tóxicos, como chumbo, cádmio ou mercúrio, conforme o tipo', 'Apenas água pura em sua composição', 'Substâncias totalmente biodegradáveis e inofensivas', 'Nenhum componente químico prejudicial'], explanation = 'A composição varia entre pilhas alcalinas, de chumbo-ácido, de níquel, de lítio e outras. O descarte inadequado pode liberar eletrólitos e metais tóxicos que contaminam o solo e os lençóis freáticos.'
 where id = '5e0815e0-52f2-4a18-824e-6f219a3b7260';
update question_translations set options = array['Toxic metals and compounds, such as lead, cadmium or mercury, depending on the type', 'Only pure water', 'Completely biodegradable, harmless substances', 'No harmful chemical components'], explanation = 'Composition varies among alkaline, lead-acid, nickel, lithium and other batteries. Improper disposal can release electrolytes and toxic metals that contaminate soil and groundwater.'
 where question_id = '5e0815e0-52f2-4a18-824e-6f219a3b7260' and locale = 'en';
update question_translations set options = array['Metales y compuestos tóxicos, como plomo, cadmio o mercurio, según el tipo', 'Solo agua pura en su composición', 'Sustancias totalmente biodegradables e inofensivas', 'Ningún componente químico perjudicial'], explanation = 'La composición varía entre pilas alcalinas, de plomo-ácido, de níquel, de litio y otras. El desecho inadecuado puede liberar electrolitos y metales tóxicos que contaminan el suelo y las aguas subterráneas.'
 where question_id = '5e0815e0-52f2-4a18-824e-6f219a3b7260' and locale = 'es';

-- Arrhenius: em água o H⁺ está como hidrônio
update questions set explanation = 'Segundo Arrhenius, ácidos em água liberam como único cátion o H⁺, que na solução está na forma de hidrônio (H₃O⁺); nos exercícios, costuma-se escrever só H⁺.'
 where id = 'a0dec77e-1717-4805-a318-d92e506f72ad';
update question_translations set explanation = 'According to Arrhenius, acids in water release H⁺ as their only cation, which in solution exists as hydronium (H₃O⁺); exercises usually write just H⁺.'
 where question_id = 'a0dec77e-1717-4805-a318-d92e506f72ad' and locale = 'en';
update question_translations set explanation = 'Según Arrhenius, los ácidos en agua liberan como único catión el H⁺, que en la solución está en forma de hidronio (H₃O⁺); en los ejercicios se suele escribir solo H⁺.'
 where question_id = 'a0dec77e-1717-4805-a318-d92e506f72ad' and locale = 'es';

-- ureia: carbonila com dois –NH₂, diamida do ácido carbônico
update questions set explanation = 'A ureia, CO(NH₂)₂, tem uma carbonila ligada a dois grupos –NH₂; por isso é classificada como diamida (do ácido carbônico) e também chamada de carbamida.'
 where id = '4196bf57-85ef-4f7e-9c16-27206c1d9c6e';
update question_translations set explanation = 'Urea, CO(NH₂)₂, has a carbonyl bonded to two –NH₂ groups; that is why it is classified as a diamide (of carbonic acid) and also called carbamide.'
 where question_id = '4196bf57-85ef-4f7e-9c16-27206c1d9c6e' and locale = 'en';
update question_translations set explanation = 'La urea, CO(NH₂)₂, tiene un carbonilo unido a dos grupos –NH₂; por eso se clasifica como diamida (del ácido carbónico) y también se llama carbamida.'
 where question_id = '4196bf57-85ef-4f7e-9c16-27206c1d9c6e' and locale = 'es';

-- éteres: a falta de O–H explica ponto de ebulição, não baixa reatividade
update questions set options = array['Terem ligações C–O estáveis e nenhum grupo funcional muito reativo', 'Serem extremamente instáveis', 'Possuírem carga elétrica elevada', 'Reagirem espontaneamente com qualquer substância'], explanation = 'Os éteres são pouco reativos em condições comuns porque as ligações C–O são estáveis e não há grupo muito reativo. A falta de O–H influi sobretudo nas propriedades físicas, como o ponto de ebulição, e não explica a baixa reatividade.'
 where id = '84cd6fd2-6c70-40b5-8a7d-d25ac10b01bd';
update question_translations set options = array['Having stable C–O bonds and no highly reactive functional group', 'Are extremely unstable', 'Carry a high electric charge', 'React spontaneously with any substance'], explanation = 'Ethers are not very reactive under ordinary conditions because their C–O bonds are stable and they have no highly reactive group. The lack of O–H mainly affects physical properties such as boiling point; it does not explain the low reactivity.'
 where question_id = '84cd6fd2-6c70-40b5-8a7d-d25ac10b01bd' and locale = 'en';
update question_translations set options = array['Tener enlaces C–O estables y ningún grupo funcional muy reactivo', 'Ser extremadamente inestables', 'Tener una carga eléctrica elevada', 'Reaccionar espontáneamente con cualquier sustancia'], explanation = 'Los éteres son poco reactivos en condiciones comunes porque los enlaces C–O son estables y no tienen ningún grupo muy reactivo. La falta de O–H influye sobre todo en las propiedades físicas, como el punto de ebullición, y no explica la baja reactividad.'
 where question_id = '84cd6fd2-6c70-40b5-8a7d-d25ac10b01bd' and locale = 'es';

-- fenol: o que o define é o –OH direto no anel (o álcool benzílico tem anel e é álcool)
update questions set prompt = 'Na nomenclatura e na classificação funcional, os fenóis se distinguem dos álcoois porque:', options = array['A hidroxila está ligada diretamente a um carbono do anel aromático', 'Não possuem qualquer grupo hidroxila em sua estrutura', 'São sempre gasosos à temperatura ambiente', 'Não podem ser sintetizados em laboratório'], explanation = 'Nos fenóis, o –OH está ligado diretamente a um carbono aromático; por isso eles têm propriedades e nomenclatura próprias. Um –OH ligado a carbono saturado, mesmo com anel na molécula, é álcool.'
 where id = '829cc26c-4231-46ed-a74e-60c5711f3def';
update question_translations set prompt = 'In nomenclature and functional classification, phenols differ from alcohols because:', options = array['The hydroxyl is bonded directly to a carbon of the aromatic ring', 'They have no hydroxyl group in their structure', 'They are always gaseous at room temperature', 'They cannot be synthesized in the laboratory'], explanation = 'In phenols the –OH is bonded directly to an aromatic carbon, which gives them their own properties and nomenclature. An –OH bonded to a saturated carbon is an alcohol, even if the molecule has a ring.'
 where question_id = '829cc26c-4231-46ed-a74e-60c5711f3def' and locale = 'en';
update question_translations set prompt = 'En la nomenclatura y la clasificación funcional, los fenoles se distinguen de los alcoholes porque:', options = array['El hidroxilo está unido directamente a un carbono del anillo aromático', 'No tienen ningún grupo hidroxilo en su estructura', 'Son siempre gaseosos a temperatura ambiente', 'No pueden sintetizarse en el laboratorio'], explanation = 'En los fenoles, el –OH está unido directamente a un carbono aromático; por eso tienen propiedades y nomenclatura propias. Un –OH unido a un carbono saturado, aunque la molécula tenga un anillo, es alcohol.'
 where question_id = '829cc26c-4231-46ed-a74e-60c5711f3def' and locale = 'es';

-- isomeria óptica: há moléculas quirais sem carbono assimétrico
update questions set explanation = 'O carbono quiral, ligado a quatro substituintes diferentes, é a causa mais comum de isomeria óptica no ensino médio; ainda assim, existem moléculas quirais sem carbono assimétrico.'
 where id = '13da8b1d-521d-42a7-804f-4dabf8fe2037';
update question_translations set explanation = 'A chiral carbon, bonded to four different substituents, is the most common cause of optical isomerism in high school chemistry; still, some chiral molecules have no asymmetric carbon.'
 where question_id = '13da8b1d-521d-42a7-804f-4dabf8fe2037' and locale = 'en';
update question_translations set explanation = 'El carbono quiral, unido a cuatro sustituyentes diferentes, es la causa más común de isomería óptica en la secundaria; aun así, existen moléculas quirales sin carbono asimétrico.'
 where question_id = '13da8b1d-521d-42a7-804f-4dabf8fe2037' and locale = 'es';

-- biodegradável depende das condições do ambiente
update questions set explanation = 'Polímeros biodegradáveis podem ser decompostos por microrganismos em condições adequadas. A velocidade depende do material e do ambiente: "biodegradável" não quer dizer que some rápido em qualquer lugar.'
 where id = '54006ef8-6f3a-4509-8a6e-3577442fbf48';
update question_translations set explanation = 'Biodegradable polymers can be broken down by microorganisms under suitable conditions. The speed depends on the material and the environment: "biodegradable" does not mean it disappears quickly anywhere.'
 where question_id = '54006ef8-6f3a-4509-8a6e-3577442fbf48' and locale = 'en';
update question_translations set explanation = 'Los polímeros biodegradables pueden ser descompuestos por microorganismos en condiciones adecuadas. La velocidad depende del material y del ambiente: "biodegradable" no quiere decir que desaparezca rápido en cualquier lugar.'
 where question_id = '54006ef8-6f3a-4509-8a6e-3577442fbf48' and locale = 'es';

-- isotônicas: vale a concentração EFETIVA de partículas
update questions set explanation = 'Soluções isotônicas têm a mesma pressão osmótica. Mesma concentração molar de soluto só garante isso quando o número efetivo de partículas dissolvidas também é o mesmo (1 mol de NaCl gera cerca de 2 mol de íons).'
 where id = '8770435a-cc5c-43ac-86a2-68b550a07f66';
update question_translations set explanation = 'Isotonic solutions have the same osmotic pressure. The same molar concentration of solute only guarantees this when the effective number of dissolved particles is also the same (1 mol of NaCl yields about 2 mol of ions).'
 where question_id = '8770435a-cc5c-43ac-86a2-68b550a07f66' and locale = 'en';
update question_translations set explanation = 'Las soluciones isotónicas tienen la misma presión osmótica. La misma concentración molar de soluto solo lo garantiza cuando el número efectivo de partículas disueltas también es el mismo (1 mol de NaCl genera cerca de 2 mol de iones).'
 where question_id = '8770435a-cc5c-43ac-86a2-68b550a07f66' and locale = 'es';

-- saturada: o limite depende da temperatura e, para gases, da pressão
update questions set explanation = 'Na saturação, a solução atinge o limite de solubilidade do soluto nas condições dadas. A temperatura é decisiva, e para gases a pressão também conta.'
 where id = 'ac8d8444-81c5-4ec6-acc2-126acaf2f4a3';
update question_translations set explanation = 'At saturation, the solution reaches the solubility limit of the solute under the given conditions. Temperature is decisive, and for gases pressure matters too.'
 where question_id = 'ac8d8444-81c5-4ec6-acc2-126acaf2f4a3' and locale = 'en';
update question_translations set explanation = 'En la saturación, la solución alcanza el límite de solubilidad del soluto en las condiciones dadas. La temperatura es decisiva, y para los gases la presión también cuenta.'
 where question_id = 'ac8d8444-81c5-4ec6-acc2-126acaf2f4a3' and locale = 'es';
