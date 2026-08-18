-- Classificacao de dificuldade — GEOGRAFIA (230 questoes de multipla escolha; nao afeta os quizzes de mapa).
-- So marca 'facil' e 'dificil'; o resto permanece 'medio'. Idempotente.

-- ===== Brasil =====
update questions set difficulty='facil'   where catalog_node_id='e1fc8704-0f8f-40c0-8083-b9830200e2a0' and order_index in (1,3);     -- Territorio
update questions set difficulty='facil'   where catalog_node_id='c2ee332a-93df-4032-b968-8d3f4c859250' and order_index in (1,3);     -- Relevo
update questions set difficulty='dificil' where catalog_node_id='c2ee332a-93df-4032-b968-8d3f4c859250' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='421fb392-005c-454f-a735-8c430672cd5e' and order_index in (1,4);     -- Biomas e vegetacao
update questions set difficulty='dificil' where catalog_node_id='421fb392-005c-454f-a735-8c430672cd5e' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='1d8e2476-b39c-452a-83ab-dc6b973c000d' and order_index in (1,2);     -- Clima
update questions set difficulty='dificil' where catalog_node_id='1d8e2476-b39c-452a-83ab-dc6b973c000d' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='e85aad6a-8b81-41c2-8952-3010f13c5fb8' and order_index in (1,2);     -- Cidades
update questions set difficulty='facil'   where catalog_node_id='17b0d454-779f-4859-8380-470d5e4ddf23' and order_index in (2,3);     -- Geografia humana
update questions set difficulty='facil'   where catalog_node_id='3da92cbb-f674-4829-ad98-d346809fcb78' and order_index in (1,2);     -- Geografia economica
update questions set difficulty='dificil' where catalog_node_id='3da92cbb-f674-4829-ad98-d346809fcb78' and order_index in (3);

-- ===== Hidrografia =====
update questions set difficulty='facil'   where catalog_node_id='19ff93e1-6e9b-4f31-a0d1-0c1501339130' and order_index in (1,3,4);   -- Principais rios do Brasil
update questions set difficulty='facil'   where catalog_node_id='d5cb9910-b35e-4b55-a2fd-f0a975e28c2a' and order_index in (2,4);     -- Bacias hidrograficas
update questions set difficulty='dificil' where catalog_node_id='d5cb9910-b35e-4b55-a2fd-f0a975e28c2a' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='fa2a77cc-acc8-4010-91b0-d3f600d7dab1' and order_index in (1,2,5);   -- Rio Amazonas e afluentes
update questions set difficulty='facil'   where catalog_node_id='32c25d44-9f51-4d08-9767-d15a6cb09f8b' and order_index in (2,3,4);   -- Rio Parana e afluentes
update questions set difficulty='facil'   where catalog_node_id='f8a0db60-38ed-4512-89a3-addf95defa11' and order_index in (1,4);     -- Rio Sao Francisco e afluentes
update questions set difficulty='dificil' where catalog_node_id='f8a0db60-38ed-4512-89a3-addf95defa11' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='3d3fa6fe-b7fb-4e32-8fb7-bba2482fa0ab' and order_index in (1,3,5);   -- Rios da Regiao Norte
update questions set difficulty='facil'   where catalog_node_id='2095a633-a9fa-4276-8a1b-2706f22380b7' and order_index in (1);       -- Rios da Regiao Nordeste
update questions set difficulty='dificil' where catalog_node_id='2095a633-a9fa-4276-8a1b-2706f22380b7' and order_index in (2,3);
update questions set difficulty='facil'   where catalog_node_id='d8d82add-d42c-4609-9e28-8160f20bf1a3' and order_index in (1,5);     -- Rios da Regiao Centro-Oeste
update questions set difficulty='dificil' where catalog_node_id='d8d82add-d42c-4609-9e28-8160f20bf1a3' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='8065021b-5ec4-4470-bc6b-a743898a5955' and order_index in (1);       -- Rios da Regiao Sudeste
update questions set difficulty='facil'   where catalog_node_id='39e51a80-1df3-4d6d-9652-a25f10b2424f' and order_index in (1,2,3);   -- Rios da Regiao Sul
update questions set difficulty='dificil' where catalog_node_id='39e51a80-1df3-4d6d-9652-a25f10b2424f' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='291853ce-ec62-4e00-baad-3bc93128bebe' and order_index in (1,2,3,4,5); -- Principais hidreletricas

-- ===== Mundo =====
update questions set difficulty='facil'   where catalog_node_id='b836a0bd-abe7-4cdb-bcd4-6f8f6468d569' and order_index in (1,2,3);   -- Continentes
update questions set difficulty='dificil' where catalog_node_id='b836a0bd-abe7-4cdb-bcd4-6f8f6468d569' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='ea820801-fbfb-4e37-adad-d3183549f66b' and order_index in (1,2,3);   -- Oceanos
update questions set difficulty='dificil' where catalog_node_id='ea820801-fbfb-4e37-adad-d3183549f66b' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='cf19dc0c-5419-4c3a-adb5-3110aab30085' and order_index in (1,5);     -- Mares
update questions set difficulty='facil'   where catalog_node_id='fecad808-3cd6-4ddd-818b-e3d612641ee5' and order_index in (1,2,3);   -- Grandes cordilheiras
update questions set difficulty='dificil' where catalog_node_id='fecad808-3cd6-4ddd-818b-e3d612641ee5' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='219bc852-f7c0-4ba9-9c29-4bc6339eae7d' and order_index in (2,5);     -- Desertos
update questions set difficulty='dificil' where catalog_node_id='219bc852-f7c0-4ba9-9c29-4bc6339eae7d' and order_index in (1);
update questions set difficulty='facil'   where catalog_node_id='4f527027-310f-4c38-8269-328fb6741d06' and order_index in (1,3,5);   -- Ilhas
update questions set difficulty='dificil' where catalog_node_id='4f527027-310f-4c38-8269-328fb6741d06' and order_index in (2);
update questions set difficulty='facil'   where catalog_node_id='458454b8-1e00-4241-9f27-9f072ba586fe' and order_index in (1,2,5);   -- Vulcoes
update questions set difficulty='facil'   where catalog_node_id='be84da4e-f4ab-4a4a-a406-9a05e49917d4' and order_index in (1,2);     -- Linhas imaginarias
update questions set difficulty='dificil' where catalog_node_id='be84da4e-f4ab-4a4a-a406-9a05e49917d4' and order_index in (4);

-- ===== Asia =====
update questions set difficulty='facil'   where catalog_node_id='6f5b44f6-3f1f-462f-a9e3-c34c2c8b0620' and order_index in (2);       -- Mares
update questions set difficulty='dificil' where catalog_node_id='6f5b44f6-3f1f-462f-a9e3-c34c2c8b0620' and order_index in (1,5);
update questions set difficulty='facil'   where catalog_node_id='f9ddd491-8916-4c61-89ec-55ef3394ede1' and order_index in (1,2,5);   -- Cordilheiras
update questions set difficulty='dificil' where catalog_node_id='f9ddd491-8916-4c61-89ec-55ef3394ede1' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='4aaed524-89fd-452f-bfd3-b85e6ba7bbcd' and order_index in (1,5);     -- Desertos
update questions set difficulty='dificil' where catalog_node_id='4aaed524-89fd-452f-bfd3-b85e6ba7bbcd' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='54e2d513-1aca-4dcb-919c-c701ae13b47b' and order_index in (1,2,5);   -- Oriente Medio
update questions set difficulty='dificil' where catalog_node_id='54e2d513-1aca-4dcb-919c-c701ae13b47b' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='ed3c676d-d6e4-45e7-937b-c3e4178be67e' and order_index in (1,5);     -- Sudeste Asiatico
update questions set difficulty='dificil' where catalog_node_id='ed3c676d-d6e4-45e7-937b-c3e4178be67e' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='0610487b-0326-483f-9176-e0f3e54f5b12' and order_index in (1,3);     -- Sul da Asia
update questions set difficulty='facil'   where catalog_node_id='a27dfbf2-4b16-442c-a302-7a47d7eae57a' and order_index in (1,2,3);   -- Asia Central

-- ===== Europa =====
update questions set difficulty='facil'   where catalog_node_id='024a3408-7afd-4ae5-87a7-d01e94a4cc5d' and order_index in (2,5);     -- Lagos e mares
update questions set difficulty='dificil' where catalog_node_id='024a3408-7afd-4ae5-87a7-d01e94a4cc5d' and order_index in (1);
update questions set difficulty='facil'   where catalog_node_id='39cd3699-9134-4ae4-a810-bf5854cc893e' and order_index in (1,5);     -- Montanhas e cordilheiras
update questions set difficulty='dificil' where catalog_node_id='39cd3699-9134-4ae4-a810-bf5854cc893e' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='317fe9ba-4cc0-45be-8f55-89b8ac9f951d' and order_index in (1,2);     -- Regioes
update questions set difficulty='facil'   where catalog_node_id='cfe523b9-6edd-4b76-85ac-76bcbf1b49ba' and order_index in (1,4);     -- Geografia historica
update questions set difficulty='dificil' where catalog_node_id='cfe523b9-6edd-4b76-85ac-76bcbf1b49ba' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='a68d37cf-fbfd-421f-b4ee-0345138f868c' and order_index in (1,2,3,5); -- Pontos turisticos

-- ===== America do Sul =====
update questions set difficulty='facil'   where catalog_node_id='651d1ca4-bfd4-48a2-802b-15fd15786685' and order_index in (1,3,5);   -- Relevo
update questions set difficulty='facil'   where catalog_node_id='16effb57-67b7-4aa0-9d12-9c77a863097b' and order_index in (1,2);     -- Biomas
update questions set difficulty='dificil' where catalog_node_id='16effb57-67b7-4aa0-9d12-9c77a863097b' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='9d06b616-e4e7-4d43-9526-719c3e8a6d1c' and order_index in (1,3);     -- Divisoes administrativas
update questions set difficulty='dificil' where catalog_node_id='9d06b616-e4e7-4d43-9526-719c3e8a6d1c' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='81783211-0d77-45eb-9444-94b49ec16201' and order_index in (1,2,3);   -- Pontos turisticos

-- ===== Africa =====
update questions set difficulty='facil'   where catalog_node_id='83bb1fe7-ca34-46c4-8f12-9dcb0ddb7fa4' and order_index in (1,5);     -- Lagos
update questions set difficulty='dificil' where catalog_node_id='83bb1fe7-ca34-46c4-8f12-9dcb0ddb7fa4' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='11e4ec76-57ff-4ea6-9068-7d8cc2f9ecdc' and order_index in (1,5);     -- Desertos
update questions set difficulty='dificil' where catalog_node_id='11e4ec76-57ff-4ea6-9068-7d8cc2f9ecdc' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='7b96b08c-035a-4cd7-a7b8-e071c3d22d39' and order_index in (1);       -- Relevo
update questions set difficulty='dificil' where catalog_node_id='7b96b08c-035a-4cd7-a7b8-e071c3d22d39' and order_index in (2);
update questions set difficulty='facil'   where catalog_node_id='4764c0da-a7f1-4cea-a2f9-25a32420095e' and order_index in (1,2);     -- Regioes africanas
