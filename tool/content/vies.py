"""Propostas de reescrita de alternativas (viés da mais longa).  python tool/content/vies.py <merge|blind-export|ingest-blind|report>
merge: valida state/vies/out/*.jsonl -> registro/vies_propostas.jsonl.   blind-export: gera state/vies/blind/in (sem gabarito).
ingest-blind: compara resolução cega (state/vies/blind/out) com o gabarito -> status aprovada/rejeitada em registro/vies_propostas.jsonl."""
import glob, json, os, re, sys, collections
D = os.path.dirname(os.path.abspath(__file__))
IN, OUT = os.path.join(D, "state", "vies", "in"), os.path.join(D, "state", "vies", "out")
BIN, BOUT = os.path.join(D, "state", "vies", "blind", "in"), os.path.join(D, "state", "vies", "blind", "out")
REG = os.path.join(D, "registro", "vies_propostas.jsonl")
POS = re.compile(r"\b(alternativa|letra|op[cç][aã]o)\s+[A-D]\b|\b[A-D]\)|\b(primeira|segunda|terceira|quarta)\s+(alternativa|op[cç][aã]o)\b", re.I)


def lines(p): return [json.loads(l) for l in open(p, encoding="utf-8") if l.strip()]
def razao(opts, c): o = [len(x) for i, x in enumerate(opts) if i != c]; return len(opts[c]) / (sum(o) / len(o))
def mais_longa(opts, c): L = [len(x) for x in opts]; return L.index(max(L)) == c and sorted(L)[-1] > sorted(L)[-2]
norm = lambda s: re.sub(r"\s+", " ", s.strip().lower()).rstrip(".;")


def validar(old, new):
    e = []
    a = new.get("alternativas")
    if not (isinstance(a, list) and len(a) == 4 and all(isinstance(x, str) and x.strip() for x in a)): return ["alternativas_invalidas"]
    c = old["correct_index"]
    if new.get("correct_index") != c: e.append("gabarito_indice_mudou")
    if len({norm(x) for x in a}) < 4: e.append("alternativas_repetidas")
    if any(POS.search(x) for x in a): e.append("referencia_posicional")
    if mais_longa(a, c) and razao(a, c) > 1.2: e.append(f"correta_ainda_mais_longa_razao_{razao(a, c):.2f}")
    if razao(a, c) > 1.35: e.append(f"razao_alta_{razao(a, c):.2f}")
    if not str(new.get("racional", "")).strip(): e.append("sem_racional")
    return e


def merge():
    ok, pend, erros, regs = 0, [], [], []
    for f in sorted(glob.glob(os.path.join(IN, "*.jsonl"))):
        fn = os.path.basename(f); rows = {r["id"]: r for r in lines(f)}; op = os.path.join(OUT, fn)
        if not os.path.exists(op): pend.append(fn); continue
        out = {r.get("id"): r for r in lines(op)}
        if set(out) != set(rows): erros.append((fn, f"faltam={len(set(rows)-set(out))} extras={len(set(out)-set(rows))}")); continue
        rej = 0
        for i, n in out.items():
            e = validar(rows[i], n)
            regs.append({"id": i, "materia": rows[i]["materia"], "alternativas_antes": rows[i]["options"], "alternativas": n.get("alternativas"),
                         "correct_index": rows[i]["correct_index"], "racional": n.get("racional", ""), "erros_deterministicos": e,
                         "status": "rejeitada_deterministica" if e else "aguardando_validacao_cega"})
            rej += bool(e)
        ok += 1
    prev = {r["id"]: r for r in lines(REG)} if os.path.exists(REG) else {}
    for r in regs:  # preserva decisão cega já registrada
        p = prev.get(r["id"])
        if p and p["alternativas"] == r["alternativas"] and p["status"] in ("aprovada_ia", "pendente_revisao_humana", "rejeitada_cega"): r["status"] = p["status"]; r["resolucao_cega"] = p.get("resolucao_cega")
    if regs:
        regs.sort(key=lambda r: r["id"]); open(REG, "w", encoding="utf-8", newline="\n").write("".join(json.dumps(r, ensure_ascii=False) + "\n" for r in regs))
    print(f"arquivos ok={ok} pendentes={len(pend)} erro={len(erros)} propostas={len(regs)}", dict(collections.Counter(r["status"] for r in regs)))
    for p in pend: print("  pendente:", p)
    for e in erros: print("  ERRO:", e)


def blind_export():
    os.makedirs(BIN, exist_ok=True); os.makedirs(BOUT, exist_ok=True)
    ex_p = os.path.join(D, "state", "vies", "blind", "exported.json")
    done = set(json.load(open(ex_p))) if os.path.exists(ex_p) else set()
    regs = [r for r in lines(REG) if r["status"] == "aguardando_validacao_cega" and r["id"] not in done]
    leg = {json.loads(l)["id"]: json.loads(l) for l in open(os.path.join(D, "state", "legacy_full.jsonl"), encoding="utf-8")}
    by = collections.defaultdict(list)
    for r in regs: by[r["materia"]].append({"id": r["id"], "materia": r["materia"], "prompt": leg[r["id"]]["prompt"], "alternativas": r["alternativas"]})
    leva = len(glob.glob(os.path.join(BIN, "*.jsonl"))) and max(int(re.search(r"_L(\d+)_", os.path.basename(f)).group(1)) for f in glob.glob(os.path.join(BIN, "*.jsonl"))) + 1 or 1
    n = 0
    for m, L in by.items():
        k = -(-len(L) // 70); s = -(-len(L) // k)
        for i in range(k):
            conteudo = "".join(json.dumps(x, ensure_ascii=False) + "\n" for x in L[i*s:(i+1)*s])
            open(os.path.join(BIN, f"{m}_L{leva}_{i+1:02d}.jsonl"), "w", encoding="utf-8", newline="\n").write(conteudo); n += 1
    json.dump(sorted(done | {r["id"] for r in regs}), open(ex_p, "w"))
    print(len(regs), f"questões -> {n} arquivos cegos (leva {leva})")


BLOQUEIO = {"ambigua", "alternativas_equivalentes", "referencia_inexistente", "desatualizada", "duplicata_provavel", "gabarito_duvidoso"}


def ingest_blind():
    """Concordância cega confirma o GABARITO; não detecta ambiguidade (auditado: 17/17 itens 'ambigua' passaram). Itens com flag de BLOQUEIO
    ficam 'pendente_revisao_humana' mesmo com concordância; 'aprovada_ia' = concordância cega + sem flag de bloqueio (não é revisão humana)."""
    fl = {r["id"]: set(r["flags"]) for r in lines(os.path.join(D, "registro", "backfill_categorias.jsonl"))}
    regs = {r["id"]: r for r in lines(REG)}; res = {}
    for f in glob.glob(os.path.join(BOUT, "*.jsonl")):
        for r in lines(f): res[r["id"]] = r
    c = collections.Counter()
    for i, r in regs.items():
        if r["status"] not in ("aguardando_validacao_cega", "aprovada") or i not in res: continue
        b = res[i]; r["resolucao_cega"] = {"resposta": b.get("resposta"), "unica": b.get("unica_correta", True), "nota": b.get("nota", "")}
        ok = b.get("resposta") == r["correct_index"] and b.get("unica_correta", True) is True
        r["status"] = ("pendente_revisao_humana" if fl.get(i, set()) & BLOQUEIO else "aprovada_ia") if ok else "rejeitada_cega"; c[r["status"]] += 1
    open(REG, "w", encoding="utf-8", newline="\n").write("".join(json.dumps(r, ensure_ascii=False) + "\n" for r in sorted(regs.values(), key=lambda r: r["id"])))
    print(dict(c), "| total:", dict(collections.Counter(r["status"] for r in regs.values())))


def report():
    regs = lines(REG); print(dict(collections.Counter(r["status"] for r in regs)))
    ap = [r for r in regs if r["status"] == "aprovada_ia"]
    if ap:
        import statistics as st
        print("aprovadas: razão mediana antes→depois:", round(st.median(razao(r["alternativas_antes"], r["correct_index"]) for r in ap), 2), "→", round(st.median(razao(r["alternativas"], r["correct_index"]) for r in ap), 2),
              "| % mais longa antes→depois:", round(100 * sum(mais_longa(r["alternativas_antes"], r["correct_index"]) for r in ap) / len(ap)), "→", round(100 * sum(mais_longa(r["alternativas"], r["correct_index"]) for r in ap) / len(ap)))


if __name__ == "__main__":
    {"merge": merge, "blind-export": blind_export, "ingest-blind": ingest_blind, "report": report}[sys.argv[1]]()
