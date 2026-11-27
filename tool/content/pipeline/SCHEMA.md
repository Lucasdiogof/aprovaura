# Formato dos lotes (JSONL) — AprovaAura expansão do acervo

Um lote vive em `tool/content/batches/<lote>/`. Autoria grava em `autoria/<area>.jsonl` (uma questão por linha, UTF-8).
O pipeline (`python tool/content/pipeline/run.py ...`) é quem muda `estado`; **autor nunca aprova o próprio conteúdo**.

## Questão (objeto JSON em uma linha)

| campo | regra |
|---|---|
| `id` | `<lote>-<area>-NNN` único (ex.: `L1-dirI-007`) |
| `materia` | slug de `curriculum/curriculum.json` (novas: `novas[].slug`; existentes: chaves de `existentes`) |
| `topico` | matérias novas: id de `novas[].topicos[].id` (ex.: `dir_penal.penas`). Existentes: `<slug>.<tema de 1º nível exatamente como em state/inventory_topics_l1.json>` |
| `categorias` | subconjunto de `["enem","vestibular","concurso"]`, conforme a matriz da matéria; individual por questão |
| `idioma` | idioma do enunciado: `pt-BR`, `en` ou `es` (só para Inglês/Espanhol; explicação sempre em pt-BR). Não traduzir texto jurídico nem questões de língua |
| `dificuldade` | `facil` \| `medio` \| `dificil` |
| `enunciado` | texto completo e autocontido (mín. 40 caracteres), texto simples, sem HTML, sem imagem/figura/gráfico ("na figura abaixo"). Se precisar de dados, coloque a tabela em texto |
| `alternativas` | exatamente 4 strings (A–D), distintas, plausíveis, de tamanho parecido |
| `gabarito` | índice 0–3 da correta. Varie: A/B/C/D ≈ 25% cada no lote |
| `explicacao` | ensina o raciocínio e diz **por que cada alternativa errada está errada** (mín. 200 caracteres) |
| `origem` | `autoral` (criada do zero) ou `autoral_baseada_em_referencias` (criada a partir do estudo de fonte oficial). **Nunca** copie/parafraseie prova, banco comercial ou questão de banca; nunca atribua a banca/instituição/ano |
| `referencias` | lista de `{"fonte": "<id de curriculum/sources.json>", "citacao": "art. 5º, LXVIII, CF/88"}`. **Obrigatória** para Direito, Legislação, Ética, Licitações, LDB, AFO/Contab. Pública, Redação Oficial, Saúde/SUS: sem citação exata e verificável a questão será rejeitada |
| `data_referencia` | `AAAA-MM-DD` da checagem do conteúdo mutável (legislação, atualidades, economia, índices). Obrigatória nesses casos |
| `verificacao` | para cálculo (Matemática, RL, Mat. Financeira, Estatística, Física, Química, Contabilidade/AFO numérica, SQL): `{"tipo":"python","codigo":"..."}`. O código (sympy/math/fractions/sqlite3 permitidos; sem rede/arquivos) deve definir `valores` (lista de 4 valores numéricos/str, na ordem das alternativas) e `correta` (valor esperado). O pipeline confere `valores[gabarito]==correta` e que só um valor coincide. Omita se não houver cálculo |
| `tags` | opcional, lista curta |

`estado` inicial: `"rascunho"` (o campo pode ser omitido). Não inclua `resolucao`, `revisao` nem hashes.

## Regras de qualidade (controles automáticos e revisão)
- Uma única resposta correta defensável; sem "todas as anteriores"/"nenhuma das anteriores"/"A e B".
- **A correta não pode ser sistematicamente a mais longa** (o acervo antigo tem esse vício em 62%): faça distratores tão longos e específicos quanto a correta; em cada área a correta deve ser a mais longa em no máximo ~30% das questões.
- Distratores baseados em erros reais de aluno; sem pegadinha de redação.
- Enunciado sem dado ambíguo; números coerentes; unidades explícitas.
- Conteúdo mutável (lei, súmula, índice, atualidade): só se tiver certeza do estado em `data_referencia`; no jurídico prefira dispositivos estáveis. **Não invente artigo, inciso, súmula, tema de repercussão geral ou número de lei.** Na dúvida, descarte a questão.
- Linguagem: português do Brasil com acentuação correta; sem marcas, nomes de pessoas reais em situações difamatórias, nem conteúdo sensível gratuito.
- Dificuldade sugerida do lote: ~30% fácil, ~45% médio, ~25% difícil (sem forçar).
- Não use o nome de nenhuma banca, instituição ou prova real no enunciado.

## Resolução independente (cega)
`run.py blind-export` gera `resolucao/<area>_cego.jsonl` com `id, materia, topico, idioma, enunciado, alternativas` (sem gabarito/explicação/verificacao).
O resolvedor grava `resolucao/<area>_respostas.jsonl`: `{"id","resposta":0-3,"confianca":"alta|media|baixa","ambigua":false,"comentario":"..."}`.

## Revisão pedagógica e de fontes
Revisor independente grava `revisao/<area>_revisao.jsonl`: `{"id","parecer":"aprovado|ajustar|rejeitar","qualidade_explicacao":1-5,"distratores":"bons|fracos","fonte_verificada":true|false|null,"fonte_nota":"o que foi conferido e onde","motivos":["..."]}`.
`fonte_verificada=true` só se o revisor conferiu o texto da citação na fonte oficial (URL do `sources.json`) e a vigência na data de referência.

## Estados
`rascunho` → `aguardando_revisao` → `em_revisao` → `aprovada_validacao_automatizada` → (`revisao_especializada_pendente` p/ jurídico/contábil-normativo) → `publicavel`; saídas: `rejeitada` (com `motivo`), `desatualizada`.
Somente `publicavel` pode ir para o SQL de importação em **staging** (nunca direto no catálogo ativo).
