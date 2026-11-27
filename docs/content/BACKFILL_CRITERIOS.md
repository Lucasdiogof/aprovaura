# Backfill de categorias das questões legadas — critérios

Objetivo: classificar cada uma das 2.609 questões ativas em **uma ou mais** categorias (`enem`, `vestibular`, `concurso`) **sem duplicar** a questão, de forma auditável e idempotente. Nunca por matéria inteira: cada questão é lida.

## Critérios (uma questão pode ter vários "sim")
- **enem**: cobra competência/habilidade da Matriz de Referência do ENEM — interpretação, contexto/situação-problema, interdisciplinaridade, texto-base, aplicação do conceito (não só memorização). Conteúdo do ensino médio.
- **vestibular**: conteúdo do ensino médio cobrado de forma mais conceitual/específica/aprofundada (fórmulas, mecanismos, cronologia, análise de obra, conhecimento disciplinar direto), típico de vestibulares tradicionais (USP, Unicamp, UFs etc.) — sem atribuir banca/ano.
- **concurso**: conteúdo que aparece em concursos públicos de nível médio/técnico/superior: Português (gramática normativa, interpretação, redação oficial), Matemática/Raciocínio, Atualidades, noções gerais; também Geografia/História/Biologia de formação geral quando tratadas como conhecimento geral.
- Tipicamente: conhecimento contextual/interdisciplinar → enem (+ vestibular se conceito sólido); conhecimento conceitual puro de ensino médio → vestibular (+ enem se aplicável); gramática normativa/Matemática básica/Português → concurso muitas vezes também. **Uma questão claramente de ensino médio que não seja claramente "só" uma delas deve receber ≥2.** Mínimo 1 categoria por questão.
- Confiança: `alta` (evidente), `media`, `baixa` (ambígua → revisão humana posterior; não bloqueia).
- Não classifique por matéria: duas questões da mesma matéria podem ter classificações diferentes.

## Flags de qualidade (aproveita a leitura para o inventário de correções)
`gabarito_duvidoso`, `ambigua`, `alternativas_equivalentes`, `explicacao_ausente_ou_fraca`, `dificuldade_inadequada` (informar `dificuldade_sugerida`), `desatualizada`, `referencia_inexistente`, `distratores_fracos`, `correta_pista_formal` (correta se destaca por tamanho/estilo/gramática), `duplicata_provavel` (informar id parecido, se perceber).
Flag só com evidência concreta, descrita em `nota` (curta). Sem flag = nenhum problema percebido (não é aprovação humana).

## Formato de saída (JSONL, 1 linha por questão, ids exatamente como no input)
`{"id":"…","enem":true,"vestibular":true,"concurso":false,"confianca":"alta","motivo":"≤140 chars","flags":[],"nota":"","dificuldade_sugerida":null}`

## Mecânica
- Entrada: `tool/content/state/backfill/in/<materia>_<NN>.jsonl` (campos: id, materia, topico, grupo, prompt, options, correct_index, explanation, difficulty).
- Saída do agente: `tool/content/state/backfill/out/<materia>_<NN>.jsonl`.
- Merge/validação: `python tool/content/backfill.py merge` (confere ids, ≥1 categoria, flags válidas) → `registro/backfill_categorias.jsonl` (versionado, auditável) → `backfill.py export-sql` gera `supabase/backfill/…sql` (idempotente `on conflict do nothing`, `source='backfill_ia'`). **Não é aplicado em produção** sem autorização do dono; testado só em Postgres descartável.
- Independência: o agente de backfill não produz/valida questões novas; um segundo agente (revisor de categorias) amostra e recheca as de confiança baixa/divergentes.
- Classificação por IA ≠ revisão humana.
