-- Matemática: 10 correções aceitas da revisão externa (2026-09-30)
--
-- Nenhum gabarito estava errado, mas duas questões eram ambíguas: "a equação
-- do 1º grau tem NO MÁXIMO quantas soluções?" tinha "Infinitas" entre as
-- alternativas (a identidade 0x = 0 bagunça a pergunta; agora a ≠ 0 está no
-- enunciado), e a de números naturais listava {0,...} e {1,...} sem fixar a
-- convenção. O resto é rigor: retas paralelas distintas e não verticais, base
-- positiva e diferente de 1, conferir solução estranha, a ≠ 0 na função afim.
--
-- Matemática não tem arquivo fonte: a correção vive só no banco.
--
-- Só o texto muda: a ORDEM das alternativas é preservada, para o gabarito
-- não se mexer e as traduções seguirem alinhadas por posição. Cada
-- update grava o valor final inteiro, então rodar de novo não muda nada.

-- 1º grau: com "Infinitas" entre as alternativas, a pergunta precisa fixar a ≠ 0
update questions set prompt = 'Uma equação do 1º grau com uma incógnita, na forma ax + b = 0 com a ≠ 0, tem quantas soluções reais?', explanation = 'Como a ≠ 0, isola-se x e obtém-se x = −b/a: a equação tem exatamente uma solução real.'
 where id = '3796e11a-b379-4ab3-a3f6-b099b4242137';
update question_translations set prompt = 'A first-degree equation in one unknown, of the form ax + b = 0 with a ≠ 0, has how many real solutions?', explanation = 'Since a ≠ 0, you can isolate x and get x = −b/a: the equation has exactly one real solution.'
 where question_id = '3796e11a-b379-4ab3-a3f6-b099b4242137' and locale = 'en';
update question_translations set prompt = 'Una ecuación de primer grado con una incógnita, de la forma ax + b = 0 con a ≠ 0, ¿cuántas soluciones reales tiene?', explanation = 'Como a ≠ 0, se despeja x y se obtiene x = −b/a: la ecuación tiene exactamente una solución real.'
 where question_id = '3796e11a-b379-4ab3-a3f6-b099b4242137' and locale = 'es';

-- exponencial: a igualdade dos expoentes vale para base positiva diferente de 1
update questions set explanation = 'Para uma mesma base positiva e diferente de 1, a função exponencial é injetiva: a^u = a^v implica u = v.'
 where id = '1380081d-e861-4a7a-8c74-e75cfc8cc508';
update question_translations set explanation = 'For the same base, positive and different from 1, the exponential function is one-to-one: a^u = a^v implies u = v.'
 where question_id = '1380081d-e861-4a7a-8c74-e75cfc8cc508' and locale = 'en';
update question_translations set explanation = 'Para una misma base positiva y distinta de 1, la función exponencial es inyectiva: a^u = a^v implica u = v.'
 where question_id = '1380081d-e861-4a7a-8c74-e75cfc8cc508' and locale = 'es';

-- raiz estranha: descartada por não satisfazer a equação original
update questions set explanation = 'A raiz estranha aparece nas manipulações algébricas, mas deve ser descartada por não satisfazer a equação original, por exemplo por anular um denominador.'
 where id = 'f9848af1-dfc2-498b-bf51-2f2810d48f17';
update question_translations set explanation = 'An extraneous root appears during the algebraic manipulations but must be discarded because it does not satisfy the original equation, for example by making a denominator zero.'
 where question_id = 'f9848af1-dfc2-498b-bf51-2f2810d48f17' and locale = 'en';
update question_translations set explanation = 'La raíz extraña aparece en las manipulaciones algebraicas, pero debe descartarse por no satisfacer la ecuación original, por ejemplo al anular un denominador.'
 where question_id = 'f9848af1-dfc2-498b-bf51-2f2810d48f17' and locale = 'es';

-- equação irracional: elevar à potência pode criar solução estranha, então é preciso conferir
update questions set prompt = 'Qual procedimento é usado com frequência para eliminar radicais ao resolver uma equação irracional?', explanation = 'Elevam-se os dois lados à potência adequada para eliminar o radical (ao quadrado, para uma raiz quadrada). Como isso pode introduzir soluções estranhas, as respostas devem ser conferidas na equação original.'
 where id = '75e9db55-27e0-44e2-b2bf-627c7025a6eb';
update question_translations set prompt = 'Which procedure is often used to eliminate radicals when solving a radical equation?', explanation = 'Both sides are raised to the appropriate power to remove the radical (squared, for a square root). Since this can introduce extraneous solutions, the answers must be checked in the original equation.'
 where question_id = '75e9db55-27e0-44e2-b2bf-627c7025a6eb' and locale = 'en';
update question_translations set prompt = '¿Qué procedimiento se usa con frecuencia para eliminar radicales al resolver una ecuación irracional?', explanation = 'Se elevan ambos lados a la potencia adecuada para eliminar el radical (al cuadrado, para una raíz cuadrada). Como esto puede introducir soluciones extrañas, las respuestas deben comprobarse en la ecuación original.'
 where question_id = '75e9db55-27e0-44e2-b2bf-627c7025a6eb' and locale = 'es';

-- sistema impossível: paralelas DISTINTAS (as coincidentes dão infinitas soluções)
update questions set options = array['Paralelas distintas', 'Perpendiculares', 'Coincidentes', 'Concorrentes'], explanation = 'Um sistema de duas equações lineares sem solução representa duas retas paralelas distintas: mesma direção e nenhum ponto em comum.'
 where id = 'a60df61e-3cfb-432b-b78c-a9fb5413104f';
update question_translations set options = array['Distinct parallel lines', 'Perpendicular', 'Coincident', 'Intersecting'], explanation = 'A system of two linear equations with no solution represents two distinct parallel lines: same direction and no point in common.'
 where question_id = 'a60df61e-3cfb-432b-b78c-a9fb5413104f' and locale = 'en';
update question_translations set options = array['Paralelas distintas', 'Perpendiculares', 'Coincidentes', 'Secantes'], explanation = 'Un sistema de dos ecuaciones lineales sin solución representa dos rectas paralelas distintas: misma dirección y ningún punto en común.'
 where question_id = 'a60df61e-3cfb-432b-b78c-a9fb5413104f' and locale = 'es';

-- função do 1º grau: sem a ≠ 0 seria constante
update questions set prompt = 'Uma função do 1º grau (afim), com a ≠ 0, tem qual formato geral?', explanation = 'A função do 1º grau tem a forma f(x) = ax + b, com a ≠ 0; seu gráfico é uma reta não horizontal.'
 where id = '48b53f1a-757d-4745-b9d9-6e6a656a94b4';
update question_translations set prompt = 'What is the general form of a first-degree (affine) function, with a ≠ 0?', explanation = 'A first-degree function has the form f(x) = ax + b, with a ≠ 0; its graph is a non-horizontal straight line.'
 where question_id = '48b53f1a-757d-4745-b9d9-6e6a656a94b4' and locale = 'en';
update question_translations set prompt = '¿Qué forma general tiene una función de primer grado (afín), con a ≠ 0?', explanation = 'La función de primer grado tiene la forma f(x) = ax + b, con a ≠ 0; su gráfica es una recta no horizontal.'
 where question_id = '48b53f1a-757d-4745-b9d9-6e6a656a94b4' and locale = 'es';

-- inteiros: 2/1 também é fração; o que fica de fora são os não inteiros
update questions set prompt = 'Qual conjunto numérico contém os inteiros negativos, o zero e os inteiros positivos, mas não números como 1/2?', explanation = 'O conjunto dos inteiros é Z = {..., −2, −1, 0, 1, 2, ...}. Números não inteiros, como 1/2, não pertencem a Z.'
 where id = '744eb7dc-3f6f-426d-bb52-ec31dde501fb';
update question_translations set prompt = 'Which set of numbers contains the negative integers, zero and the positive integers, but not numbers such as 1/2?', explanation = 'The set of integers is Z = {..., −2, −1, 0, 1, 2, ...}. Non-integers such as 1/2 do not belong to Z.'
 where question_id = '744eb7dc-3f6f-426d-bb52-ec31dde501fb' and locale = 'en';
update question_translations set prompt = '¿Qué conjunto numérico contiene los enteros negativos, el cero y los enteros positivos, pero no números como 1/2?', explanation = 'El conjunto de los enteros es Z = {..., −2, −1, 0, 1, 2, ...}. Los números no enteros, como 1/2, no pertenecen a Z.'
 where question_id = '744eb7dc-3f6f-426d-bb52-ec31dde501fb' and locale = 'es';

-- naturais: {0,...} e {1,...} estão entre as alternativas, então a convenção vai no enunciado
update questions set prompt = 'Adotando a convenção frequente no ensino brasileiro, que inclui o zero, qual é o conjunto dos números naturais (N)?', explanation = 'Nessa convenção, N = {0, 1, 2, 3, ...}. Alguns autores começam N em 1, por isso o enunciado explicita a convenção.'
 where id = '16004372-9b31-4d40-852d-36f84d240ab5';
update question_translations set prompt = 'Following the convention common in Brazilian schools, which includes zero, what is the set of natural numbers (N)?', explanation = 'Under this convention, N = {0, 1, 2, 3, ...}. Some authors start N at 1, which is why the prompt states the convention.'
 where question_id = '16004372-9b31-4d40-852d-36f84d240ab5' and locale = 'en';
update question_translations set prompt = 'Adoptando la convención frecuente en la enseñanza brasileña, que incluye el cero, ¿cuál es el conjunto de los números naturales (N)?', explanation = 'En esa convención, N = {0, 1, 2, 3, ...}. Algunos autores empiezan N en 1, por eso el enunciado explicita la convención.'
 where question_id = '16004372-9b31-4d40-852d-36f84d240ab5' and locale = 'es';

-- paralelas: coincidentes também têm o mesmo coeficiente; e vertical não tem coeficiente
update questions set prompt = 'Duas retas distintas e não verticais são paralelas quando têm o mesmo:', explanation = 'Duas retas distintas com o mesmo coeficiente angular têm a mesma inclinação e não se cruzam. Retas coincidentes também têm o mesmo coeficiente, por isso o enunciado pede retas distintas.'
 where id = 'b36d48ca-4c25-48e3-bc5a-f3deda5b046d';
update question_translations set prompt = 'Two distinct, non-vertical lines are parallel when they have the same:', explanation = 'Two distinct lines with the same slope have the same inclination and never cross. Coincident lines also share the slope, which is why the prompt asks for distinct lines.'
 where question_id = 'b36d48ca-4c25-48e3-bc5a-f3deda5b046d' and locale = 'en';
update question_translations set prompt = 'Dos rectas distintas y no verticales son paralelas cuando tienen la misma:', explanation = 'Dos rectas distintas con la misma pendiente tienen la misma inclinación y no se cruzan. Las rectas coincidentes también comparten la pendiente, por eso el enunciado pide rectas distintas.'
 where question_id = 'b36d48ca-4c25-48e3-bc5a-f3deda5b046d' and locale = 'es';

-- juros compostos: exponencial com taxa constante e positiva, M = C(1 + i)^t
update questions set prompt = 'Com uma taxa de juros compostos constante e positiva, o crescimento do capital ao longo do tempo é:', explanation = 'Com taxa constante, o montante segue M = C(1 + i)^t: os juros de cada período passam a render juros, e o crescimento é exponencial.'
 where id = 'ee7db4c1-b1f9-4e42-9590-12f15869eee9';
update question_translations set prompt = 'With a constant, positive compound interest rate, how does the principal grow over time?', explanation = 'With a constant rate, the amount follows M = C(1 + i)^t: each period''s interest starts earning interest, so growth is exponential.'
 where question_id = 'ee7db4c1-b1f9-4e42-9590-12f15869eee9' and locale = 'en';
update question_translations set prompt = 'Con una tasa de interés compuesto constante y positiva, ¿cómo crece el capital a lo largo del tiempo?', explanation = 'Con tasa constante, el monto sigue M = C(1 + i)^t: los intereses de cada período pasan a generar intereses, y el crecimiento es exponencial.'
 where question_id = 'ee7db4c1-b1f9-4e42-9590-12f15869eee9' and locale = 'es';
