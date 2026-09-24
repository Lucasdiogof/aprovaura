-- i18n FASE 4: en/es translations of the whole catalog (376 nodes x 2
-- locales = 752 rows). Only writes catalog_node_translations; catalog_nodes
-- (the pt-BR original) is never touched.
--
-- Keyed by the real catalog_nodes.id read from the live database on
-- 2026-09-24. A node that no longer exists is skipped by the join instead
-- of failing the whole script. Idempotent: re-running updates in place
-- (on conflict do update), so fixing one translation later is just editing
-- its line and running this again.
--
-- Depends on i18n_translations_schema.sql. Check afterwards with
-- i18n_catalog_checkup.sql.

insert into catalog_node_translations (catalog_node_id, locale, title, description)
select v.id::uuid, v.locale, v.title, v.description
from (values
  ('71efa0d4-b29b-4bc2-8c75-4df063ac4b56', 'en', 'Cytology', 'Cells, organelles, membranes and cell division'),  -- Citologia
  ('71efa0d4-b29b-4bc2-8c75-4df063ac4b56', 'es', 'Citología', 'Células, orgánulos, membranas y división celular'),
  ('986e3038-ed77-4549-bdd8-41eaf4c6e391', 'en', 'Plasma membrane', null),  -- Membrana plasmática
  ('986e3038-ed77-4549-bdd8-41eaf4c6e391', 'es', 'Membrana plasmática', null),
  ('953f689f-2c4f-47c2-9b7d-afce1fd27e7e', 'en', 'Diffusion', null),  -- Difusão
  ('953f689f-2c4f-47c2-9b7d-afce1fd27e7e', 'es', 'Difusión', null),
  ('b6e6a404-ea29-44dd-a791-84fe0afd6075', 'en', 'Osmosis', null),  -- Osmose
  ('b6e6a404-ea29-44dd-a791-84fe0afd6075', 'es', 'Ósmosis', null),
  ('01231beb-4568-4adf-81ec-cd7f6625ac75', 'en', 'Active transport', null),  -- Transporte ativo
  ('01231beb-4568-4adf-81ec-cd7f6625ac75', 'es', 'Transporte activo', null),
  ('a0579b4d-2452-400c-b231-5657f7ae4cd1', 'en', 'Endocytosis', null),  -- Endocitose
  ('a0579b4d-2452-400c-b231-5657f7ae4cd1', 'es', 'Endocitosis', null),
  ('2cc4c95d-0ae8-43ea-9bc3-94d735b6ffd2', 'en', 'Exocytosis', null),  -- Exocitose
  ('2cc4c95d-0ae8-43ea-9bc3-94d735b6ffd2', 'es', 'Exocitosis', null),
  ('d80746e0-0836-482c-8fc9-67d7596e8efb', 'en', 'Organelles', null),  -- Organelas
  ('d80746e0-0836-482c-8fc9-67d7596e8efb', 'es', 'Orgánulos', null),
  ('3b5d566c-f5a1-4d2a-a367-4e10fd9aee10', 'en', 'Nucleus', null),  -- Núcleo
  ('3b5d566c-f5a1-4d2a-a367-4e10fd9aee10', 'es', 'Núcleo', null),
  ('227e8f6a-30c1-4f98-8258-caad221e1b9b', 'en', 'Ribosomes', null),  -- Ribossomos
  ('227e8f6a-30c1-4f98-8258-caad221e1b9b', 'es', 'Ribosomas', null),
  ('53997b60-6c93-406c-86c1-61ae5144284f', 'en', 'Mitochondria', null),  -- Mitocôndrias
  ('53997b60-6c93-406c-86c1-61ae5144284f', 'es', 'Mitocondrias', null),
  ('bc066aa7-c7cc-4dda-99b5-2261662b2911', 'en', 'Lysosomes', null),  -- Lisossomos
  ('bc066aa7-c7cc-4dda-99b5-2261662b2911', 'es', 'Lisosomas', null),
  ('ae5f9b1f-c63d-48ac-8317-92c213efdfab', 'en', 'Golgi apparatus', null),  -- Complexo golgiense
  ('ae5f9b1f-c63d-48ac-8317-92c213efdfab', 'es', 'Aparato de Golgi', null),
  ('200ba258-f3fa-4a2e-a3ca-be9f6679f885', 'en', 'Endoplasmic reticulum', null),  -- Retículo endoplasmático
  ('200ba258-f3fa-4a2e-a3ca-be9f6679f885', 'es', 'Retículo endoplasmático', null),
  ('4af454c7-1cd0-481e-bd5c-9701185a49c3', 'en', 'Centrioles', null),  -- Centríolos
  ('4af454c7-1cd0-481e-bd5c-9701185a49c3', 'es', 'Centriolos', null),
  ('47233064-12a0-4db3-893c-d357da648432', 'en', 'Chloroplasts', null),  -- Cloroplastos
  ('47233064-12a0-4db3-893c-d357da648432', 'es', 'Cloroplastos', null),
  ('4c802fad-3592-4adb-9031-5b7f4cf48fe0', 'en', 'Cell cycle, mitosis and meiosis', null),  -- Ciclo celular, mitose e meiose
  ('4c802fad-3592-4adb-9031-5b7f4cf48fe0', 'es', 'Ciclo celular, mitosis y meiosis', null),
  ('2c2c66ad-1bf7-4404-b071-2c92c34d5974', 'en', 'Genetics and Biotechnology', 'DNA, heredity, Mendel and genetic engineering'),  -- Genética e Biotecnologia
  ('2c2c66ad-1bf7-4404-b071-2c92c34d5974', 'es', 'Genética y Biotecnología', 'ADN, herencia, Mendel e ingeniería genética'),
  ('30873677-7ed8-4f49-b50e-1a75010f108f', 'en', 'Core concepts', null),  -- Conceitos fundamentais
  ('30873677-7ed8-4f49-b50e-1a75010f108f', 'es', 'Conceptos fundamentales', null),
  ('39a35cba-9950-4962-a03a-3996395bd685', 'en', 'Gene', null),  -- Gene
  ('39a35cba-9950-4962-a03a-3996395bd685', 'es', 'Gen', null),
  ('b6c1f281-a862-4508-a4b3-806650514fdc', 'en', 'Allele', null),  -- Alelo
  ('b6c1f281-a862-4508-a4b3-806650514fdc', 'es', 'Alelo', null),
  ('9fbb43c6-7af2-4b6b-b454-9502d5150108', 'en', 'Genotype', null),  -- Genótipo
  ('9fbb43c6-7af2-4b6b-b454-9502d5150108', 'es', 'Genotipo', null),
  ('1b185c81-5bc2-4217-b29b-fb2608b85c41', 'en', 'Phenotype', null),  -- Fenótipo
  ('1b185c81-5bc2-4217-b29b-fb2608b85c41', 'es', 'Fenotipo', null),
  ('81a8d9f8-2691-41c2-be3a-5d93901ad947', 'en', 'Homozygous', null),  -- Homozigoto
  ('81a8d9f8-2691-41c2-be3a-5d93901ad947', 'es', 'Homocigoto', null),
  ('d3c597c4-5a2b-4cf4-958c-eb921554f24f', 'en', 'Heterozygous', null),  -- Heterozigoto
  ('d3c597c4-5a2b-4cf4-958c-eb921554f24f', 'es', 'Heterocigoto', null),
  ('837b3e0e-7b56-4136-91f4-a129dd2eb70e', 'en', 'Mendel''s laws and inheritance patterns', null),  -- Leis de Mendel e padrões de herança
  ('837b3e0e-7b56-4136-91f4-a129dd2eb70e', 'es', 'Leyes de Mendel y patrones de herencia', null),
  ('f60e7769-0be0-4a8e-b2e5-bb84e9163a6f', 'en', 'Mendel''s First Law', null),  -- Primeira Lei de Mendel
  ('f60e7769-0be0-4a8e-b2e5-bb84e9163a6f', 'es', 'Primera Ley de Mendel', null),
  ('c141235f-fa2d-4f57-92f6-9155f4e51b24', 'en', 'Mendel''s Second Law', null),  -- Segunda Lei de Mendel
  ('c141235f-fa2d-4f57-92f6-9155f4e51b24', 'es', 'Segunda Ley de Mendel', null),
  ('1c0394e3-ac5b-4b78-8e22-424c8d2eef2c', 'en', 'Complete dominance', null),  -- Dominância completa
  ('1c0394e3-ac5b-4b78-8e22-424c8d2eef2c', 'es', 'Dominancia completa', null),
  ('58559535-fd80-4280-be81-84c7eedf4ebd', 'en', 'Incomplete dominance', null),  -- Dominância incompleta
  ('58559535-fd80-4280-be81-84c7eedf4ebd', 'es', 'Dominancia incompleta', null),
  ('c0706ac2-24d8-4fc6-a9b7-a73885687e25', 'en', 'Codominance', null),  -- Codominância
  ('c0706ac2-24d8-4fc6-a9b7-a73885687e25', 'es', 'Codominancia', null),
  ('6d0f873d-1dcd-4396-a193-fbe5b4476a7d', 'en', 'Sex-linked inheritance', null),  -- Herança ligada ao sexo
  ('6d0f873d-1dcd-4396-a193-fbe5b4476a7d', 'es', 'Herencia ligada al sexo', null),
  ('706f8471-6cd6-403b-8928-773860a47556', 'en', 'Pedigree charts', null),  -- Heredogramas
  ('706f8471-6cd6-403b-8928-773860a47556', 'es', 'Genealogías', null),
  ('edb22fe5-2942-49e0-bd62-33c741f20ba3', 'en', 'Ecology', 'Ecosystems, food chains and natural cycles'),  -- Ecologia
  ('edb22fe5-2942-49e0-bd62-33c741f20ba3', 'es', 'Ecología', 'Ecosistemas, cadenas alimentarias y ciclos naturales'),
  ('d00e2a28-2f3f-426a-b8c8-09029d320752', 'en', 'Food chains and food webs', null),  -- Cadeias e teias alimentares
  ('d00e2a28-2f3f-426a-b8c8-09029d320752', 'es', 'Cadenas y redes alimentarias', null),
  ('f7f37257-1f07-46d7-961d-36267d9ff9b0', 'en', 'Food chains', null),  -- Cadeias alimentares
  ('f7f37257-1f07-46d7-961d-36267d9ff9b0', 'es', 'Cadenas alimentarias', null),
  ('c4b861cb-2247-46b7-9b38-fe2f1295d952', 'en', 'Food webs', null),  -- Teias alimentares
  ('c4b861cb-2247-46b7-9b38-fe2f1295d952', 'es', 'Redes alimentarias', null),
  ('515a6c10-a2b5-4e46-b5a1-f1dc8340ee22', 'en', 'Trophic levels', null),  -- Níveis tróficos
  ('515a6c10-a2b5-4e46-b5a1-f1dc8340ee22', 'es', 'Niveles tróficos', null),
  ('2d65cb2b-f381-4767-b8a3-2ccb1d4f0f90', 'en', 'Ecological pyramids', null),  -- Pirâmides ecológicas
  ('2d65cb2b-f381-4767-b8a3-2ccb1d4f0f90', 'es', 'Pirámides ecológicas', null),
  ('8d4ad7cd-759a-4b4e-ae22-d209dcba9973', 'en', 'Ecological relationships', null),  -- Relações ecológicas
  ('8d4ad7cd-759a-4b4e-ae22-d209dcba9973', 'es', 'Relaciones ecológicas', null),
  ('3723cf19-5eb3-4231-8a8a-78b127777486', 'en', 'Mutualism', null),  -- Mutualismo
  ('3723cf19-5eb3-4231-8a8a-78b127777486', 'es', 'Mutualismo', null),
  ('a78092ea-853a-4dea-9aff-0ad87ee76b60', 'en', 'Protocooperation', null),  -- Protocooperação
  ('a78092ea-853a-4dea-9aff-0ad87ee76b60', 'es', 'Protocooperación', null),
  ('ee473daf-bfff-422d-a764-d6234b14ffd1', 'en', 'Commensalism', null),  -- Comensalismo
  ('ee473daf-bfff-422d-a764-d6234b14ffd1', 'es', 'Comensalismo', null),
  ('c837e759-5dad-4a7e-ba58-6bbc7b99e205', 'en', 'Predation', null),  -- Predatismo
  ('c837e759-5dad-4a7e-ba58-6bbc7b99e205', 'es', 'Depredación', null),
  ('4a468f5a-608c-4dc3-becb-821d451dfc9c', 'en', 'Parasitism', null),  -- Parasitismo
  ('4a468f5a-608c-4dc3-becb-821d451dfc9c', 'es', 'Parasitismo', null),
  ('93ffea02-0672-48f6-9185-9b6b1a0fdedf', 'en', 'Competition', null),  -- Competição
  ('93ffea02-0672-48f6-9185-9b6b1a0fdedf', 'es', 'Competencia', null),
  ('599b3dba-748c-425a-b38b-411283947db3', 'en', 'Amensalism', null),  -- Amensalismo
  ('599b3dba-748c-425a-b38b-411283947db3', 'es', 'Amensalismo', null),
  ('6bcd2a2c-cadd-435f-a5ab-ea0071614e22', 'en', 'Environmental impacts', null),  -- Impactos ambientais
  ('6bcd2a2c-cadd-435f-a5ab-ea0071614e22', 'es', 'Impactos ambientales', null),
  ('6ef61f6f-ff8b-4bc6-b064-6eeeb77d1ba7', 'en', 'Global warming', null),  -- Aquecimento global
  ('6ef61f6f-ff8b-4bc6-b064-6eeeb77d1ba7', 'es', 'Calentamiento global', null),
  ('7b65a833-d7c3-44af-8168-07eb7c28bf4b', 'en', 'Deforestation', null),  -- Desmatamento
  ('7b65a833-d7c3-44af-8168-07eb7c28bf4b', 'es', 'Deforestación', null),
  ('4b45af32-53e6-4f3a-a628-194ac2bc1035', 'en', 'Pollution', null),  -- Poluição
  ('4b45af32-53e6-4f3a-a628-194ac2bc1035', 'es', 'Contaminación', null),
  ('2dbe9c65-6d79-4abd-ace9-fa5f3545b7de', 'en', 'Acid rain', null),  -- Chuva ácida
  ('2dbe9c65-6d79-4abd-ace9-fa5f3545b7de', 'es', 'Lluvia ácida', null),
  ('a08bdf48-dce2-4e57-9418-96e2b1122ea5', 'en', 'Invasive species', null),  -- Espécies invasoras
  ('a08bdf48-dce2-4e57-9418-96e2b1122ea5', 'es', 'Especies invasoras', null),
  ('82d8b80e-11eb-4f9e-bed3-f107fbba97d9', 'en', 'Human Body and Physiology', 'Systems, organs and how the body works'),  -- Corpo Humano e Fisiologia
  ('82d8b80e-11eb-4f9e-bed3-f107fbba97d9', 'es', 'Cuerpo Humano y Fisiología', 'Sistemas, órganos y funcionamiento del organismo'),
  ('ad214c71-30af-4088-ba6f-b60f27258812', 'en', 'Cardiovascular system', null),  -- Sistema cardiovascular
  ('ad214c71-30af-4088-ba6f-b60f27258812', 'es', 'Sistema cardiovascular', null),
  ('e53efaa2-9b86-4ffb-a802-7981ff47cf0f', 'en', 'Heart', null),  -- Coração
  ('e53efaa2-9b86-4ffb-a802-7981ff47cf0f', 'es', 'Corazón', null),
  ('a1858027-f953-4d1b-8b40-3e2ff2456097', 'en', 'Valves', null),  -- Válvulas
  ('a1858027-f953-4d1b-8b40-3e2ff2456097', 'es', 'Válvulas', null),
  ('95373244-bfd4-4ba0-aa81-0d7cb89f8805', 'en', 'Arteries', null),  -- Artérias
  ('95373244-bfd4-4ba0-aa81-0d7cb89f8805', 'es', 'Arterias', null),
  ('3bdaccc7-106a-488d-a95b-8b42e9b29cc7', 'en', 'Veins', null),  -- Veias
  ('3bdaccc7-106a-488d-a95b-8b42e9b29cc7', 'es', 'Venas', null),
  ('7d0ed443-aa25-429f-89cd-b5ce672f22d2', 'en', 'Capillaries', null),  -- Capilares
  ('7d0ed443-aa25-429f-89cd-b5ce672f22d2', 'es', 'Capilares', null),
  ('bfeb4cb7-a05a-4d9b-a38d-a6e6815a808f', 'en', 'Pulmonary circulation', null),  -- Circulação pulmonar
  ('bfeb4cb7-a05a-4d9b-a38d-a6e6815a808f', 'es', 'Circulación pulmonar', null),
  ('c71f4bd6-9a85-47d3-b979-b99d2626971a', 'en', 'Systemic circulation', null),  -- Circulação sistêmica
  ('c71f4bd6-9a85-47d3-b979-b99d2626971a', 'es', 'Circulación sistémica', null),
  ('584a54b8-5141-4bf6-8b40-e045e0eebf43', 'en', 'Nervous system', null),  -- Sistema nervoso
  ('584a54b8-5141-4bf6-8b40-e045e0eebf43', 'es', 'Sistema nervioso', null),
  ('9480bb3f-8a4e-44dc-8040-c969d518bc77', 'en', 'Neuron', null),  -- Neurônio
  ('9480bb3f-8a4e-44dc-8040-c969d518bc77', 'es', 'Neurona', null),
  ('3802e1b8-5448-4536-87de-e4bc3341c3b0', 'en', 'Central nervous system', null),  -- Sistema nervoso central
  ('3802e1b8-5448-4536-87de-e4bc3341c3b0', 'es', 'Sistema nervioso central', null),
  ('9af22c5f-f2e2-4112-bc80-077daa270068', 'en', 'Peripheral nervous system', null),  -- Sistema nervoso periférico
  ('9af22c5f-f2e2-4112-bc80-077daa270068', 'es', 'Sistema nervioso periférico', null),
  ('df20c43e-9e92-4cbe-bd39-2a79e44e981e', 'en', 'Synapses', null),  -- Sinapses
  ('df20c43e-9e92-4cbe-bd39-2a79e44e981e', 'es', 'Sinapsis', null),
  ('3a31c349-9503-413e-b5bb-908655f4bc6b', 'en', 'Reflex arc', null),  -- Arco reflexo
  ('3a31c349-9503-413e-b5bb-908655f4bc6b', 'es', 'Arco reflejo', null),
  ('73124495-e312-4308-9edf-71f1edbfd5a5', 'en', 'Digestive system', null),  -- Sistema digestório
  ('73124495-e312-4308-9edf-71f1edbfd5a5', 'es', 'Sistema digestivo', null),
  ('2436eaec-370e-4bca-8451-cc835788a34f', 'en', 'Endocrine system', null),  -- Sistema endócrino
  ('2436eaec-370e-4bca-8451-cc835788a34f', 'es', 'Sistema endocrino', null),
  ('d717ee10-b8f6-4406-8314-3d4a9c9ed7d1', 'en', 'Immune system', null),  -- Sistema imunológico
  ('d717ee10-b8f6-4406-8314-3d4a9c9ed7d1', 'es', 'Sistema inmunitario', null),
  ('ac32071e-53bb-4644-bc7e-a0dfe219e216', 'en', 'Botany', 'Plant tissues, organs, reproduction and physiology'),  -- Botânica
  ('ac32071e-53bb-4644-bc7e-a0dfe219e216', 'es', 'Botánica', 'Tejidos, órganos, reproducción y fisiología vegetal'),
  ('b380072b-51b4-462b-99fa-266d0dcffa59', 'en', 'Zoology', 'Invertebrates, vertebrates and animal evolution'),  -- Zoologia
  ('b380072b-51b4-462b-99fa-266d0dcffa59', 'es', 'Zoología', 'Invertebrados, vertebrados y evolución animal'),
  ('bee5e4cb-fe57-4ac9-936a-626442f07b75', 'en', 'Microbiology and Health', 'Viruses, bacteria, protozoa, fungi and diseases'),  -- Microbiologia e Saúde
  ('bee5e4cb-fe57-4ac9-936a-626442f07b75', 'es', 'Microbiología y Salud', 'Virus, bacterias, protozoos, hongos y enfermedades'),
  ('18976237-e643-437e-8216-7ff0c5a09df5', 'en', 'Evolution', 'Natural selection, speciation and the origin of life'),  -- Evolução
  ('18976237-e643-437e-8216-7ff0c5a09df5', 'es', 'Evolución', 'Selección natural, especiación y origen de la vida'),
  ('1008dfdf-4892-4aeb-aa6d-ab444c40080a', 'en', 'Mechanics', 'Motion, forces, energy and gravitation'),  -- Mecânica
  ('1008dfdf-4892-4aeb-aa6d-ab444c40080a', 'es', 'Mecánica', 'Movimiento, fuerzas, energía y gravitación'),
  ('5c80bf20-516d-4821-8322-d2ccc3f1e195', 'en', 'Kinematics', null),  -- Cinemática
  ('5c80bf20-516d-4821-8322-d2ccc3f1e195', 'es', 'Cinemática', null),
  ('8298e55f-972f-4aef-9447-bff9347da0b7', 'en', 'Uniform motion', null),  -- Movimento uniforme
  ('8298e55f-972f-4aef-9447-bff9347da0b7', 'es', 'Movimiento uniforme', null),
  ('67153ecb-1781-4067-8650-94cb1de96321', 'en', 'Acceleration', null),  -- Aceleração
  ('67153ecb-1781-4067-8650-94cb1de96321', 'es', 'Aceleración', null),
  ('d8f64aef-8abc-45da-9e5d-501798c0d345', 'en', 'Uniformly accelerated motion', null),  -- Movimento uniformemente variado
  ('d8f64aef-8abc-45da-9e5d-501798c0d345', 'es', 'Movimiento uniformemente variado', null),
  ('95ca3ad3-5c40-4ccc-b0d0-0c54e2105207', 'en', 'Free fall', null),  -- Queda livre
  ('95ca3ad3-5c40-4ccc-b0d0-0c54e2105207', 'es', 'Caída libre', null),
  ('b6821cec-74b2-4da2-8026-8d821f82f15d', 'en', 'Horizontal launch', null),  -- Lançamento horizontal
  ('b6821cec-74b2-4da2-8026-8d821f82f15d', 'es', 'Lanzamiento horizontal', null),
  ('92e52c60-4571-450a-99cc-e6e840caa2f8', 'en', 'Oblique launch', null),  -- Lançamento oblíquo
  ('92e52c60-4571-450a-99cc-e6e840caa2f8', 'es', 'Lanzamiento oblicuo', null),
  ('9bd07167-90b3-4b80-b58c-096e5c179ff0', 'en', 'Dynamics', null),  -- Dinâmica
  ('9bd07167-90b3-4b80-b58c-096e5c179ff0', 'es', 'Dinámica', null),
  ('a5777654-961e-4813-9fed-c5d835825966', 'en', 'Newton''s First Law', null),  -- Primeira Lei de Newton
  ('a5777654-961e-4813-9fed-c5d835825966', 'es', 'Primera Ley de Newton', null),
  ('9df1808d-9ac5-4809-8bdb-63e12480aa97', 'en', 'Newton''s Second Law', null),  -- Segunda Lei de Newton
  ('9df1808d-9ac5-4809-8bdb-63e12480aa97', 'es', 'Segunda Ley de Newton', null),
  ('a1fea6a5-c59f-43d7-8ba9-0e6865d95221', 'en', 'Newton''s Third Law', null),  -- Terceira Lei de Newton
  ('a1fea6a5-c59f-43d7-8ba9-0e6865d95221', 'es', 'Tercera Ley de Newton', null),
  ('88d296cd-2bea-41f5-ad96-3bf158827298', 'en', 'Weight', null),  -- Força peso
  ('88d296cd-2bea-41f5-ad96-3bf158827298', 'es', 'Fuerza peso', null),
  ('ea8116d3-4182-4be6-a7b6-73f969adb43d', 'en', 'Normal force', null),  -- Força normal
  ('ea8116d3-4182-4be6-a7b6-73f969adb43d', 'es', 'Fuerza normal', null),
  ('fea10bb2-7f2f-40f8-baaf-e398343701aa', 'en', 'Friction', null),  -- Atrito
  ('fea10bb2-7f2f-40f8-baaf-e398343701aa', 'es', 'Rozamiento', null),
  ('7e0cc321-55aa-4635-b067-8ab32d376084', 'en', 'Inclined plane', null),  -- Plano inclinado
  ('7e0cc321-55aa-4635-b067-8ab32d376084', 'es', 'Plano inclinado', null),
  ('f394659b-6de0-4d60-a1bf-4935db2b35b5', 'en', 'Work and energy', null),  -- Trabalho e energia
  ('f394659b-6de0-4d60-a1bf-4935db2b35b5', 'es', 'Trabajo y energía', null),
  ('e5d65d25-c4b5-40b9-8c2a-641f4c56e0bb', 'en', 'Gravitation', null),  -- Gravitação
  ('e5d65d25-c4b5-40b9-8c2a-641f4c56e0bb', 'es', 'Gravitación', null),
  ('c11d5ba1-65e8-487a-96e0-38e15a64af15', 'en', 'Thermology and Thermodynamics', 'Temperature, heat, gases and heat engines'),  -- Termologia e Termodinâmica
  ('c11d5ba1-65e8-487a-96e0-38e15a64af15', 'es', 'Termología y Termodinámica', 'Temperatura, calor, gases y máquinas térmicas'),
  ('8f3b95a7-93f3-4d62-b383-d9b66d005f08', 'en', 'Waves', 'Waves, sound, frequency and wave phenomena'),  -- Ondulatória
  ('8f3b95a7-93f3-4d62-b383-d9b66d005f08', 'es', 'Ondulatoria', 'Ondas, sonido, frecuencia y fenómenos ondulatorios'),
  ('86d67080-58c6-4e5c-b97e-f5237c2ab57e', 'en', 'Optics', 'Mirrors, lenses, reflection and refraction'),  -- Óptica
  ('86d67080-58c6-4e5c-b97e-f5237c2ab57e', 'es', 'Óptica', 'Espejos, lentes, reflexión y refracción'),
  ('c14b193d-29a7-4918-8349-596384e4b6b7', 'en', 'Spherical mirrors', null),  -- Espelhos esféricos
  ('c14b193d-29a7-4918-8349-596384e4b6b7', 'es', 'Espejos esféricos', null),
  ('3d47f86a-ebcd-4a53-8742-71245315dc79', 'en', 'Concave mirror', null),  -- Espelho côncavo
  ('3d47f86a-ebcd-4a53-8742-71245315dc79', 'es', 'Espejo cóncavo', null),
  ('9cd02d29-4fa4-4a9e-ac80-69ac42eb183a', 'en', 'Convex mirror', null),  -- Espelho convexo
  ('9cd02d29-4fa4-4a9e-ac80-69ac42eb183a', 'es', 'Espejo convexo', null),
  ('2e7f9326-dd6b-4cf9-820b-df10c38fef0c', 'en', 'Focus and center of curvature', null),  -- Foco e centro de curvatura
  ('2e7f9326-dd6b-4cf9-820b-df10c38fef0c', 'es', 'Foco y centro de curvatura', null),
  ('7d71354e-4686-4b6b-8825-be631b2ad042', 'en', 'Principal rays', null),  -- Raios notáveis
  ('7d71354e-4686-4b6b-8825-be631b2ad042', 'es', 'Rayos notables', null),
  ('cff09107-8f47-44a2-a166-8ba7a3c3d6ca', 'en', 'Image formation', null),  -- Formação de imagens
  ('cff09107-8f47-44a2-a166-8ba7a3c3d6ca', 'es', 'Formación de imágenes', null),
  ('842d5646-9a58-480a-854b-74957cc64527', 'en', 'Lenses', null),  -- Lentes
  ('842d5646-9a58-480a-854b-74957cc64527', 'es', 'Lentes', null),
  ('b124402a-4ae1-486c-abee-1db66cc184a6', 'en', 'Converging lenses', null),  -- Lentes convergentes
  ('b124402a-4ae1-486c-abee-1db66cc184a6', 'es', 'Lentes convergentes', null),
  ('4531a57b-6384-4e17-ac73-6ebbe7849d71', 'en', 'Diverging lenses', null),  -- Lentes divergentes
  ('4531a57b-6384-4e17-ac73-6ebbe7849d71', 'es', 'Lentes divergentes', null),
  ('267de3da-1b72-4c3d-af98-0a38a3bedc32', 'en', 'Myopia', null),  -- Miopia
  ('267de3da-1b72-4c3d-af98-0a38a3bedc32', 'es', 'Miopía', null),
  ('d28fdc19-50a8-4dca-9d0e-98407bfc325b', 'en', 'Hyperopia', null),  -- Hipermetropia
  ('d28fdc19-50a8-4dca-9d0e-98407bfc325b', 'es', 'Hipermetropía', null),
  ('c7c85039-59ec-4178-8acd-9d672c717542', 'en', 'Presbyopia', null),  -- Presbiopia
  ('c7c85039-59ec-4178-8acd-9d672c717542', 'es', 'Presbicia', null),
  ('89939da9-3bec-40f4-826d-514c063a9351', 'en', 'Electricity', 'Charges, circuits, current and power'),  -- Eletricidade
  ('89939da9-3bec-40f4-826d-514c063a9351', 'es', 'Electricidad', 'Cargas, circuitos, corriente y potencia'),
  ('2678423c-4c04-4815-aea0-c4568078732e', 'en', 'Magnetism and Electromagnetism', 'Magnetic fields, induction and electromagnetic waves'),  -- Magnetismo e Eletromagnetismo
  ('2678423c-4c04-4815-aea0-c4568078732e', 'es', 'Magnetismo y Electromagnetismo', 'Campos magnéticos, inducción y ondas electromagnéticas'),
  ('bf4b630c-1de1-4cdd-9cbf-f31c70007234', 'en', 'Fluids', 'Pressure, hydrostatics and buoyancy'),  -- Fluidos
  ('bf4b630c-1de1-4cdd-9cbf-f31c70007234', 'es', 'Fluidos', 'Presión, hidrostática y empuje'),
  ('85e6f278-d298-4e1f-aca8-e602debf1051', 'en', 'Modern Physics', 'Relativity, quantum physics, radioactivity and nuclear physics'),  -- Física Moderna
  ('85e6f278-d298-4e1f-aca8-e602debf1051', 'es', 'Física Moderna', 'Relatividad, cuántica, radiactividad y física nuclear'),
  ('62729857-18c7-447e-9348-b4ec76710bf3', 'en', 'Brazil', 'States, cities, rivers, landforms, biomes and much more'),  -- Brasil
  ('62729857-18c7-447e-9348-b4ec76710bf3', 'es', 'Brasil', 'Estados, ciudades, ríos, relieve, biomas y mucho más'),
  ('e1fc8704-0f8f-40c0-8083-b9830200e2a0', 'en', 'Territory', null),  -- Território
  ('e1fc8704-0f8f-40c0-8083-b9830200e2a0', 'es', 'Territorio', null),
  ('bf6e1daa-f7c7-4ee3-a6fc-7831372d872d', 'en', 'Hydrography', null),  -- Hidrografia
  ('bf6e1daa-f7c7-4ee3-a6fc-7831372d872d', 'es', 'Hidrografía', null),
  ('19ff93e1-6e9b-4f31-a0d1-0c1501339130', 'en', 'Main rivers of Brazil', null),  -- Principais rios do Brasil
  ('19ff93e1-6e9b-4f31-a0d1-0c1501339130', 'es', 'Principales ríos de Brasil', null),
  ('d5cb9910-b35e-4b55-a2fd-f0a975e28c2a', 'en', 'Brazilian river basins', null),  -- Bacias hidrográficas brasileiras
  ('d5cb9910-b35e-4b55-a2fd-f0a975e28c2a', 'es', 'Cuencas hidrográficas brasileñas', null),
  ('fa2a77cc-acc8-4010-91b0-d3f600d7dab1', 'en', 'Amazon River and its main tributaries', null),  -- Rio Amazonas e seus principais afluentes
  ('fa2a77cc-acc8-4010-91b0-d3f600d7dab1', 'es', 'Río Amazonas y sus principales afluentes', null),
  ('32c25d44-9f51-4d08-9767-d15a6cb09f8b', 'en', 'Paraná River and its main tributaries', null),  -- Rio Paraná e seus principais afluentes
  ('32c25d44-9f51-4d08-9767-d15a6cb09f8b', 'es', 'Río Paraná y sus principales afluentes', null),
  ('f8a0db60-38ed-4512-89a3-addf95defa11', 'en', 'São Francisco River and its main tributaries', null),  -- Rio São Francisco e seus principais afluentes
  ('f8a0db60-38ed-4512-89a3-addf95defa11', 'es', 'Río São Francisco y sus principales afluentes', null),
  ('3d3fa6fe-b7fb-4e32-8fb7-bba2482fa0ab', 'en', 'Rivers of the North Region', null),  -- Rios da Região Norte
  ('3d3fa6fe-b7fb-4e32-8fb7-bba2482fa0ab', 'es', 'Ríos de la Región Norte', null),
  ('2095a633-a9fa-4276-8a1b-2706f22380b7', 'en', 'Rivers of the Northeast Region', null),  -- Rios da Região Nordeste
  ('2095a633-a9fa-4276-8a1b-2706f22380b7', 'es', 'Ríos de la Región Nordeste', null),
  ('d8d82add-d42c-4609-9e28-8160f20bf1a3', 'en', 'Rivers of the Center-West Region', null),  -- Rios da Região Centro-Oeste
  ('d8d82add-d42c-4609-9e28-8160f20bf1a3', 'es', 'Ríos de la Región Centro-Oeste', null),
  ('8065021b-5ec4-4470-bc6b-a743898a5955', 'en', 'Rivers of the Southeast Region', null),  -- Rios da Região Sudeste
  ('8065021b-5ec4-4470-bc6b-a743898a5955', 'es', 'Ríos de la Región Sudeste', null),
  ('39e51a80-1df3-4d6d-9652-a25f10b2424f', 'en', 'Rivers of the South Region', null),  -- Rios da Região Sul
  ('39e51a80-1df3-4d6d-9652-a25f10b2424f', 'es', 'Ríos de la Región Sur', null),
  ('291853ce-ec62-4e00-baad-3bc93128bebe', 'en', 'Main Brazilian hydroelectric plants', null),  -- Principais hidrelétricas brasileiras
  ('291853ce-ec62-4e00-baad-3bc93128bebe', 'es', 'Principales centrales hidroeléctricas brasileñas', null),
  ('c2ee332a-93df-4032-b968-8d3f4c859250', 'en', 'Landforms', null),  -- Relevo
  ('c2ee332a-93df-4032-b968-8d3f4c859250', 'es', 'Relieve', null),
  ('421fb392-005c-454f-a735-8c430672cd5e', 'en', 'Biomes and vegetation', null),  -- Biomas e vegetação
  ('421fb392-005c-454f-a735-8c430672cd5e', 'es', 'Biomas y vegetación', null),
  ('1d8e2476-b39c-452a-83ab-dc6b973c000d', 'en', 'Climate', null),  -- Clima
  ('1d8e2476-b39c-452a-83ab-dc6b973c000d', 'es', 'Clima', null),
  ('e85aad6a-8b81-41c2-8952-3010f13c5fb8', 'en', 'Cities', null),  -- Cidades
  ('e85aad6a-8b81-41c2-8952-3010f13c5fb8', 'es', 'Ciudades', null),
  ('17b0d454-779f-4859-8380-470d5e4ddf23', 'en', 'Human geography', null),  -- Geografia humana
  ('17b0d454-779f-4859-8380-470d5e4ddf23', 'es', 'Geografía humana', null),
  ('3da92cbb-f674-4829-ad98-d346809fcb78', 'en', 'Economic geography', null),  -- Geografia econômica
  ('3da92cbb-f674-4829-ad98-d346809fcb78', 'es', 'Geografía económica', null),
  ('294b30a4-5efc-49fc-ac23-302a3ff4d180', 'en', 'States', null),  -- Estados
  ('294b30a4-5efc-49fc-ac23-302a3ff4d180', 'es', 'Estados', null),
  ('7de338e6-9744-46a0-9b49-2ef0bb0a4c66', 'en', 'Goiás', null),  -- Goiás
  ('7de338e6-9744-46a0-9b49-2ef0bb0a4c66', 'es', 'Goiás', null),
  ('2e944ac7-b959-45ed-99f0-440a0be55aa7', 'en', 'Municipalities', null),  -- Municípios
  ('2e944ac7-b959-45ed-99f0-440a0be55aa7', 'es', 'Municipios', null),
  ('c68a49b8-1679-4edd-9d1f-03e0d46b3178', 'en', 'Main cities', null),  -- Principais cidades
  ('c68a49b8-1679-4edd-9d1f-03e0d46b3178', 'es', 'Principales ciudades', null),
  ('0182c671-3269-47b0-9b4f-4ffa92509e18', 'en', 'Rivers', null),  -- Rios
  ('0182c671-3269-47b0-9b4f-4ffa92509e18', 'es', 'Ríos', null),
  ('0d84ad26-a469-4c2b-b022-f0c5bb724e13', 'en', 'Araguaia River', null),  -- Rio Araguaia
  ('0d84ad26-a469-4c2b-b022-f0c5bb724e13', 'es', 'Río Araguaia', null),
  ('5a03b58b-9347-425a-a4c8-b8117a351d37', 'en', 'Paranaíba River', null),  -- Rio Paranaíba
  ('5a03b58b-9347-425a-a4c8-b8117a351d37', 'es', 'Río Paranaíba', null),
  ('6d679874-fdd0-4b6d-a3b8-76488172e735', 'en', 'Meia Ponte River', null),  -- Rio Meia Ponte
  ('6d679874-fdd0-4b6d-a3b8-76488172e735', 'es', 'Río Meia Ponte', null),
  ('c1b714b7-f1e5-45ab-a154-0d610e35f4d4', 'en', 'Corumbá River', null),  -- Rio Corumbá
  ('c1b714b7-f1e5-45ab-a154-0d610e35f4d4', 'es', 'Río Corumbá', null),
  ('b70eaa36-0f04-4dc3-9a1d-136986b0c125', 'en', 'Das Almas River', null),  -- Rio das Almas
  ('b70eaa36-0f04-4dc3-9a1d-136986b0c125', 'es', 'Río das Almas', null),
  ('f433d7c9-1e81-4194-b72f-72353b47da82', 'en', 'Vermelho River', null),  -- Rio Vermelho
  ('f433d7c9-1e81-4194-b72f-72353b47da82', 'es', 'Río Vermelho', null),
  ('b27d26d7-d97d-401f-acb9-5e3fdc114ac9', 'en', 'Landforms', null),  -- Relevo
  ('b27d26d7-d97d-401f-acb9-5e3fdc114ac9', 'es', 'Relieve', null),
  ('c65b7146-55a4-4cdf-9635-6e0f2e2cd20a', 'en', 'Vegetation', null),  -- Vegetação
  ('c65b7146-55a4-4cdf-9635-6e0f2e2cd20a', 'es', 'Vegetación', null),
  ('3c380043-c7e1-4e78-b0c7-8e4e8f9f1c5c', 'en', 'Climate', null),  -- Clima
  ('3c380043-c7e1-4e78-b0c7-8e4e8f9f1c5c', 'es', 'Clima', null),
  ('62b00d63-c257-4541-bcc7-083fba96d806', 'en', 'Regional divisions', null),  -- Divisões regionais
  ('62b00d63-c257-4541-bcc7-083fba96d806', 'es', 'Divisiones regionales', null),
  ('5fcbdbdf-b066-4a44-a9c1-fa464dead5cf', 'en', 'Goiânia Metropolitan Region', null),  -- Região Metropolitana de Goiânia
  ('5fcbdbdf-b066-4a44-a9c1-fa464dead5cf', 'es', 'Región Metropolitana de Goiânia', null),
  ('19d5aaee-9c87-442a-8f56-f04174952d3a', 'en', 'Economy', null),  -- Economia
  ('19d5aaee-9c87-442a-8f56-f04174952d3a', 'es', 'Economía', null),
  ('3e6171a4-2d01-4fe7-8aed-f86614908ea9', 'en', 'Landforms of Brazil', 'Brazil''s main mountain ranges, plateaus, tablelands and plains'),  -- Relevo do Brasil
  ('3e6171a4-2d01-4fe7-8aed-f86614908ea9', 'es', 'Relieve de Brasil', 'Las principales sierras, mesetas, chapadas y llanuras de Brasil'),
  ('91b59525-7426-4918-835d-0a12afe2c688', 'en', 'Industry in Brazil', 'Brazil''s main industrial hubs and ports'),  -- Indústria do Brasil
  ('91b59525-7426-4918-835d-0a12afe2c688', 'es', 'Industria de Brasil', 'Los principales polos industriales y puertos de Brasil'),
  ('72caea53-82f0-4f9a-ac0c-b8b834587043', 'en', 'Agriculture in Brazil', 'Soybeans, sugarcane, coffee, oranges and the country''s main agricultural frontiers'),  -- Agricultura do Brasil
  ('72caea53-82f0-4f9a-ac0c-b8b834587043', 'es', 'Agricultura de Brasil', 'Soja, caña de azúcar, café, naranja y las principales fronteras agrícolas del país'),
  ('1e13d445-2268-4d4f-abed-aeeef2db21e1', 'en', 'Urbanization of Brazil', null),  -- Urbanização do Brasil
  ('1e13d445-2268-4d4f-abed-aeeef2db21e1', 'es', 'Urbanización de Brasil', null),
  ('787ccefa-e009-4971-bcd0-35b20ba3b4bd', 'en', 'Biomes of Brazil', 'Amazon, Cerrado, Atlantic Forest, Caatinga, Pampa and Pantanal on the map'),  -- Biomas do Brasil
  ('787ccefa-e009-4971-bcd0-35b20ba3b4bd', 'es', 'Biomas de Brasil', 'Amazonia, Cerrado, Mata Atlántica, Caatinga, Pampa y Pantanal en el mapa'),
  ('668506de-7073-4f06-b633-ec983a590b79', 'en', 'Ports of Brazil', 'The main Brazilian ports on the map'),  -- Portos do Brasil
  ('668506de-7073-4f06-b633-ec983a590b79', 'es', 'Puertos de Brasil', 'Los principales puertos brasileños en el mapa'),
  ('295cbec6-0a96-4586-99c8-d1da8b0e515a', 'en', 'Population of Brazil', null),  -- População do Brasil
  ('295cbec6-0a96-4586-99c8-d1da8b0e515a', 'es', 'Población de Brasil', null),
  ('99b6637a-cdd8-4b7e-b3aa-67ab095831fc', 'en', 'Energy in Brazil', null),  -- Energia do Brasil
  ('99b6637a-cdd8-4b7e-b3aa-67ab095831fc', 'es', 'Energía de Brasil', null),
  ('38591ed7-9d86-4b5e-9330-b8810e8ef782', 'en', 'Environmental issues in Brazil', null),  -- Questão ambiental do Brasil
  ('38591ed7-9d86-4b5e-9330-b8810e8ef782', 'es', 'Cuestión ambiental de Brasil', null),
  ('a7206d68-f61b-45a0-9ee8-70722a723fb7', 'en', 'South America', 'Countries, capitals, cities, landforms and hydrography'),  -- América do Sul
  ('a7206d68-f61b-45a0-9ee8-70722a723fb7', 'es', 'América del Sur', 'Países, capitales, ciudades, relieve e hidrografía'),
  ('159b40c1-303d-4999-bce4-a6fb7ade0b01', 'en', 'Countries', null),  -- Países
  ('159b40c1-303d-4999-bce4-a6fb7ade0b01', 'es', 'Países', null),
  ('8cca30ab-8897-4078-88cb-c135900e9008', 'en', 'Flags', null),  -- Bandeiras
  ('8cca30ab-8897-4078-88cb-c135900e9008', 'es', 'Banderas', null),
  ('7a9fe166-a904-4a6a-b418-db163e1d20a1', 'en', 'Capitals', null),  -- Capitais
  ('7a9fe166-a904-4a6a-b418-db163e1d20a1', 'es', 'Capitales', null),
  ('d8bcc5de-a0b8-49a7-a017-8f4fba6b4f92', 'en', 'Cities', null),  -- Cidades
  ('d8bcc5de-a0b8-49a7-a017-8f4fba6b4f92', 'es', 'Ciudades', null),
  ('78cd83dd-f366-4f08-b362-13a1625be062', 'en', 'Rivers', null),  -- Rios
  ('78cd83dd-f366-4f08-b362-13a1625be062', 'es', 'Ríos', null),
  ('651d1ca4-bfd4-48a2-802b-15fd15786685', 'en', 'Landforms', null),  -- Relevo
  ('651d1ca4-bfd4-48a2-802b-15fd15786685', 'es', 'Relieve', null),
  ('16effb57-67b7-4aa0-9d12-9c77a863097b', 'en', 'Biomes', null),  -- Biomas
  ('16effb57-67b7-4aa0-9d12-9c77a863097b', 'es', 'Biomas', null),
  ('9d06b616-e4e7-4d43-9526-719c3e8a6d1c', 'en', 'Administrative divisions', null),  -- Divisões administrativas
  ('9d06b616-e4e7-4d43-9526-719c3e8a6d1c', 'es', 'Divisiones administrativas', null),
  ('81783211-0d77-45eb-9444-94b49ec16201', 'en', 'Landmarks', null),  -- Pontos turísticos
  ('81783211-0d77-45eb-9444-94b49ec16201', 'es', 'Puntos turísticos', null),
  ('d9e7a22c-03de-4849-ad6d-3420107e4805', 'en', 'Biomes of South America', 'Amazon, Atacama, Patagonia and Pampa on the map'),  -- Biomas da América do Sul
  ('d9e7a22c-03de-4849-ad6d-3420107e4805', 'es', 'Biomas de América del Sur', 'Amazonia, Atacama, Patagonia y Pampa en el mapa'),
  ('ec75dc30-24b6-4d4d-9eda-a08130cb618c', 'en', 'North America', 'Countries, states, capitals, landforms and hydrography'),  -- América do Norte
  ('ec75dc30-24b6-4d4d-9eda-a08130cb618c', 'es', 'América del Norte', 'Países, estados, capitales, relieve e hidrografía'),
  ('8614d4f5-57de-4adb-b791-b2675d231146', 'en', 'Countries', 'Countries, capitals, cities and landforms'),  -- Países
  ('8614d4f5-57de-4adb-b791-b2675d231146', 'es', 'Países', 'Países, capitales, ciudades y relieve'),
  ('4d01bc22-f595-4fc6-a438-47dd5149eec5', 'en', 'Rivers', 'Main rivers of North America'),  -- Rios
  ('4d01bc22-f595-4fc6-a438-47dd5149eec5', 'es', 'Ríos', 'Principales ríos de América del Norte'),
  ('37225bb6-1d51-478c-b34f-9a0519ce152a', 'en', 'Capitals', 'Capitals of the North American countries'),  -- Capitais
  ('37225bb6-1d51-478c-b34f-9a0519ce152a', 'es', 'Capitales', 'Capitales de los países norteamericanos'),
  ('8cb43a48-5bb3-499f-ba84-88766dbee7c6', 'en', 'Cities', 'Major cities of North America'),  -- Cidades
  ('8cb43a48-5bb3-499f-ba84-88766dbee7c6', 'es', 'Ciudades', 'Grandes ciudades de América del Norte'),
  ('3f1bce0e-b7e7-4483-8384-5fe7814d8d46', 'en', 'Flags', 'Flags of the North American countries'),  -- Bandeiras
  ('3f1bce0e-b7e7-4483-8384-5fe7814d8d46', 'es', 'Banderas', 'Banderas de los países de América del Norte'),
  ('235355d0-5d0f-47c2-a32b-b50cfcb30d07', 'en', 'Landforms of North America', 'The main mountain ranges of North America'),  -- Relevo da América do Norte
  ('235355d0-5d0f-47c2-a32b-b50cfcb30d07', 'es', 'Relieve de América del Norte', 'Las principales cordilleras de América del Norte'),
  ('181684b0-7fa9-46bd-84e5-734978827037', 'en', 'United States', 'Agriculture, industry and the main economic belts of the US'),  -- Estados Unidos
  ('181684b0-7fa9-46bd-84e5-734978827037', 'es', 'Estados Unidos', 'Agricultura, industria y los principales cinturones económicos de EE. UU.'),
  ('3318de1e-d0da-4b05-a5b8-a1af7d831a15', 'en', 'Europe', 'Countries, capitals, cities, rivers and landforms'),  -- Europa
  ('3318de1e-d0da-4b05-a5b8-a1af7d831a15', 'es', 'Europa', 'Países, capitales, ciudades, ríos y relieve'),
  ('b1b8af46-010e-47dc-9be3-520ad7b987d3', 'en', 'Countries', null),  -- Países
  ('b1b8af46-010e-47dc-9be3-520ad7b987d3', 'es', 'Países', null),
  ('47c2eaf3-d4e4-476c-90b7-1cf6d8ddad27', 'en', 'Flags', null),  -- Bandeiras
  ('47c2eaf3-d4e4-476c-90b7-1cf6d8ddad27', 'es', 'Banderas', null),
  ('0f32f1d7-45c0-40ea-b0d8-7b6059c7bfff', 'en', 'Capitals', null),  -- Capitais
  ('0f32f1d7-45c0-40ea-b0d8-7b6059c7bfff', 'es', 'Capitales', null),
  ('c3a94a41-c598-4f80-a222-38064c3a9770', 'en', 'Cities', null),  -- Cidades
  ('c3a94a41-c598-4f80-a222-38064c3a9770', 'es', 'Ciudades', null),
  ('f61b0f28-002f-4064-beea-76e7bd89f845', 'en', 'Rivers', null),  -- Rios
  ('f61b0f28-002f-4064-beea-76e7bd89f845', 'es', 'Ríos', null),
  ('024a3408-7afd-4ae5-87a7-d01e94a4cc5d', 'en', 'Lakes and seas', null),  -- Lagos e mares
  ('024a3408-7afd-4ae5-87a7-d01e94a4cc5d', 'es', 'Lagos y mares', null),
  ('39cd3699-9134-4ae4-a810-bf5854cc893e', 'en', 'Mountains and mountain ranges', null),  -- Montanhas e cordilheiras
  ('39cd3699-9134-4ae4-a810-bf5854cc893e', 'es', 'Montañas y cordilleras', null),
  ('317fe9ba-4cc0-45be-8f55-89b8ac9f951d', 'en', 'Regions', null),  -- Regiões
  ('317fe9ba-4cc0-45be-8f55-89b8ac9f951d', 'es', 'Regiones', null),
  ('cfe523b9-6edd-4b76-85ac-76bcbf1b49ba', 'en', 'Historical geography', null),  -- Geografia histórica
  ('cfe523b9-6edd-4b76-85ac-76bcbf1b49ba', 'es', 'Geografía histórica', null),
  ('a68d37cf-fbfd-421f-b4ee-0345138f868c', 'en', 'Landmarks', null),  -- Pontos turísticos
  ('a68d37cf-fbfd-421f-b4ee-0345138f868c', 'es', 'Puntos turísticos', null),
  ('ad46bf73-1dda-4a66-9057-abdaed47de79', 'en', 'Africa', 'Countries, capitals, cities, rivers and landforms'),  -- África
  ('ad46bf73-1dda-4a66-9057-abdaed47de79', 'es', 'África', 'Países, capitales, ciudades, ríos y relieve'),
  ('2d0a356f-6664-447e-9e99-4584d8e0663f', 'en', 'Countries', null),  -- Países
  ('2d0a356f-6664-447e-9e99-4584d8e0663f', 'es', 'Países', null),
  ('5b6a06bb-fa04-4671-960f-19ce67fe4808', 'en', 'Flags', null),  -- Bandeiras
  ('5b6a06bb-fa04-4671-960f-19ce67fe4808', 'es', 'Banderas', null),
  ('9c16fc74-a23e-4822-9c43-bf88f29e6a0c', 'en', 'Capitals', null),  -- Capitais
  ('9c16fc74-a23e-4822-9c43-bf88f29e6a0c', 'es', 'Capitales', null),
  ('6be2cc01-a1de-4e42-a10d-d0833c6ff83b', 'en', 'Cities', null),  -- Cidades
  ('6be2cc01-a1de-4e42-a10d-d0833c6ff83b', 'es', 'Ciudades', null),
  ('43e1463b-59ff-4dd7-b618-283a592c3f2f', 'en', 'Rivers', null),  -- Rios
  ('43e1463b-59ff-4dd7-b618-283a592c3f2f', 'es', 'Ríos', null),
  ('83bb1fe7-ca34-46c4-8f12-9dcb0ddb7fa4', 'en', 'Lakes', null),  -- Lagos
  ('83bb1fe7-ca34-46c4-8f12-9dcb0ddb7fa4', 'es', 'Lagos', null),
  ('11e4ec76-57ff-4ea6-9068-7d8cc2f9ecdc', 'en', 'Deserts', null),  -- Desertos
  ('11e4ec76-57ff-4ea6-9068-7d8cc2f9ecdc', 'es', 'Desiertos', null),
  ('7b96b08c-035a-4cd7-a7b8-e071c3d22d39', 'en', 'Landforms', null),  -- Relevo
  ('7b96b08c-035a-4cd7-a7b8-e071c3d22d39', 'es', 'Relieve', null),
  ('4764c0da-a7f1-4cea-a2f9-25a32420095e', 'en', 'African regions', null),  -- Regiões africanas
  ('4764c0da-a7f1-4cea-a2f9-25a32420095e', 'es', 'Regiones africanas', null),
  ('6ef525e5-6426-4cef-8f65-52f84fde3162', 'en', 'Asia', 'Countries, capitals, cities, rivers and landforms'),  -- Ásia
  ('6ef525e5-6426-4cef-8f65-52f84fde3162', 'es', 'Asia', 'Países, capitales, ciudades, ríos y relieve'),
  ('a76aa97e-2694-41b8-a5f7-cedf46df41c6', 'en', 'Countries', null),  -- Países
  ('a76aa97e-2694-41b8-a5f7-cedf46df41c6', 'es', 'Países', null),
  ('57aabc63-5acd-4c54-8212-0f1f49ab44a2', 'en', 'Flags', null),  -- Bandeiras
  ('57aabc63-5acd-4c54-8212-0f1f49ab44a2', 'es', 'Banderas', null),
  ('57e578a4-38f4-4770-ae1f-890ef3e3f6f9', 'en', 'Capitals', null),  -- Capitais
  ('57e578a4-38f4-4770-ae1f-890ef3e3f6f9', 'es', 'Capitales', null),
  ('2bfe0425-c32a-4e2f-b783-140c79cdd33c', 'en', 'Cities', null),  -- Cidades
  ('2bfe0425-c32a-4e2f-b783-140c79cdd33c', 'es', 'Ciudades', null),
  ('6bb22a03-a00d-4515-8839-261640323b81', 'en', 'Rivers', null),  -- Rios
  ('6bb22a03-a00d-4515-8839-261640323b81', 'es', 'Ríos', null),
  ('6f5b44f6-3f1f-462f-a9e3-c34c2c8b0620', 'en', 'Seas', null),  -- Mares
  ('6f5b44f6-3f1f-462f-a9e3-c34c2c8b0620', 'es', 'Mares', null),
  ('f9ddd491-8916-4c61-89ec-55ef3394ede1', 'en', 'Mountain ranges', null),  -- Cordilheiras
  ('f9ddd491-8916-4c61-89ec-55ef3394ede1', 'es', 'Cordilleras', null),
  ('4aaed524-89fd-452f-bfd3-b85e6ba7bbcd', 'en', 'Deserts', null),  -- Desertos
  ('4aaed524-89fd-452f-bfd3-b85e6ba7bbcd', 'es', 'Desiertos', null),
  ('54e2d513-1aca-4dcb-919c-c701ae13b47b', 'en', 'Middle East', null),  -- Oriente Médio
  ('54e2d513-1aca-4dcb-919c-c701ae13b47b', 'es', 'Oriente Medio', null),
  ('ed3c676d-d6e4-45e7-937b-c3e4178be67e', 'en', 'Southeast Asia', null),  -- Sudeste Asiático
  ('ed3c676d-d6e4-45e7-937b-c3e4178be67e', 'es', 'Sudeste Asiático', null),
  ('0610487b-0326-483f-9176-e0f3e54f5b12', 'en', 'South Asia', null),  -- Sul da Ásia
  ('0610487b-0326-483f-9176-e0f3e54f5b12', 'es', 'Asia del Sur', null),
  ('a27dfbf2-4b16-442c-a302-7a47d7eae57a', 'en', 'Central Asia', null),  -- Ásia Central
  ('a27dfbf2-4b16-442c-a302-7a47d7eae57a', 'es', 'Asia Central', null),
  ('66a2cb34-89b3-4d86-89e1-e1f3ffaa9b85', 'en', 'Oceania', 'Countries, capitals, islands and landforms'),  -- Oceania
  ('66a2cb34-89b3-4d86-89e1-e1f3ffaa9b85', 'es', 'Oceanía', 'Países, capitales, islas y relieve'),
  ('54557ac9-e1c0-4528-8f85-90770585ce70', 'en', 'Countries', 'Countries, capitals, islands and landforms'),  -- Países
  ('54557ac9-e1c0-4528-8f85-90770585ce70', 'es', 'Países', 'Países, capitales, islas y relieve'),
  ('3f3122b9-8bf1-4d7c-aa38-1a018a71e83d', 'en', 'Capitals', 'Capitals of the countries of Oceania'),  -- Capitais
  ('3f3122b9-8bf1-4d7c-aa38-1a018a71e83d', 'es', 'Capitales', 'Capitales de los países de Oceanía'),
  ('2d920dbb-3653-4c07-83c2-645e456f068b', 'en', 'Cities', 'Major cities of Oceania'),  -- Cidades
  ('2d920dbb-3653-4c07-83c2-645e456f068b', 'es', 'Ciudades', 'Grandes ciudades de Oceanía'),
  ('695fcbfa-09f7-4720-9bb0-5405cf446dc2', 'en', 'Flags', 'Flags of the countries of Oceania'),  -- Bandeiras
  ('695fcbfa-09f7-4720-9bb0-5405cf446dc2', 'es', 'Banderas', 'Banderas de los países de Oceanía'),
  ('4f1631c5-7b29-418f-93aa-8eb82ab150ee', 'en', 'Landforms of Oceania', 'The main mountain ranges of Oceania'),  -- Relevo da Oceania
  ('4f1631c5-7b29-418f-93aa-8eb82ab150ee', 'es', 'Relieve de Oceanía', 'Las principales cordilleras de Oceanía'),
  ('3d8ed012-2fd0-49b8-b238-294f80dcec07', 'en', 'World', 'Continents, oceans, countries and major landforms'),  -- Mundo
  ('3d8ed012-2fd0-49b8-b238-294f80dcec07', 'es', 'Mundo', 'Continentes, océanos, países y grandes formaciones'),
  ('b836a0bd-abe7-4cdb-bcd4-6f8f6468d569', 'en', 'Continents', null),  -- Continentes
  ('b836a0bd-abe7-4cdb-bcd4-6f8f6468d569', 'es', 'Continentes', null),
  ('ea820801-fbfb-4e37-adad-d3183549f66b', 'en', 'Oceans', null),  -- Oceanos
  ('ea820801-fbfb-4e37-adad-d3183549f66b', 'es', 'Océanos', null),
  ('7702b50d-364a-4236-a042-7d2799328521', 'en', 'Countries of the world', null),  -- Países do mundo
  ('7702b50d-364a-4236-a042-7d2799328521', 'es', 'Países del mundo', null),
  ('b57f2795-d8f3-43dc-a7aa-e082fc887568', 'en', 'Flags of the world', null),  -- Bandeiras do mundo
  ('b57f2795-d8f3-43dc-a7aa-e082fc887568', 'es', 'Banderas del mundo', null),
  ('19ee546c-270d-4111-9e73-10ff9398e303', 'en', 'Capitals of the world', null),  -- Capitais do mundo
  ('19ee546c-270d-4111-9e73-10ff9398e303', 'es', 'Capitales del mundo', null),
  ('67418a3d-3a87-4885-921d-317c75c99383', 'en', 'Major cities', null),  -- Grandes cidades
  ('67418a3d-3a87-4885-921d-317c75c99383', 'es', 'Grandes ciudades', null),
  ('a5731187-0c27-4a85-85fc-a82650ac35ac', 'en', 'Major rivers', null),  -- Grandes rios
  ('a5731187-0c27-4a85-85fc-a82650ac35ac', 'es', 'Grandes ríos', null),
  ('cf19dc0c-5419-4c3a-adb5-3110aab30085', 'en', 'Seas', null),  -- Mares
  ('cf19dc0c-5419-4c3a-adb5-3110aab30085', 'es', 'Mares', null),
  ('fecad808-3cd6-4ddd-818b-e3d612641ee5', 'en', 'Major mountain ranges', null),  -- Grandes cordilheiras
  ('fecad808-3cd6-4ddd-818b-e3d612641ee5', 'es', 'Grandes cordilleras', null),
  ('219bc852-f7c0-4ba9-9c29-4bc6339eae7d', 'en', 'Deserts', null),  -- Desertos
  ('219bc852-f7c0-4ba9-9c29-4bc6339eae7d', 'es', 'Desiertos', null),
  ('4f527027-310f-4c38-8269-328fb6741d06', 'en', 'Islands', null),  -- Ilhas
  ('4f527027-310f-4c38-8269-328fb6741d06', 'es', 'Islas', null),
  ('458454b8-1e00-4241-9f27-9f072ba586fe', 'en', 'Volcanoes', null),  -- Vulcões
  ('458454b8-1e00-4241-9f27-9f072ba586fe', 'es', 'Volcanes', null),
  ('be84da4e-f4ab-4a4a-a406-9a05e49917d4', 'en', 'Imaginary lines', null),  -- Linhas imaginárias
  ('be84da4e-f4ab-4a4a-a406-9a05e49917d4', 'es', 'Líneas imaginarias', null),
  ('b7d3c950-9f2b-4206-9bb7-74263dacc6e7', 'en', 'Straits', 'The world''s main straits'),  -- Estreitos
  ('b7d3c950-9f2b-4206-9bb7-74263dacc6e7', 'es', 'Estrechos', 'Los principales estrechos del mundo'),
  ('8bf588de-aad5-4871-b0f5-fdf1bc4083c0', 'en', 'Landforms of the world', 'The world''s main mountain ranges and plateaus'),  -- Relevo do mundo
  ('8bf588de-aad5-4871-b0f5-fdf1bc4083c0', 'es', 'Relieve del mundo', 'Las principales cordilleras y mesetas del mundo'),
  ('1fa3c3e7-b2b1-4530-a356-4240e157644f', 'en', 'Soils of the world', 'The main soil types around the world'),  -- Solos do mundo
  ('1fa3c3e7-b2b1-4530-a356-4240e157644f', 'es', 'Suelos del mundo', 'Los principales tipos de suelo del mundo'),
  ('36f310e8-f7c0-4dd2-9151-cec01f4bee5c', 'en', 'Ocean currents', 'The world''s main warm and cold ocean currents'),  -- Correntes marítimas
  ('36f310e8-f7c0-4dd2-9151-cec01f4bee5c', 'es', 'Corrientes marinas', 'Las principales corrientes marinas cálidas y frías del mundo'),
  ('28c6f408-1614-4e86-b8b2-c0ddad137ff4', 'en', 'World agriculture', 'The leading producers of grains, soybeans, corn, cotton and tropical products'),  -- Agricultura mundial
  ('28c6f408-1614-4e86-b8b2-c0ddad137ff4', 'es', 'Agricultura mundial', 'Los principales países productores de granos, soja, maíz, algodón y productos tropicales'),
  ('f85b69d0-019a-487c-8e82-dc5d99bbfdec', 'en', 'Climates of the world', 'Climate zones, ocean currents and how deserts form'),  -- Climas do mundo
  ('f85b69d0-019a-487c-8e82-dc5d99bbfdec', 'es', 'Climas del mundo', 'Zonas climáticas, corrientes marinas y formación de los desiertos'),
  ('dddc6035-2ce5-49d6-ae2c-e902f6d14a67', 'en', 'Biomes of the world', 'The world''s main vegetation types on the map'),  -- Biomas do mundo
  ('dddc6035-2ce5-49d6-ae2c-e902f6d14a67', 'es', 'Biomas del mundo', 'Las principales formaciones vegetales del mundo en el mapa'),
  ('c78a7a6e-b797-4f63-bc88-df1daefe4237', 'en', 'Geopolitics and globalization', null),  -- Geopolítica e globalização
  ('c78a7a6e-b797-4f63-bc88-df1daefe4237', 'es', 'Geopolítica y globalización', null),
  ('ca6e22cd-17bf-4b83-b598-b76876f23959', 'en', 'History of Brazil', 'Colony, Empire, Republic and contemporary Brazil'),  -- História do Brasil
  ('ca6e22cd-17bf-4b83-b598-b76876f23959', 'es', 'Historia de Brasil', 'Colonia, Imperio, República y Brasil contemporáneo'),
  ('4387fdad-2724-4b69-be79-970eaf8f168a', 'en', 'Indigenous peoples', null),  -- Povos indígenas
  ('4387fdad-2724-4b69-be79-970eaf8f168a', 'es', 'Pueblos indígenas', null),
  ('ad10464d-0d11-4255-9fef-d341a0f856d6', 'en', 'Colonial Brazil', null),  -- Brasil Colonial
  ('ad10464d-0d11-4255-9fef-d341a0f856d6', 'es', 'Brasil Colonial', null),
  ('8e6bf89f-70bf-4ecd-b680-e2ee171d41fc', 'en', 'Independence of Brazil', null),  -- Independência do Brasil
  ('8e6bf89f-70bf-4ecd-b680-e2ee171d41fc', 'es', 'Independencia de Brasil', null),
  ('f479bffd-9b8d-4b42-aa90-b17fb95862f4', 'en', 'Empire of Brazil', null),  -- Brasil Império
  ('f479bffd-9b8d-4b42-aa90-b17fb95862f4', 'es', 'Brasil Imperio', null),
  ('602710f8-5c91-44c0-adf0-88b0cf87f333', 'en', 'Old Republic', null),  -- República Velha
  ('602710f8-5c91-44c0-adf0-88b0cf87f333', 'es', 'República Vieja', null),
  ('91c096b3-e30c-4b70-8317-f78ac30cddcc', 'en', 'Vargas Era', null),  -- Era Vargas
  ('91c096b3-e30c-4b70-8317-f78ac30cddcc', 'es', 'Era Vargas', null),
  ('d8a3ff73-b95d-4c49-8438-a6f562936779', 'en', 'Revolution of 1930', null),  -- Revolução de 1930
  ('d8a3ff73-b95d-4c49-8438-a6f562936779', 'es', 'Revolución de 1930', null),
  ('b75f4f86-6f0d-4ebd-895f-5fb3118d35ca', 'en', 'Provisional Government (1930–1934)', null),  -- Governo Provisório (1930–1934)
  ('b75f4f86-6f0d-4ebd-895f-5fb3118d35ca', 'es', 'Gobierno Provisional (1930–1934)', null),
  ('b0581df7-1582-41b8-95f9-c2addfb47ddf', 'en', 'Constitutional Government (1934–1937)', null),  -- Governo Constitucional (1934–1937)
  ('b0581df7-1582-41b8-95f9-c2addfb47ddf', 'es', 'Gobierno Constitucional (1934–1937)', null),
  ('7b0d8c6d-b900-4411-82b6-924ff29d2697', 'en', 'Estado Novo (1937–1945)', null),  -- Estado Novo (1937–1945)
  ('7b0d8c6d-b900-4411-82b6-924ff29d2697', 'es', 'Estado Novo (1937–1945)', null),
  ('3a099505-6721-49f2-8633-8aa2b613a762', 'en', '1937 Constitution', null),  -- Constituição de 1937
  ('3a099505-6721-49f2-8633-8aa2b613a762', 'es', 'Constitución de 1937', null),
  ('2065151d-f988-43b0-b8d9-f784cbec1278', 'en', 'Labor policies (Trabalhismo)', null),  -- Trabalhismo
  ('2065151d-f988-43b0-b8d9-f784cbec1278', 'es', 'Laborismo', null),
  ('8cdb0962-4694-476e-9c83-9cb807353e6c', 'en', 'DIP — Department of Press and Propaganda', null),  -- DIP — Departamento de Imprensa e Propaganda
  ('8cdb0962-4694-476e-9c83-9cb807353e6c', 'es', 'DIP — Departamento de Prensa y Propaganda', null),
  ('87dcdeae-bf22-493e-a53a-6f09c878f224', 'en', 'Communist Uprising of 1935', null),  -- Intentona Comunista
  ('87dcdeae-bf22-493e-a53a-6f09c878f224', 'es', 'Intentona Comunista', null),
  ('b134a54a-0add-4719-8e97-0f28c82bc7a5', 'en', 'Integralism', null),  -- Integralismo
  ('b134a54a-0add-4719-8e97-0f28c82bc7a5', 'es', 'Integralismo', null),
  ('b32513cb-a94e-4040-a310-2c97c607bed4', 'en', 'Brazil in World War II', null),  -- Brasil na Segunda Guerra Mundial
  ('b32513cb-a94e-4040-a310-2c97c607bed4', 'es', 'Brasil en la Segunda Guerra Mundial', null),
  ('0384be9b-0291-4535-b984-c77bb61c1611', 'en', 'End of the Estado Novo', null),  -- Fim do Estado Novo
  ('0384be9b-0291-4535-b984-c77bb61c1611', 'es', 'Fin del Estado Novo', null),
  ('5508a9c1-91a7-463b-bf08-a36f296d2251', 'en', 'Republic of 1946', null),  -- República de 1946
  ('5508a9c1-91a7-463b-bf08-a36f296d2251', 'es', 'República de 1946', null),
  ('5bc5ce90-bf36-45a1-97fc-156a2423ae89', 'en', 'Military Dictatorship', null),  -- Ditadura Militar
  ('5bc5ce90-bf36-45a1-97fc-156a2423ae89', 'es', 'Dictadura Militar', null),
  ('7740f68e-21bc-47e1-8052-848e287f27dd', 'en', 'New Republic', null),  -- Nova República
  ('7740f68e-21bc-47e1-8052-848e287f27dd', 'es', 'Nueva República', null),
  ('143ae168-abcf-4512-a0c7-3c67e34e9fcb', 'en', 'Antiquity', 'Egypt, Greece, Rome and ancient civilizations'),  -- Antiguidade
  ('143ae168-abcf-4512-a0c7-3c67e34e9fcb', 'es', 'Antigüedad', 'Egipto, Grecia, Roma y civilizaciones antiguas'),
  ('c14f34bc-fdf8-4797-88a6-14fafbad4194', 'en', 'Middle Ages', 'Feudalism, the Church, the Crusades and medieval changes'),  -- Idade Média
  ('c14f34bc-fdf8-4797-88a6-14fafbad4194', 'es', 'Edad Media', 'Feudalismo, Iglesia, Cruzadas y transformaciones medievales'),
  ('e93f87be-ca79-4813-9a67-616320aa9a8a', 'en', 'Early Modern Period', 'Renaissance, absolutism, reformations and maritime expansion'),  -- Idade Moderna
  ('e93f87be-ca79-4813-9a67-616320aa9a8a', 'es', 'Edad Moderna', 'Renacimiento, absolutismo, reformas y expansión marítima'),
  ('9d1627ca-eade-4dcf-83dc-a1acfcd096c8', 'en', 'Contemporary Period', 'Revolutions, wars, imperialism and today''s world'),  -- Idade Contemporânea
  ('9d1627ca-eade-4dcf-83dc-a1acfcd096c8', 'es', 'Edad Contemporánea', 'Revoluciones, guerras, imperialismo y mundo actual'),
  ('3a6764c6-67a5-4941-b3c0-aa0b5e17a190', 'en', 'History of the Americas', 'Indigenous peoples, colonization and independence movements'),  -- História da América
  ('3a6764c6-67a5-4941-b3c0-aa0b5e17a190', 'es', 'Historia de América', 'Pueblos originarios, colonización e independencias'),
  ('43bff7ca-8f49-46a3-b757-e20105c00ad2', 'en', 'History of Africa', 'African civilizations, colonialism and independence movements'),  -- História da África
  ('43bff7ca-8f49-46a3-b757-e20105c00ad2', 'es', 'Historia de África', 'Civilizaciones africanas, colonialismo e independencias'),
  ('b5a0f0a7-33bf-4676-86aa-073a0d0f5426', 'en', 'Major historical themes', 'Slavery, democracy, revolutions and human rights'),  -- Grandes temas históricos
  ('b5a0f0a7-33bf-4676-86aa-073a0d0f5426', 'es', 'Grandes temas históricos', 'Esclavitud, democracia, revoluciones y derechos humanos'),
  ('1835c88c-3f57-4bda-9c68-a4177a82beb8', 'en', 'Fundamentals', 'Operations, fractions, powers and numbers'),  -- Fundamentos
  ('1835c88c-3f57-4bda-9c68-a4177a82beb8', 'es', 'Fundamentos', 'Operaciones, fracciones, potencias y números'),
  ('9751f8f3-54ba-466d-9ff2-1369e393ee4f', 'en', 'Numbers (natural, integer, rational, irrational, real)', null),  -- Números (naturais, inteiros, racionais, irracionais, reais)
  ('9751f8f3-54ba-466d-9ff2-1369e393ee4f', 'es', 'Números (naturales, enteros, racionales, irracionales, reales)', null),
  ('63193752-9df4-4e14-a28c-423863dcdaf3', 'en', 'Basic operations and order of operations', null),  -- Operações básicas e ordem das operações
  ('63193752-9df4-4e14-a28c-423863dcdaf3', 'es', 'Operaciones básicas y orden de las operaciones', null),
  ('8d65ae08-ddf2-4dfd-badd-6476500448a6', 'en', 'Fractions', null),  -- Frações
  ('8d65ae08-ddf2-4dfd-badd-6476500448a6', 'es', 'Fracciones', null),
  ('4c39e2ed-67c8-482d-af15-6ae32fc86389', 'en', 'Decimal numbers', null),  -- Números decimais
  ('4c39e2ed-67c8-482d-af15-6ae32fc86389', 'es', 'Números decimales', null),
  ('42d19683-3191-437b-8c14-4edc7c66b826', 'en', 'Powers and roots', null),  -- Potenciação e radiciação
  ('42d19683-3191-437b-8c14-4edc7c66b826', 'es', 'Potenciación y radicación', null),
  ('0cd50fd3-ff11-4fe3-ab3d-204051a557b6', 'en', 'Divisibility', null),  -- Divisibilidade
  ('0cd50fd3-ff11-4fe3-ab3d-204051a557b6', 'es', 'Divisibilidad', null),
  ('6225352f-06bf-428a-b8bb-3a523f9f1c0b', 'en', 'Divisibility rules', null),  -- Critérios de divisibilidade
  ('6225352f-06bf-428a-b8bb-3a523f9f1c0b', 'es', 'Criterios de divisibilidad', null),
  ('7a538d1e-a300-4f02-8d84-4d488e645591', 'en', 'Prime numbers', null),  -- Números primos
  ('7a538d1e-a300-4f02-8d84-4d488e645591', 'es', 'Números primos', null),
  ('57a8df6f-0a57-4e45-a32b-feab275585a1', 'en', 'Prime factorization', null),  -- Fatoração
  ('57a8df6f-0a57-4e45-a32b-feab275585a1', 'es', 'Factorización', null),
  ('7ee4230f-60aa-49b2-a78b-7e6465e0261e', 'en', 'LCM and GCD', null),  -- MMC e MDC
  ('7ee4230f-60aa-49b2-a78b-7e6465e0261e', 'es', 'MCM y MCD', null),
  ('0363eefa-224b-4f7f-949b-118e86b2a3e8', 'en', 'Ratio, proportion and percentage', 'Proportion, rule of three and percentages'),  -- Razão, proporção e porcentagem
  ('0363eefa-224b-4f7f-949b-118e86b2a3e8', 'es', 'Razón, proporción y porcentaje', 'Proporción, regla de tres y porcentajes'),
  ('3e925e74-94a7-48d8-8674-a7d4e7d080fb', 'en', 'Algebra', 'Equations, systems, inequalities and polynomials'),  -- Álgebra
  ('3e925e74-94a7-48d8-8674-a7d4e7d080fb', 'es', 'Álgebra', 'Ecuaciones, sistemas, inecuaciones y polinomios'),
  ('b6cba9af-45d2-456f-96d6-912a5d468261', 'en', 'Algebraic expressions', null),  -- Expressões algébricas
  ('b6cba9af-45d2-456f-96d6-912a5d468261', 'es', 'Expresiones algebraicas', null),
  ('a1f647ec-40c6-4b93-b102-cded53c50431', 'en', 'Special products', null),  -- Produtos notáveis
  ('a1f647ec-40c6-4b93-b102-cded53c50431', 'es', 'Productos notables', null),
  ('34da53ba-be37-4cb3-b1cb-ebdcae782991', 'en', 'Factoring', null),  -- Fatoração
  ('34da53ba-be37-4cb3-b1cb-ebdcae782991', 'es', 'Factorización', null),
  ('27847cf7-2de7-4ada-8db3-4b7792dbd794', 'en', 'Equations', null),  -- Equações
  ('27847cf7-2de7-4ada-8db3-4b7792dbd794', 'es', 'Ecuaciones', null),
  ('9a31b7e7-652e-490f-a9db-d7ffbb634774', 'en', 'Linear equations', null),  -- Equação do 1º grau
  ('9a31b7e7-652e-490f-a9db-d7ffbb634774', 'es', 'Ecuación de primer grado', null),
  ('db814794-c73b-483b-8aa9-78927f551afd', 'en', 'Quadratic equations', null),  -- Equação do 2º grau
  ('db814794-c73b-483b-8aa9-78927f551afd', 'es', 'Ecuación de segundo grado', null),
  ('815e802e-a4dd-4f2c-ab27-c1715a433bf2', 'en', 'Rational equations', null),  -- Equações fracionárias
  ('815e802e-a4dd-4f2c-ab27-c1715a433bf2', 'es', 'Ecuaciones fraccionarias', null),
  ('35d26944-58a3-43d6-868c-c04705be6487', 'en', 'Radical equations', null),  -- Equações irracionais
  ('35d26944-58a3-43d6-868c-c04705be6487', 'es', 'Ecuaciones irracionales', null),
  ('4cf8f783-8ebd-426e-859b-6c5692e4e9ce', 'en', 'Exponential equations', null),  -- Equações exponenciais
  ('4cf8f783-8ebd-426e-859b-6c5692e4e9ce', 'es', 'Ecuaciones exponenciales', null),
  ('d8d2ce85-4316-4b16-ae86-12483e8ba748', 'en', 'Systems of equations', null),  -- Sistemas de equações
  ('d8d2ce85-4316-4b16-ae86-12483e8ba748', 'es', 'Sistemas de ecuaciones', null),
  ('ad24dbee-1914-4cf1-962a-f6358926b8b8', 'en', 'Inequalities', null),  -- Inequações
  ('ad24dbee-1914-4cf1-962a-f6358926b8b8', 'es', 'Inecuaciones', null),
  ('c4dc4513-74fe-418c-8f0a-aa8910676246', 'en', 'Polynomials', null),  -- Polinômios
  ('c4dc4513-74fe-418c-8f0a-aa8910676246', 'es', 'Polinomios', null),
  ('a8a0b1df-a556-4d34-ac80-99f5e750921e', 'en', 'Functions', 'Linear, quadratic and exponential functions and graphs'),  -- Funções
  ('a8a0b1df-a556-4d34-ac80-99f5e750921e', 'es', 'Funciones', 'Función afín, cuadrática, exponencial y gráficas'),
  ('1ddc8f51-6638-4415-8bca-f39c11f95524', 'en', 'Geometry', 'Areas, perimeters, solids and trigonometry'),  -- Geometria
  ('1ddc8f51-6638-4415-8bca-f39c11f95524', 'es', 'Geometría', 'Áreas, perímetros, sólidos y trigonometría'),
  ('799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c', 'en', 'Plane geometry', null),  -- Geometria plana
  ('799c0dbd-3ee8-449b-a2e9-cc6b9ffe673c', 'es', 'Geometría plana', null),
  ('b219eae9-446c-4831-aae9-357f67cb8a75', 'en', 'Solid geometry', null),  -- Geometria espacial
  ('b219eae9-446c-4831-aae9-357f67cb8a75', 'es', 'Geometría espacial', null),
  ('834539eb-c22c-4c35-acff-24cbf082d4e2', 'en', 'Analytic geometry', null),  -- Geometria analítica
  ('834539eb-c22c-4c35-acff-24cbf082d4e2', 'es', 'Geometría analítica', null),
  ('1d9499bd-c3f9-4228-9deb-81951feb605c', 'en', 'Trigonometry', null),  -- Trigonometria
  ('1d9499bd-c3f9-4228-9deb-81951feb605c', 'es', 'Trigonometría', null),
  ('eaf55158-60df-41a1-a5e4-06a810df3d53', 'en', 'Sequences and progressions', 'Arithmetic and geometric progressions'),  -- Sequências e progressões
  ('eaf55158-60df-41a1-a5e4-06a810df3d53', 'es', 'Sucesiones y progresiones', 'Progresión aritmética y geométrica'),
  ('184775e6-5bcb-4648-80d5-e7d97ee02af7', 'en', 'Probability', 'Sample space, events and conditional probability'),  -- Probabilidade
  ('184775e6-5bcb-4648-80d5-e7d97ee02af7', 'es', 'Probabilidad', 'Espacio muestral, eventos y probabilidad condicional'),
  ('17a0936f-4a79-47a2-9d8d-7b40c17c46bb', 'en', 'Combinatorics', 'Permutations, arrangements and combinations'),  -- Análise combinatória
  ('17a0936f-4a79-47a2-9d8d-7b40c17c46bb', 'es', 'Análisis combinatorio', 'Permutación, variación y combinación'),
  ('847f1a39-37fd-46ae-9005-51f6fd129221', 'en', 'Statistics', 'Charts, mean, median, mode and standard deviation'),  -- Estatística
  ('847f1a39-37fd-46ae-9005-51f6fd129221', 'es', 'Estadística', 'Gráficos, media, mediana, moda y desviación estándar'),
  ('47f9a514-4c99-4d8b-acb4-f9a8f8740916', 'en', 'Financial mathematics', 'Interest, discounts and percentages'),  -- Matemática financeira
  ('47f9a514-4c99-4d8b-acb4-f9a8f8740916', 'es', 'Matemática financiera', 'Intereses, descuentos y porcentajes'),
  ('e60b341c-e9bd-4e61-8d78-7710a0b79d34', 'en', 'Sets', 'Membership, union, intersection and Venn diagrams'),  -- Conjuntos
  ('e60b341c-e9bd-4e61-8d78-7710a0b79d34', 'es', 'Conjuntos', 'Pertenencia, unión, intersección y diagramas de Venn'),
  ('0b735557-66a3-42f2-baa2-69fb5e66e7e6', 'en', 'Logical reasoning', 'Sequences, propositions and logic problems'),  -- Raciocínio lógico
  ('0b735557-66a3-42f2-baa2-69fb5e66e7e6', 'es', 'Razonamiento lógico', 'Sucesiones, proposiciones y problemas de lógica'),
  ('19f2971b-4602-48d5-81d3-85f7f898d65b', 'en', 'Advanced topics', 'Matrices, determinants and complex numbers'),  -- Conteúdos avançados
  ('19f2971b-4602-48d5-81d3-85f7f898d65b', 'es', 'Contenidos avanzados', 'Matrices, determinantes y números complejos'),
  ('ec79fc3c-767b-4f48-9233-f74033f0522d', 'en', 'Reading comprehension', 'Comprehension, inference and text analysis'),  -- Interpretação de texto
  ('ec79fc3c-767b-4f48-9233-f74033f0522d', 'es', 'Interpretación de texto', 'Comprensión, inferencia y análisis textual'),
  ('8fe5bf1c-3e9f-4d21-9a31-f993693afaac', 'en', 'Text comprehension', null),  -- Compreensão textual
  ('8fe5bf1c-3e9f-4d21-9a31-f993693afaac', 'es', 'Comprensión textual', null),
  ('44d0f715-a155-43e0-8b7b-96afdfaa2cdd', 'en', 'Theme and subject', null),  -- Tema e assunto
  ('44d0f715-a155-43e0-8b7b-96afdfaa2cdd', 'es', 'Tema y asunto', null),
  ('2e4619ba-f64c-4e10-87cd-50e6b21b4c69', 'en', 'Main idea', null),  -- Ideia principal
  ('2e4619ba-f64c-4e10-87cd-50e6b21b4c69', 'es', 'Idea principal', null),
  ('5ba08373-5941-4b7f-8cd7-596108ce31d3', 'en', 'Explicit information', null),  -- Informações explícitas
  ('5ba08373-5941-4b7f-8cd7-596108ce31d3', 'es', 'Información explícita', null),
  ('c90c0ff6-432c-4ec2-bad7-6cad9bde3a70', 'en', 'Implicit information', null),  -- Informações implícitas
  ('c90c0ff6-432c-4ec2-bad7-6cad9bde3a70', 'es', 'Información implícita', null),
  ('cb1d24d0-03e9-4017-ab28-d5fc087bcedb', 'en', 'Inference', null),  -- Inferência
  ('cb1d24d0-03e9-4017-ab28-d5fc087bcedb', 'es', 'Inferencia', null),
  ('6a66a026-2fd0-4874-8216-4cdc03e6744e', 'en', 'Author''s intent', null),  -- Intenção do autor
  ('6a66a026-2fd0-4874-8216-4cdc03e6744e', 'es', 'Intención del autor', null),
  ('7715e4c7-fa79-47be-9cdf-ea20ca7b2db6', 'en', 'Argumentation', null),  -- Argumentação
  ('7715e4c7-fa79-47be-9cdf-ea20ca7b2db6', 'es', 'Argumentación', null),
  ('6528814e-981a-48c0-959c-b4969beb0ebd', 'en', 'Fact × opinion', null),  -- Fato × opinião
  ('6528814e-981a-48c0-959c-b4969beb0ebd', 'es', 'Hecho × opinión', null),
  ('c158ce9d-b7ad-4cc6-ab9c-8ad373022d8a', 'en', 'Textual cohesion and coherence', null),  -- Coesão e coerência textual
  ('c158ce9d-b7ad-4cc6-ab9c-8ad373022d8a', 'es', 'Cohesión y coherencia textual', null),
  ('282f04a3-1ac5-45ca-93d0-79ebb055890c', 'en', 'Grammar', 'Parts of speech, word formation and structure'),  -- Gramática
  ('282f04a3-1ac5-45ca-93d0-79ebb055890c', 'es', 'Gramática', 'Clases de palabras, formación y estructura'),
  ('6328fd95-8026-4dc2-8cdc-40bcaf543628', 'en', 'Syntax', 'Clauses, sentences and syntactic relations'),  -- Sintaxe
  ('6328fd95-8026-4dc2-8cdc-40bcaf543628', 'es', 'Sintaxis', 'Oraciones, períodos y relaciones sintácticas'),
  ('7a5990be-75cb-47a5-a2c9-2ecafee8af28', 'en', 'Spelling and accents', 'Writing, accent marks and spelling rules'),  -- Ortografia e acentuação
  ('7a5990be-75cb-47a5-a2c9-2ecafee8af28', 'es', 'Ortografía y acentuación', 'Escritura, acentos y reglas ortográficas'),
  ('6a6414ae-01ff-4f65-b7a0-6c7d37a3bbe6', 'en', 'Agreement and government', 'Agreement, government and crase'),  -- Concordância e regência
  ('6a6414ae-01ff-4f65-b7a0-6c7d37a3bbe6', 'es', 'Concordancia y régimen', 'Concordancia, régimen y crasis'),
  ('bab8c7fa-d87c-40af-9233-15430973131c', 'en', 'Verb agreement', null),  -- Concordância verbal
  ('bab8c7fa-d87c-40af-9233-15430973131c', 'es', 'Concordancia verbal', null),
  ('722ebf8c-3c85-43e1-a1c9-8469fa704939', 'en', 'Noun agreement', null),  -- Concordância nominal
  ('722ebf8c-3c85-43e1-a1c9-8469fa704939', 'es', 'Concordancia nominal', null),
  ('68cee128-2eef-4976-9666-bd7f350ede5b', 'en', 'Verb government', null),  -- Regência verbal
  ('68cee128-2eef-4976-9666-bd7f350ede5b', 'es', 'Régimen verbal', null),
  ('bfef7570-b2ba-4900-a90d-0f20290faa61', 'en', 'Noun government', null),  -- Regência nominal
  ('bfef7570-b2ba-4900-a90d-0f20290faa61', 'es', 'Régimen nominal', null),
  ('2cff6123-3f68-4609-9752-04a0cca3e81f', 'en', 'Crase', null),  -- Crase
  ('2cff6123-3f68-4609-9752-04a0cca3e81f', 'es', 'Crasis', null),
  ('dcb45577-a87e-4388-8653-846ef83e2e15', 'en', 'Mandatory cases', null),  -- Casos obrigatórios
  ('dcb45577-a87e-4388-8653-846ef83e2e15', 'es', 'Casos obligatorios', null),
  ('9ce83537-830c-4917-81f7-34ecdd190e04', 'en', 'Forbidden cases', null),  -- Casos proibidos
  ('9ce83537-830c-4917-81f7-34ecdd190e04', 'es', 'Casos prohibidos', null),
  ('4eea3b08-cfd1-4658-98b0-98af83d3df62', 'en', 'Optional cases', null),  -- Casos facultativos
  ('4eea3b08-cfd1-4658-98b0-98af83d3df62', 'es', 'Casos facultativos', null),
  ('1badbb7e-4488-4334-bbf5-6403153e2872', 'en', 'Set phrases', null),  -- Locuções
  ('1badbb7e-4488-4334-bbf5-6403153e2872', 'es', 'Locuciones', null),
  ('f25a58d3-8d53-4fda-abee-4ee3cb708b26', 'en', 'Semantics', 'Meaning, figures of speech and ambiguity'),  -- Semântica
  ('f25a58d3-8d53-4fda-abee-4ee3cb708b26', 'es', 'Semántica', 'Sentidos, figuras retóricas y ambigüedades'),
  ('3489b617-c328-4af1-bd3d-7a84dd343f79', 'en', 'Essay writing', 'Structure, argumentation and cohesion'),  -- Redação
  ('3489b617-c328-4af1-bd3d-7a84dd343f79', 'es', 'Redacción', 'Estructura, argumentación y cohesión'),
  ('a0caa678-52be-4ae4-9251-8f26e0ca476c', 'en', 'Literature', 'Literary movements, authors and works'),  -- Literatura
  ('a0caa678-52be-4ae4-9251-8f26e0ca476c', 'es', 'Literatura', 'Escuelas literarias, autores y obras'),
  ('f300eda1-d4f6-43d8-829f-29bf66347eae', 'en', 'Chemistry Fundamentals', 'Matter, atoms, elements and the periodic table'),  -- Fundamentos da Química
  ('f300eda1-d4f6-43d8-829f-29bf66347eae', 'es', 'Fundamentos de la Química', 'Materia, átomos, elementos y tabla periódica'),
  ('44ae7326-6451-4558-928a-c1c21eeb68ee', 'en', 'Atomic structure', null),  -- Estrutura atômica
  ('44ae7326-6451-4558-928a-c1c21eeb68ee', 'es', 'Estructura atómica', null),
  ('f7d3367f-0ede-4557-b30c-9ff239249e46', 'en', 'Protons', null),  -- Prótons
  ('f7d3367f-0ede-4557-b30c-9ff239249e46', 'es', 'Protones', null),
  ('923a07a3-fe07-459f-bb12-d7487ee924ee', 'en', 'Neutrons', null),  -- Nêutrons
  ('923a07a3-fe07-459f-bb12-d7487ee924ee', 'es', 'Neutrones', null),
  ('8c2a2d8d-fbff-4b4a-8010-a79227baf853', 'en', 'Electrons', null),  -- Elétrons
  ('8c2a2d8d-fbff-4b4a-8010-a79227baf853', 'es', 'Electrones', null),
  ('7ff92853-53ea-456f-81d2-d266d9a2cb74', 'en', 'Ions (cation and anion)', null),  -- Íons (cátion e ânion)
  ('7ff92853-53ea-456f-81d2-d266d9a2cb74', 'es', 'Iones (catión y anión)', null),
  ('4523e44f-8897-4776-a810-64248b111623', 'en', 'Isotopes', null),  -- Isótopos
  ('4523e44f-8897-4776-a810-64248b111623', 'es', 'Isótopos', null),
  ('9f2e679d-ca9c-49b8-b8a6-c2f1dcec5517', 'en', 'Atomic models', null),  -- Modelos atômicos
  ('9f2e679d-ca9c-49b8-b8a6-c2f1dcec5517', 'es', 'Modelos atómicos', null),
  ('1d7027f0-9cb2-46bc-a969-71fb69e1c2c5', 'en', 'Dalton', null),  -- Dalton
  ('1d7027f0-9cb2-46bc-a969-71fb69e1c2c5', 'es', 'Dalton', null),
  ('a6800379-be79-4f16-a0d5-9f741c728963', 'en', 'Thomson', null),  -- Thomson
  ('a6800379-be79-4f16-a0d5-9f741c728963', 'es', 'Thomson', null),
  ('732824ff-da40-4a2a-9f16-44c5274ba4b8', 'en', 'Rutherford', null),  -- Rutherford
  ('732824ff-da40-4a2a-9f16-44c5274ba4b8', 'es', 'Rutherford', null),
  ('8dabaafe-27a9-467e-907c-7ed9aa0236b8', 'en', 'Bohr', null),  -- Bohr
  ('8dabaafe-27a9-467e-907c-7ed9aa0236b8', 'es', 'Bohr', null),
  ('1e5c5853-82d6-4cde-abe8-bec5089a6d5a', 'en', 'Periodic table', null),  -- Tabela periódica
  ('1e5c5853-82d6-4cde-abe8-bec5089a6d5a', 'es', 'Tabla periódica', null),
  ('e0017fec-c1a0-44a2-9501-073e14904f77', 'en', 'Periods', null),  -- Períodos
  ('e0017fec-c1a0-44a2-9501-073e14904f77', 'es', 'Períodos', null),
  ('2880a5d7-04f0-4587-8c21-6225dba9a778', 'en', 'Groups', null),  -- Famílias
  ('2880a5d7-04f0-4587-8c21-6225dba9a778', 'es', 'Grupos', null),
  ('db4c138e-2f1d-4b62-9c05-772bbfcd8a7e', 'en', 'Metals, nonmetals and metalloids', null),  -- Metais, ametais e semimetais
  ('db4c138e-2f1d-4b62-9c05-772bbfcd8a7e', 'es', 'Metales, no metales y semimetales', null),
  ('61b08c3e-7325-4199-9fb1-3b1a891d2b5b', 'en', 'Noble gases', null),  -- Gases nobres
  ('61b08c3e-7325-4199-9fb1-3b1a891d2b5b', 'es', 'Gases nobles', null),
  ('8388a421-a787-4bf0-9e15-fee32a78e884', 'en', 'Alkali metals', null),  -- Metais alcalinos
  ('8388a421-a787-4bf0-9e15-fee32a78e884', 'es', 'Metales alcalinos', null),
  ('7a0bf96c-65fd-4af6-b8c1-a69d0f51b0a3', 'en', 'Halogens', null),  -- Halogênios
  ('7a0bf96c-65fd-4af6-b8c1-a69d0f51b0a3', 'es', 'Halógenos', null),
  ('e0d8da54-8dd1-478e-98ed-1c168d697958', 'en', 'Periodic properties', null),  -- Propriedades periódicas
  ('e0d8da54-8dd1-478e-98ed-1c168d697958', 'es', 'Propiedades periódicas', null),
  ('806021ed-dee3-457f-94b5-a8e94e8b51aa', 'en', 'Bonding and Structure', 'Chemical bonds, molecular geometry and intermolecular forces'),  -- Ligações e Estrutura
  ('806021ed-dee3-457f-94b5-a8e94e8b51aa', 'es', 'Enlaces y Estructura', 'Enlaces químicos, geometría y fuerzas intermoleculares'),
  ('1694b662-d892-4687-8727-9f74c2715b11', 'en', 'Stoichiometry', 'Moles, masses, reactions and chemical calculations'),  -- Estequiometria
  ('1694b662-d892-4687-8727-9f74c2715b11', 'es', 'Estequiometría', 'Mol, masas, reacciones y cálculos químicos'),
  ('f41ba2d7-4462-4a77-8362-272bb8313c47', 'en', 'Solutions', 'Concentration, dilution, mixtures and solubility'),  -- Soluções
  ('f41ba2d7-4462-4a77-8362-272bb8313c47', 'es', 'Disoluciones', 'Concentración, dilución, mezclas y solubilidad'),
  ('2e117b4e-3e7c-492e-82dc-22b964209b9a', 'en', 'Physical Chemistry', 'Thermochemistry, kinetics, equilibrium, pH and electrochemistry'),  -- Físico-Química
  ('2e117b4e-3e7c-492e-82dc-22b964209b9a', 'es', 'Fisicoquímica', 'Termoquímica, cinética, equilibrio, pH y electroquímica'),
  ('047a3c19-6572-45e7-87fa-ba36b78190d0', 'en', 'Inorganic Chemistry', 'Acids, bases, salts, oxides and inorganic reactions'),  -- Química Inorgânica
  ('047a3c19-6572-45e7-87fa-ba36b78190d0', 'es', 'Química Inorgánica', 'Ácidos, bases, sales, óxidos y reacciones inorgánicas'),
  ('2fa65779-5326-4e6f-b1c0-5c608d960eb3', 'en', 'Organic Chemistry', 'Carbon, organic functions, reactions and isomerism'),  -- Química Orgânica
  ('2fa65779-5326-4e6f-b1c0-5c608d960eb3', 'es', 'Química Orgánica', 'Carbono, funciones orgánicas, reacciones e isomería'),
  ('0f844d56-03ad-4c25-b48b-ce3ce4a5715e', 'en', 'Carbon chains', null),  -- Cadeias carbônicas
  ('0f844d56-03ad-4c25-b48b-ce3ce4a5715e', 'es', 'Cadenas carbonadas', null),
  ('f6780f3c-d1a8-4091-8106-bbac738a0f99', 'en', 'Organic functions', null),  -- Funções orgânicas
  ('f6780f3c-d1a8-4091-8106-bbac738a0f99', 'es', 'Funciones orgánicas', null),
  ('0b38a8c8-d003-4a83-a64c-e9d13a55d2f2', 'en', 'Hydrocarbons', null),  -- Hidrocarbonetos
  ('0b38a8c8-d003-4a83-a64c-e9d13a55d2f2', 'es', 'Hidrocarburos', null),
  ('bfab5e46-9539-4913-9b74-9caa035c2ee2', 'en', 'Alcohol', null),  -- Álcool
  ('bfab5e46-9539-4913-9b74-9caa035c2ee2', 'es', 'Alcohol', null),
  ('a6ee5567-9eaa-4311-b38d-0d558fc20104', 'en', 'Phenol', null),  -- Fenol
  ('a6ee5567-9eaa-4311-b38d-0d558fc20104', 'es', 'Fenol', null),
  ('a1e1464d-452e-4217-b190-6066b91e6084', 'en', 'Ether', null),  -- Éter
  ('a1e1464d-452e-4217-b190-6066b91e6084', 'es', 'Éter', null),
  ('bf6b8661-333d-4328-a787-c65089ba7e26', 'en', 'Aldehyde', null),  -- Aldeído
  ('bf6b8661-333d-4328-a787-c65089ba7e26', 'es', 'Aldehído', null),
  ('0247a3f8-16d1-47df-b712-4862d0f1282f', 'en', 'Ketone', null),  -- Cetona
  ('0247a3f8-16d1-47df-b712-4862d0f1282f', 'es', 'Cetona', null),
  ('a9d41e8f-b75b-480b-bbe4-6539427e297c', 'en', 'Carboxylic acid', null),  -- Ácido carboxílico
  ('a9d41e8f-b75b-480b-bbe4-6539427e297c', 'es', 'Ácido carboxílico', null),
  ('28c43ed0-e18f-41ac-84f3-0035879e636e', 'en', 'Ester', null),  -- Éster
  ('28c43ed0-e18f-41ac-84f3-0035879e636e', 'es', 'Éster', null),
  ('46421855-4463-49fe-8248-16700eb7b3ac', 'en', 'Amine', null),  -- Amina
  ('46421855-4463-49fe-8248-16700eb7b3ac', 'es', 'Amina', null),
  ('32224fa9-22dd-40b6-a5da-43f6996544ce', 'en', 'Amide', null),  -- Amida
  ('32224fa9-22dd-40b6-a5da-43f6996544ce', 'es', 'Amida', null),
  ('5a184c6f-1a60-4351-afa3-dbd35050d165', 'en', 'Nomenclature', null),  -- Nomenclatura
  ('5a184c6f-1a60-4351-afa3-dbd35050d165', 'es', 'Nomenclatura', null),
  ('6e3937ec-84c9-4de7-86ea-ffb98fb8f93f', 'en', 'Isomerism', null),  -- Isomeria
  ('6e3937ec-84c9-4de7-86ea-ffb98fb8f93f', 'es', 'Isomería', null),
  ('4d4f08dd-12b7-447c-8a16-17a5ec57eb26', 'en', 'Organic reactions', null),  -- Reações orgânicas
  ('4d4f08dd-12b7-447c-8a16-17a5ec57eb26', 'es', 'Reacciones orgánicas', null),
  ('b645c629-c218-475a-ad49-7524c0d4efe3', 'en', 'Polymers', null),  -- Polímeros
  ('b645c629-c218-475a-ad49-7524c0d4efe3', 'es', 'Polímeros', null),
  ('73cac530-0e0d-4775-b9c0-ae6ce4912b8c', 'en', 'Environmental and Everyday Chemistry', 'Pollution, fuels, water, materials and applications'),  -- Química Ambiental e Cotidiano
  ('73cac530-0e0d-4775-b9c0-ae6ce4912b8c', 'es', 'Química Ambiental y Cotidiana', 'Contaminación, combustibles, agua, materiales y aplicaciones')
) as v(id, locale, title, description)
join catalog_nodes c on c.id = v.id::uuid
on conflict (catalog_node_id, locale) do update
  set title = excluded.title,
      description = excluded.description;
