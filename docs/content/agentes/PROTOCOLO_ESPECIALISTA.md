# Protocolo comum dos agentes de conteúdo (lido por todos os agentes)

Dados mutáveis ficam em arquivos — nunca copiados para as instruções dos agentes:
- Matriz, metas e fontes: `tool/content/curriculum/` (`curriculum.json`, `sources.json`) · resumo vivo por matéria: `python tool/content/agents/ctx.py <slug>`.
- Inventário real do acervo: `tool/content/state/inventory*.json`, `docs/content/INVENTARIO_ACERVO.md`.
- Lotes e estados: `tool/content/batches/<lote>/` · formato: `tool/content/pipeline/SCHEMA.md` · cobertura: `docs/content/COBERTURA.md`.
- Pendências, histórico de correções e datas de revisão: `tool/content/registro/` (`pendencias.md`, `correcoes.jsonl`, `revisoes.md`) — ler antes, atualizar depois.
- Arquitetura: `docs/content/ARQUITETURA_CLASSIFICACAO.md`.

## Ciclo obrigatório de qualquer tarefa
1. **Consultar o estado atual** (`ctx.py`, `run.py status <lote>`, registro de pendências) antes de produzir.
2. Produzir/corrigir **em arquivos** (`tool/content/batches/<lote>/autoria/<area>.jsonl` ou `registro/`), nunca em banco.
3. Rodar as validações determinísticas (`python tool/content/pipeline/run.py ingest <lote>`; cálculo por `verificacao`).
4. **Nunca aprovar o próprio conteúdo.** A aprovação é do pipeline após resolução cega + revisão independente por *outro* agente. Registre divergências em `registro/correcoes.jsonl`.
5. Atualizar `registro/pendencias.md` e a data em `registro/revisoes.md`.

## Regras duras
- Sem custos (nada de API paga/banco pago). Sem produção, dados pessoais, credenciais, pagamentos, configuração comercial ou outros projetos. Não ler o cofre. Não aplicar migration, não chamar `content_promote_batch`.
- Questões 100% autorais; não copiar/parafrasear provas, Qconcursos/Gran/Estratégia/TEC; não atribuir a banca/instituição/ano. Questão oficial só com autorização/licença/domínio público documentados em `sources.json`.
- Nada de lei, artigo, súmula, tema, data ou número inventado. Sem referência verificável = não entra.
- Conteúdo mutável leva `data_referencia` (o pipeline calcula `expira_em`).
- Validação por IA **não é** revisão humana especializada: jurídico/contábil-normativo fica `revisao_especializada_pendente`.
- Não traduzir questões de Português/Inglês/Espanhol nem textos jurídicos de modo que destrua o conteúdo avaliado.
- Qualidade acima de quantidade: correta não pode ser sistematicamente a mais longa; distratores plausíveis; explicação que ensina e justifica as erradas, **citando o conteúdo da alternativa, não a posição** (A/B/ordinais quebram se reordenar).
- Responder sempre em português.
