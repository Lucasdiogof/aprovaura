# Roadmap — Grande expansão do acervo educacional (progresso REAL)

Legenda: ✅ concluído e verificado · 🟡 parcial · ⬜ não iniciado. Planejado ≠ concluído. Atualizado em 2026-11-27.

| # | Etapa | Estado | Evidência / verificação |
|---|---|---|---|
| 1 | Leitura de arquitetura/estado do repositório | ✅ | catálogo = árvore `catalog_nodes` + `questions` (4 alternativas), RPCs i18n, dossiês, mapas |
| 2 | Inventário real (produção, só leitura) | ✅ | `INVENTARIO_ACERVO.md`: **2.609 questões / 572 nós confirmados**; viés de 62% (correta = mais longa) |
| 3 | Matriz curricular | ✅ (proposta) | `MATRIZ_CURRICULAR.md`: 16 existentes + 59 novas incluídas; 3 agrupadas/adiadas |
| 4 | Fontes e licenciamento | 🟡 | `FONTES_E_LICENCAS.md`: 48 fontes; 5 sem verificação (403/404/erro); licenças "a confirmar" tratadas como só-matriz |
| 5 | Infra de classificação/proveniência/lotes | ✅ (não aplicada) | migration + rollback testados em Postgres descartável (`tool/db/content_classification_check.sh`): testes, rollback, reaplicação, carga de staging |
| 6 | Pipeline retomável e auditável | ✅ | `tool/content/pipeline/` (24 testes); estados, checkpoints, dedupe MinHash, verificação sympy, regra jurídica |
| 7 | Primeiros lotes | 🟡 | `lote-0001`: 305 questões; **177 publicáveis (staging)**, **89 revisão especializada humana pendente**, 39 rejeitadas/ajustar. Teoria (8) e propostas de redação (12) produzidas, **sem revisão independente ainda** |
| 8 | Relatórios de cobertura | ✅ | `COBERTURA.md` (gerado por `run.py report`, totais únicos) |
| 9 | Documentação futura (tabs, professores, performance) | ✅ (doc) | `PLANO_FUTURO_APP.md` (nada implementado) |
| 10 | Arquitetura permanente de agentes | ✅ | 75 especialistas + 10 transversais em `.claude/agents/`, índice `agentes/INDICE_AGENTES.md`, testes `tool/content/agents` |
| 11 | Aplicar migration em produção / promover lotes | ⬜ | **Depende de autorização do dono** (nada é feito automaticamente) |
| 12 | Backfill de categorias do legado; correção do viés de distratores | ⬜ | decisão do dono; fila de revisão |
| 13 | Revisão humana especializada (jurídico/contábil) | ⬜ | pendente de especialistas humanos |
| 14 | Lotes 0002+ (ajustar rejeitadas, 4–10 por tópico) | ⬜ | próximos lotes; meta 20 mil é de planejamento |
| 15 | Traduções en/es das questões novas | ⬜ | pendente |
| 16 | Revisão independente de teoria e redação do lote-0001 | ⬜ | pendente |
| 17 | Implementação no app (tabs, filtro por categoria, matérias novas) | ⬜ | requer código; ver `PLANO_FUTURO_APP.md` |

## Honestidade dos números
- Os 177 "publicáveis" passaram: validação estrutural, cálculo determinístico quando aplicável, deduplicação, resolução independente cega e revisão por um segundo agente. **Não houve revisão humana.** Em várias áreas o revisor atribuiu notas por leitura rápida e `fonte_verificada=null` (não normativas).
- Jurídico/contábil-normativo/redação oficial **nunca** ficam publicáveis sem revisão humana especializada (89 em espera). A conferência de dispositivos foi via WebFetch (resumo por modelo) — não substitui jurista.
- Rejeitadas incluem pareceres "ajustar" (explicação posicional, dificuldade, distratores): voltam em lote novo.
- Meta 20.000+ aprovadas: estoque real hoje = 2.609 (legado) + 177 em staging; faltam ~17 mil.
