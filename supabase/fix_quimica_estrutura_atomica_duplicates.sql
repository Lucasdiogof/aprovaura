-- Remove duplicatas causadas por execução repetida de questions_seed_quimica_estrutura_atomica.sql.
-- Mantém apenas uma cópia de cada questão (por catalog_node_id + prompt), remove o resto.
delete from questions
where id in (
  select id from (
    select id,
           row_number() over (partition by catalog_node_id, prompt order by id) as rn
    from questions
    where catalog_node_id in (
      'f7d3367f-0ede-4557-b30c-9ff239249e46', -- Prótons
      '923a07a3-fe07-459f-bb12-d7487ee924ee', -- Nêutrons
      '8c2a2d8d-fbff-4b4a-8010-a79227baf853', -- Elétrons
      '7ff92853-53ea-456f-81d2-d266d9a2cb74', -- Íons
      '4523e44f-8897-4776-a810-64248b111623', -- Isótopos
      '1d7027f0-9cb2-46bc-a969-71fb69e1c2c5', -- Dalton
      'a6800379-be79-4f16-a0d5-9f741c728963', -- Thomson
      '732824ff-da40-4a2a-9f16-44c5274ba4b8', -- Rutherford
      '8dabaafe-27a9-467e-907c-7ed9aa0236b8'  -- Bohr
    )
  ) t
  where rn > 1
);
