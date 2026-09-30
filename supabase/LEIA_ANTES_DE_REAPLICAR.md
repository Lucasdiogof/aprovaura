# Quais .sql podem ser rodados de novo

Nem todo arquivo daqui é idempotente, e a diferença não está no nome.
Em 2026-09-30 rodei todos de uma vez para provar que os arquivos
realinhados não mexiam no banco. Os realinhados de fato não mexeram —
mas os seeds antigos foram junto e criaram **1.425 questões**, 1.319
delas duplicatas exatas, além de apagar e recriar 21 de geografia com
ids novos. Desfeito por `revert_reaplicacao_seeds.sql`.

## Pode rodar de novo

- `questions_<materia>.sql`, `questions_dificeis_*.sql`,
  `questions_revisao*.sql` — trazem o id explícito (uuid5 do enunciado
  pt, ou o `id=` fixado no `.txt`) e usam `on conflict do nothing`.
- `i18n_questions_*.sql` — só escrevem `question_translations`, com
  `on conflict do update`.
- Os `fix_*.sql`, que foram escritos para serem idempotentes.

## NÃO rode de novo

- **`questions_seed_*.sql`** — inserem com `insert into questions
  (catalog_node_id, ...)`, sem id e sem `on conflict`. Cada execução
  cria um novo conjunto de questões.
- **`questions_seed_goias_rios.sql`** — além disso, começa com um
  `delete from questions` nos seus nós: rodá-lo troca os ids das 21
  questões de rios, quebrando o que apontar para elas.
- **`fix_missing_portugues_concordancia_regencia.sql`**, mesmo motivo
  (insert sem id).
- `cleanup_duplicates_*.sql` e `fix_*_duplicates.sql` — são limpezas
  pontuais, escritas para um estado do banco que não existe mais.

## Como conferir que um arquivo não mudou nada

Tire um retrato antes e depois e compare — é o que pega esta classe de
erro:

    select jsonb_agg(jsonb_build_object('id',q.id,'p',q.prompt,
      'o',q.options,'c',q.correct_index)) from questions q;

O número de linhas de `questions` é o primeiro sinal: ele não pode
mudar quando se reaplica um arquivo de conteúdo.
