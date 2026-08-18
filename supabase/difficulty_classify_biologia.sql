-- Classificacao de dificuldade — BIOLOGIA (322 questoes).
-- So marca 'facil' e 'dificil'; o resto permanece 'medio' (default da coluna).
-- Idempotente: reaplicar o mesmo nivel nao duplica nada.

-- ===== Fundamentos =====
update questions set difficulty='facil'   where catalog_node_id='ac32071e-53bb-4644-bc7e-a0dfe219e216' and order_index in (1,2,5,7,8); -- Botanica
update questions set difficulty='facil'   where catalog_node_id='b380072b-51b4-462b-99fa-266d0dcffa59' and order_index in (1,3,7);     -- Zoologia
update questions set difficulty='facil'   where catalog_node_id='bee5e4cb-fe57-4ac9-936a-626442f07b75' and order_index in (1,8);       -- Microbiologia
update questions set difficulty='dificil' where catalog_node_id='18976237-e643-437e-8216-7ff0c5a09df5' and order_index in (4,6,8);     -- Evolucao

-- ===== Citologia =====
update questions set difficulty='facil'   where catalog_node_id='953f689f-2c4f-47c2-9b7d-afce1fd27e7e' and order_index in (1);       -- Difusao
update questions set difficulty='facil'   where catalog_node_id='b6e6a404-ea29-44dd-a791-84fe0afd6075' and order_index in (1);       -- Osmose
update questions set difficulty='facil'   where catalog_node_id='01231beb-4568-4adf-81ec-cd7f6625ac75' and order_index in (1);       -- Transporte ativo
update questions set difficulty='dificil' where catalog_node_id='01231beb-4568-4adf-81ec-cd7f6625ac75' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='a0579b4d-2452-400c-b231-5657f7ae4cd1' and order_index in (1,4);     -- Endocitose
update questions set difficulty='facil'   where catalog_node_id='2cc4c95d-0ae8-43ea-9bc3-94d735b6ffd2' and order_index in (1);       -- Exocitose
update questions set difficulty='facil'   where catalog_node_id='3b5d566c-f5a1-4d2a-a367-4e10fd9aee10' and order_index in (1,5);     -- Nucleo
update questions set difficulty='facil'   where catalog_node_id='227e8f6a-30c1-4f98-8258-caad221e1b9b' and order_index in (1,5);     -- Ribossomos
update questions set difficulty='facil'   where catalog_node_id='53997b60-6c93-406c-86c1-61ae5144284f' and order_index in (1);       -- Mitocondrias
update questions set difficulty='dificil' where catalog_node_id='53997b60-6c93-406c-86c1-61ae5144284f' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='bc066aa7-c7cc-4dda-99b5-2261662b2911' and order_index in (1);       -- Lisossomos
update questions set difficulty='dificil' where catalog_node_id='bc066aa7-c7cc-4dda-99b5-2261662b2911' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='ae5f9b1f-c63d-48ac-8317-92c213efdfab' and order_index in (1);       -- Complexo golgiense
update questions set difficulty='facil'   where catalog_node_id='200ba258-f3fa-4a2e-a3ca-be9f6679f885' and order_index in (1);       -- Reticulo endoplasmatico
update questions set difficulty='dificil' where catalog_node_id='200ba258-f3fa-4a2e-a3ca-be9f6679f885' and order_index in (4);
update questions set difficulty='dificil' where catalog_node_id='4af454c7-1cd0-481e-bd5c-9701185a49c3' and order_index in (4);       -- Centriolos
update questions set difficulty='facil'   where catalog_node_id='47233064-12a0-4db3-893c-d357da648432' and order_index in (1,2,5);   -- Cloroplastos
update questions set difficulty='dificil' where catalog_node_id='47233064-12a0-4db3-893c-d357da648432' and order_index in (4);
update questions set difficulty='dificil' where catalog_node_id='4c802fad-3592-4adb-9031-5b7f4cf48fe0' and order_index in (5);       -- Ciclo celular

-- ===== Corpo Humano e Fisiologia =====
update questions set difficulty='facil'   where catalog_node_id='e53efaa2-9b86-4ffb-a802-7981ff47cf0f' and order_index in (1);       -- Coracao
update questions set difficulty='facil'   where catalog_node_id='a1858027-f953-4d1b-8b40-3e2ff2456097' and order_index in (1);       -- Valvulas
update questions set difficulty='facil'   where catalog_node_id='95373244-bfd4-4ba0-aa81-0d7cb89f8805' and order_index in (1);       -- Arterias
update questions set difficulty='dificil' where catalog_node_id='95373244-bfd4-4ba0-aa81-0d7cb89f8805' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='3bdaccc7-106a-488d-a95b-8b42e9b29cc7' and order_index in (1);       -- Veias
update questions set difficulty='dificil' where catalog_node_id='3bdaccc7-106a-488d-a95b-8b42e9b29cc7' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='7d0ed443-aa25-429f-89cd-b5ce672f22d2' and order_index in (1);       -- Capilares
update questions set difficulty='dificil' where catalog_node_id='7d0ed443-aa25-429f-89cd-b5ce672f22d2' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='bfeb4cb7-a05a-4d9b-a38d-a6e6815a808f' and order_index in (1);       -- Circulacao pulmonar
update questions set difficulty='facil'   where catalog_node_id='c71f4bd6-9a85-47d3-b979-b99d2626971a' and order_index in (1);       -- Circulacao sistemica
update questions set difficulty='facil'   where catalog_node_id='9480bb3f-8a4e-44dc-8040-c969d518bc77' and order_index in (1);       -- Neuronio
update questions set difficulty='dificil' where catalog_node_id='9480bb3f-8a4e-44dc-8040-c969d518bc77' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='3802e1b8-5448-4536-87de-e4bc3341c3b0' and order_index in (1,5);     -- SNC
update questions set difficulty='facil'   where catalog_node_id='9af22c5f-f2e2-4112-bc80-077daa270068' and order_index in (1);       -- SNP
update questions set difficulty='facil'   where catalog_node_id='df20c43e-9e92-4cbe-bd39-2a79e44e981e' and order_index in (1);       -- Sinapses
update questions set difficulty='dificil' where catalog_node_id='df20c43e-9e92-4cbe-bd39-2a79e44e981e' and order_index in (5);
update questions set difficulty='dificil' where catalog_node_id='3a31c349-9503-413e-b5bb-908655f4bc6b' and order_index in (3,5);     -- Arco reflexo
update questions set difficulty='facil'   where catalog_node_id='73124495-e312-4308-9edf-71f1edbfd5a5' and order_index in (1);       -- Sistema digestorio
update questions set difficulty='dificil' where catalog_node_id='73124495-e312-4308-9edf-71f1edbfd5a5' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='2436eaec-370e-4bca-8451-cc835788a34f' and order_index in (1);       -- Sistema endocrino
update questions set difficulty='facil'   where catalog_node_id='d717ee10-b8f6-4406-8314-3d4a9c9ed7d1' and order_index in (1);       -- Sistema imunologico

-- ===== Ecologia =====
update questions set difficulty='facil'   where catalog_node_id='f7f37257-1f07-46d7-961d-36267d9ff9b0' and order_index in (1,2);     -- Cadeias alimentares
update questions set difficulty='facil'   where catalog_node_id='c4b861cb-2247-46b7-9b38-fe2f1295d952' and order_index in (1);       -- Teias alimentares
update questions set difficulty='dificil' where catalog_node_id='c4b861cb-2247-46b7-9b38-fe2f1295d952' and order_index in (4,5);
update questions set difficulty='facil'   where catalog_node_id='515a6c10-a2b5-4e46-b5a1-f1dc8340ee22' and order_index in (1,2);     -- Niveis troficos
update questions set difficulty='dificil' where catalog_node_id='515a6c10-a2b5-4e46-b5a1-f1dc8340ee22' and order_index in (4,5);
update questions set difficulty='facil'   where catalog_node_id='2d65cb2b-f381-4767-b8a3-2ccb1d4f0f90' and order_index in (1);       -- Piramides ecologicas
update questions set difficulty='dificil' where catalog_node_id='2d65cb2b-f381-4767-b8a3-2ccb1d4f0f90' and order_index in (3,5);
update questions set difficulty='facil'   where catalog_node_id='3723cf19-5eb3-4231-8a8a-78b127777486' and order_index in (1);       -- Mutualismo
update questions set difficulty='dificil' where catalog_node_id='3723cf19-5eb3-4231-8a8a-78b127777486' and order_index in (5);
update questions set difficulty='dificil' where catalog_node_id='a78092ea-853a-4dea-9aff-0ad87ee76b60' and order_index in (3);       -- Protocooperacao
update questions set difficulty='facil'   where catalog_node_id='ee473daf-bfff-422d-a764-d6234b14ffd1' and order_index in (1);       -- Comensalismo
update questions set difficulty='facil'   where catalog_node_id='c837e759-5dad-4a7e-ba58-6bbc7b99e205' and order_index in (1);       -- Predatismo
update questions set difficulty='dificil' where catalog_node_id='c837e759-5dad-4a7e-ba58-6bbc7b99e205' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='4a468f5a-608c-4dc3-becb-821d451dfc9c' and order_index in (1);       -- Parasitismo
update questions set difficulty='facil'   where catalog_node_id='93ffea02-0672-48f6-9185-9b6b1a0fdedf' and order_index in (1);       -- Competicao
update questions set difficulty='dificil' where catalog_node_id='93ffea02-0672-48f6-9185-9b6b1a0fdedf' and order_index in (4,5);
update questions set difficulty='dificil' where catalog_node_id='599b3dba-748c-425a-b38b-411283947db3' and order_index in (2,3,5);   -- Amensalismo
update questions set difficulty='facil'   where catalog_node_id='6ef61f6f-ff8b-4bc6-b064-6eeeb77d1ba7' and order_index in (1);       -- Aquecimento global
update questions set difficulty='facil'   where catalog_node_id='7b65a833-d7c3-44af-8168-07eb7c28bf4b' and order_index in (1);       -- Desmatamento
update questions set difficulty='dificil' where catalog_node_id='7b65a833-d7c3-44af-8168-07eb7c28bf4b' and order_index in (4);
update questions set difficulty='facil'   where catalog_node_id='4b45af32-53e6-4f3a-a628-194ac2bc1035' and order_index in (1);       -- Poluicao
update questions set difficulty='dificil' where catalog_node_id='4b45af32-53e6-4f3a-a628-194ac2bc1035' and order_index in (2);
update questions set difficulty='dificil' where catalog_node_id='2dbe9c65-6d79-4abd-ace9-fa5f3545b7de' and order_index in (5);       -- Chuva acida
update questions set difficulty='facil'   where catalog_node_id='a08bdf48-dce2-4e57-9418-96e2b1122ea5' and order_index in (1);       -- Especies invasoras

-- ===== Genetica e Biotecnologia =====
update questions set difficulty='facil'   where catalog_node_id='39a35cba-9950-4962-a03a-3996395bd685' and order_index in (1,2);     -- Gene
update questions set difficulty='facil'   where catalog_node_id='b6c1f281-a862-4508-a4b3-806650514fdc' and order_index in (1);       -- Alelo
update questions set difficulty='facil'   where catalog_node_id='9fbb43c6-7af2-4b6b-b454-9502d5150108' and order_index in (1);       -- Genotipo
update questions set difficulty='dificil' where catalog_node_id='9fbb43c6-7af2-4b6b-b454-9502d5150108' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='1b185c81-5bc2-4217-b29b-fb2608b85c41' and order_index in (1);       -- Fenotipo
update questions set difficulty='dificil' where catalog_node_id='1b185c81-5bc2-4217-b29b-fb2608b85c41' and order_index in (3);
update questions set difficulty='facil'   where catalog_node_id='81a8d9f8-2691-41c2-be3a-5d93901ad947' and order_index in (1,2,3);   -- Homozigoto
update questions set difficulty='dificil' where catalog_node_id='81a8d9f8-2691-41c2-be3a-5d93901ad947' and order_index in (5);
update questions set difficulty='facil'   where catalog_node_id='d3c597c4-5a2b-4cf4-958c-eb921554f24f' and order_index in (1);       -- Heterozigoto
update questions set difficulty='dificil' where catalog_node_id='d3c597c4-5a2b-4cf4-958c-eb921554f24f' and order_index in (4,5);
update questions set difficulty='dificil' where catalog_node_id='f60e7769-0be0-4a8e-b2e5-bb84e9163a6f' and order_index in (4);       -- Primeira Lei de Mendel
update questions set difficulty='dificil' where catalog_node_id='c141235f-fa2d-4f57-92f6-9155f4e51b24' and order_index in (2,3,4);   -- Segunda Lei de Mendel
update questions set difficulty='facil'   where catalog_node_id='1c0394e3-ac5b-4b78-8e22-424c8d2eef2c' and order_index in (1);       -- Dominancia completa
update questions set difficulty='dificil' where catalog_node_id='1c0394e3-ac5b-4b78-8e22-424c8d2eef2c' and order_index in (3,4,5);
update questions set difficulty='facil'   where catalog_node_id='58559535-fd80-4280-be81-84c7eedf4ebd' and order_index in (1);       -- Dominancia incompleta
update questions set difficulty='dificil' where catalog_node_id='58559535-fd80-4280-be81-84c7eedf4ebd' and order_index in (4);
update questions set difficulty='dificil' where catalog_node_id='c0706ac2-24d8-4fc6-a9b7-a73885687e25' and order_index in (3);       -- Codominancia
update questions set difficulty='facil'   where catalog_node_id='6d0f873d-1dcd-4396-a193-fbe5b4476a7d' and order_index in (1);       -- Heranca ligada ao sexo
update questions set difficulty='dificil' where catalog_node_id='6d0f873d-1dcd-4396-a193-fbe5b4476a7d' and order_index in (3,5);
update questions set difficulty='facil'   where catalog_node_id='706f8471-6cd6-403b-8928-773860a47556' and order_index in (1);       -- Heredogramas
update questions set difficulty='dificil' where catalog_node_id='706f8471-6cd6-403b-8928-773860a47556' and order_index in (4,5);
