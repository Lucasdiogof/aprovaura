-- Desambigua 16 questoes de Portugues com enunciado generico
--
-- Seis enunciados ("Assinale a alternativa correta quanto a regencia
-- verbal:") serviam a duas ou tres questoes diferentes, e o aluno via a
-- mesma pergunta voltar com outras alternativas. Outras duas tinham
-- enunciado distinto em portugues ("esta de acordo com a norma-padrao" e
-- "segue a norma-padrao") mas caiam na mesma traducao em en e es. Cada enunciado passa a
-- nomear a palavra cobrada, o que tambem diz o que se testa ali sem
-- entregar a resposta: o erro das outras alternativas continua sendo a
-- preposicao ou a flexao.
--
-- So o enunciado muda. Alternativas, gabarito e explicacao ficam como
-- estao, e o id nao deriva do prompt nestas questoes (seed antigo).
--
-- Idempotente: rodar de novo escreve o mesmo valor.

update questions set prompt = 'Assinale a alternativa em que "anexo" concorda corretamente com "certidões":'
 where id = '0be6745e-fedb-4ad7-b39c-0ebc29348acd';
update question_translations set prompt = 'Choose the option in which "anexo" correctly agrees with "certidões" in Portuguese:'
 where question_id = '0be6745e-fedb-4ad7-b39c-0ebc29348acd' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa en la que "anexo" concuerda correctamente con "certidões" en portugués:'
 where question_id = '0be6745e-fedb-4ad7-b39c-0ebc29348acd' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a construção com "se" e o verbo "precisar" está correta:'
 where id = '25a6dd51-0578-4e0b-b415-8bf308866093';
update question_translations set prompt = 'Choose the option in which the Portuguese construction with "se" and the verb "precisar" is correct:'
 where question_id = '25a6dd51-0578-4e0b-b415-8bf308866093' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa en la que la construcción portuguesa con "se" y el verbo "precisar" es correcta:'
 where question_id = '25a6dd51-0578-4e0b-b415-8bf308866093' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que "anexo" concorda corretamente com "comprovante":'
 where id = '351990dd-0be0-49b9-a158-d27ca2772538';
update question_translations set prompt = 'Choose the option in which "anexo" correctly agrees with "comprovante" in Portuguese:'
 where question_id = '351990dd-0be0-49b9-a158-d27ca2772538' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa en la que "anexo" concuerda correctamente con "comprovante" en portugués:'
 where question_id = '351990dd-0be0-49b9-a158-d27ca2772538' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que o adjetivo concorda corretamente com o substantivo "trabalho":'
 where id = '3718d4a6-077a-4ab2-ba43-9933bcd5a277';
update question_translations set prompt = 'Choose the option in which the adjective correctly agrees with the noun "trabalho" in Portuguese:'
 where question_id = '3718d4a6-077a-4ab2-ba43-9933bcd5a277' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa en la que el adjetivo concuerda correctamente con el sustantivo "trabalho" en portugués:'
 where question_id = '3718d4a6-077a-4ab2-ba43-9933bcd5a277' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a preposição exigida pelo substantivo "necessidade" está correta:'
 where id = '42607522-9914-48b9-a71e-1d12f2868148';
update question_translations set prompt = 'Choose the option with the preposition required by the Portuguese noun "necessidade":'
 where question_id = '42607522-9914-48b9-a71e-1d12f2868148' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa con la preposición que exige el sustantivo portugués "necessidade":'
 where question_id = '42607522-9914-48b9-a71e-1d12f2868148' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a preposição exigida pelo adjetivo "grato" está correta:'
 where id = '51c103f1-2d63-42de-86e7-fc038e082fce';
update question_translations set prompt = 'Choose the option with the preposition required by the Portuguese adjective "grato":'
 where question_id = '51c103f1-2d63-42de-86e7-fc038e082fce' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa con la preposición que exige el adjetivo portugués "grato":'
 where question_id = '51c103f1-2d63-42de-86e7-fc038e082fce' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a palavra "mesmo", usada como reforço, está corretamente flexionada:'
 where id = '53968ccb-e166-49f5-ad3b-849032ff0a38';
update question_translations set prompt = 'Choose the option in which the Portuguese word "mesmo", used for emphasis, is correctly inflected:'
 where question_id = '53968ccb-e166-49f5-ad3b-849032ff0a38' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa en la que la palabra portuguesa "mesmo", usada como refuerzo, está correctamente flexionada:'
 where question_id = '53968ccb-e166-49f5-ad3b-849032ff0a38' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a preposição exigida pelo adjetivo "fiel" está correta:'
 where id = '6be46e2e-ec21-43b3-9a30-bba069f23833';
update question_translations set prompt = 'Choose the option with the preposition required by the Portuguese adjective "fiel":'
 where question_id = '6be46e2e-ec21-43b3-9a30-bba069f23833' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa con la preposición que exige el adjetivo portugués "fiel":'
 where question_id = '6be46e2e-ec21-43b3-9a30-bba069f23833' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a preposição exigida pelo adjetivo "confiante" está correta:'
 where id = '7ce8382d-a5ce-49a6-a651-e3365c14fd2d';
update question_translations set prompt = 'Choose the option with the preposition required by the Portuguese adjective "confiante":'
 where question_id = '7ce8382d-a5ce-49a6-a651-e3365c14fd2d' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa con la preposición que exige el adjetivo portugués "confiante":'
 where question_id = '7ce8382d-a5ce-49a6-a651-e3365c14fd2d' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a preposição exigida pelo adjetivo "ansioso" está correta:'
 where id = '812cafd6-adf9-46c7-861e-ac3ed6dab9a0';
update question_translations set prompt = 'Choose the option with the preposition required by the Portuguese adjective "ansioso":'
 where question_id = '812cafd6-adf9-46c7-861e-ac3ed6dab9a0' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa con la preposición que exige el adjetivo portugués "ansioso":'
 where question_id = '812cafd6-adf9-46c7-861e-ac3ed6dab9a0' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a expressão "é proibido" está corretamente flexionada:'
 where id = '9aa52ba3-c3e5-4f42-92f3-c22183f0b01a';
update question_translations set prompt = 'Choose the option in which the Portuguese expression "é proibido" is correctly inflected:'
 where question_id = '9aa52ba3-c3e5-4f42-92f3-c22183f0b01a' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa en la que la expresión portuguesa "é proibido" está correctamente flexionada:'
 where question_id = '9aa52ba3-c3e5-4f42-92f3-c22183f0b01a' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que o verbo concorda corretamente com o sujeito "nós":'
 where id = 'b2bff02c-ea5f-4bca-8899-63c0a6aa0420';
update question_translations set prompt = 'Choose the option in which the verb correctly agrees with the subject "nós" in Portuguese:'
 where question_id = 'b2bff02c-ea5f-4bca-8899-63c0a6aa0420' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa en la que el verbo concuerda correctamente con el sujeto "nós" en portugués:'
 where question_id = 'b2bff02c-ea5f-4bca-8899-63c0a6aa0420' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a concordância dos verbos "fazer" e "haver" segue a norma-padrão:'
 where id = 'c103f29b-f274-4afd-a8a3-90e0f82bbe5c';
update question_translations set prompt = 'Choose the option in which the Portuguese verbs "fazer" and "haver" follow standard agreement:'
 where question_id = 'c103f29b-f274-4afd-a8a3-90e0f82bbe5c' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa en la que los verbos portugueses "fazer" y "haver" siguen la concordancia estándar:'
 where question_id = 'c103f29b-f274-4afd-a8a3-90e0f82bbe5c' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a regência do verbo "preferir" está correta:'
 where id = 'd0b54040-9759-4552-b1e7-773e91648620';
update question_translations set prompt = 'Choose the option with the correct government of the Portuguese verb "preferir":'
 where question_id = 'd0b54040-9759-4552-b1e7-773e91648620' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa con el régimen correcto del verbo portugués "preferir":'
 where question_id = 'd0b54040-9759-4552-b1e7-773e91648620' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a regência do verbo "chegar" está correta:'
 where id = 'd75a67d9-436d-461a-aa87-ad3a8caab6b4';
update question_translations set prompt = 'Choose the option with the correct government of the Portuguese verb "chegar":'
 where question_id = 'd75a67d9-436d-461a-aa87-ad3a8caab6b4' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa con el régimen correcto del verbo portugués "chegar":'
 where question_id = 'd75a67d9-436d-461a-aa87-ad3a8caab6b4' and locale = 'es';

update questions set prompt = 'Assinale a alternativa em que a concordância com a expressão "mais de um" está correta:'
 where id = 'e0697d13-9b28-4026-85fd-5953cda6cac4';
update question_translations set prompt = 'Choose the option with the correct agreement for the Portuguese expression "mais de um":'
 where question_id = 'e0697d13-9b28-4026-85fd-5953cda6cac4' and locale = 'en';
update question_translations set prompt = 'Señala la alternativa con la concordancia correcta para la expresión portuguesa "mais de um":'
 where question_id = 'e0697d13-9b28-4026-85fd-5953cda6cac4' and locale = 'es';

