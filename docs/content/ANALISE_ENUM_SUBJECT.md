# Limite do `enum Subject` (16 matérias) e catálogo dinâmico — análise e desenho

Estado: **análise e desenho** (nada implementado no app; sem mudança de abas). Atualizado em 2026-11-27.

## 1. Fato atual
- `lib/features/subjects/domain/entities/subject.dart`: `enum Subject` com **16 valores** (15 bancos de questões + `redacao`). Cada valor carrega `key` (`educacaoFisica`↔`educacao_fisica`), `icon`, `accentColor`, `label(language)` e `description(language)` em pt/en/es **dentro do código**.
- No banco, `catalog_nodes.subject` é **texto livre** (hoje 14 chaves com questões). `interested_subjects` (perfil) é `text[]`. Ou seja, o banco já aceita matérias novas; o gargalo é o cliente Dart.
- Já existe tolerância parcial: `subject_style.dart` devolve ícone/cor/rótulo de fallback para chave desconhecida; `Subject.fromKey` retorna `null` (linhas gravadas por build mais novo).
- 75 matérias do plano (16 existentes + 59 novas) **não cabem** no enum sem recompilar o app a cada matéria nova, e o enum é usado em ~33 arquivos.

## 2. Mapa de dependências (32 arquivos em `lib/features`, 14 usos de `Subject.values`)
| Área | Arquivos / uso | Risco com 75 matérias |
|---|---|---|
| Navegação/Prática | `practice_page.dart` (grade por `Subject.values`), `subject_card/tile/multi_selector` | grade precisa de agrupamento/busca; hoje assume 16 cards |
| Catálogo | `catalog_list_page`, `catalog_node_tile`, `catalog_leaf_tile`, `catalog_node_icon` | já recebe `subject` como texto; usa `subjectStyle` (ok) |
| Perfil/Onboarding | `interested_subjects_*`, `onboarding_*`, `profile_repository_impl` (filtra por `Subject.values`) | **descarta silenciosamente** chaves desconhecidas ao ler `interested_subjects` — perderia matérias novas |
| Simulados | `mock_exam_setup_cubit` (`for s in Subject.values`), result page, `mock_exam_strings` | simulado por matéria nova exige regra de composição; ordenação por índice do enum |
| Caderno de erros | `error_review_list_page` (ordena por índice), `error_topic_card` | índice `values.length` para desconhecidas já é fallback razoável |
| Favoritos | `favorite_subject.dart`, `favorites_list_page` | idem; usar chave texto |
| Progresso/estatísticas/conquistas | via `user_question_progress` (ids de questão, **sem matéria**) | independente do enum — preservado |
| Portal do professor | `partner_pages`, `user_detail_page` | listas de matérias hoje do enum |
| l10n | rótulos/descrições pt/en/es no próprio enum | 59 matérias × 3 idiomas × (label+descrição) |
| Cache/offline/sync | chave texto nas tabelas locais; não depende do enum | ok, desde que a chave seja estável |

## 3. Desenho proposto (compatível, incremental)
1. **Chave estável** (`key`, texto) continua sendo o identificador universal (banco, RPCs, perfil, cache, favoritos, erros). IDs existentes **não mudam**.
2. **Catálogo de matérias dinâmico** (tabela nova, só leitura para o app):
   `content_subjects(key pk, label_pt, label_en, label_es, description_pt/en/es, icon_token, color_hex, group_key, order_index, has_questions bool, active bool, kind in ('banco','redacao'))` + N:N `content_subject_categories(subject_key, category)`. RLS: `select` para `authenticated`; escrita só `service_role`. As 16 atuais entram como seed idêntico ao enum (mesmos `key`, cores e textos).
3. **No Dart**: `SubjectRef` (value class: `key`, `label(lang)`, `description(lang)`, `icon`, `color`, `hasQuestions`, `order`) alimentado por um `SubjectRepository` com 3 fontes em cascata: (a) RPC remota → (b) cache local (offline) → (c) tabela embutida das 16 atuais (hoje o `enum`). O `enum Subject` permanece **como camada de compatibilidade** (getter `ref`) e é aposentado por arquivo, sem big-bang.
4. **icon_token → IconData** por mapa fechado no cliente (Material Icons nomeados; token desconhecido = `bookmark_rounded`). Cor: hex do catálogo, com fallback do tema. Nenhum código remoto executável.
5. **Perfil**: `profile_repository_impl` passa a preservar chaves desconhecidas (hoje filtra) — pré-requisito para evitar perda de dados quando o app antigo lê perfil gravado pelo novo.
6. **Prática/Simulado**: grade agrupada por categoria (aba ENEM | Vestibulares | Concursos, conforme `PLANO_FUTURO_APP.md`) + busca; matéria só aparece se tiver questões publicadas na categoria (`content_coverage`). Simulado: composição por matéria passa a vir do catálogo (peso/ordem), preservando o simulado atual.
7. **Conquistas/estatísticas**: não dependem de matéria; recalcular por categoria é opcional e posterior.
8. **Compatibilidade de versões**: build antigo vê `subject` desconhecido → já cai no fallback do `subject_style`; matérias novas só são "ativadas" (`active=true`) quando a versão mínima do app suportar (campo `min_app_build` no catálogo).

## 4. Ordem de implementação sugerida (futura, **precisa de autorização do dono**)
1. Migration `content_subjects` + seed das 16 + RPC `list_subjects()` (isolada, testada em Postgres descartável).
2. `SubjectRepository` + `SubjectRef` com cache + testes (sem trocar telas).
3. Migrar telas uma a uma do enum para `SubjectRef` (ordem: catálogo → prática → perfil/onboarding → erros/favoritos → simulado → portal).
4. Tabs ENEM/Vestibulares/Concursos (componente no padrão do Fan Hub, ver `PLANO_FUTURO_APP.md`).
5. Só então ativar matérias novas por categoria, conforme cobertura real.

## 5. O que NÃO foi feito (e por quê)
Nenhuma alteração em `lib/`, migrations de produção ou abas — fora do escopo autorizado (infra isolada e documentação). Esta análise é a base para a decisão do dono.
