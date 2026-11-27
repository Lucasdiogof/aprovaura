# Arquitetura de classificação, proveniência e lotes

Migration: `supabase/migrations/20261209000100_content_classification.sql` · rollback: `supabase/rollbacks/20261209000100_content_classification.down.sql` · teste: `tool/db/content_classification_check.sh` (Postgres descartável em Docker).
**Não aplicada em produção nem no stack de QA.** Validada em banco vazio com as 30 migrations/base, testes SQL, rollback e reaplicação (resultado: `content_classification_tests OK`, 0 tabelas após rollback, `REAPLICOU_OK`).

## Modelo (sem duplicar entidades)
- `content_categories` (`enem`, `vestibular`, `concurso`): exatamente 3; **não existe "Todas"**.
- `question_categories(question_id, category)` e `catalog_node_categories(catalog_node_id, category)`: ligação N:N. Uma questão (ou matéria/tópico/trilha) pertence a 1, 2 ou 3 categorias sem cópia; o `questions.id` continua único → progresso, favoritos, caderno de erros, estatísticas, conquistas e vínculos de professores **não mudam**.
- `question_provenance`: `origin` (`legado_nao_registrado`, `autoral`, `autoral_baseada_em_referencias`, `oficial_autorizada`), instituição/banca/ano **só** se oficial (CHECK), `source_url`+`license`+`consulted_at` obrigatórios se oficial, `content_version`, `validation_state`, `reference_date`/`expires_at` (conteúdo mutável), `batch_id`. Sem leitura pública.
- `content_batches`: lotes versionados (`em_preparo → em_staging → promovido/revertido`).
- `content_question_staging`: onde o conteúdo novo entra. RLS ligado, sem policy e sem grant: **invisível ao app**. Pendente/rejeitada nunca está em `questions`.
- `content_promote_batch(lote, mapa_topico→nó)`: única porta para o catálogo ativo; só `service_role`; só linhas `publicavel`; id determinístico (md5 do lote+chave) → idempotente; exige nó de catálogo válido. **Só chamar com autorização do dono.**
- `content_unpromote_batch(lote)`: remove apenas questões do lote **sem** progresso/favorito/simulado/reporte; com histórico, recusa (reverter por desativação).
- `content_coverage` (view): questões **únicas** por categoria, `total_unico`, `sem_categoria` (não soma compartilhadas em duplicidade).
- Dificuldade: `questions.difficulty` (facil/medio/dificil) preservada; distribuição sugerida 30/45/25 só como orientação.

## Lacunas conhecidas (próximas migrações, não feitas)
- Backfill das 2.609 existentes em categorias exige decisão do dono (hoje `sem_categoria`).
- Trilhas por categoria: reaproveitar `catalog_node_categories`; não há tabela de trilha própria hoje.
- Traduções en/es das questões novas (`question_translations`) — pendentes; Português/Inglês/Espanhol (línguas) não são traduzidos.
- RPCs do app não filtram por categoria ainda (ver `PLANO_FUTURO_APP.md`).

## Pipeline (`tool/content/pipeline/`)
`ingest` (normalização + validação estrutural + classificação contra a matriz + cálculo determinístico sympy/python + referências normativas) → `dedupe` (hash exato + MinHash/LSH de 3-gramas contra o acervo de produção e lotes anteriores; **nunca apaga**, só rejeita a nova) → `blind-export` → resolução independente cega (agente diferente do autor, sem gabarito) → `ingest-resolution` → revisão pedagógica e de fontes independente → `ingest-review` → `export-sql` (só `publicavel`, só para staging) → `report`.
Estados: rascunho · aguardando_revisao · em_revisao · aprovada_validacao_automatizada · revisao_especializada_pendente · rejeitada · desatualizada · publicavel. Jurídico/normativo: sem `fonte_verificada=true` do revisor = rejeitada; com ela = `revisao_especializada_pendente` (nunca `publicavel` sem humano especialista). Checkpoints atômicos em `tool/content/batches/<lote>/estado/questoes.jsonl`; reexecutar só reprocessa o que mudou. Testes: `python -m unittest discover -s tool/content/pipeline` (23 testes).
Controles automáticos: resposta única/alternativas duplicadas, 4 alternativas, gabarito em intervalo, explicação mínima, HTML/script, "todas/nenhuma das anteriores", dependência de imagem, citação de banca/instituição, categoria fora da matéria, tópico inexistente, referência normativa, data de referência, viés (correta = mais longa) e distribuição do gabarito por área.
Limitação: o código de `verificacao` roda em subprocesso com timeout e denylist, **sem sandbox forte** (autoria interna, máquina local).
