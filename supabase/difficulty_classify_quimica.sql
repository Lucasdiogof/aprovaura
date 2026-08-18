-- Classificacao de dificuldade — QUIMICA (203 questoes).
-- So marca 'facil' e 'dificil'; o resto permanece 'medio'. Idempotente.

-- ===== Estrutura atomica e Modelos atomicos =====
update questions set difficulty='facil'   where catalog_node_id='f7d3367f-0ede-4557-b30c-9ff239249e46' and order_index in (1,2);     -- Protons
update questions set difficulty='facil'   where catalog_node_id='923a07a3-fe07-459f-bb12-d7487ee924ee' and order_index in (1,2);     -- Neutrons
update questions set difficulty='dificil' where catalog_node_id='923a07a3-fe07-459f-bb12-d7487ee924ee' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='8c2a2d8d-fbff-4b4a-8010-a79227baf853' and order_index in (1,2,3);   -- Eletrons
update questions set difficulty='facil'   where catalog_node_id='7ff92853-53ea-456f-81d2-d266d9a2cb74' and order_index in (1,2);     -- Ions
update questions set difficulty='dificil' where catalog_node_id='7ff92853-53ea-456f-81d2-d266d9a2cb74' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='4523e44f-8897-4776-a810-64248b111623' and order_index in (1,2);     -- Isotopos
update questions set difficulty='dificil' where catalog_node_id='4523e44f-8897-4776-a810-64248b111623' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='1d7027f0-9cb2-46bc-a969-71fb69e1c2c5' and order_index in (1,2);     -- Dalton
update questions set difficulty='facil'   where catalog_node_id='a6800379-be79-4f16-a0d5-9f741c728963' and order_index in (1,3);     -- Thomson
update questions set difficulty='dificil' where catalog_node_id='a6800379-be79-4f16-a0d5-9f741c728963' and order_index in (2);
update questions set difficulty='facil'   where catalog_node_id='732824ff-da40-4a2a-9f16-44c5274ba4b8' and order_index in (1,2);     -- Rutherford
update questions set difficulty='dificil' where catalog_node_id='732824ff-da40-4a2a-9f16-44c5274ba4b8' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='8dabaafe-27a9-467e-907c-7ed9aa0236b8' and order_index in (1,4);     -- Bohr
update questions set difficulty='dificil' where catalog_node_id='8dabaafe-27a9-467e-907c-7ed9aa0236b8' and order_index in (5);

-- ===== Tabela periodica =====
update questions set difficulty='facil'   where catalog_node_id='e0017fec-c1a0-44a2-9501-073e14904f77' and order_index in (1,2);     -- Periodos
update questions set difficulty='dificil' where catalog_node_id='e0017fec-c1a0-44a2-9501-073e14904f77' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='2880a5d7-04f0-4587-8c21-6225dba9a778' and order_index in (1,3,4);   -- Familias
update questions set difficulty='facil'   where catalog_node_id='db4c138e-2f1d-4b62-9c05-772bbfcd8a7e' and order_index in (1,5);     -- Metais/ametais/semimetais
update questions set difficulty='facil'   where catalog_node_id='61b08c3e-7325-4199-9fb1-3b1a891d2b5b' and order_index in (1,2);     -- Gases nobres
update questions set difficulty='dificil' where catalog_node_id='61b08c3e-7325-4199-9fb1-3b1a891d2b5b' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='8388a421-a787-4bf0-9e15-fee32a78e884' and order_index in (1,5);     -- Metais alcalinos
update questions set difficulty='facil'   where catalog_node_id='7a0bf96c-65fd-4af6-b8c1-a69d0f51b0a3' and order_index in (1,3);     -- Halogenios
update questions set difficulty='dificil' where catalog_node_id='7a0bf96c-65fd-4af6-b8c1-a69d0f51b0a3' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='e0d8da54-8dd1-478e-98ed-1c168d697958' and order_index in (2,4);     -- Propriedades periodicas
update questions set difficulty='dificil' where catalog_node_id='e0d8da54-8dd1-478e-98ed-1c168d697958' and order_index in (5);

-- ===== Quimica Organica geral (cadeias, nomenclatura, isomeria, reacoes, polimeros) =====
update questions set difficulty='facil'   where catalog_node_id='0f844d56-03ad-4c25-b48b-ce3ce4a5715e' and order_index in (2,3);     -- Cadeias carbonicas
update questions set difficulty='dificil' where catalog_node_id='0f844d56-03ad-4c25-b48b-ce3ce4a5715e' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='5a184c6f-1a60-4351-afa3-dbd35050d165' and order_index in (1,2,3);   -- Nomenclatura
update questions set difficulty='facil'   where catalog_node_id='6e3937ec-84c9-4de7-86ea-ffb98fb8f93f' and order_index in (1);       -- Isomeria
update questions set difficulty='dificil' where catalog_node_id='6e3937ec-84c9-4de7-86ea-ffb98fb8f93f' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='4d4f08dd-12b7-447c-8a16-17a5ec57eb26' and order_index in (1,2,3);   -- Reacoes organicas
update questions set difficulty='facil'   where catalog_node_id='b645c629-c218-475a-ad49-7524c0d4efe3' and order_index in (1,2);     -- Polimeros
update questions set difficulty='dificil' where catalog_node_id='b645c629-c218-475a-ad49-7524c0d4efe3' and order_index in (5);

-- ===== Funcoes organicas =====
update questions set difficulty='facil'   where catalog_node_id='0b38a8c8-d003-4a83-a64c-e9d13a55d2f2' and order_index in (1,2,3);   -- Hidrocarbonetos
update questions set difficulty='facil'   where catalog_node_id='bfab5e46-9539-4913-9b74-9caa035c2ee2' and order_index in (1,4);     -- Alcool
update questions set difficulty='dificil' where catalog_node_id='bfab5e46-9539-4913-9b74-9caa035c2ee2' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='a6ee5567-9eaa-4311-b38d-0d558fc20104' and order_index in (1,3);     -- Fenol
update questions set difficulty='dificil' where catalog_node_id='a6ee5567-9eaa-4311-b38d-0d558fc20104' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='a1e1464d-452e-4217-b190-6066b91e6084' and order_index in (1,2);     -- Eter
update questions set difficulty='dificil' where catalog_node_id='a1e1464d-452e-4217-b190-6066b91e6084' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='bf6b8661-333d-4328-a787-c65089ba7e26' and order_index in (1,2,5);   -- Aldeido
update questions set difficulty='dificil' where catalog_node_id='bf6b8661-333d-4328-a787-c65089ba7e26' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='0247a3f8-16d1-47df-b712-4862d0f1282f' and order_index in (1,2);     -- Cetona
update questions set difficulty='dificil' where catalog_node_id='0247a3f8-16d1-47df-b712-4862d0f1282f' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='a9d41e8f-b75b-480b-bbe4-6539427e297c' and order_index in (1,2,4,5); -- Acido carboxilico
update questions set difficulty='dificil' where catalog_node_id='a9d41e8f-b75b-480b-bbe4-6539427e297c' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='28c43ed0-e18f-41ac-84f3-0035879e636e' and order_index in (1,2);     -- Ester
update questions set difficulty='dificil' where catalog_node_id='28c43ed0-e18f-41ac-84f3-0035879e636e' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='46421855-4463-49fe-8248-16700eb7b3ac' and order_index in (1,3,5);   -- Amina
update questions set difficulty='dificil' where catalog_node_id='46421855-4463-49fe-8248-16700eb7b3ac' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='32224fa9-22dd-40b6-a5da-43f6996544ce' and order_index in (1);       -- Amida
update questions set difficulty='dificil' where catalog_node_id='32224fa9-22dd-40b6-a5da-43f6996544ce' and order_index in (4);

-- ===== Areas gerais (Ligacoes, Estequiometria, Solucoes, Fisico-Quimica, Inorganica, Ambiental) =====
update questions set difficulty='facil'   where catalog_node_id='806021ed-dee3-457f-94b5-a8e94e8b51aa' and order_index in (1,2);     -- Ligacoes e Estrutura
update questions set difficulty='dificil' where catalog_node_id='806021ed-dee3-457f-94b5-a8e94e8b51aa' and order_index in (3,6);
update questions set difficulty='facil'   where catalog_node_id='1694b662-d892-4687-8727-9f74c2715b11' and order_index in (1,2,8);   -- Estequiometria
update questions set difficulty='dificil' where catalog_node_id='1694b662-d892-4687-8727-9f74c2715b11' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='f41ba2d7-4462-4a77-8362-272bb8313c47' and order_index in (1,2,4);   -- Solucoes
update questions set difficulty='dificil' where catalog_node_id='f41ba2d7-4462-4a77-8362-272bb8313c47' and order_index in (7);
update questions set difficulty='facil'   where catalog_node_id='2e117b4e-3e7c-492e-82dc-22b964209b9a' and order_index in (1,2,6,7); -- Fisico-Quimica
update questions set difficulty='dificil' where catalog_node_id='2e117b4e-3e7c-492e-82dc-22b964209b9a' and order_index in (4,5);
update questions set difficulty='facil'   where catalog_node_id='047a3c19-6572-45e7-87fa-ba36b78190d0' and order_index in (1,2,3,5,8); -- Quimica Inorganica
update questions set difficulty='dificil' where catalog_node_id='047a3c19-6572-45e7-87fa-ba36b78190d0' and order_index in (4,6);
update questions set difficulty='facil'   where catalog_node_id='73cac530-0e0d-4775-b9c0-ae6ce4912b8c' and order_index in (1,2,3,4,5,8); -- Quimica Ambiental
update questions set difficulty='dificil' where catalog_node_id='73cac530-0e0d-4775-b9c0-ae6ce4912b8c' and order_index in (7);
