-- Filosofia: 6 correções aceitas da revisão externa (2026-09-30)
--
-- Nenhum gabarito estava errado. São ganhos de precisão: o meio-termo
-- aristotélico é relativo a nós, não média aritmética; Hobbes não faz o
-- indivíduo abrir mão da autoconservação; "o homem nasce bom, a sociedade o
-- corrompe" é síntese de Rousseau, não citação; Diógenes vivia num pithos,
-- não num barril; o eterno retorno como teste é uma leitura entre outras; e
-- a responsabilidade moral admite graus.
--
-- Recusadas 3 (ver o relatório da revisão): alternativas certas reescritas
-- que ficariam bem mais longas que os distratores, entregando a resposta, e
-- explicações que perdiam informação (os três tipos de ideia em Descartes).
--
-- Só o texto muda: a ORDEM das alternativas é preservada, para o gabarito
-- não se mexer e as traduções seguirem alinhadas por posição. Cada
-- update grava o valor final inteiro, então rodar de novo não muda nada.

-- responsabilidade moral: consciência e liberdade em grau, não tudo ou nada
update questions set explanation = 'Atribuir responsabilidade moral normalmente pressupõe algum grau de consciência e liberdade de escolha; coerção ou ignorância relevante podem reduzir a responsabilidade.'
 where id = '7cc71b4b-aef7-5cc1-8d79-bad285150493';
update question_translations set explanation = 'Attributing moral responsibility usually presupposes some degree of awareness and freedom of choice; coercion or relevant ignorance can reduce responsibility.'
 where question_id = '7cc71b4b-aef7-5cc1-8d79-bad285150493' and locale = 'en';
update question_translations set explanation = 'Atribuir responsabilidad moral suele presuponer cierto grado de conciencia y libertad de elección; la coacción o una ignorancia relevante pueden reducir la responsabilidad.'
 where question_id = '7cc71b4b-aef7-5cc1-8d79-bad285150493' and locale = 'es';

-- Aristóteles: o meio-termo é relativo a nós, não média aritmética
update questions set explanation = 'Para Aristóteles, a virtude moral é um meio-termo relativo a nós entre excesso e falta, determinado pela razão, e não uma média aritmética: a coragem fica entre a covardia e a temeridade.'
 where id = '8abf746a-6516-5de5-a76c-5076713fe5c7';
update question_translations set explanation = 'For Aristotle, moral virtue is a mean relative to us between excess and deficiency, determined by reason, not an arithmetic average: courage lies between cowardice and rashness.'
 where question_id = '8abf746a-6516-5de5-a76c-5076713fe5c7' and locale = 'en';
update question_translations set explanation = 'Para Aristóteles, la virtud moral es un término medio relativo a nosotros entre el exceso y el defecto, determinado por la razón, y no una media aritmética: el coraje está entre la cobardía y la temeridad.'
 where question_id = '8abf746a-6516-5de5-a76c-5076713fe5c7' and locale = 'es';

-- eterno retorno: a leitura como teste é uma entre outras
update questions set prompt = 'Em uma interpretação frequente do eterno retorno em Nietzsche, a ideia funciona como um teste que pergunta:', explanation = 'Nessa leitura, imaginar a repetição infinita da própria vida é uma prova de afirmação da existência, embora o conceito admita outras interpretações.'
 where id = '336986fe-0150-5c54-a6dc-c750576a6dbe';
update question_translations set prompt = 'In a common reading of Nietzsche''s eternal recurrence, the idea works as a test that asks:', explanation = 'On this reading, imagining your own life repeating endlessly is a test of affirming existence, although the concept admits other interpretations.'
 where question_id = '336986fe-0150-5c54-a6dc-c750576a6dbe' and locale = 'en';
update question_translations set prompt = 'En una interpretación frecuente del eterno retorno en Nietzsche, la idea funciona como una prueba que pregunta:', explanation = 'En esa lectura, imaginar la repetición infinita de la propia vida es una prueba de afirmación de la existencia, aunque el concepto admite otras interpretaciones.'
 where question_id = '336986fe-0150-5c54-a6dc-c750576a6dbe' and locale = 'es';

-- Hobbes: o direito de autoconservação não é transferido
update questions set explanation = 'Para Hobbes, os indivíduos autorizam um soberano forte para sair da insegurança do estado de natureza, a guerra de todos contra todos. O direito de autoconservação, porém, não é abandonado.'
 where id = '7f8ce014-2db2-5060-bab0-82de54395b19';
update question_translations set explanation = 'For Hobbes, individuals authorize a strong sovereign to escape the insecurity of the state of nature, the war of all against all. The right of self-preservation, however, is not given up.'
 where question_id = '7f8ce014-2db2-5060-bab0-82de54395b19' and locale = 'en';
update question_translations set explanation = 'Para Hobbes, los individuos autorizan a un soberano fuerte para salir de la inseguridad del estado de naturaleza, la guerra de todos contra todos. El derecho a la autoconservación, sin embargo, no se abandona.'
 where question_id = '7f8ce014-2db2-5060-bab0-82de54395b19' and locale = 'es';

-- Rousseau: a frase é síntese, não citação
update questions set prompt = 'A ideia de que o ser humano é bom por natureza, mas pode ser corrompido pelas relações sociais, é associada a:', explanation = 'Rousseau sustenta que os seres humanos são bons por natureza e que formas de vida social, como a propriedade e a desigualdade, podem corrompê-los. "O homem nasce bom, a sociedade o corrompe" é uma síntese de seu pensamento, não uma citação literal.'
 where id = '4e032cfc-14a4-5262-a61b-fe778b8b784c';
update question_translations set prompt = 'The idea that human beings are good by nature but can be corrupted by social relations is associated with:', explanation = 'Rousseau holds that human beings are good by nature and that forms of social life, such as property and inequality, can corrupt them. "Man is born good, society corrupts him" is a summary of his thought, not a literal quotation.'
 where question_id = '4e032cfc-14a4-5262-a61b-fe778b8b784c' and locale = 'en';
update question_translations set prompt = 'La idea de que el ser humano es bueno por naturaleza, pero puede ser corrompido por las relaciones sociales, se asocia a:', explanation = 'Rousseau sostiene que los seres humanos son buenos por naturaleza y que ciertas formas de vida social, como la propiedad y la desigualdad, pueden corromperlos. "El hombre nace bueno, la sociedad lo corrompe" es una síntesis de su pensamiento, no una cita literal.'
 where question_id = '4e032cfc-14a4-5262-a61b-fe778b8b784c' and locale = 'es';

-- Diógenes: era um pithos (jarro de cerâmica), não um barril
update questions set prompt = 'Diógenes de Sínope, conhecido por levar uma vida extremamente simples e por se abrigar em um grande jarro de cerâmica, pertencia à escola:', explanation = 'Os cínicos defendiam uma vida simples, segundo a natureza, rejeitando riquezas e convenções. A tradição antiga associa Diógenes a um pithos, um grande jarro de cerâmica; o "barril" é uma simplificação posterior.'
 where id = 'c7046610-83cf-5a9e-bd58-84c78900a0a6';
update question_translations set prompt = 'Diogenes of Sinope, known for living an extremely simple life and sheltering in a large ceramic jar, belonged to the school of the:', explanation = 'The Cynics advocated a simple life according to nature, rejecting wealth and conventions. Ancient tradition links Diogenes to a pithos, a large ceramic jar; the "barrel" is a later simplification.'
 where question_id = 'c7046610-83cf-5a9e-bd58-84c78900a0a6' and locale = 'en';
update question_translations set prompt = 'Diógenes de Sinope, conocido por llevar una vida extremadamente sencilla y por refugiarse en una gran tinaja de cerámica, pertenecía a la escuela:', explanation = 'Los cínicos defendían una vida sencilla, según la naturaleza, rechazando riquezas y convenciones. La tradición antigua asocia a Diógenes con un pithos, una gran tinaja de cerámica; el "barril" es una simplificación posterior.'
 where question_id = 'c7046610-83cf-5a9e-bd58-84c78900a0a6' and locale = 'es';
