-- Classificacao de dificuldade — HISTORIA (146 questoes).
-- So marca 'facil' e 'dificil'; o resto permanece 'medio'. Idempotente.

-- ===== Brasil Colonia ate Republica Velha =====
update questions set difficulty='facil'   where catalog_node_id='4387fdad-2724-4b69-be79-970eaf8f168a' and order_index in (1,2,3);   -- Povos indigenas
update questions set difficulty='dificil' where catalog_node_id='4387fdad-2724-4b69-be79-970eaf8f168a' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='ad10464d-0d11-4255-9fef-d341a0f856d6' and order_index in (2,5);     -- Brasil Colonial
update questions set difficulty='facil'   where catalog_node_id='8e6bf89f-70bf-4ecd-b680-e2ee171d41fc' and order_index in (1,3);     -- Independencia
update questions set difficulty='dificil' where catalog_node_id='8e6bf89f-70bf-4ecd-b680-e2ee171d41fc' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='f479bffd-9b8d-4b42-aa90-b17fb95862f4' and order_index in (1,4,5);   -- Brasil Imperio
update questions set difficulty='dificil' where catalog_node_id='f479bffd-9b8d-4b42-aa90-b17fb95862f4' and order_index in (2);
update questions set difficulty='facil'   where catalog_node_id='602710f8-5c91-44c0-adf0-88b0cf87f333' and order_index in (1,2);     -- Republica Velha
update questions set difficulty='dificil' where catalog_node_id='602710f8-5c91-44c0-adf0-88b0cf87f333' and order_index in (5);

-- ===== Era Vargas =====
update questions set difficulty='facil'   where catalog_node_id='d8a3ff73-b95d-4c49-8438-a6f562936779' and order_index in (1,3,5);   -- Revolucao de 1930
update questions set difficulty='facil'   where catalog_node_id='b75f4f86-6f0d-4ebd-895f-5fb3118d35ca' and order_index in (1,4,5);   -- Governo Provisorio
update questions set difficulty='facil'   where catalog_node_id='b0581df7-1582-41b8-95f9-c2addfb47ddf' and order_index in (1,2);     -- Governo Constitucional
update questions set difficulty='dificil' where catalog_node_id='b0581df7-1582-41b8-95f9-c2addfb47ddf' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='3a099505-6721-49f2-8633-8aa2b613a762' and order_index in (1,2,3);   -- Constituicao de 1937
update questions set difficulty='dificil' where catalog_node_id='3a099505-6721-49f2-8633-8aa2b613a762' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='2065151d-f988-43b0-b8d9-f784cbec1278' and order_index in (1,4);     -- Trabalhismo
update questions set difficulty='facil'   where catalog_node_id='8cdb0962-4694-476e-9c83-9cb807353e6c' and order_index in (1,2,5);   -- DIP
update questions set difficulty='facil'   where catalog_node_id='87dcdeae-bf22-493e-a53a-6f09c878f224' and order_index in (1,5);     -- Intentona Comunista
update questions set difficulty='dificil' where catalog_node_id='87dcdeae-bf22-493e-a53a-6f09c878f224' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='b134a54a-0add-4719-8e97-0f28c82bc7a5' and order_index in (1,4);     -- Integralismo
update questions set difficulty='dificil' where catalog_node_id='b134a54a-0add-4719-8e97-0f28c82bc7a5' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='b32513cb-a94e-4040-a310-2c97c607bed4' and order_index in (1,2,3);   -- Brasil na 2a Guerra
update questions set difficulty='dificil' where catalog_node_id='b32513cb-a94e-4040-a310-2c97c607bed4' and order_index in (4,5);
update questions set difficulty='facil'   where catalog_node_id='0384be9b-0291-4535-b984-c77bb61c1611' and order_index in (2,5);     -- Fim do Estado Novo
update questions set difficulty='dificil' where catalog_node_id='0384be9b-0291-4535-b984-c77bb61c1611' and order_index in (4);

-- ===== Brasil Contemporaneo =====
update questions set difficulty='facil'   where catalog_node_id='5508a9c1-91a7-463b-bf08-a36f296d2251' and order_index in (1,2,3);   -- Republica de 1946
update questions set difficulty='dificil' where catalog_node_id='5508a9c1-91a7-463b-bf08-a36f296d2251' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='5bc5ce90-bf36-45a1-97fc-156a2423ae89' and order_index in (2,4,5);   -- Ditadura Militar
update questions set difficulty='dificil' where catalog_node_id='5bc5ce90-bf36-45a1-97fc-156a2423ae89' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='7740f68e-21bc-47e1-8052-848e287f27dd' and order_index in (1,2,3,5); -- Nova Republica
update questions set difficulty='dificil' where catalog_node_id='7740f68e-21bc-47e1-8052-848e287f27dd' and order_index in (4);

-- ===== Areas gerais (Antiguidade, Idade Media/Moderna/Contemporanea, America, Africa, Grandes temas) =====
update questions set difficulty='facil'   where catalog_node_id='143ae168-abcf-4512-a0c7-3c67e34e9fcb' and order_index in (1,2,4,5,8); -- Antiguidade
update questions set difficulty='dificil' where catalog_node_id='143ae168-abcf-4512-a0c7-3c67e34e9fcb' and order_index in (7);
update questions set difficulty='facil'   where catalog_node_id='c14f34bc-fdf8-4797-88a6-14fafbad4194' and order_index in (4,5,6,8); -- Idade Media
update questions set difficulty='dificil' where catalog_node_id='c14f34bc-fdf8-4797-88a6-14fafbad4194' and order_index in (2);
update questions set difficulty='facil'   where catalog_node_id='e93f87be-ca79-4813-9a67-616320aa9a8a' and order_index in (1,3,6,7); -- Idade Moderna
update questions set difficulty='dificil' where catalog_node_id='e93f87be-ca79-4813-9a67-616320aa9a8a' and order_index in (8);
update questions set difficulty='facil'   where catalog_node_id='9d1627ca-eade-4dcf-83dc-a1acfcd096c8' and order_index in (1,3,5,7,8); -- Idade Contemporanea
update questions set difficulty='facil'   where catalog_node_id='3a6764c6-67a5-4941-b3c0-aa0b5e17a190' and order_index in (1,2,4,7,8); -- Historia da America
update questions set difficulty='dificil' where catalog_node_id='3a6764c6-67a5-4941-b3c0-aa0b5e17a190' and order_index in (6);
update questions set difficulty='facil'   where catalog_node_id='43bff7ca-8f49-46a3-b757-e20105c00ad2' and order_index in (1,2,3,4,7,8); -- Historia da Africa
update questions set difficulty='dificil' where catalog_node_id='43bff7ca-8f49-46a3-b757-e20105c00ad2' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='b5a0f0a7-33bf-4676-86aa-073a0d0f5426' and order_index in (1,3,8);    -- Grandes temas historicos
update questions set difficulty='dificil' where catalog_node_id='b5a0f0a7-33bf-4676-86aa-073a0d0f5426' and order_index in (5,6);
