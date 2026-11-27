"""Baixa (somente leitura) enunciados/alternativas do acervo ativo para deduplicação local -> state/existing_questions.jsonl (ignorado pelo git)."""
import json, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "lib"))
from prodread import select
rows = select("select id, prompt, options from questions")
p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "state", "existing_questions.jsonl")
with open(p, "w", encoding="utf-8", newline="\n") as f:
    for r in rows: f.write(json.dumps(r, ensure_ascii=False) + "\n")
print(len(rows), "questões ->", p)
