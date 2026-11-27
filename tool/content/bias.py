"""Análise do viés 'correta = alternativa mais longa' no legado.  python tool/content/bias.py  (lê state/legacy_full.jsonl)"""
import json, os, collections, statistics as st
D = os.path.dirname(os.path.abspath(__file__))
R = [json.loads(l) for l in open(os.path.join(D, "state", "legacy_full.jsonl"), encoding="utf-8")]
def longest(r): L = [len(o) for o in r["options"]]; return L.index(max(L)) == r["correct_index"] and sorted(L)[-1] > sorted(L)[-2]
def ratio(r): L = [len(o) for i, o in enumerate(r["options"]) if i != r["correct_index"]]; return len(r["options"][r["correct_index"]]) / (sum(L) / len(L))
def tab(key):
    g = collections.defaultdict(list)
    for r in R: g[key(r)].append(r)
    return {k: (len(v), round(100 * sum(map(longest, v)) / len(v)), round(st.median(map(ratio, v)), 2)) for k, v in sorted(g.items())}
out = {"total": (len(R), round(100 * sum(map(longest, R)) / len(R)), round(st.median(map(ratio, R)), 2)),
       "por_materia": tab(lambda r: r["materia"]), "por_dificuldade": tab(lambda r: r["difficulty"]),
       "por_posicao_gabarito": tab(lambda r: r["correct_index"]),
       "por_formato": tab(lambda r: "negativa(EXCETO/NÃO)" if any(w in r["prompt"].upper() for w in (" EXCETO", " NÃO ", "INCORRET")) else ("lacuna" if "___" in r["prompt"] or "_ _" in r["prompt"] else "direta")),
       "por_faixa_tamanho_enunciado": tab(lambda r: "curto<80" if len(r["prompt"]) < 80 else ("medio<160" if len(r["prompt"]) < 160 else "longo"))}
print("(n, % correta é a mais longa, razão mediana correta/média das erradas)")
for k, v in out.items(): print(k, v)
json.dump(out, open(os.path.join(D, "state", "bias.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
