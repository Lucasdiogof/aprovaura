-- Funções (a8a0b1df-a556-4d34-ac80-99f5e750921e)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('a8a0b1df-a556-4d34-ac80-99f5e750921e', 'Em uma função f(x) = 2x + 1, qual é o valor de f(3)?',
  array['7', '6', '5', '9'], 0,
  '2 × 3 + 1 = 7.', 1),
('a8a0b1df-a556-4d34-ac80-99f5e750921e', 'Uma função do 1º grau (afim) tem qual formato geral?',
  array['f(x) = ax + b', 'f(x) = ax²', 'f(x) = a/x', 'f(x) = aˣ'], 0,
  'É uma função representada por uma reta no gráfico.', 2),
('a8a0b1df-a556-4d34-ac80-99f5e750921e', 'Em uma função quadrática, como f(x) = x², o gráfico tem qual formato?',
  array['Uma parábola', 'Uma reta', 'Um círculo', 'Uma hipérbole'], 0,
  'Funções do 2º grau sempre geram gráficos em forma de parábola.', 3),
('a8a0b1df-a556-4d34-ac80-99f5e750921e', 'O que representa o "domínio" de uma função?',
  array['O conjunto de valores que a variável de entrada (x) pode assumir', 'Apenas o maior valor da função', 'O gráfico completo da função', 'O valor de f(0)'], 0,
  'O domínio define para quais valores de x a função está definida.', 4),
('a8a0b1df-a556-4d34-ac80-99f5e750921e', 'Em uma função f(x) = 3x, se f(x) = 15, qual é o valor de x?',
  array['5', '3', '45', '18'], 0,
  '15 ÷ 3 = 5.', 5);

-- Geometria plana (799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c', 'Qual é a fórmula da área de um retângulo?',
  array['base × altura', 'base + altura', '2 × (base + altura)', 'base² + altura²'], 0,
  'A área do retângulo é o produto de seus lados.', 1),
('799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c', 'Qual é a fórmula da área de um triângulo?',
  array['(base × altura) / 2', 'base × altura', 'base + altura', '2 × base × altura'], 0,
  'O triângulo tem metade da área de um retângulo com mesma base e altura.', 2),
('799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c', 'Quanto é a soma dos ângulos internos de um triângulo?',
  array['180°', '90°', '360°', '270°'], 0,
  'Essa soma é constante para qualquer triângulo.', 3),
('799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c', 'Qual é a fórmula da área de um círculo?',
  array['π × r²', '2 × π × r', 'π × d', 'r²'], 0,
  'Onde r é o raio do círculo.', 4),
('799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c', 'Quanto é a soma dos ângulos internos de um quadrilátero (4 lados)?',
  array['360°', '180°', '270°', '400°'], 0,
  'Pode-se calcular dividindo o quadrilátero em dois triângulos (180° × 2).', 5);

-- Geometria espacial (b219eae9-446c-4831-aae9-357f67cb8a75)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('b219eae9-446c-4831-aae9-357f67cb8a75', 'Qual é a fórmula do volume de um cubo de aresta a?',
  array['a³', 'a²', '6 × a', '4 × a²'], 0,
  'O volume do cubo é a aresta elevada ao cubo.', 1),
('b219eae9-446c-4831-aae9-357f67cb8a75', 'Qual é a fórmula do volume de um paralelepípedo (caixa retangular)?',
  array['comprimento × largura × altura', 'comprimento + largura + altura', '2 × (comprimento × largura)', 'comprimento²'], 0,
  'Multiplica-se as três dimensões da caixa.', 2),
('b219eae9-446c-4831-aae9-357f67cb8a75', 'Quantas faces tem um cubo?',
  array['6', '4', '8', '12'], 0,
  'Um cubo tem 6 faces quadradas, 8 vértices e 12 arestas.', 3),
('b219eae9-446c-4831-aae9-357f67cb8a75', 'Qual é a fórmula do volume de um cilindro?',
  array['π × r² × h', '2 × π × r × h', 'π × r × h', 'r² × h'], 0,
  'É a área da base circular (π×r²) multiplicada pela altura.', 4),
('b219eae9-446c-4831-aae9-357f67cb8a75', 'Quantos vértices tem um cubo?',
  array['8', '6', '12', '4'], 0,
  'Um cubo tem 8 vértices (cantos).', 5);

-- Geometria analítica (834539eb-c22c-4c35-acff-24cbf082d4e2)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('834539eb-c22c-4c35-acff-24cbf082d4e2', 'Qual é a fórmula da distância entre dois pontos no plano cartesiano?',
  array['d = √((x₂-x₁)² + (y₂-y₁)²)', 'd = (x₂-x₁) + (y₂-y₁)', 'd = x₂×y₂ - x₁×y₁', 'd = √(x₂+y₂)'], 0,
  'É uma aplicação direta do Teorema de Pitágoras no plano.', 1),
('834539eb-c22c-4c35-acff-24cbf082d4e2', 'No plano cartesiano, o ponto (0, 0) é chamado de?',
  array['Origem', 'Vértice', 'Foco', 'Eixo'], 0,
  'É o ponto de encontro dos eixos x e y.', 2),
('834539eb-c22c-4c35-acff-24cbf082d4e2', 'Qual é o coeficiente angular (inclinação) da reta y = 2x + 3?',
  array['2', '3', '5', '1'], 0,
  'Na equação y = ax + b, o coeficiente angular é o valor de a.', 3),
('834539eb-c22c-4c35-acff-24cbf082d4e2', 'Duas retas são paralelas quando têm o mesmo?',
  array['Coeficiente angular', 'Coeficiente linear', 'Ponto de origem', 'Comprimento'], 0,
  'Retas com mesma inclinação nunca se cruzam (a menos que sejam coincidentes).', 4),
('834539eb-c22c-4c35-acff-24cbf082d4e2', 'Qual é o ponto médio entre os pontos (2, 4) e (6, 8)?',
  array['(4, 6)', '(8, 12)', '(3, 5)', '(2, 4)'], 0,
  'O ponto médio é a média das coordenadas: ((2+6)/2, (4+8)/2) = (4, 6).', 5);

-- Trigonometria (1d9499bd-c3f9-4228-9deb-81951feb605c)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('1d9499bd-c3f9-4228-9deb-81951feb605c', 'Em um triângulo retângulo, o que representa o seno de um ângulo?',
  array['A razão entre o cateto oposto e a hipotenusa', 'A razão entre o cateto adjacente e a hipotenusa', 'A razão entre os dois catetos', 'O produto dos dois catetos'], 0,
  'Seno = cateto oposto / hipotenusa.', 1),
('1d9499bd-c3f9-4228-9deb-81951feb605c', 'Qual é o valor de sen(90°)?',
  array['1', '0', '0,5', '-1'], 0,
  'É o valor máximo que o seno pode assumir.', 2),
('1d9499bd-c3f9-4228-9deb-81951feb605c', 'Qual é o valor de cos(0°)?',
  array['1', '0', '0,5', '-1'], 0,
  'É o valor máximo que o cosseno pode assumir.', 3),
('1d9499bd-c3f9-4228-9deb-81951feb605c', 'O Teorema de Pitágoras relaciona os lados de qual tipo de triângulo?',
  array['Triângulo retângulo', 'Triângulo equilátero', 'Triângulo obtusângulo', 'Qualquer triângulo'], 0,
  'O teorema só se aplica a triângulos que têm um ângulo de 90°.', 4),
('1d9499bd-c3f9-4228-9deb-81951feb605c', 'Segundo o Teorema de Pitágoras, em um triângulo retângulo com catetos 3 e 4, qual é a hipotenusa?',
  array['5', '7', '6', '12'], 0,
  '3² + 4² = 9 + 16 = 25, e a raiz quadrada de 25 é 5.', 5);
