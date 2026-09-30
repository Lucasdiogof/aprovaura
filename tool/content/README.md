# Ferramentas de conteúdo

Scripts usados para manter o conteúdo do Aprovaura (questões, traduções, nomes de mapa).
Não fazem parte do app: rodam na máquina de quem mantém o conteúdo, com Python 3.
O SQL que eles geram é rodado pela CLI do Supabase, nunca com `db push`:

```bash
npx.cmd supabase db query -f <arquivo.sql> --linked --project-ref cesuqfgrtcitatxvokez
```

A saída da CLI é JSON com `rows`. Para ler a saída como arquivo, grave-a e leia-a em UTF-8.
Um pipe direto para o Python no Windows estraga os acentos.

## Nomes das regiões dos mapas: `gen_map_region_names.py`

`map_region_names.txt` é a fonte do dicionário pt-BR → (en, es) dos quizzes de mapa. Cada linha é
`pt|en|es`, e a seção `## overrides` é `camada:pt|en|es` (ex.: `rivers:Amazonas|Amazon|Amazonas`).

```bash
python tool/content/gen_map_region_names.py tool/content/map_region_names.txt
dart format lib/features/map_quiz/l10n/map_region_names.dart
```

O script lê todos os `.geojson` e imprime `missing [...] extra [...]`. Os dois precisam sair vazios.
O teste `test/features/map_quiz/map_region_names_test.dart` confere a mesma coisa.

Para renomear um lugar, troque o `"nome":"X"` nos `.geojson` por substituição de texto, sem
reescrever o JSON (isso reformataria milhares de coordenadas). Ajuste a linha correspondente no
`.txt` e regenere. Nunca mude `sigla`: o progresso e as bandeiras dependem dela.

Os arquivos `*_bg` às vezes guardam o nome com escape JSON (ex.: `Madagáscar`).

## Questões novas já traduzidas: `gen_new_questions.py`

Entrada em texto, um bloco por questão:

```
=== <caminho do tópico exatamente como no catálogo> c=<índice correto 0..3>
P: enunciado pt
- alternativa (4 linhas)
E: explicação pt
--- en
P: / - x4 (ou "- @" para copiar a alternativa pt) / E:
--- es
P: / - x4 / E:
```

`leaves.json` é gerado pela query abaixo (tópicos-folha com a contagem por nível), gravada em
`<dir>/leaves.json` no formato `{"leaves": [...]}`:

```sql
with recursive p as (
  select id, title::text path, subject from catalog_nodes where parent_id is null
  union all select c.id, p.path||' > '||c.title, c.subject from catalog_nodes c join p on c.parent_id=p.id)
select json_build_object('leaves', (select json_agg(x) from (
  select p.id, p.subject, p.path,
    count(q.*) filter (where q.difficulty='facil') f,
    count(q.*) filter (where q.difficulty='medio') m,
    count(q.*) filter (where q.difficulty='dificil') d
  from p join questions q on q.catalog_node_id = p.id group by 1,2,3) x)) j;
```

```bash
python tool/content/gen_new_questions.py <dir> <materia> <entrada.txt> supabase/<saida>.sql
```

O script valida as 4 alternativas em cada língua, o índice correto e a explicação.
O id é o uuid5 do enunciado, então rodar o SQL de novo não duplica nada.
Hoje as questões novas entram como `dificil`; mude no SQL gerado se precisar de outro nível.

## Matéria nova: `gen_subject_catalog.py`

Cria a árvore de uma matéria que ainda não existe (áreas e tópicos, já com en/es) e o
`leaves.json` que o `gen_new_questions.py` usa, então as questões podem ser escritas antes
de o catálogo estar no banco. As fontes ficam em `materias/` (ex.: `filosofia_catalogo.txt`,
`filosofia_q1.txt` … `q4`).

```
== <área pt> | <descrição pt> | <emoji>
en: <área en> | <descrição en>
es: <área es> | <descrição es>
-- <tópico pt>
en: <tópico en>
es: <tópico es>
```

```bash
python tool/content/gen_subject_catalog.py filosofia tool/content/materias/filosofia_catalogo.txt supabase/catalog_seed_filosofia.sql <dir>
# um arquivo por vez, com linha em branco entre eles (sem isso, o fim de um cola no começo do outro)
for f in tool/content/materias/filosofia_q*.txt; do cat "$f"; echo; done > <dir>/all.txt
python tool/content/gen_new_questions.py <dir> filosofia <dir>/all.txt supabase/questions_filosofia.sql
```

Nas questões, o cabeçalho aceita o nível: `=== <área> > <tópico> c=<0..3> d=facil|medio|dificil`
(sem `d=`, fica `dificil`). Padrão das matérias novas: 6 questões por tópico, 2 de cada nível,
gabarito equilibrado entre as letras. Confira a contagem por tópico que o gerador imprime: todo tópico com 6. Depois de rodar os dois SQL, rode o checkup
(`supabase/check_<materia>.sql`) e só então acrescente a matéria ao enum `Subject` no app:
sem conteúdo, ela viraria um card vazio no Praticar.

## Acentos faltando: `find_missing_accents.py`

Procura palavra sem acento cuja forma acentuada aparece em outras questões do banco
(ex.: `paises` ao lado de `países`). A entrada é `<dir>/all_pt.json`, uma lista de
`{id, subject, prompt, options, explanation}`:

```sql
select json_agg(json_build_object('id',q.id,'subject',c.subject,'prompt',q.prompt,
  'options',q.options,'explanation',q.explanation)) j
from questions q join catalog_nodes c on c.id = q.catalog_node_id;
```

```bash
python tool/content/find_missing_accents.py <dir>
```

A saída lista os pares encontrados e as questões onde aparecem.

**Nem todo par é erro.** Estes são válidos sem acento:
- `e`, `da`, `as`, `tem`, `esta`;
- verbos como `influencia`, `continua`, `pratica`;
- `ideia` e `voo`, que seguem o Acordo Ortográfico;
- "Zona Franca".

As questões de Português podem ter palavras sem acento de propósito, por exemplo a questão sobre
acentuação. Revise cada caso antes de gerar o `update`.

A correção de 2026-09-27 está em `supabase/content_acentos_ptbr.sql`. O gerador dela conferiu que,
tirando os acentos, o texto novo é idêntico ao original.
