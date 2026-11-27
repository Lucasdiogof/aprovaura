# Protocolo de validação de questões

Princípio: **concordância ≈100% não prova qualidade.** A auditoria mostrou que a resolução cega concorda quase sempre e deixou passar 17/17 itens ambíguos. Um validador só é considerado **calibrado** se detectar controles defeituosos conhecidos (`tool/content/pipeline/controles.py`: sensibilidade ≥ 0,7 em todos os tipos de defeito e especificidade ≥ 0,85 em questões íntegras). Validador não calibrado não serve de prova de qualidade.

Cada responsabilidade abaixo é um passo separado, com agente independente do autor e dos demais passos. Saída padrão por item: `{id, veredito:"ok|defeito", tipo_defeito, confianca, nota}`.

| # | Responsabilidade | Agente / ferramenta | Entrada | Saída | Critério de aprovação |
|---|---|---|---|---|---|
| 1 | Validação do gabarito | Resolvedor cego (`run.py blind-export`) + `vies.py` (alternativas embaralhadas) | enunciado + alternativas, sem gabarito | resposta, confiança, `ambigua` | Resposta = gabarito, também após permutar alternativas; divergência vai a revisão humana |
| 2 | Unicidade da resposta correta | Agente **adversarial**: para cada alternativa errada, tenta construir a melhor defesa de que está correta | enunciado + alternativas + gabarito | por alternativa: defesa (texto) e `defensavel` sim/não | Nenhuma errada defensável; qualquer `defensavel=sim` reprova ou reescreve a questão |
| 3 | Ambiguidades | Agente leitor crítico (sem gabarito): lista dados ausentes, termos vagos, duas leituras possíveis | enunciado + alternativas | lista de ambiguidades, `ambigua` | Zero ambiguidade material; enunciado autocontido |
| 4 | Qualidade dos distratores | Agente revisor + `qc.py` (tamanho, "correta mais longa", duplicatas) | questão completa | `distratores: bons\|fracos`, motivo por distrator | Cada distrator plausível, baseado em erro real, de tamanho parecido; sem absurdos nem pegadinha de redação |
| 5 | Validação da explicação | Agente revisor | questão completa com explicação | coerência com gabarito (s/n), por alternativa errada: justificada (s/n) | Explicação aponta a mesma correta do gabarito e justifica **cada** errada |
| 6 | Classificação pedagógica | Agente classificador (sem ver a classificação do autor) | enunciado + alternativas | dificuldade, categorias (`enem/vestibular/concurso`), competência/tópico | Concorda com o autor ou diverge e a divergência é arbitrada; tópico existe em `curriculum.json` |
| 7 | Verificação de referências | Agente com acesso à fonte oficial (`curriculum/sources.json`, `verify_sources.py`) | `referencias[]`, `data_referencia` | `fonte_verificada` true/false/null, trecho conferido | Dispositivo existe, texto confere com a citação e está vigente na data; obrigatório nas áreas jurídico-normativas; sem verificação, rejeita |
| 8 | Deduplicação | `dedupe.py` (MinHash, já existente) + comparação semântica por agente/embedding nos pares próximos | enunciado + alternativas vs. acervo e lotes | pares duplicados/quase-duplicados | Nenhum par acima do limiar lexical; pares semânticos suspeitos revisados |
| 9 | Validação determinística (matemática/científica) | Sandbox existente (`run.py`, campo `verificacao`) | código Python em `verificacao` | `valores[gabarito]==correta` e só um valor coincide | Passa sem timeout/erro; obrigatória em cálculo |
| 10 | Calibração dos validadores | `controles.py` | controles + íntegras misturados, ids opacos | sensibilidade por defeito, especificidade, F1 | CALIBRADO (limites acima) antes de aceitar passos 1–5 e 7 como prova |

## Regras
- Autor nunca valida a própria questão; cada passo usa agente sem acesso ao veredito dos outros (exceto passo 5, que precisa do gabarito).
- Rodar a calibração (passo 10) para cada validador/prompt/modelo novo e após qualquer mudança de prompt. Registrar o resultado junto do lote.
- Se não calibrado: ajustar o prompt e recalibrar; enquanto isso, o passo conta apenas como triagem, nunca como aprovação.
- Controles e `verdade.jsonl` ficam fora do que o validador vê; o validador recebe só `para_validador.jsonl`.

## Calibração (como rodar)
```
python tool/content/pipeline/controles.py gerar --n 60 --seed 1     # 60 defeituosos + 40 íntegras
# validador lê state/controles/para_validador.jsonl e grava respostas.jsonl (um objeto por id)
python tool/content/pipeline/controles.py avaliar respostas.jsonl   # imprime CALIBRADO ou NÃO CALIBRADO
```
Tipos de defeito: `gabarito_trocado`, `duas_corretas`, `nenhuma_correta`, `enunciado_ambiguo`, `explicacao_contraditoria`, `citacao_alterada`, `distratores_absurdos`. Ids ausentes na resposta contam como "ok".
