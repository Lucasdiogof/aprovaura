-- Classificacao de dificuldade — FISICA (173 questoes).
-- So marca 'facil' e 'dificil'; o resto permanece 'medio'. Idempotente.

-- ===== Cinematica =====
update questions set difficulty='facil'   where catalog_node_id='8298e55f-972f-4aef-9447-bff9347da0b7' and order_index in (1,2,3); -- Movimento uniforme
update questions set difficulty='dificil' where catalog_node_id='8298e55f-972f-4aef-9447-bff9347da0b7' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='67153ecb-1781-4067-8650-94cb1de96321' and order_index in (1,2,3,5); -- Aceleracao
update questions set difficulty='facil'   where catalog_node_id='d8f64aef-8abc-45da-9e5d-501798c0d345' and order_index in (1);     -- MUV
update questions set difficulty='facil'   where catalog_node_id='95ca3ad3-5c40-4ccc-b0d0-0c54e2105207' and order_index in (1,2);   -- Queda livre
update questions set difficulty='dificil' where catalog_node_id='95ca3ad3-5c40-4ccc-b0d0-0c54e2105207' and order_index in (5);
update questions set difficulty='dificil' where catalog_node_id='b6821cec-74b2-4da2-8026-8d821f82f15d' and order_index in (3);     -- Lancamento horizontal
update questions set difficulty='facil'   where catalog_node_id='92e52c60-4571-450a-99cc-e6e840caa2f8' and order_index in (1);     -- Lancamento obliquo
update questions set difficulty='dificil' where catalog_node_id='92e52c60-4571-450a-99cc-e6e840caa2f8' and order_index in (5);

-- ===== Dinamica, Trabalho e energia, Gravitacao =====
update questions set difficulty='facil'   where catalog_node_id='a5777654-961e-4813-9fed-c5d835825966' and order_index in (1);     -- 1a Lei de Newton
update questions set difficulty='facil'   where catalog_node_id='9df1808d-9ac5-4809-8bdb-63e12480aa97' and order_index in (1,2,3,4); -- 2a Lei de Newton
update questions set difficulty='facil'   where catalog_node_id='a1fea6a5-c59f-43d7-8ba9-0e6865d95221' and order_index in (1);     -- 3a Lei de Newton
update questions set difficulty='facil'   where catalog_node_id='88d296cd-2bea-41f5-ad96-3bf158827298' and order_index in (1,2,5); -- Forca peso
update questions set difficulty='facil'   where catalog_node_id='ea8116d3-4182-4be6-a7b6-73f969adb43d' and order_index in (1,2);   -- Forca normal
update questions set difficulty='dificil' where catalog_node_id='ea8116d3-4182-4be6-a7b6-73f969adb43d' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='fea10bb2-7f2f-40f8-baaf-e398343701aa' and order_index in (1,5);   -- Atrito
update questions set difficulty='dificil' where catalog_node_id='7e0cc321-55aa-4635-b067-8ab32d376084' and order_index in (3);     -- Plano inclinado
update questions set difficulty='facil'   where catalog_node_id='f394659b-6de0-4d60-a1bf-4935db2b35b5' and order_index in (1,2,3); -- Trabalho e energia
update questions set difficulty='dificil' where catalog_node_id='e5d65d25-c4b5-40b9-8c2a-641f4c56e0bb' and order_index in (2);     -- Gravitacao

-- ===== Areas gerais (Termologia, Ondulatoria, Eletricidade, Magnetismo, Fluidos, Fisica Moderna) =====
update questions set difficulty='facil'   where catalog_node_id='c11d5ba1-65e8-487a-96e0-38e15a64af15' and order_index in (1,2,3,4); -- Termologia
update questions set difficulty='dificil' where catalog_node_id='c11d5ba1-65e8-487a-96e0-38e15a64af15' and order_index in (5,7,8);
update questions set difficulty='facil'   where catalog_node_id='8f3b95a7-93f3-4d62-b383-d9b66d005f08' and order_index in (1,3,4); -- Ondulatoria
update questions set difficulty='dificil' where catalog_node_id='8f3b95a7-93f3-4d62-b383-d9b66d005f08' and order_index in (8);
update questions set difficulty='facil'   where catalog_node_id='89939da9-3bec-40f4-826d-514c063a9351' and order_index in (2,3,6,8); -- Eletricidade
update questions set difficulty='facil'   where catalog_node_id='2678423c-4c04-4815-aea0-c4568078732e' and order_index in (1,2);   -- Magnetismo
update questions set difficulty='facil'   where catalog_node_id='bf4b630c-1de1-4cdd-9cbf-f31c70007234' and order_index in (1);     -- Fluidos
update questions set difficulty='dificil' where catalog_node_id='bf4b630c-1de1-4cdd-9cbf-f31c70007234' and order_index in (6,8);
update questions set difficulty='facil'   where catalog_node_id='85e6f278-d298-4e1f-aca8-e602debf1051' and order_index in (2);     -- Fisica Moderna
update questions set difficulty='dificil' where catalog_node_id='85e6f278-d298-4e1f-aca8-e602debf1051' and order_index in (6);

-- ===== Optica (Espelhos + Lentes) =====
update questions set difficulty='facil'   where catalog_node_id='3d47f86a-ebcd-4a53-8742-71245315dc79' and order_index in (1);     -- Espelho concavo
update questions set difficulty='dificil' where catalog_node_id='3d47f86a-ebcd-4a53-8742-71245315dc79' and order_index in (2,3,5);
update questions set difficulty='facil'   where catalog_node_id='9cd02d29-4fa4-4a9e-ac80-69ac42eb183a' and order_index in (1);     -- Espelho convexo
update questions set difficulty='facil'   where catalog_node_id='2e7f9326-dd6b-4cf9-820b-df10c38fef0c' and order_index in (1,3,5); -- Foco e centro de curvatura
update questions set difficulty='facil'   where catalog_node_id='7d71354e-4686-4b6b-8825-be631b2ad042' and order_index in (5);     -- Raios notaveis
update questions set difficulty='facil'   where catalog_node_id='cff09107-8f47-44a2-a166-8ba7a3c3d6ca' and order_index in (3,5);   -- Formacao de imagens
update questions set difficulty='facil'   where catalog_node_id='b124402a-4ae1-486c-abee-1db66cc184a6' and order_index in (1);     -- Lentes convergentes
update questions set difficulty='dificil' where catalog_node_id='b124402a-4ae1-486c-abee-1db66cc184a6' and order_index in (3,4);
update questions set difficulty='facil'   where catalog_node_id='4531a57b-6384-4e17-ac73-6ebbe7849d71' and order_index in (1);     -- Lentes divergentes
update questions set difficulty='dificil' where catalog_node_id='4531a57b-6384-4e17-ac73-6ebbe7849d71' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='267de3da-1b72-4c3d-af98-0a38a3bedc32' and order_index in (1,5);   -- Miopia
update questions set difficulty='facil'   where catalog_node_id='d28fdc19-50a8-4dca-9d0e-98407bfc325b' and order_index in (1,5);   -- Hipermetropia
update questions set difficulty='facil'   where catalog_node_id='c7c85039-59ec-4178-8acd-9d672c717542' and order_index in (1,2);   -- Presbiopia
