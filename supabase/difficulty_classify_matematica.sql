-- Classificacao de dificuldade — MATEMATICA (170 questoes).
-- So marca 'facil' e 'dificil'; o resto permanece 'medio'. Idempotente.

-- ===== Fundamentos =====
update questions set difficulty='facil'   where catalog_node_id='9751f8f3-54ba-466d-9ff2-1369e393ee4f' and order_index in (2,5);       -- Numeros (conjuntos)
update questions set difficulty='facil'   where catalog_node_id='63193752-9df4-4e14-a28c-423863dcdaf3' and order_index in (1,2);       -- Operacoes basicas
update questions set difficulty='facil'   where catalog_node_id='8d65ae08-ddf2-4dfd-badd-6476500448a6' and order_index in (3,4);       -- Fracoes
update questions set difficulty='facil'   where catalog_node_id='4c39e2ed-67c8-482d-af15-6ae32fc86389' and order_index in (2,4);       -- Numeros decimais
update questions set difficulty='dificil' where catalog_node_id='4c39e2ed-67c8-482d-af15-6ae32fc86389' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='42d19683-3191-437b-8c14-4edc7c66b826' and order_index in (1,3);       -- Potenciacao e radiciacao
update questions set difficulty='dificil' where catalog_node_id='42d19683-3191-437b-8c14-4edc7c66b826' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='6225352f-06bf-428a-b8bb-3a523f9f1c0b' and order_index in (1,3,5);     -- Criterios de divisibilidade
update questions set difficulty='facil'   where catalog_node_id='7a538d1e-a300-4f02-8d84-4d488e645591' and order_index in (1);         -- Numeros primos
update questions set difficulty='dificil' where catalog_node_id='7a538d1e-a300-4f02-8d84-4d488e645591' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='57a8df6f-0a57-4e45-a32b-feab275585a1' and order_index in (1,4);       -- Fatoracao (numeros)
update questions set difficulty='facil'   where catalog_node_id='7ee4230f-60aa-49b2-a78b-7e6465e0261e' and order_index in (1,2);       -- MMC e MDC
update questions set difficulty='dificil' where catalog_node_id='7ee4230f-60aa-49b2-a78b-7e6465e0261e' and order_index in (5);

-- ===== Algebra =====
update questions set difficulty='facil'   where catalog_node_id='0363eefa-224b-4f7f-949b-118e86b2a3e8' and order_index in (1,3,4);     -- Razao, proporcao e porcentagem
update questions set difficulty='dificil' where catalog_node_id='0363eefa-224b-4f7f-949b-118e86b2a3e8' and order_index in (2);
update questions set difficulty='facil'   where catalog_node_id='b6cba9af-45d2-456f-96d6-912a5d468261' and order_index in (1,2,3);     -- Expressoes algebricas
update questions set difficulty='facil'   where catalog_node_id='a1f647ec-40c6-4b93-b102-cded53c50431' and order_index in (1,2,4);     -- Produtos notaveis
update questions set difficulty='dificil' where catalog_node_id='a1f647ec-40c6-4b93-b102-cded53c50431' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='34da53ba-be37-4cb3-b1cb-ebdcae782991' and order_index in (3,4);       -- Fatoracao (algebra)
update questions set difficulty='dificil' where catalog_node_id='34da53ba-be37-4cb3-b1cb-ebdcae782991' and order_index in (2);
update questions set difficulty='facil'   where catalog_node_id='9a31b7e7-652e-490f-a9db-d7ffbb634774' and order_index in (1,2);       -- Equacao do 1o grau
update questions set difficulty='dificil' where catalog_node_id='9a31b7e7-652e-490f-a9db-d7ffbb634774' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='db814794-c73b-483b-8aa9-78927f551afd' and order_index in (1,3);       -- Equacao do 2o grau
update questions set difficulty='dificil' where catalog_node_id='db814794-c73b-483b-8aa9-78927f551afd' and order_index in (2);
update questions set difficulty='facil'   where catalog_node_id='815e802e-a4dd-4f2c-ab27-c1715a433bf2' and order_index in (1,2);       -- Equacoes fracionarias
update questions set difficulty='dificil' where catalog_node_id='815e802e-a4dd-4f2c-ab27-c1715a433bf2' and order_index in (4,5);
update questions set difficulty='facil'   where catalog_node_id='35d26944-58a3-43d6-868c-c04705be6487' and order_index in (1,3);       -- Equacoes irracionais
update questions set difficulty='dificil' where catalog_node_id='35d26944-58a3-43d6-868c-c04705be6487' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='4cf8f783-8ebd-426e-859b-6c5692e4e9ce' and order_index in (1,2,4);     -- Equacoes exponenciais
update questions set difficulty='dificil' where catalog_node_id='4cf8f783-8ebd-426e-859b-6c5692e4e9ce' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='d8d2ce85-4316-4b16-ae86-12483e8ba748' and order_index in (1,3);       -- Sistemas de equacoes
update questions set difficulty='dificil' where catalog_node_id='d8d2ce85-4316-4b16-ae86-12483e8ba748' and order_index in (2);
update questions set difficulty='facil'   where catalog_node_id='ad24dbee-1914-4cf1-962a-f6358926b8b8' and order_index in (1,2,5);     -- Inequacoes
update questions set difficulty='dificil' where catalog_node_id='ad24dbee-1914-4cf1-962a-f6358926b8b8' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='c4dc4513-74fe-418c-8f0a-aa8910676246' and order_index in (1,3,4);     -- Polinomios

-- ===== Funcoes e Geometria =====
update questions set difficulty='facil'   where catalog_node_id='a8a0b1df-a556-4d34-ac80-99f5e750921e' and order_index in (1,2,3);     -- Funcoes
update questions set difficulty='facil'   where catalog_node_id='799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c' and order_index in (1,3);       -- Geometria plana
update questions set difficulty='facil'   where catalog_node_id='b219eae9-446c-4831-aae9-357f67cb8a75' and order_index in (1,3);       -- Geometria espacial
update questions set difficulty='dificil' where catalog_node_id='b219eae9-446c-4831-aae9-357f67cb8a75' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='834539eb-c22c-4c35-acff-24cbf082d4e2' and order_index in (2,3,4);     -- Geometria analitica
update questions set difficulty='dificil' where catalog_node_id='834539eb-c22c-4c35-acff-24cbf082d4e2' and order_index in (1);
update questions set difficulty='facil'   where catalog_node_id='1d9499bd-c3f9-4228-9deb-81951feb605c' and order_index in (1,2,3);     -- Trigonometria
update questions set difficulty='dificil' where catalog_node_id='1d9499bd-c3f9-4228-9deb-81951feb605c' and order_index in (5);

-- ===== Diversos =====
update questions set difficulty='facil'   where catalog_node_id='eaf55158-60df-41a1-a5e4-06a810df3d53' and order_index in (1,3,4);     -- Sequencias e progressoes
update questions set difficulty='facil'   where catalog_node_id='184775e6-5bcb-4648-80d5-e7d97ee02af7' and order_index in (1,2,3);     -- Probabilidade
update questions set difficulty='facil'   where catalog_node_id='17a0936f-4a79-47a2-9d8d-7b40c17c46bb' and order_index in (1,2);       -- Analise combinatoria
update questions set difficulty='facil'   where catalog_node_id='847f1a39-37fd-46ae-9005-51f6fd129221' and order_index in (1,2,3);     -- Estatistica
update questions set difficulty='dificil' where catalog_node_id='847f1a39-37fd-46ae-9005-51f6fd129221' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='47f9a514-4c99-4d8b-acb4-f9a8f8740916' and order_index in (1,2,4);     -- Matematica financeira
update questions set difficulty='dificil' where catalog_node_id='47f9a514-4c99-4d8b-acb4-f9a8f8740916' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='e60b341c-e9bd-4e61-8d78-7710a0b79d34' and order_index in (1,2,3);     -- Conjuntos
update questions set difficulty='facil'   where catalog_node_id='0b735557-66a3-42f2-baa2-69fb5e66e7e6' and order_index in (1);         -- Raciocinio logico
update questions set difficulty='dificil' where catalog_node_id='0b735557-66a3-42f2-baa2-69fb5e66e7e6' and order_index in (3,5);
update questions set difficulty='facil'   where catalog_node_id='19f2971b-4602-48d5-81d3-85f7f898d65b' and order_index in (2,4,5);     -- Conteudos avancados
