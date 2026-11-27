# Viés "a correta é a mais longa" — diagnóstico e protocolo de correção

Gerado a partir de `tool/content/bias.py` sobre as 2.609 questões ativas (somente leitura). Acaso para 4 alternativas ≈ 25%.

## Diagnóstico (2026-11-27)
- Total: **58%** das corretas são estritamente as mais longas; razão mediana correta/média das erradas = 1,37.
- **Por matéria**: história 87% · sociologia 84% · literatura 81% (razão 2,12) · filosofia 77% · artes 77% · educação física 70% · biologia 66% · espanhol 58% · química 56% · inglês 54% · geografia 48% · física 44% · português 40% · **matemática 18%** (numérica, sem viés).
- **Por dificuldade**: fácil 52% · médio 61% · difícil 62%.
- **Posição do gabarito**: uniforme (A–D entre 57% e 60% de "mais longa"; distribuição de posições equilibrada) — o viés é de **forma**, não de posição.
- **Por formato**: direta 60% · lacuna 28% · negativa 42%. Enunciado curto/médio/longo: 61/56/64%.
- Concentra-se em humanas/biológicas, onde a correta traz a explicação completa e os distratores são frases curtas.

## Correção (sem encurtar às cegas nem "encher" distrator)
1. Candidatas: corretas mais longas com razão ≥ 1,3 (exceto matemática), ou com flag `correta_pista_formal`/`distratores_fracos` do backfill: **1.438 questões** em `tool/content/state/vies/in/`.
2. Agente especialista propõe, por questão: novas alternativas (mesmo gabarito de conteúdo; distratores = erros conceituais reais e plausíveis, comprimento e estrutura gramatical comparáveis, sem pistas de estilo/concordância; correta pode ser enxugada **sem perder o conteúdo avaliado**). Nunca inventar fato. IDs e histórico preservados: é **proposta** em `registro/vies_propostas.jsonl`, não UPDATE.
3. Validação determinística (`vies.py merge`): 4 alternativas distintas, índice do gabarito preservado, correta não é a mais longa por margem (razão ≤ 1,2 ou não é a mais longa), sem repetição entre alternativas, sem referência posicional (A/B…).
4. **Revalidação cega independente**: outro agente resolve a questão reescrita **sem o gabarito**; divergência ⇒ proposta rejeitada e questão volta à fila.
5. Aplicar em produção é decisão do dono (nada é alterado no banco); a proposta aprovada vira UPDATE auditável com `content_version+1` somente após autorização.
