"""Exporta (SOMENTE LEITURA) o acervo ativo completo -> state/legacy_full.jsonl (ignorado pelo git): base do backfill e da revisão de viés."""
import json, os, sys
D = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.join(D, "lib"))
from prodread import select
rows = select("""select q.id, n.subject as materia, n.title as topico, p.title as grupo, q.prompt, q.options, q.correct_index, q.explanation, q.difficulty
  from questions q join catalog_nodes n on n.id=q.catalog_node_id left join catalog_nodes p on p.id=n.parent_id order by n.subject, q.id""")
with open(os.path.join(D, "state", "legacy_full.jsonl"), "w", encoding="utf-8", newline="\n") as f:
    for r in rows: f.write(json.dumps(r, ensure_ascii=False) + "\n")
print(len(rows), "questões")
