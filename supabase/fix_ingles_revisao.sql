-- Inglês: 2 correções aceitas da revisão externa (2026-09-30)
--
-- A Austrália não define idioma oficial em lei federal, então a pergunta
-- "tem o inglês como idioma oficial" não se sustentava. Na Nova Zelândia, a
-- English Language Act (sancionada em 6/8/2026) tornou o inglês oficial ao
-- lado do māori e da Língua de Sinais: "qual outro idioma é oficial" passou
-- a ter duas respostas, e a pergunta agora pede a língua indígena.
--
-- Os gabaritos de Inglês estão em fix_gabarito_espanhol_ingles.sql.
--
-- Só o texto muda: a ORDEM das alternativas é preservada, para o gabarito
-- não se mexer e as traduções seguirem alinhadas por posição. Cada
-- update grava o valor final inteiro, então rodar de novo não muda nada.

-- Nova Zelândia: desde a lei de 2026 há três línguas oficiais; a pergunta passa a pedir a indígena
update questions set prompt = 'Na Nova Zelândia, além do inglês, qual língua indígena tem status oficial?', explanation = 'O te reo Māori é língua oficial da Nova Zelândia. Desde agosto de 2026, o inglês também tem esse status expresso em lei, e a Língua de Sinais da Nova Zelândia é igualmente oficial.'
 where id = '1dab01c8-2fa7-596b-965c-5736786c5644';
update question_translations set prompt = 'In New Zealand, besides English, which Indigenous language has official status?', explanation = 'Te reo Māori is an official language of New Zealand. Since August 2026 English has also had that status set out in law, and New Zealand Sign Language is official as well.'
 where question_id = '1dab01c8-2fa7-596b-965c-5736786c5644' and locale = 'en';
update question_translations set prompt = 'En Nueva Zelanda, además del inglés, ¿qué lengua indígena tiene estatus oficial?', explanation = 'El te reo māori es lengua oficial de Nueva Zelanda. Desde agosto de 2026, el inglés también tiene ese estatus fijado por ley, y la Lengua de Señas de Nueva Zelanda es igualmente oficial.'
 where question_id = '1dab01c8-2fa7-596b-965c-5736786c5644' and locale = 'es';

-- Austrália não tem idioma oficial em lei federal
update questions set prompt = 'Em qual destes países o inglês é a língua nacional de fato, embora não haja idioma oficial definido em lei federal?', explanation = 'Na Austrália, o inglês é a língua nacional de fato, mas o país não estabelece um idioma oficial em nível federal.'
 where id = 'a7e7565d-8f84-5eb5-9ec7-b92917df691e';
update question_translations set prompt = 'In which of these countries is English the de facto national language, although no official language is set in federal law?', explanation = 'In Australia, English is the de facto national language, but the country sets no official language at the federal level.'
 where question_id = 'a7e7565d-8f84-5eb5-9ec7-b92917df691e' and locale = 'en';
update question_translations set prompt = '¿En cuál de estos países el inglés es la lengua nacional de facto, aunque no haya un idioma oficial definido por ley federal?', explanation = 'En Australia, el inglés es la lengua nacional de facto, pero el país no establece un idioma oficial a nivel federal.'
 where question_id = 'a7e7565d-8f84-5eb5-9ec7-b92917df691e' and locale = 'es';
