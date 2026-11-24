#!/usr/bin/env bash
# Executa a matriz de combinações priorizadas; resultados em $1/results.jsonl
OUT="$1"; mkdir -p "$OUT"
run() { PYTHONIOENCODING=utf-8 timeout 700 python tool/qa/run_matrix.py "$@" 2>/dev/null | tail -1 >> "$OUT/results.jsonl"; }
for combo in "320 pt-BR dark" "320 en light" "320 es dark" "390 en dark" "360 es light" "430 pt-BR light" "768 pt-BR light" "1024 en light" "1440 pt-BR dark" "1920 pt-BR light"; do
  set -- $combo
  for g in pub app conta; do run trial $1 $2 $3 "$OUT" $g; done
  run expirado $1 $2 $3 "$OUT" paywall
done
for combo in "320 pt-BR light" "390 en dark" "768 es light" "1440 pt-BR light" "1920 en dark"; do
  set -- $combo
  run admin $1 $2 $3 "$OUT" portal-admin
  run prof $1 $2 $3 "$OUT" portal-prof
done
echo DONE >> "$OUT/results.jsonl"
