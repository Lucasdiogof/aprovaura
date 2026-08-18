-- DIAGNÓSTICO AURA (somente leitura — não altera nada).
-- Cole tudo no SQL Editor do Supabase, rode, e me mande a tabela que aparecer.
select 1 as ord,
       'tabela dossier_questions existe?' as verificacao,
       case when to_regclass('public.dossier_questions') is null
            then 'NAO — falta rodar dossier_questions_schema.sql'
            else 'SIM' end as resultado
union all
select 2, 'total de dossies (dossiers)',
       (select count(*)::text from dossiers)
union all
select 3, 'dossies DUPLICADOS (mesma area+title)',
       (select coalesce(string_agg(area || ' / ' || title, '; '), 'nenhum')
          from (select area, title from dossiers
                 group by area, title having count(*) > 1) x)
union all
select 4, 'total de questoes (questions)',
       (select count(*)::text from questions)
union all
select 5, 'questoes DUPLICADAS (mesmo node + prompt)',
       (select count(*)::text
          from (select catalog_node_id, prompt from questions
                 group by catalog_node_id, prompt having count(*) > 1) d)
union all
select 6, 'questoes por materia',
       (select coalesce(string_agg(subject || '=' || c::text, ', ' order by subject), 'nenhuma')
          from (select n.subject, count(q.id) c
                  from catalog_nodes n
                  join questions q on q.catalog_node_id = n.id
                 group by n.subject) s)
order by ord;
