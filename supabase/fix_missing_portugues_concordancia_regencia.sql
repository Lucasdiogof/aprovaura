-- Completa as 8 questoes de Concordancia e Regencia que faltaram na
-- primeira insercao (confirmado por auditoria: banco tinha 130/138 de
-- Portugues, todas as 8 faltantes vinham deste bloco). Idempotente na
-- pratica (rode uma vez so; nao ha chave unica que impeca duplicar se
-- rodar de novo, entao confira com audit_questions_duplicates.sql depois).

insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty) values

-- Concordancia verbal (bab8c7fa-d87c-40af-9233-15430973131c) — faltava idx 5
('bab8c7fa-d87c-40af-9233-15430973131c', 'Assinale a alternativa em que a concordância verbal está correta:',
  array['Precisa-se de funcionários experientes.', 'Precisam-se de funcionários experientes.', 'Preciso-se de funcionários experientes.', 'Precisam-se funcionários experientes.'], 0,
  'Com o verbo transitivo indireto "precisar" seguido de "de", o "se" é índice de indeterminação do sujeito, e o verbo permanece no singular.', 5, 'dificil'),

-- Concordancia nominal (722ebf8c-3c85-43e1-a1c9-8469fa704939) — faltavam idx 3, 4, 5
('722ebf8c-3c85-43e1-a1c9-8469fa704939', 'Assinale a alternativa em que a concordância nominal está correta:',
  array['Estão anexas ao processo as certidões solicitadas.', 'Estão anexo ao processo as certidões solicitadas.', 'Está anexas ao processo as certidões solicitadas.', 'Estão anexos ao processo as certidões solicitadas.'], 0,
  'O adjetivo "anexo" varia em gênero e número; como "certidões" é feminino plural, a forma correta é "anexas".', 3, 'medio'),
('722ebf8c-3c85-43e1-a1c9-8469fa704939', 'Assinale a alternativa correta quanto à concordância nominal:',
  array['É proibida a entrada de visitantes.', 'É proibido a entrada de visitantes.', 'É proibidos a entrada de visitantes.', 'É proibida entrada de visitantes.'], 0,
  'Diante de substantivo precedido de artigo definido ("a entrada"), a expressão "é proibido" deve concordar em gênero e número: "é proibida a entrada".', 4, 'dificil'),
('722ebf8c-3c85-43e1-a1c9-8469fa704939', 'Assinale a alternativa em que a concordância nominal está correta:',
  array['Segue anexo o comprovante de pagamento.', 'Segue anexa o comprovante de pagamento.', 'Seguem anexo os comprovante de pagamento.', 'Segue anexos o comprovante de pagamento.'], 0,
  '"Anexo" deve concordar com o substantivo a que se refere; como "comprovante" é masculino singular, a forma correta é "anexo".', 5, 'medio'),

-- Regencia verbal (68cee128-2eef-4976-9666-bd7f350ede5b) — faltava idx 4
('68cee128-2eef-4976-9666-bd7f350ede5b', 'Assinale a alternativa correta quanto à regência verbal:',
  array['Prefiro chá a café.', 'Prefiro chá do que café.', 'Prefiro mais chá do que café.', 'Prefiro chá que café.'], 0,
  'O verbo "preferir", na norma-padrão, rege a preposição "a" e não deve ser usado com "do que": "prefiro chá a café".', 4, 'medio'),

-- Regencia nominal (bfef7570-b2ba-4900-a90d-0f20290faa61) — faltavam idx 2, 4, 5
('bfef7570-b2ba-4900-a90d-0f20290faa61', 'Assinale a alternativa em que a regência nominal está correta:',
  array['Ele tem necessidade de apoio profissional.', 'Ele tem necessidade em apoio profissional.', 'Ele tem necessidade com apoio profissional.', 'Ele tem necessidade para apoio profissional.'], 0,
  'O substantivo "necessidade" rege a preposição "de": "necessidade de algo".', 2, 'facil'),
('bfef7570-b2ba-4900-a90d-0f20290faa61', 'Assinale a alternativa em que a regência nominal está correta:',
  array['Ele é grato aos amigos pela ajuda.', 'Ele é grato dos amigos pela ajuda.', 'Ele é grato com os amigos pela ajuda.', 'Ele é grato para os amigos pela ajuda.'], 0,
  'O adjetivo "grato" rege a preposição "a": "grato a alguém".', 4, 'facil'),
('bfef7570-b2ba-4900-a90d-0f20290faa61', 'Assinale a alternativa correta quanto à regência nominal:',
  array['O time estava confiante na vitória.', 'O time estava confiante da vitória.', 'O time estava confiante para a vitória.', 'O time estava confiante com a vitória.'], 0,
  'O adjetivo "confiante" rege a preposição "em": "confiante em algo".', 5, 'medio');
