-- Educação Física: remove as 4 questões substituídas pela revisão externa.
--
-- As questões entram com `on conflict do nothing` e o id é o uuid5 do
-- enunciado, então uma questão cujo enunciado mudou entra como linha
-- nova: a antiga precisa sair, ou as duas versões conviveriam.
--
-- Rodar ANTES de questions_educacao_fisica.sql. Idempotente: se as
-- antigas já saíram, não apaga nada.
--
-- Sem risco de progresso perdido: conferido em 2026-09-30 que
-- user_question_progress e user_question_favorites estavam vazios.

delete from questions where prompt in (
  'Políticas públicas de esporte e lazer costumam ser classificadas em três dimensões: esporte de rendimento, esporte educacional e:',
  'A classificação funcional no esporte paralímpico serve para:',
  'A ginástica rítmica se caracteriza pelo uso de:',
  'A maratona olímpica tem uma distância oficial de aproximadamente:'
);
