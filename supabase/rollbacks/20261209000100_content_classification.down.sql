-- Reverte 20261209000100_content_classification.sql. Remove só estruturas novas; `questions`/`catalog_nodes` e dados de usuário não são tocados.
-- ATENÇÃO: apaga classificações, proveniência, lotes e staging já gravados (perda dos metadados novos, não do acervo).
drop function if exists content_unpromote_batch(text);
drop function if exists content_promote_batch(text, jsonb);
drop view if exists content_coverage;
drop table if exists content_question_staging;
drop table if exists question_provenance;
drop table if exists content_batches;
drop table if exists catalog_node_categories;
drop table if exists question_categories;
drop table if exists content_categories;
