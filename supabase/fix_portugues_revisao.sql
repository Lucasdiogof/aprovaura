-- Português: 6 correções aceitas da revisão externa (2026-09-30)
--
-- Nenhum gabarito deslocado. A de "visar" tinha duas respostas defensáveis:
-- "visa melhorar", sem preposição, também é aceito no uso culto atual; agora o
-- enunciado pede a regência da tradição normativa escolar. A de argumento de
-- autoridade atribuía à OMS uma afirmação que ela não faz nesses termos. O resto
-- é precisão (crase com nome próprio, Competência 5 do Enem, repertório).
--
-- Recusadas: a reescrita da crase facultativa (o "à à" é distrator de propósito)
-- e alternativas certas alongadas nas questões de Redação e Barroco.
-- Português não tem fonte: vive só no banco.
--
-- Só o texto muda: a ORDEM das alternativas é preservada, para o gabarito
-- não se mexer e as traduções seguirem alinhadas por posição. Cada
-- update grava o valor final inteiro, então rodar de novo não muda nada.

-- crase e nome próprio: "em geral não leva artigo" não vale para todo o país
update questions set explanation = 'Com o nome próprio empregado sem artigo, há só a preposição "a", sem crase: "a Maria". Onde o uso admite o artigo, "à Maria" também ocorre.'
 where id = '01ba7740-19dd-4b77-8935-d4fbabf26f41';
update question_translations set explanation = 'With the proper name used without an article, there is only the preposition "a", with no crase: "a Maria". Where usage allows the article, "à Maria" also occurs.'
 where question_id = '01ba7740-19dd-4b77-8935-d4fbabf26f41' and locale = 'en';
update question_translations set explanation = 'Con el nombre propio usado sin artículo, solo hay la preposición "a", sin crasis: "a Maria". Donde el uso admite el artículo, "à Maria" también aparece.'
 where question_id = '01ba7740-19dd-4b77-8935-d4fbabf26f41' and locale = 'es';

-- "visa melhorar" também é aceito no uso culto: a questão passa a pedir a regência da tradição normativa
update questions set prompt = 'Na tradição normativa escolar, assinale a alternativa em que o verbo "visar", no sentido de "ter como objetivo", aparece com a regência esperada:', explanation = 'Na tradição normativa escolar, "visar", no sentido de "ter como objetivo", rege a preposição "a": "visa a melhorar". No uso culto contemporâneo, a construção sem preposição também é encontrada.'
 where id = '025545b1-e267-490e-a1b1-6595f6899e6c';
update question_translations set prompt = 'In the traditional school grammar of Portuguese, choose the option in which the verb "visar", meaning "to aim at", has the expected government:', explanation = 'In traditional school grammar, "visar" meaning "to have as a goal" takes the preposition "a": "visa a melhorar". In contemporary educated usage, the construction without the preposition is also found.'
 where question_id = '025545b1-e267-490e-a1b1-6595f6899e6c' and locale = 'en';
update question_translations set prompt = 'En la tradición normativa escolar del portugués, señala la alternativa en la que el verbo "visar", en el sentido de "tener como objetivo", aparece con el régimen esperado:', explanation = 'En la tradición normativa escolar, "visar", en el sentido de "tener como objetivo", rige la preposición "a": "visa a melhorar". En el uso culto contemporáneo también se encuentra la construcción sin preposición.'
 where question_id = '025545b1-e267-490e-a1b1-6595f6899e6c' and locale = 'es';

-- argumento de autoridade: tira a afirmação atribuída à OMS, que ela não faz nesses termos
update questions set prompt = 'Leia: "Segundo uma instituição de pesquisa em saúde, estudos associam a privação crônica de sono a maior risco de problemas cardiovasculares; portanto, o sono deve ser tratado como questão de saúde pública." O autor sustenta sua tese principalmente por meio de:', explanation = 'A tese se apoia na autoridade de uma instituição de pesquisa e nos estudos que ela cita, o que caracteriza o argumento de autoridade. Não há relato pessoal, comparação nem apelo à emoção.'
 where id = '7e966574-fdbc-5139-ae32-893e90d86d92';
update question_translations set prompt = 'Read: "According to a health research institution, studies link chronic sleep deprivation to a higher risk of cardiovascular problems; therefore, sleep should be treated as a public health issue." The author supports the thesis mainly through:', explanation = 'The thesis rests on the authority of a research institution and the studies it cites, which is an argument from authority. There is no personal account, comparison or appeal to emotion.'
 where question_id = '7e966574-fdbc-5139-ae32-893e90d86d92' and locale = 'en';
update question_translations set prompt = 'Lee: "Según una institución de investigación en salud, los estudios asocian la privación crónica de sueño a un mayor riesgo de problemas cardiovasculares; por lo tanto, el sueño debe tratarse como una cuestión de salud pública." El autor sostiene su tesis principalmente mediante:', explanation = 'La tesis se apoya en la autoridad de una institución de investigación y en los estudios que cita, lo que caracteriza el argumento de autoridad. No hay relato personal, comparación ni llamado a la emoción.'
 where question_id = '7e966574-fdbc-5139-ae32-893e90d86d92' and locale = 'es';

-- Enem: a exigência é ponto de vista, argumentos e proposta; a divisão em partes é o jeito usual
update questions set explanation = 'O Enem exige um texto dissertativo-argumentativo com ponto de vista, argumentos coerentes e proposta de intervenção. A organização em introdução, desenvolvimento e conclusão é a forma usual de estruturar esses elementos.'
 where id = '9e3960af-d959-4368-b928-c5eca86f9e03';
update question_translations set explanation = 'The Enem requires an argumentative text with a point of view, coherent arguments and an intervention proposal. Organizing it into introduction, body and conclusion is the usual way to structure these elements.'
 where question_id = '9e3960af-d959-4368-b928-c5eca86f9e03' and locale = 'en';
update question_translations set explanation = 'El Enem exige un texto argumentativo con punto de vista, argumentos coherentes y propuesta de intervención. La organización en introducción, desarrollo y conclusión es la forma habitual de estructurar esos elementos.'
 where question_id = '9e3960af-d959-4368-b928-c5eca86f9e03' and locale = 'es';

-- proposta de intervenção: os cinco elementos da Competência 5
update questions set explanation = 'Na Competência 5, a proposta completa traz ação, agente, modo ou meio, efeito e detalhamento, ligados ao problema discutido e respeitando os direitos humanos.'
 where id = '7af25067-d50c-4c3d-aba1-c8c744ae7789';
update question_translations set explanation = 'Under Competency 5, a complete proposal states action, agent, means, effect and detail, tied to the problem discussed and respecting human rights.'
 where question_id = '7af25067-d50c-4c3d-aba1-c8c744ae7789' and locale = 'en';
update question_translations set explanation = 'En la Competencia 5, la propuesta completa presenta acción, agente, modo o medio, efecto y detalle, vinculados al problema discutido y respetando los derechos humanos.'
 where question_id = '7af25067-d50c-4c3d-aba1-c8c744ae7789' and locale = 'es';

-- repertório: conta quando é pertinente e bem articulado
update questions set explanation = 'Repertório sociocultural é conhecimento externo aos textos motivadores (histórico, científico, filosófico, cultural) que, quando pertinente e bem articulado, sustenta a argumentação.'
 where id = '40a07164-d836-4e49-97fe-cb5d9ce700a7';
update question_translations set explanation = 'Sociocultural repertoire is knowledge from outside the prompt texts (historical, scientific, philosophical, cultural) that, when relevant and well connected, supports the argumentation.'
 where question_id = '40a07164-d836-4e49-97fe-cb5d9ce700a7' and locale = 'en';
update question_translations set explanation = 'El repertorio sociocultural es conocimiento externo a los textos motivadores (histórico, científico, filosófico, cultural) que, cuando es pertinente y está bien articulado, sostiene la argumentación.'
 where question_id = '40a07164-d836-4e49-97fe-cb5d9ce700a7' and locale = 'es';
