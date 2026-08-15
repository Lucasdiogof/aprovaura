-- Razão, proporção e porcentagem (0363eefa-224b-4f7f-949b-118e86b2a3e8)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('0363eefa-224b-4f7f-949b-118e86b2a3e8', 'Qual é 20% de 150?',
  array['30', '20', '15', '25'], 0,
  '150 × 0,20 = 30.', 1),
('0363eefa-224b-4f7f-949b-118e86b2a3e8', 'Se a razão entre dois números é 3:4 e o menor deles é 12, qual é o maior?',
  array['16', '15', '14', '20'], 0,
  '12 ÷ 3 = 4, então o maior é 4 × 4 = 16.', 2),
('0363eefa-224b-4f7f-949b-118e86b2a3e8', 'Aumentar um valor em 10% é o mesmo que multiplicá-lo por?',
  array['1,1', '0,1', '1,01', '10'], 0,
  '100% + 10% = 110%, que em forma decimal é 1,1.', 3),
('0363eefa-224b-4f7f-949b-118e86b2a3e8', 'Uma proporção é uma igualdade entre duas?',
  array['Razões', 'Somas', 'Potências', 'Raízes'], 0,
  'Exemplo: 2/4 = 1/2 é uma proporção.', 4),
('0363eefa-224b-4f7f-949b-118e86b2a3e8', 'Um produto custava R$ 50 e teve desconto de 20%. Qual é o novo preço?',
  array['R$ 40', 'R$ 45', 'R$ 30', 'R$ 35'], 0,
  '50 × 0,8 = 40.', 5);

-- Expressões algébricas (b6cba9af-45d2-456f-96d6-912a5d468261)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('b6cba9af-45d2-456f-96d6-912a5d468261', 'Qual é o valor da expressão 2x + 3 quando x = 5?',
  array['13', '10', '11', '15'], 0,
  '2 × 5 + 3 = 13.', 1),
('b6cba9af-45d2-456f-96d6-912a5d468261', 'Qual é o resultado de simplificar 3x + 2x?',
  array['5x', '6x', '5x²', '2x'], 0,
  'Somando os coeficientes dos termos semelhantes: 3+2=5.', 2),
('b6cba9af-45d2-456f-96d6-912a5d468261', 'Qual é o valor de x² - 4 quando x = 3?',
  array['5', '9', '1', '13'], 0,
  '3² - 4 = 9 - 4 = 5.', 3),
('b6cba9af-45d2-456f-96d6-912a5d468261', 'Qual é o resultado de simplificar 4a + 3b - 2a?',
  array['2a + 3b', '2a - 3b', '6a + 3b', '2a + 3ab'], 0,
  'Somam-se apenas os termos semelhantes: 4a - 2a = 2a.', 4),
('b6cba9af-45d2-456f-96d6-912a5d468261', 'Qual é o valor da expressão 2(x + 3) quando x = 4?',
  array['14', '11', '10', '9'], 0,
  '2 × (4+3) = 2 × 7 = 14.', 5);

-- Produtos notáveis (a1f647ec-40c6-4b93-b102-cded53c50431)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('a1f647ec-40c6-4b93-b102-cded53c50431', 'Qual é o desenvolvimento de (a + b)²?',
  array['a² + 2ab + b²', 'a² + b²', 'a² - 2ab + b²', 'a² + ab + b²'], 0,
  'É o "quadrado da soma": quadrado do primeiro, mais duas vezes o produto, mais quadrado do segundo.', 1),
('a1f647ec-40c6-4b93-b102-cded53c50431', 'Qual é o desenvolvimento de (a - b)²?',
  array['a² - 2ab + b²', 'a² + 2ab + b²', 'a² - b²', 'a² - ab + b²'], 0,
  'É o "quadrado da diferença", semelhante ao quadrado da soma, mas com o termo do meio negativo.', 2),
('a1f647ec-40c6-4b93-b102-cded53c50431', 'Qual é o resultado de (x + 5)(x - 5)?',
  array['x² - 25', 'x² + 25', 'x² - 10x - 25', 'x² + 10x - 25'], 0,
  'É a "diferença de quadrados": (a+b)(a-b) = a² - b².', 3),
('a1f647ec-40c6-4b93-b102-cded53c50431', 'Qual é o desenvolvimento de (a + b)(a - b)?',
  array['a² - b²', 'a² + b²', 'a² - 2ab + b²', 'a² + 2ab - b²'], 0,
  'É a fórmula da diferença de quadrados.', 4),
('a1f647ec-40c6-4b93-b102-cded53c50431', 'Qual é o resultado de (x + 2)²?',
  array['x² + 4x + 4', 'x² + 4', 'x² + 2x + 4', 'x² + 4x + 2'], 0,
  'x² + 2×x×2 + 2² = x² + 4x + 4.', 5);

-- Fatoração (34da53ba-be37-4cb3-b1cb-ebdcae782991)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('34da53ba-be37-4cb3-b1cb-ebdcae782991', 'Qual é a forma fatorada de x² - 9?',
  array['(x + 3)(x - 3)', '(x + 9)(x - 1)', '(x - 3)²', '(x + 3)²'], 0,
  'É uma diferença de quadrados: x² - 3².', 1),
('34da53ba-be37-4cb3-b1cb-ebdcae782991', 'Qual é a forma fatorada de x² + 6x + 9?',
  array['(x + 3)²', '(x + 9)²', '(x + 3)(x - 3)', '(x + 6)(x + 3)'], 0,
  'É um trinômio quadrado perfeito: x² + 2×x×3 + 3².', 2),
('34da53ba-be37-4cb3-b1cb-ebdcae782991', 'Qual é a forma fatorada de 6x + 9?',
  array['3(2x + 3)', '2(3x + 9)', '9(x + 6)', '6(x + 9)'], 0,
  'O fator comum entre 6 e 9 é 3.', 3),
('34da53ba-be37-4cb3-b1cb-ebdcae782991', 'Qual é a forma fatorada de 2x² + 4x?',
  array['2x(x + 2)', 'x(2x + 4)', '4x(x + 1)', '2(x² + 2x)'], 0,
  'O fator comum entre os termos é 2x.', 4),
('34da53ba-be37-4cb3-b1cb-ebdcae782991', 'Qual é a forma fatorada de x² - 4x + 4?',
  array['(x - 2)²', '(x + 2)²', '(x - 4)(x + 1)', '(x - 2)(x + 2)'], 0,
  'É um trinômio quadrado perfeito: x² - 2×x×2 + 2².', 5);

-- Equação do 1º grau (9a31b7e7-652e-490f-a9db-d7ffbb634774)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('9a31b7e7-652e-490f-a9db-d7ffbb634774', 'Qual é o valor de x na equação x + 5 = 12?',
  array['7', '17', '5', '12'], 0,
  'x = 12 - 5 = 7.', 1),
('9a31b7e7-652e-490f-a9db-d7ffbb634774', 'Qual é o valor de x na equação 2x = 10?',
  array['5', '10', '20', '2'], 0,
  'x = 10 ÷ 2 = 5.', 2),
('9a31b7e7-652e-490f-a9db-d7ffbb634774', 'Qual é o valor de x na equação 3x - 4 = 11?',
  array['5', '4', '15', '7'], 0,
  '3x = 15, então x = 5.', 3),
('9a31b7e7-652e-490f-a9db-d7ffbb634774', 'Qual é o valor de x na equação 2x + 3 = x + 7?',
  array['4', '3', '10', '2'], 0,
  '2x - x = 7 - 3, então x = 4.', 4),
('9a31b7e7-652e-490f-a9db-d7ffbb634774', 'Uma equação do 1º grau com uma incógnita tem, no máximo, quantas soluções?',
  array['1', '2', '0', 'Infinitas'], 0,
  'Uma equação do 1º grau tem sempre uma única solução (exceto casos especiais de identidade ou impossibilidade).', 5);

-- Equação do 2º grau (db814794-c73b-483b-8aa9-78927f551afd)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('db814794-c73b-483b-8aa9-78927f551afd', 'Qual fórmula é usada para resolver uma equação do 2º grau (fórmula de Bhaskara)?',
  array['x = (-b ± √(b² - 4ac)) / 2a', 'x = (b ± √(a² - 4bc)) / 2c', 'x = -b / 2a apenas', 'x = a + b + c'], 0,
  'É a fórmula geral para equações do tipo ax² + bx + c = 0.', 1),
('db814794-c73b-483b-8aa9-78927f551afd', 'Na equação x² - 5x + 6 = 0, quais são as raízes?',
  array['2 e 3', '1 e 6', '-2 e -3', '5 e 6'], 0,
  'A soma das raízes é 5 e o produto é 6: 2+3=5 e 2×3=6.', 2),
('db814794-c73b-483b-8aa9-78927f551afd', 'O que é o discriminante (Δ) de uma equação do 2º grau?',
  array['Δ = b² - 4ac', 'Δ = a² - 4bc', 'Δ = b² + 4ac', 'Δ = c² - 4ab'], 0,
  'O discriminante indica quantas raízes reais a equação possui.', 3),
('db814794-c73b-483b-8aa9-78927f551afd', 'Se o discriminante (Δ) de uma equação do 2º grau é negativo, quantas raízes reais ela tem?',
  array['Nenhuma', 'Uma', 'Duas', 'Infinitas'], 0,
  'Quando Δ < 0, não existe raiz quadrada real de um número negativo.', 4),
('db814794-c73b-483b-8aa9-78927f551afd', 'Qual é o valor de x na equação x² - 9 = 0?',
  array['x = 3 ou x = -3', 'x = 9 ou x = -9', 'x = 3 apenas', 'x = 81'], 0,
  'x² = 9, então x pode ser 3 ou -3.', 5);

-- Equações fracionárias (815e802e-a4dd-4f2c-ab27-c1715a433bf2)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('815e802e-a4dd-4f2c-ab27-c1715a433bf2', 'Em uma equação fracionária, qual é geralmente o primeiro passo para resolvê-la?',
  array['Encontrar o MMC dos denominadores e eliminar as frações', 'Somar todos os numeradores diretamente', 'Elevar ambos os lados ao quadrado', 'Ignorar os denominadores'], 0,
  'Isso transforma a equação fracionária em uma equação mais simples, sem frações.', 1),
('815e802e-a4dd-4f2c-ab27-c1715a433bf2', 'Qual é a principal restrição ao resolver equações fracionárias?',
  array['O denominador não pode ser igual a zero', 'O numerador deve ser sempre positivo', 'A incógnita não pode aparecer no numerador', 'A equação deve ter no máximo duas frações'], 0,
  'Divisão por zero não é definida, então esses valores devem ser excluídos da solução.', 2),
('815e802e-a4dd-4f2c-ab27-c1715a433bf2', 'Na equação 1/x = 2, qual é o valor de x?',
  array['1/2', '2', '-2', '1'], 0,
  'Invertendo: x = 1/2.', 3),
('815e802e-a4dd-4f2c-ab27-c1715a433bf2', 'Na equação x/2 + x/3 = 5, qual é o valor de x?',
  array['6', '5', '3', '10'], 0,
  'Multiplicando tudo por 6: 3x + 2x = 30, então 5x = 30 e x = 6.', 4),
('815e802e-a4dd-4f2c-ab27-c1715a433bf2', 'O que é uma "raiz estranha" em uma equação fracionária?',
  array['Uma solução que torna algum denominador igual a zero', 'A maior raiz possível da equação', 'Uma raiz sempre negativa', 'Uma raiz que aparece duas vezes'], 0,
  'Essas soluções aparentes devem ser descartadas por tornarem a equação original indefinida.', 5);

-- Equações irracionais (35d26944-58a3-43d6-868c-c04705be6487)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('35d26944-58a3-43d6-868c-c04705be6487', 'Uma equação irracional é caracterizada por ter a incógnita em que posição?',
  array['Dentro de uma raiz (radical)', 'No denominador de uma fração', 'Apenas como expoente', 'Fora de qualquer operação'], 0,
  'É o que diferencia esse tipo de equação das demais.', 1),
('35d26944-58a3-43d6-868c-c04705be6487', 'Qual é o valor de x na equação √x = 4?',
  array['16', '2', '8', '4'], 0,
  'Elevando ambos os lados ao quadrado: x = 4² = 16.', 2),
('35d26944-58a3-43d6-868c-c04705be6487', 'Qual é o principal método para resolver uma equação irracional?',
  array['Elevar ambos os lados à potência adequada para eliminar a raiz', 'Somar 1 aos dois lados', 'Multiplicar por zero', 'Ignorar o radical'], 0,
  'Por exemplo, elevar ao quadrado elimina uma raiz quadrada.', 3),
('35d26944-58a3-43d6-868c-c04705be6487', 'Por que é necessário verificar as soluções encontradas em uma equação irracional?',
  array['Porque elevar a uma potência pode gerar soluções que não satisfazem a equação original', 'Porque toda equação irracional não tem solução', 'Porque a resposta é sempre negativa', 'Porque não existe verificação nesse tipo de equação'], 0,
  'Essas soluções falsas são descartadas após a verificação.', 4),
('35d26944-58a3-43d6-868c-c04705be6487', 'Qual é o valor de x na equação √(x + 1) = 3?',
  array['8', '9', '2', '3'], 0,
  'Elevando ao quadrado: x + 1 = 9, então x = 8.', 5);

-- Equações exponenciais (4cf8f783-8ebd-426e-859b-6c5692e4e9ce)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('4cf8f783-8ebd-426e-859b-6c5692e4e9ce', 'Qual é o valor de x na equação 2ˣ = 8?',
  array['3', '4', '2', '8'], 0,
  '2³ = 8, então x = 3.', 1),
('4cf8f783-8ebd-426e-859b-6c5692e4e9ce', 'Quando as bases de uma equação exponencial já são iguais, qual é o método mais direto para resolvê-la?',
  array['Igualar os expoentes', 'Igualar as bases a zero', 'Somar as bases', 'Multiplicar os expoentes'], 0,
  'Se as bases são iguais, a igualdade só é possível se os expoentes também forem iguais.', 2),
('4cf8f783-8ebd-426e-859b-6c5692e4e9ce', 'Qual é o valor de x na equação 3ˣ = 81?',
  array['4', '3', '27', '9'], 0,
  '3⁴ = 81, então x = 4.', 3),
('4cf8f783-8ebd-426e-859b-6c5692e4e9ce', 'Qual é o valor de x na equação 5ˣ = 1?',
  array['0', '1', '5', 'Não existe solução'], 0,
  'Qualquer número elevado a zero é igual a 1.', 4),
('4cf8f783-8ebd-426e-859b-6c5692e4e9ce', 'Qual é o valor de x na equação 2ˣ⁺¹ = 16?',
  array['3', '4', '2', '15'], 0,
  '16 = 2⁴, então x + 1 = 4 e x = 3.', 5);

-- Sistemas de equações (d8d2ce85-4316-4b16-ae86-12483e8ba748)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('d8d2ce85-4316-4b16-ae86-12483e8ba748', 'Ao resolver um sistema de equações, buscamos encontrar quais valores?',
  array['Os valores que satisfazem simultaneamente todas as equações', 'Apenas o maior valor entre as equações', 'A soma de todas as equações', 'O valor de apenas uma das incógnitas'], 0,
  'A solução deve valer para todas as equações do sistema ao mesmo tempo.', 1),
('d8d2ce85-4316-4b16-ae86-12483e8ba748', 'No sistema x + y = 10 e x - y = 2, quais são os valores de x e y?',
  array['x = 6, y = 4', 'x = 5, y = 5', 'x = 8, y = 2', 'x = 4, y = 6'], 0,
  'Somando as duas equações: 2x = 12, então x = 6 e y = 10 - 6 = 4.', 2),
('d8d2ce85-4316-4b16-ae86-12483e8ba748', 'Qual é um dos métodos mais usados para resolver sistemas de equações?',
  array['Substituição', 'Radiciação', 'Fatoração exclusiva', 'Potenciação'], 0,
  'Consiste em isolar uma variável em uma equação e substituir na outra.', 3),
('d8d2ce85-4316-4b16-ae86-12483e8ba748', 'Quando um sistema de duas equações lineares não tem nenhuma solução, as retas que elas representam são?',
  array['Paralelas', 'Perpendiculares', 'Coincidentes', 'Concorrentes'], 0,
  'Retas paralelas nunca se cruzam, por isso não há um ponto comum (solução).', 4),
('d8d2ce85-4316-4b16-ae86-12483e8ba748', 'Quando um sistema tem infinitas soluções, o que isso indica sobre as duas equações?',
  array['Elas representam a mesma reta', 'Elas são perpendiculares', 'Elas não têm relação alguma', 'Uma delas está errada'], 0,
  'Se as equações são equivalentes, qualquer ponto de uma também satisfaz a outra.', 5);

-- Inequações (ad24dbee-1914-4cf1-962a-f6358926b8b8)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('ad24dbee-1914-4cf1-962a-f6358926b8b8', 'Ao multiplicar ou dividir uma inequação por um número negativo, o que deve ser feito com o sinal de desigualdade?',
  array['Ele deve ser invertido', 'Ele deve ser mantido', 'Ele deve virar uma igualdade', 'Nada muda'], 0,
  'É uma das regras mais importantes ao resolver inequações.', 1),
('ad24dbee-1914-4cf1-962a-f6358926b8b8', 'Qual é a solução da inequação x + 3 > 7?',
  array['x > 4', 'x > 10', 'x < 4', 'x > 3'], 0,
  'Subtraindo 3 dos dois lados: x > 4.', 2),
('ad24dbee-1914-4cf1-962a-f6358926b8b8', 'Qual é a solução da inequação 2x ≤ 10?',
  array['x ≤ 5', 'x ≤ 20', 'x ≥ 5', 'x ≤ 8'], 0,
  'Dividindo os dois lados por 2 (número positivo, sinal mantido): x ≤ 5.', 3),
('ad24dbee-1914-4cf1-962a-f6358926b8b8', 'Qual é a solução da inequação -x > 5?',
  array['x < -5', 'x > -5', 'x > 5', 'x < 5'], 0,
  'Multiplicando por -1, o sinal se inverte: x < -5.', 4),
('ad24dbee-1914-4cf1-962a-f6358926b8b8', 'O símbolo "≥" representa qual relação?',
  array['Maior ou igual a', 'Menor ou igual a', 'Apenas maior que', 'Diferente de'], 0,
  'É usado quando um valor pode ser igual ou superior a outro.', 5);

-- Polinômios (c4dc4513-74fe-418c-8f0a-aa8910676246)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('c4dc4513-74fe-418c-8f0a-aa8910676246', 'Qual é o grau do polinômio 3x³ + 2x² - x + 5?',
  array['3', '5', '2', '4'], 0,
  'O grau é dado pelo maior expoente da variável, nesse caso o 3 de x³.', 1),
('c4dc4513-74fe-418c-8f0a-aa8910676246', 'Qual é o resultado de somar os polinômios (2x² + 3x) e (x² - x)?',
  array['3x² + 2x', '3x² + 4x', '2x² + 2x', 'x² + 2x'], 0,
  'Somam-se os termos semelhantes: 2x²+x²=3x² e 3x-x=2x.', 2),
('c4dc4513-74fe-418c-8f0a-aa8910676246', 'Qual é o resultado de multiplicar x por (x + 2)?',
  array['x² + 2x', 'x² + 2', '2x + 2', 'x² + x'], 0,
  'x × x = x², e x × 2 = 2x.', 3),
('c4dc4513-74fe-418c-8f0a-aa8910676246', 'Um polinômio com apenas um termo é chamado de?',
  array['Monômio', 'Binômio', 'Trinômio', 'Polinômio completo'], 0,
  'Quando tem dois termos é chamado de binômio, e com três, trinômio.', 4),
('c4dc4513-74fe-418c-8f0a-aa8910676246', 'Qual é o valor numérico do polinômio x² + 2x + 1 quando x = 2?',
  array['9', '7', '5', '11'], 0,
  '2² + 2×2 + 1 = 4 + 4 + 1 = 9.', 5);
