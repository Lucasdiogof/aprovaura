-- Sequências e progressões (eaf55158-60df-41a1-a5e4-06a810df3d53)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('eaf55158-60df-41a1-a5e4-06a810df3d53', 'Na Progressão Aritmética (PA) 2, 5, 8, 11..., qual é a razão?',
  array['3', '2', '5', '9'], 0,
  'Cada termo é obtido somando 3 ao anterior.', 1),
('eaf55158-60df-41a1-a5e4-06a810df3d53', 'Qual é o 5º termo da PA que começa em 2 com razão 3?',
  array['14', '11', '17', '12'], 0,
  '2, 5, 8, 11, 14 — o quinto termo é 14.', 2),
('eaf55158-60df-41a1-a5e4-06a810df3d53', 'Na Progressão Geométrica (PG) 2, 6, 18, 54..., qual é a razão?',
  array['3', '2', '4', '6'], 0,
  'Cada termo é obtido multiplicando o anterior por 3.', 3),
('eaf55158-60df-41a1-a5e4-06a810df3d53', 'Qual é a fórmula do termo geral de uma PA?',
  array['aₙ = a₁ + (n-1) × r', 'aₙ = a₁ × rⁿ⁻¹', 'aₙ = a₁ + n × r', 'aₙ = a₁ / r'], 0,
  'Onde a₁ é o primeiro termo, r é a razão e n é a posição do termo.', 4),
('eaf55158-60df-41a1-a5e4-06a810df3d53', 'Em uma PG com primeiro termo 3 e razão 2, qual é o 4º termo?',
  array['24', '12', '48', '18'], 0,
  '3, 6, 12, 24 — o quarto termo é 24.', 5);

-- Probabilidade (184775e6-5bcb-4648-80d5-e7d97ee02af7)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('184775e6-5bcb-4648-80d5-e7d97ee02af7', 'Ao lançar uma moeda honesta, qual é a probabilidade de sair "cara"?',
  array['1/2', '1/4', '1', '1/3'], 0,
  'Há duas possibilidades igualmente prováveis: cara ou coroa.', 1),
('184775e6-5bcb-4648-80d5-e7d97ee02af7', 'Ao lançar um dado de 6 faces, qual é a probabilidade de sair o número 4?',
  array['1/6', '1/4', '1/2', '4/6'], 0,
  'Há 6 resultados possíveis, todos igualmente prováveis.', 2),
('184775e6-5bcb-4648-80d5-e7d97ee02af7', 'A probabilidade de um evento sempre varia entre quais valores?',
  array['0 e 1', '-1 e 1', '0 e 100', '1 e 10'], 0,
  '0 representa impossibilidade e 1 representa certeza absoluta.', 3),
('184775e6-5bcb-4648-80d5-e7d97ee02af7', 'Ao lançar um dado, qual é a probabilidade de sair um número par (2, 4 ou 6)?',
  array['1/2', '1/3', '1/6', '2/3'], 0,
  'São 3 resultados favoráveis em 6 possíveis: 3/6 = 1/2.', 4),
('184775e6-5bcb-4648-80d5-e7d97ee02af7', 'Se a probabilidade de chover amanhã é 30%, qual é a probabilidade de não chover?',
  array['70%', '30%', '50%', '60%'], 0,
  'A soma das probabilidades de um evento e seu complementar é sempre 100%.', 5);

-- Análise combinatória (17a0936f-4a79-47a2-9d8d-7b40c17c46bb)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('17a0936f-4a79-47a2-9d8d-7b40c17c46bb', 'De quantas formas diferentes podemos organizar 3 objetos distintos em fila?',
  array['6', '3', '9', '12'], 0,
  '3! = 3 × 2 × 1 = 6 formas diferentes.', 1),
('17a0936f-4a79-47a2-9d8d-7b40c17c46bb', 'O que é o "fatorial" de um número n, representado por n!?',
  array['O produto de todos os inteiros positivos de 1 até n', 'A soma de todos os inteiros de 1 até n', 'O dobro de n', 'A metade de n'], 0,
  'Exemplo: 4! = 4 × 3 × 2 × 1.', 2),
('17a0936f-4a79-47a2-9d8d-7b40c17c46bb', 'Quanto é 4! (fatorial de 4)?',
  array['24', '16', '12', '10'], 0,
  '4 × 3 × 2 × 1 = 24.', 3),
('17a0936f-4a79-47a2-9d8d-7b40c17c46bb', 'Uma combinação se diferencia de um arranjo por não considerar qual fator?',
  array['A ordem dos elementos', 'A quantidade de elementos', 'O valor dos elementos', 'A repetição dos elementos'], 0,
  'Em uma combinação, trocar a ordem dos elementos escolhidos não gera um novo resultado.', 4),
('17a0936f-4a79-47a2-9d8d-7b40c17c46bb', 'Quantas permutações diferentes existem para as 3 letras distintas da palavra "SOL"?',
  array['6', '3', '9', '1'], 0,
  '3! = 6 formas de organizar as três letras.', 5);

-- Estatística (847f1a39-37fd-46ae-9005-51f6fd129221)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('847f1a39-37fd-46ae-9005-51f6fd129221', 'Qual é a média aritmética dos números 2, 4 e 6?',
  array['4', '3', '6', '12'], 0,
  '(2 + 4 + 6) ÷ 3 = 12 ÷ 3 = 4.', 1),
('847f1a39-37fd-46ae-9005-51f6fd129221', 'A "moda" de um conjunto de dados representa?',
  array['O valor que mais se repete', 'O valor central', 'A soma de todos os valores', 'O maior valor do conjunto'], 0,
  'Um conjunto pode ter mais de uma moda, ou nenhuma, se nenhum valor se repetir.', 2),
('847f1a39-37fd-46ae-9005-51f6fd129221', 'A "mediana" de um conjunto de dados representa?',
  array['O valor central quando os dados estão ordenados', 'O valor que mais se repete', 'A média de todos os valores', 'O menor valor do conjunto'], 0,
  'Se houver um número par de dados, a mediana é a média dos dois valores centrais.', 3),
('847f1a39-37fd-46ae-9005-51f6fd129221', 'Qual é a mediana do conjunto {1, 3, 5, 7, 9}?',
  array['5', '3', '7', '4'], 0,
  'Os dados já estão ordenados; o valor central é o 5.', 4),
('847f1a39-37fd-46ae-9005-51f6fd129221', 'O desvio padrão é uma medida que indica?',
  array['A dispersão dos dados em relação à média', 'Apenas o maior valor do conjunto', 'A quantidade de dados no conjunto', 'A soma total dos dados'], 0,
  'Quanto maior o desvio padrão, mais espalhados estão os dados.', 5);

-- Matemática financeira (47f9a514-4c99-4d8b-acb4-f9a8f8740916)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('47f9a514-4c99-4d8b-acb4-f9a8f8740916', 'No regime de juros simples, os juros incidem sempre sobre qual valor?',
  array['O capital inicial', 'O montante acumulado no período anterior', 'A taxa de juros', 'O prazo total da aplicação'], 0,
  'Diferente dos juros compostos, no juros simples os juros não incidem sobre juros anteriores.', 1),
('47f9a514-4c99-4d8b-acb4-f9a8f8740916', 'No regime de juros compostos, os juros incidem sobre qual valor a cada período?',
  array['O montante acumulado (capital + juros anteriores)', 'Apenas o capital inicial', 'A taxa de juros do período anterior', 'A metade do capital inicial'], 0,
  'Por isso o crescimento é mais acentuado do que no juros simples.', 2),
('47f9a514-4c99-4d8b-acb4-f9a8f8740916', 'Qual é o montante de um capital de R$ 1.000 aplicado a juros simples de 10% ao ano, após 2 anos?',
  array['R$ 1.200', 'R$ 1.100', 'R$ 1.210', 'R$ 1.000'], 0,
  'M = C × (1 + i × t) = 1000 × (1 + 0,10 × 2) = 1000 × 1,2 = 1.200.', 3),
('47f9a514-4c99-4d8b-acb4-f9a8f8740916', 'Na fórmula do montante em juros simples, M = C × (1 + i × t), o que representa "i"?',
  array['A taxa de juros', 'O capital inicial', 'O tempo da aplicação', 'O montante final'], 0,
  'C é o capital, i é a taxa e t é o tempo.', 4),
('47f9a514-4c99-4d8b-acb4-f9a8f8740916', 'Em juros compostos, o crescimento do capital ao longo do tempo é?',
  array['Exponencial', 'Linear', 'Constante', 'Decrescente'], 0,
  'Isso ocorre porque os juros de cada período passam a gerar novos juros.', 5);

-- Conjuntos (e60b341c-e9bd-4e61-8d78-7710a0b79d34)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('e60b341c-e9bd-4e61-8d78-7710a0b79d34', 'Se A = {1, 2, 3} e B = {2, 3, 4}, qual é a interseção (A ∩ B)?',
  array['{2, 3}', '{1, 2, 3, 4}', '{1, 4}', '{1, 2, 3}'], 0,
  'A interseção contém apenas os elementos que pertencem a ambos os conjuntos.', 1),
('e60b341c-e9bd-4e61-8d78-7710a0b79d34', 'Se A = {1, 2, 3} e B = {2, 3, 4}, qual é a união (A ∪ B)?',
  array['{1, 2, 3, 4}', '{2, 3}', '{1, 4}', '{1, 2, 3}'], 0,
  'A união reúne todos os elementos de A e de B, sem repetição.', 2),
('e60b341c-e9bd-4e61-8d78-7710a0b79d34', 'O que representa o conjunto vazio, simbolizado por ∅?',
  array['Um conjunto que não possui nenhum elemento', 'Um conjunto com apenas o número zero', 'Um conjunto infinito', 'Um conjunto com um único elemento'], 0,
  'É um conceito fundamental na teoria dos conjuntos.', 3),
('e60b341c-e9bd-4e61-8d78-7710a0b79d34', 'Se A = {1, 2, 3, 4} e B = {2, 3}, dizemos que B é um?',
  array['Subconjunto de A', 'Conjunto vazio', 'Conjunto disjunto de A', 'Conjunto universo'], 0,
  'Todo elemento de B também pertence a A.', 4),
('e60b341c-e9bd-4e61-8d78-7710a0b79d34', 'Se A = {1, 2, 3} e B = {4, 5}, qual é a interseção entre A e B?',
  array['Conjunto vazio (∅)', '{1, 2, 3, 4, 5}', '{1, 2, 3}', '{4, 5}'], 0,
  'Como não têm elementos em comum, são chamados de conjuntos disjuntos.', 5);

-- Raciocínio lógico (0b735557-66a3-42f2-baa2-69fb5e66e7e6)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('0b735557-66a3-42f2-baa2-69fb5e66e7e6', 'Na sequência 2, 4, 6, 8, ..., qual é o próximo número?',
  array['10', '9', '12', '16'], 0,
  'A sequência avança de 2 em 2.', 1),
('0b735557-66a3-42f2-baa2-69fb5e66e7e6', 'Na sequência de quadrados perfeitos 1, 4, 9, 16, ..., qual é o próximo número?',
  array['25', '20', '18', '36'], 0,
  'São os quadrados de 1, 2, 3, 4... o próximo é 5² = 25.', 2),
('0b735557-66a3-42f2-baa2-69fb5e66e7e6', 'Se "todo A é B" e "todo B é C", o que podemos concluir logicamente?',
  array['Todo A é C', 'Todo C é A', 'Nenhum A é C', 'Nada pode ser concluído'], 0,
  'É um exemplo clássico de silogismo, uma forma de raciocínio dedutivo.', 3),
('0b735557-66a3-42f2-baa2-69fb5e66e7e6', 'Na sequência 3, 6, 12, 24, ..., em que cada termo dobra o anterior, qual é o próximo número?',
  array['48', '36', '30', '42'], 0,
  '24 × 2 = 48.', 4),
('0b735557-66a3-42f2-baa2-69fb5e66e7e6', 'Se hoje é terça-feira, que dia da semana será daqui a 8 dias?',
  array['Quarta-feira', 'Terça-feira', 'Quinta-feira', 'Segunda-feira'], 0,
  '7 dias completam uma semana (volta à terça), e mais 1 dia é quarta-feira.', 5);

-- Conteúdos avançados (19f2971b-4602-48d5-81d3-85f7f898d65b)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('19f2971b-4602-48d5-81d3-85f7f898d65b', 'Uma matriz com 2 linhas e 3 colunas é classificada como uma matriz de ordem?',
  array['2×3', '3×2', '5', '6'], 0,
  'A ordem de uma matriz é dada por (número de linhas) × (número de colunas).', 1),
('19f2971b-4602-48d5-81d3-85f7f898d65b', 'O determinante de uma matriz 2×2 [[a,b],[c,d]] é calculado por?',
  array['a×d - b×c', 'a×b - c×d', 'a+d - b+c', 'a×c - b×d'], 0,
  'É a regra usada para calcular o determinante de matrizes de ordem 2.', 2),
('19f2971b-4602-48d5-81d3-85f7f898d65b', 'Qual é o determinante da matriz [[2,3],[1,4]]?',
  array['5', '11', '8', '2'], 0,
  '(2×4) - (3×1) = 8 - 3 = 5.', 3),
('19f2971b-4602-48d5-81d3-85f7f898d65b', 'Um número complexo é escrito na forma a + bi, onde "i" representa?',
  array['A unidade imaginária, com i² = -1', 'Um número inteiro qualquer', 'Sempre o valor zero', 'A parte real do número'], 0,
  'Números complexos permitem trabalhar com raízes quadradas de números negativos.', 4),
('19f2971b-4602-48d5-81d3-85f7f898d65b', 'Qual é o resultado de i² (a unidade imaginária ao quadrado)?',
  array['-1', '1', '0', 'i'], 0,
  'Por definição, i é a raiz quadrada de -1, então i² = -1.', 5);
