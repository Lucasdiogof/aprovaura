-- Classificacao de dificuldade — PORTUGUES (138 questoes).
-- So marca 'facil' e 'dificil'; o resto permanece 'medio'. Idempotente.

-- ===== Concordancia e regencia =====
update questions set difficulty='facil'   where catalog_node_id='bab8c7fa-d87c-40af-9233-15430973131c' and order_index in (2);         -- Concordancia verbal
update questions set difficulty='dificil' where catalog_node_id='bab8c7fa-d87c-40af-9233-15430973131c' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='722ebf8c-3c85-43e1-a1c9-8469fa704939' and order_index in (2);         -- Concordancia nominal
update questions set difficulty='dificil' where catalog_node_id='722ebf8c-3c85-43e1-a1c9-8469fa704939' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='68cee128-2eef-4976-9666-bd7f350ede5b' and order_index in (3);         -- Regencia verbal
update questions set difficulty='dificil' where catalog_node_id='68cee128-2eef-4976-9666-bd7f350ede5b' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='bfef7570-b2ba-4900-a90d-0f20290faa61' and order_index in (1,2,4);     -- Regencia nominal

-- ===== Crase =====
update questions set difficulty='facil'   where catalog_node_id='dcb45577-a87e-4388-8653-846ef83e2e15' and order_index in (1,2);       -- Casos obrigatorios
update questions set difficulty='dificil' where catalog_node_id='dcb45577-a87e-4388-8653-846ef83e2e15' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='9ce83537-830c-4917-81f7-34ecdd190e04' and order_index in (1,2,3);     -- Casos proibidos
update questions set difficulty='dificil' where catalog_node_id='9ce83537-830c-4917-81f7-34ecdd190e04' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='4eea3b08-cfd1-4658-98b0-98af83d3df62' and order_index in (3,4,5);     -- Casos facultativos
update questions set difficulty='facil'   where catalog_node_id='1badbb7e-4488-4334-bbf5-6403153e2872' and order_index in (1,2,3);     -- Locucoes
update questions set difficulty='dificil' where catalog_node_id='1badbb7e-4488-4334-bbf5-6403153e2872' and order_index in (5);

-- ===== Areas gerais =====
update questions set difficulty='facil'   where catalog_node_id='282f04a3-1ac5-45ca-93d0-79ebb055890c' and order_index in (1,2,3,4);   -- Gramatica
update questions set difficulty='dificil' where catalog_node_id='282f04a3-1ac5-45ca-93d0-79ebb055890c' and order_index in (6);
update questions set difficulty='facil'   where catalog_node_id='6328fd95-8026-4dc2-8cdc-40bcaf543628' and order_index in (1,5,6,7);   -- Sintaxe
update questions set difficulty='dificil' where catalog_node_id='6328fd95-8026-4dc2-8cdc-40bcaf543628' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='7a5990be-75cb-47a5-a2c9-2ecafee8af28' and order_index in (1,4,8);     -- Ortografia e acentuacao
update questions set difficulty='dificil' where catalog_node_id='7a5990be-75cb-47a5-a2c9-2ecafee8af28' and order_index in (5,6);
update questions set difficulty='facil'   where catalog_node_id='f25a58d3-8d53-4fda-abee-4ee3cb708b26' and order_index in (2,3,4,6);   -- Semantica
update questions set difficulty='dificil' where catalog_node_id='f25a58d3-8d53-4fda-abee-4ee3cb708b26' and order_index in (8);
update questions set difficulty='facil'   where catalog_node_id='3489b617-c328-4af1-bd3d-7a84dd343f79' and order_index in (1,2,6,8);   -- Redacao
update questions set difficulty='dificil' where catalog_node_id='3489b617-c328-4af1-bd3d-7a84dd343f79' and order_index in (7);
update questions set difficulty='facil'   where catalog_node_id='a0caa678-52be-4ae4-9251-8f26e0ca476c' and order_index in (3,4,5);     -- Literatura
update questions set difficulty='dificil' where catalog_node_id='a0caa678-52be-4ae4-9251-8f26e0ca476c' and order_index in (8);

-- ===== Interpretacao de texto =====
update questions set difficulty='facil'   where catalog_node_id='8fe5bf1c-3e9f-4d21-9a31-f993693afaac' and order_index in (1,3);       -- Compreensao textual
update questions set difficulty='facil'   where catalog_node_id='44d0f715-a155-43e0-8b7b-96afdfaa2cdd' and order_index in (1,4);       -- Tema e assunto
update questions set difficulty='dificil' where catalog_node_id='44d0f715-a155-43e0-8b7b-96afdfaa2cdd' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='2e4619ba-f64c-4e10-87cd-50e6b21b4c69' and order_index in (1,3);       -- Ideia principal
update questions set difficulty='dificil' where catalog_node_id='2e4619ba-f64c-4e10-87cd-50e6b21b4c69' and order_index in (2);
update questions set difficulty='facil'   where catalog_node_id='5ba08373-5941-4b7f-8cd7-596108ce31d3' and order_index in (1,2);       -- Informacoes explicitas
update questions set difficulty='facil'   where catalog_node_id='c90c0ff6-432c-4ec2-bad7-6cad9bde3a70' and order_index in (2,4);       -- Informacoes implicitas
update questions set difficulty='dificil' where catalog_node_id='c90c0ff6-432c-4ec2-bad7-6cad9bde3a70' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='cb1d24d0-03e9-4017-ab28-d5fc087bcedb' and order_index in (2);         -- Inferencia
update questions set difficulty='dificil' where catalog_node_id='cb1d24d0-03e9-4017-ab28-d5fc087bcedb' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='6a66a026-2fd0-4874-8216-4cdc03e6744e' and order_index in (1,4,5);     -- Intencao do autor
update questions set difficulty='facil'   where catalog_node_id='7715e4c7-fa79-47be-9cdf-ea20ca7b2db6' and order_index in (1,2);       -- Argumentacao
update questions set difficulty='dificil' where catalog_node_id='7715e4c7-fa79-47be-9cdf-ea20ca7b2db6' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='6528814e-981a-48c0-959c-b4969beb0ebd' and order_index in (1,4);       -- Fato x opiniao
update questions set difficulty='facil'   where catalog_node_id='c158ce9d-b7ad-4cc6-ab9c-8ad373022d8a' and order_index in (1,5);       -- Coesao e coerencia textual
