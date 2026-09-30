-- Biologia: 7 correções aceitas da revisão externa (2026-09-30)
--
-- Nenhum gabarito estava apontando alternativa errada. São correções de
-- conteúdo: decompositores não ficam "ao final" da cadeia; característica
-- não é sinônimo de locus; sem dizer "linhagem pura" a F1 de Mendel não
-- está garantida; a definição de gene deixava de fora os genes de RNA
-- funcional; a de vacina não cobria vacinas de mRNA; mutualismo
-- obrigatório basta ser obrigatório para uma das espécies; e a afirmação
-- de que teia complexa é sempre mais estável não se sustenta.
--
-- Só o texto muda: a ORDEM das alternativas é preservada, para o gabarito
-- não se mexer e as traduções seguirem alinhadas por posição.
--
-- Idempotente: rodar de novo escreve o mesmo valor.

update questions set options[1] = 'Apresentar ao sistema imune antígenos ou instruções para produzi-los, induzindo resposta e memória imunológica'
 where id = 'e5eb81ef-8e0a-4425-a60e-1aabdd335591';
update questions set explanation = 'Vacinas expõem o sistema imune a antígenos ou às instruções para produzi-los, gerando resposta específica e memória imunológica.'
 where id = 'e5eb81ef-8e0a-4425-a60e-1aabdd335591';
update question_translations set options[1] = 'Presenting the immune system with antigens, or the instructions to make them, prompting a response and immune memory', explanation = 'Vaccines expose the immune system to antigens, or to the instructions to make them, producing a specific response and immune memory.'
 where question_id = 'e5eb81ef-8e0a-4425-a60e-1aabdd335591' and locale = 'en';
update question_translations set options[1] = 'Presentar al sistema inmune antígenos o las instrucciones para producirlos, induciendo respuesta y memoria inmunitaria', explanation = 'Las vacunas exponen al sistema inmune a antígenos o a las instrucciones para producirlos, generando respuesta específica y memoria inmunitaria.'
 where question_id = 'e5eb81ef-8e0a-4425-a60e-1aabdd335591' and locale = 'es';

update questions set prompt = 'Os decompositores atuam sobre matéria orgânica de diferentes níveis tróficos e desempenham papel fundamental ao:'
 where id = '0e91bf38-d9c5-4f80-86eb-a2e3fbd7c236';
update questions set explanation = 'Fungos e bactérias decompositoras degradam matéria orgânica morta vinda de qualquer nível trófico, devolvendo nutrientes ao ambiente.'
 where id = '0e91bf38-d9c5-4f80-86eb-a2e3fbd7c236';
update question_translations set prompt = 'Decomposers act on organic matter from different trophic levels and play a fundamental role by:', explanation = 'Decomposing fungi and bacteria break down dead organic matter from any trophic level, returning nutrients to the environment.'
 where question_id = '0e91bf38-d9c5-4f80-86eb-a2e3fbd7c236' and locale = 'en';
update question_translations set prompt = 'Los descomponedores actúan sobre materia orgánica de distintos niveles tróficos y desempeñan un papel fundamental al:', explanation = 'Los hongos y las bacterias descomponedoras degradan materia orgánica muerta de cualquier nivel trófico y devuelven nutrientes al ambiente.'
 where question_id = '0e91bf38-d9c5-4f80-86eb-a2e3fbd7c236' and locale = 'es';

update questions set prompt = 'Em muitos ecossistemas, uma teia alimentar com múltiplas conexões pode contribuir para:'
 where id = '53229dab-70cb-4c80-a98a-3c6800bf929e';
update questions set options[1] = 'Maior resiliência a algumas perturbações, por oferecer rotas alternativas de fluxo de energia'
 where id = '53229dab-70cb-4c80-a98a-3c6800bf929e';
update questions set explanation = 'A redundância de interações pode aumentar a resiliência, mas a relação entre complexidade e estabilidade não é uma regra universal.'
 where id = '53229dab-70cb-4c80-a98a-3c6800bf929e';
update question_translations set prompt = 'In many ecosystems, a food web with multiple connections can contribute to:', options[1] = 'Greater resilience to some disturbances, by offering alternative routes for energy flow', explanation = 'Redundant interactions can raise resilience, but the link between complexity and stability is not a universal rule.'
 where question_id = '53229dab-70cb-4c80-a98a-3c6800bf929e' and locale = 'en';
update question_translations set prompt = 'En muchos ecosistemas, una red trófica con múltiples conexiones puede contribuir a:', options[1] = 'Mayor resiliencia ante algunas perturbaciones, al ofrecer rutas alternativas de flujo de energía', explanation = 'La redundancia de interacciones puede aumentar la resiliencia, pero la relación entre complejidad y estabilidad no es una regla universal.'
 where question_id = '53229dab-70cb-4c80-a98a-3c6800bf929e' and locale = 'es';

update questions set options[1] = 'Dependem da interação — ao menos uma delas — para sobreviver ou completar o ciclo de vida'
 where id = '3056a2c7-7a88-4357-8f63-94be74249ded';
update questions set explanation = 'No mutualismo obrigatório a associação é indispensável para pelo menos um dos parceiros; é isso que o separa do facultativo.'
 where id = '3056a2c7-7a88-4357-8f63-94be74249ded';
update question_translations set options[1] = 'Depend on the interaction — at least one of them — to survive or complete their life cycle', explanation = 'In obligate mutualism the association is indispensable for at least one partner; that is what separates it from the facultative kind.'
 where question_id = '3056a2c7-7a88-4357-8f63-94be74249ded' and locale = 'en';
update question_translations set options[1] = 'Dependen de la interacción — al menos una de ellas — para sobrevivir o completar su ciclo de vida', explanation = 'En el mutualismo obligado la asociación es indispensable para al menos uno de los socios; eso lo separa del facultativo.'
 where question_id = '3056a2c7-7a88-4357-8f63-94be74249ded' and locale = 'es';

update questions set prompt = 'Em um organismo diploide, como o ser humano, para um determinado locus autossômico, um indivíduo geralmente possui:'
 where id = 'a7951f74-503a-4e07-bd76-89b944daea59';
update questions set explanation = 'Em organismos diploides cada locus autossômico está presente em dois cromossomos homólogos, o que dá dois alelos por indivíduo.'
 where id = 'a7951f74-503a-4e07-bd76-89b944daea59';
update question_translations set prompt = 'In a diploid organism such as a human, for a given autosomal locus, an individual usually has:', explanation = 'In diploid organisms each autosomal locus sits on two homologous chromosomes, which gives the individual two alleles.'
 where question_id = 'a7951f74-503a-4e07-bd76-89b944daea59' and locale = 'en';
update question_translations set prompt = 'En un organismo diploide, como el ser humano, para un determinado locus autosómico, un individuo suele tener:', explanation = 'En organismos diploides cada locus autosómico está en dos cromosomas homólogos, lo que da dos alelos por individuo.'
 where question_id = 'a7951f74-503a-4e07-bd76-89b944daea59' and locale = 'es';

update questions set options[1] = 'Um segmento de DNA cuja informação dá origem a um produto funcional, como um RNA ou uma proteína'
 where id = '57548181-13cf-4521-8d4b-4dacbbe8e2e9';
update questions set explanation = 'Gene é uma região do DNA cuja informação é usada para produzir um RNA funcional e, em muitos casos, uma proteína.'
 where id = '57548181-13cf-4521-8d4b-4dacbbe8e2e9';
update question_translations set options[1] = 'A segment of DNA whose information gives rise to a functional product, such as an RNA or a protein', explanation = 'A gene is a region of DNA whose information is used to make a functional RNA and, in many cases, a protein.'
 where question_id = '57548181-13cf-4521-8d4b-4dacbbe8e2e9' and locale = 'en';
update question_translations set options[1] = 'Un segmento de ADN cuya información da origen a un producto funcional, como un ARN o una proteína', explanation = 'Un gen es una región del ADN cuya información se usa para producir un ARN funcional y, en muchos casos, una proteína.'
 where question_id = '57548181-13cf-4521-8d4b-4dacbbe8e2e9' and locale = 'es';

update questions set prompt = 'No experimento clássico de Mendel com ervilhas, ao cruzar uma linhagem pura de sementes lisas com uma linhagem pura de sementes rugosas, a geração F1 apresentou:'
 where id = 'ff4c89c2-858f-4861-94ea-0f5d0b0afbfe';
update questions set explanation = 'No cruzamento entre linhagens puras AA × aa toda a geração F1 é heterozigota e mostra o fenótipo dominante: sementes lisas.'
 where id = 'ff4c89c2-858f-4861-94ea-0f5d0b0afbfe';
update question_translations set prompt = 'In Mendel''s classic pea experiment, crossing a pure line of smooth seeds with a pure line of wrinkled seeds, the F1 generation showed:', explanation = 'In a cross between pure lines AA × aa the whole F1 generation is heterozygous and shows the dominant phenotype: smooth seeds.'
 where question_id = 'ff4c89c2-858f-4861-94ea-0f5d0b0afbfe' and locale = 'en';
update question_translations set prompt = 'En el experimento clásico de Mendel con guisantes, al cruzar una línea pura de semillas lisas con una línea pura de semillas rugosas, la generación F1 presentó:', explanation = 'En el cruce entre líneas puras AA × aa toda la generación F1 es heterocigota y muestra el fenotipo dominante: semillas lisas.'
 where question_id = 'ff4c89c2-858f-4861-94ea-0f5d0b0afbfe' and locale = 'es';

