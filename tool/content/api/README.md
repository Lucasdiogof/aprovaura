# API Anthropic para conteúdo (preparação, NADA executado)

Só biblioteca padrão do Python. Estratégia, achados e go/no-go: `docs/content/CUSTO_API_ESTRATEGIA.md`.

- `estimar.py`: dry-run. `python estimar.py --tabela` compara modelos; `--tarefa autoral --n 500 --modelo sonnet-5.5 --batch --cache`; `--arquivo jobs.jsonl` estima por matéria. Sai com código 2 se estimativa + margem (30%) > orçamento (US$ 100 por padrão).
- `executor.py`: dry-run por padrão. Só chama a API com `--executar` **e** variável de ambiente `ANTHROPIC_API_KEY` (nome ajustável com `--env-chave`) **e** arquivo `AUTORIZADO` (vazio) criado à mão pelo dono nesta pasta. A chave nunca é impressa nem gravada. Teto efetivo = orçamento / (1 + margem); o executor para antes de qualquer chamada cujo pior caso estoure o teto. Erro de limite de gasto do Console (HTTP 429 `enforced_spend_limit_reached` ou 400 "specified API usage limits") interrompe sem retry. `--batch` usa Message Batches (50% de desconto, um batch por vez, retomável).
- Entrada JSONL: `{"materia","tarefa","lote","id","system","prompt","max_tokens","modelo"?}`.
- Saída em `uso/`: `uso.jsonl` (tokens e custo por chamada/lote/matéria), `resultados.jsonl`, `estado.json` (batches pendentes). Retomar = rodar de novo o mesmo comando; dedupe por SHA-256 de modelo+system+prompt+max_tokens.
- Testes (cliente HTTP falso, sem rede): `python test_api.py`.

Antes de criar `AUTORIZADO`, cumpra os pré-requisitos do documento de estratégia (Console: crédito comprado zerado, auto-reload desligado, spend limit mensal baixo, confirmados pelo dono). `uso/` e `AUTORIZADO` não devem ser commitados.
