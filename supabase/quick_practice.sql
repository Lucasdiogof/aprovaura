-- "Prática rápida": um baralho de questões que o usuário ainda não
-- respondeu, montado em rodadas -- uma questão de cada matéria por rodada,
-- sorteada dentro da matéria, e as matérias em ordem aleatória dentro da
-- rodada.
--
-- Nada de progresso novo aqui: "não respondida" é simplesmente não ter
-- linha em user_question_progress, a mesma tabela que alimenta a barra de
-- progresso do catálogo e o "revisar erros". Ou seja, responder pela
-- prática rápida já conta no tópico de origem, e errar já cai na revisão,
-- sem nenhuma escrita extra.
--
-- Atualidades fica de fora por construção: os dossiês têm banco próprio
-- (dossier_questions) e não penduram em catalog_nodes/questions.
--
-- SECURITY INVOKER (padrão): as policies públicas de questions/
-- catalog_nodes e a policy de leitura do próprio progresso já bastam.

create or replace function get_quick_practice_questions(
  p_limit integer default 10
)
returns table (
  id uuid,
  catalog_node_id uuid,
  prompt text,
  options text[],
  correct_index int,
  explanation text,
  difficulty text,
  subject text
)
language sql
stable
as $$
  with unanswered as (
    select q.id,
           q.catalog_node_id,
           q.prompt,
           q.options,
           q.correct_index,
           q.explanation,
           q.difficulty,
           cn.subject,
           -- Posição da questão dentro da sua matéria, já sorteada: todas
           -- as de round_index = 1 formam a primeira rodada (uma por
           -- matéria), as de 2 a segunda, e assim por diante.
           row_number() over (
             partition by cn.subject order by random()
           ) as round_index
    from questions q
    join catalog_nodes cn on cn.id = q.catalog_node_id
    where not exists (
      select 1
      from user_question_progress up
      where up.user_id = auth.uid()
        and up.question_id = q.id
    )
  )
  select id,
         catalog_node_id,
         prompt,
         options,
         correct_index,
         explanation,
         difficulty,
         subject
  from unanswered
  order by round_index, random()
  limit greatest(p_limit, 1);
$$;
