-- Números (naturais, inteiros, racionais, irracionais, reais) (9751f8f3-54ba-466d-9ff2-1369e393ee4f)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('9751f8f3-54ba-466d-9ff2-1369e393ee4f', 'Qual conjunto numérico inclui os negativos, o zero e os positivos, mas não as frações?',
  array['Números inteiros (Z)', 'Números naturais (N)', 'Números racionais (Q)', 'Números irracionais'], 0,
  'Os inteiros são ..., -2, -1, 0, 1, 2, ...', 1),
('9751f8f3-54ba-466d-9ff2-1369e393ee4f', 'O número √2 (raiz quadrada de 2) é classificado como?',
  array['Irracional', 'Racional', 'Inteiro', 'Natural'], 0,
  'Não pode ser escrito como fração de dois inteiros; sua representação decimal é infinita e não periódica.', 2),
('9751f8f3-54ba-466d-9ff2-1369e393ee4f', 'Qual é o conjunto dos números naturais (N), segundo a definição mais usada no Brasil?',
  array['{0, 1, 2, 3, 4, ...}', '{1, 2, 3, 4, ...}', '{..., -1, 0, 1, ...}', '{0,5; 1; 1,5; ...}'], 0,
  'No Brasil, o zero é geralmente incluído no conjunto dos naturais.', 3),
('9751f8f3-54ba-466d-9ff2-1369e393ee4f', 'Um número racional pode sempre ser escrito na forma de?',
  array['Uma fração (razão entre dois inteiros)', 'Uma dízima infinita não periódica', 'Apenas um número negativo', 'Apenas um número decimal exato'], 0,
  'Racional vem justamente de "razão", ou seja, uma divisão entre dois números inteiros.', 4),
('9751f8f3-54ba-466d-9ff2-1369e393ee4f', 'O número π (pi), usado em cálculos com círculos, é um exemplo de número?',
  array['Irracional', 'Racional', 'Inteiro', 'Natural'], 0,
  'Assim como √2, o π tem infinitas casas decimais sem repetição.', 5);

-- Operações básicas e ordem das operações (63193752-9df4-4e14-a28c-423863dcdaf3)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('63193752-9df4-4e14-a28c-423863dcdaf3', 'Qual é o resultado de 2 + 3 × 4?',
  array['14', '20', '9', '24'], 0,
  'Multiplicação antes de adição: 3×4=12, depois 2+12=14.', 1),
('63193752-9df4-4e14-a28c-423863dcdaf3', 'Na ordem das operações, o que deve ser resolvido antes: multiplicação/divisão ou adição/subtração?',
  array['Multiplicação e divisão', 'Adição e subtração', 'Depende da ordem em que aparecem', 'Todas têm a mesma prioridade'], 0,
  'Multiplicação e divisão têm prioridade sobre adição e subtração.', 2),
('63193752-9df4-4e14-a28c-423863dcdaf3', 'Qual é o resultado de (5 + 3) × 2?',
  array['16', '13', '10', '11'], 0,
  'Primeiro resolve-se o parênteses: 5+3=8, depois 8×2=16.', 3),
('63193752-9df4-4e14-a28c-423863dcdaf3', 'Qual é o resultado de 20 ÷ 4 × 2?',
  array['10', '2,5', '40', '5'], 0,
  'Divisão e multiplicação têm a mesma prioridade e são feitas da esquerda para a direita: 20÷4=5, depois 5×2=10.', 4),
('63193752-9df4-4e14-a28c-423863dcdaf3', 'Qual é o resultado de 10 - 2 × 3?',
  array['4', '24', '8', '-4'], 0,
  'Multiplicação antes: 2×3=6, depois 10-6=4.', 5);

-- Frações (8d65ae08-ddf2-4dfd-badd-6476500448a6)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('8d65ae08-ddf2-4dfd-badd-6476500448a6', 'Qual é o resultado de 1/2 + 1/4?',
  array['3/4', '2/6', '1/6', '2/4'], 0,
  'Colocando em mesmo denominador: 2/4 + 1/4 = 3/4.', 1),
('8d65ae08-ddf2-4dfd-badd-6476500448a6', 'Qual é o resultado de 2/3 × 3/4?',
  array['1/2', '5/7', '6/7', '2/4'], 0,
  'Multiplica-se numerador por numerador e denominador por denominador: 6/12, que simplifica para 1/2.', 2),
('8d65ae08-ddf2-4dfd-badd-6476500448a6', 'Qual fração é equivalente a 0,5?',
  array['1/2', '1/4', '2/3', '1/5'], 0,
  '0,5 é o mesmo que 5/10, que simplifica para 1/2.', 3),
('8d65ae08-ddf2-4dfd-badd-6476500448a6', 'Para dividir uma fração por outra, o que devemos fazer?',
  array['Multiplicar pela fração invertida', 'Somar os denominadores', 'Subtrair os numeradores', 'Dividir os numeradores entre si apenas'], 0,
  'Dividir por uma fração é o mesmo que multiplicar pelo seu inverso.', 4),
('8d65ae08-ddf2-4dfd-badd-6476500448a6', 'Qual é o resultado de 3/4 - 1/4?',
  array['1/2', '2/4', '1/4', '4/4'], 0,
  'Como os denominadores já são iguais, basta subtrair os numeradores: 3-1=2, então 2/4 = 1/2.', 5);

-- Números decimais (4c39e2ed-67c8-482d-af15-6ae32fc86389)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('4c39e2ed-67c8-482d-af15-6ae32fc86389', 'Qual é o resultado de 0,25 + 0,5?',
  array['0,75', '0,7', '0,55', '0,8'], 0,
  'Basta somar os valores alinhando as casas decimais.', 1),
('4c39e2ed-67c8-482d-af15-6ae32fc86389', 'Qual é a forma decimal da fração 3/4?',
  array['0,75', '0,25', '0,34', '0,43'], 0,
  '3 dividido por 4 resulta em 0,75.', 2),
('4c39e2ed-67c8-482d-af15-6ae32fc86389', 'Qual é o resultado de 1,5 × 2?',
  array['3,0', '2,5', '3,5', '1,5'], 0,
  'Multiplicar 1,5 por 2 dá 3.', 3),
('4c39e2ed-67c8-482d-af15-6ae32fc86389', 'Ao multiplicar um número decimal por 10, o que acontece com a vírgula?',
  array['Desloca uma casa para a direita', 'Desloca uma casa para a esquerda', 'Desaparece', 'Não muda'], 0,
  'Multiplicar por 10 sempre desloca a vírgula uma casa para a direita.', 4),
('4c39e2ed-67c8-482d-af15-6ae32fc86389', 'Qual é o resultado de 2,5 - 0,75?',
  array['1,75', '1,25', '2,25', '3,25'], 0,
  '2,50 menos 0,75 resulta em 1,75.', 5);

-- Potenciação e radiciação (42d19683-3191-437b-8c14-4edc7c66b826)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('42d19683-3191-437b-8c14-4edc7c66b826', 'Qual é o resultado de 2³ (dois elevado ao cubo)?',
  array['8', '6', '9', '4'], 0,
  '2 × 2 × 2 = 8.', 1),
('42d19683-3191-437b-8c14-4edc7c66b826', 'Qual é o resultado de √81 (raiz quadrada de 81)?',
  array['9', '8', '81', '18'], 0,
  '9 × 9 = 81, então √81 = 9.', 2),
('42d19683-3191-437b-8c14-4edc7c66b826', 'Qual é o resultado de 5⁰ (cinco elevado a zero)?',
  array['1', '0', '5', '25'], 0,
  'Todo número não nulo elevado a zero é igual a 1.', 3),
('42d19683-3191-437b-8c14-4edc7c66b826', 'Qual é o resultado de 2⁻¹ (dois elevado a menos um)?',
  array['1/2', '-2', '2', '-1/2'], 0,
  'Expoente negativo indica inverso: 2⁻¹ = 1/2¹ = 1/2.', 4),
('42d19683-3191-437b-8c14-4edc7c66b826', 'Qual é o resultado de (2²)³?',
  array['64', '32', '16', '12'], 0,
  '2² = 4, e 4³ = 64 (ou 2^(2×3) = 2⁶ = 64).', 5);

-- Critérios de divisibilidade (6225352f-06bf-428a-b8bb-3a523f9f1c0b)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('6225352f-06bf-428a-b8bb-3a523f9f1c0b', 'Um número é divisível por 2 quando?',
  array['Termina em algarismo par (0, 2, 4, 6 ou 8)', 'A soma dos algarismos é par', 'Termina em 0', 'É maior que 100'], 0,
  'Basta olhar o último algarismo do número.', 1),
('6225352f-06bf-428a-b8bb-3a523f9f1c0b', 'Um número é divisível por 3 quando?',
  array['A soma de seus algarismos é divisível por 3', 'Termina em 3', 'É um número ímpar', 'É maior que 30'], 0,
  'Exemplo: 123 → 1+2+3=6, que é divisível por 3.', 2),
('6225352f-06bf-428a-b8bb-3a523f9f1c0b', 'Um número é divisível por 5 quando?',
  array['Termina em 0 ou 5', 'Termina em algarismo par', 'A soma dos algarismos é 5', 'É múltiplo de 10'], 0,
  'Basta verificar o último algarismo.', 3),
('6225352f-06bf-428a-b8bb-3a523f9f1c0b', 'Um número é divisível por 9 quando?',
  array['A soma de seus algarismos é divisível por 9', 'Termina em 9', 'É múltiplo de 3 apenas', 'Tem 9 algarismos'], 0,
  'Exemplo: 918 → 9+1+8=18, que é divisível por 9.', 4),
('6225352f-06bf-428a-b8bb-3a523f9f1c0b', 'Um número é divisível por 10 quando?',
  array['Termina em 0', 'Termina em algarismo par', 'A soma dos algarismos é 10', 'É maior que 100'], 0,
  'Todo número que termina em zero é divisível por 10.', 5);

-- Números primos (7a538d1e-a300-4f02-8d84-4d488e645591)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('7a538d1e-a300-4f02-8d84-4d488e645591', 'Um número primo é aquele que é divisível apenas por?',
  array['1 e por ele mesmo', 'Apenas por 1', 'Todos os números ímpares', 'Qualquer número menor que ele'], 0,
  'Se um número tiver outros divisores além de 1 e ele mesmo, não é primo.', 1),
('7a538d1e-a300-4f02-8d84-4d488e645591', 'Qual desses números é primo?',
  array['17', '21', '15', '9'], 0,
  '17 só é divisível por 1 e por 17. Os outros têm outros divisores (21=3×7, 15=3×5, 9=3×3).', 2),
('7a538d1e-a300-4f02-8d84-4d488e645591', 'O número 1 é considerado um número primo?',
  array['Não', 'Sim', 'Apenas em alguns casos', 'Sim, mas só na matemática avançada'], 0,
  'Por definição, um número primo deve ter exatamente dois divisores distintos: 1 e ele mesmo. O número 1 tem só um divisor.', 3),
('7a538d1e-a300-4f02-8d84-4d488e645591', 'Qual é o único número primo par?',
  array['2', '4', '0', 'Não existe nenhum'], 0,
  'Todos os outros números pares são divisíveis por 2 além de si mesmos, então não são primos.', 4),
('7a538d1e-a300-4f02-8d84-4d488e645591', 'Qual desses números NÃO é primo?',
  array['33', '23', '29', '31'], 0,
  '33 = 3 × 11, então tem outros divisores além de 1 e ele mesmo. Os demais são primos.', 5);

-- Fatoração (números/divisibilidade) (57a8df6f-0a57-4e45-a32b-feab275585a1)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('57a8df6f-0a57-4e45-a32b-feab275585a1', 'Qual é a fatoração em números primos de 12?',
  array['2² × 3', '2 × 3²', '2² × 3²', '2 × 6'], 0,
  '12 = 2 × 2 × 3 = 2² × 3.', 1),
('57a8df6f-0a57-4e45-a32b-feab275585a1', 'Qual é a fatoração em números primos de 30?',
  array['2 × 3 × 5', '2² × 3', '3 × 5²', '2 × 15'], 0,
  '30 = 2 × 3 × 5.', 2),
('57a8df6f-0a57-4e45-a32b-feab275585a1', 'Qual é a fatoração em números primos de 100?',
  array['2² × 5²', '2 × 5³', '2³ × 5', '10²'], 0,
  '100 = 4 × 25 = 2² × 5².', 3),
('57a8df6f-0a57-4e45-a32b-feab275585a1', 'Qual é a fatoração em números primos de 36?',
  array['2² × 3²', '2 × 3³', '2³ × 3', '4 × 9'], 0,
  '36 = 4 × 9 = 2² × 3².', 4),
('57a8df6f-0a57-4e45-a32b-feab275585a1', 'Qual é a fatoração em números primos de 45?',
  array['3² × 5', '3 × 5²', '9 × 5', '3² × 5²'], 0,
  '45 = 9 × 5 = 3² × 5.', 5);

-- MMC e MDC (7ee4230f-60aa-49b2-a78b-7e6465e0261e)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('7ee4230f-60aa-49b2-a78b-7e6465e0261e', 'Qual é o MMC (Mínimo Múltiplo Comum) entre 4 e 6?',
  array['12', '24', '10', '6'], 0,
  'Múltiplos de 4: 4, 8, 12... Múltiplos de 6: 6, 12... O menor comum é 12.', 1),
('7ee4230f-60aa-49b2-a78b-7e6465e0261e', 'Qual é o MDC (Máximo Divisor Comum) entre 12 e 18?',
  array['6', '3', '9', '12'], 0,
  'Os divisores comuns de 12 e 18 são 1, 2, 3 e 6. O maior é 6.', 2),
('7ee4230f-60aa-49b2-a78b-7e6465e0261e', 'Qual é o MMC entre 3 e 5?',
  array['15', '8', '10', '3'], 0,
  'Como 3 e 5 não têm fatores em comum, o MMC é o produto entre eles: 15.', 3),
('7ee4230f-60aa-49b2-a78b-7e6465e0261e', 'Qual é o MDC entre 8 e 12?',
  array['4', '2', '8', '24'], 0,
  'Os divisores comuns de 8 e 12 são 1, 2 e 4. O maior é 4.', 4),
('7ee4230f-60aa-49b2-a78b-7e6465e0261e', 'O MDC entre dois números primos entre si (sem fatores comuns) é sempre?',
  array['1', '0', 'O produto dos dois', 'Igual ao menor deles'], 0,
  'Números primos entre si, por definição, não compartilham nenhum fator além do 1.', 5);
