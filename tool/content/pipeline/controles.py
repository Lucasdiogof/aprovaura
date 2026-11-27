"""Controles deliberadamente defeituosos para calibrar validadores (ver docs/content/PROTOCOLO_VALIDACAO.md).

  python controles.py gerar --n 60 --seed 1
  python controles.py avaliar <respostas.jsonl>

Resposta do validador (JSONL, 1 linha por id): {"id","veredito":"ok|defeito","tipo_defeito","confianca","nota"}.
"""
import argparse, glob, hashlib, json, os, random, re, sys

CONTENT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
OUT = os.path.join(CONTENT, "state", "controles")
TIPOS = ["gabarito_trocado", "duas_corretas", "nenhuma_correta", "enunciado_ambiguo",
         "explicacao_contraditoria", "citacao_alterada", "distratores_absurdos"]
ABSURDOS = ["A resposta é a cor azul, porque sim.", "Depende apenas do humor de quem responde.",
            "Nada disso tem relação com o assunto da pergunta.", "O contrário de qualquer coisa já dita.",
            "Uma opção qualquer, escolhida ao acaso.", "Isso só acontece em dias de chuva.",
            "Ninguém jamais soube a resposta."]
ART = re.compile(r"(art(?:igo|s?\.)\s*)(\d+)", re.I)
L = "ABCD"


def rj(p):
    with open(p, encoding="utf-8") as f:
        return [json.loads(l) for l in f if l.strip()]


def carregar():
    """Banco canônico: {id, materia, enunciado, alternativas, gabarito, explicacao, referencias, fonte}."""
    pool = []
    for p in glob.glob(os.path.join(CONTENT, "batches", "lote-0001", "estado", "questoes.jsonl")):
        for q in rj(p):
            if q.get("estado") == "publicavel":
                pool.append({k: q.get(k) for k in ("id", "materia", "enunciado", "alternativas", "gabarito", "explicacao")}
                            | {"referencias": q.get("referencias") or [], "fonte": "lote-0001"})
    for q in rj(os.path.join(CONTENT, "state", "legacy_full.jsonl")):
        pool.append({"id": q["id"], "materia": q.get("materia"), "enunciado": q["prompt"], "alternativas": q["options"],
                     "gabarito": q["correct_index"], "explicacao": q.get("explanation") or "", "referencias": [], "fonte": "legado"})
    pool = [q for q in pool if len(q["alternativas"]) == 4 and isinstance(q["gabarito"], int)]
    return sorted(pool, key=lambda q: q["id"])


def trocar_art(s, f):
    return ART.sub(lambda m: m.group(1) + str(f(int(m.group(2)))), s)


# Cada mutador devolve a cópia alterada ou None se a questão for inelegível.
def m_gabarito_trocado(q, rng, pool):
    q["gabarito"] = rng.choice([i for i in range(4) if i != q["gabarito"]]); return q


def m_duas_corretas(q, rng, pool):
    c = q["alternativas"][q["gabarito"]].rstrip(".")
    if len(c) < 6: return None
    d = rng.choice([i for i in range(4) if i != q["gabarito"]])
    # shortcut: paráfrase por moldura fixa; um LLM faria paráfrases melhores
    q["alternativas"][d] = rng.choice(["Em essência, ", "É correto afirmar que ", "Equivale a dizer: "]) + c[0].lower() + c[1:] + "."
    return q


def m_nenhuma_correta(q, rng, pool):
    outros = [p for p in pool if p["materia"] == q["materia"] and p["id"] != q["id"]]
    if not outros: return None
    o = rng.choice(outros); novo = o["alternativas"][o["gabarito"]]
    if novo in q["alternativas"]: return None
    q["alternativas"][q["gabarito"]] = novo; return q


def m_enunciado_ambiguo(q, rng, pool):
    e = q["enunciado"]
    n = re.sub(r"\d[\d.,]*", "determinado valor", e, count=2)  # remove dado numérico essencial
    if n == e:
        w = e.split()
        if len(w) < 8: return None
        k = len(w) // 3; n = " ".join(w[:k] + w[2 * k:])  # senão, corta o miolo do enunciado
    q["enunciado"] = n; return q


def m_explicacao_contraditoria(q, rng, pool):
    d = rng.choice([i for i in range(4) if i != q["gabarito"]])
    q["explicacao"] = f"A alternativa correta é a letra {L[d]}: {q['alternativas'][d]} " + q["explicacao"]; return q


def m_citacao_alterada(q, rng, pool):
    if not ART.search(q["enunciado"] + q["explicacao"] + json.dumps(q["referencias"], ensure_ascii=False)): return None
    k = 7 + rng.randrange(20); f = lambda n: n + k  # mesma troca em todos os campos
    q["enunciado"], q["explicacao"] = trocar_art(q["enunciado"], f), trocar_art(q["explicacao"], f)
    q["referencias"] = [dict(r, citacao=trocar_art(r.get("citacao", ""), f)) for r in q["referencias"]]
    return q


def m_distratores_absurdos(q, rng, pool):
    ab = rng.sample(ABSURDOS, 3)
    q["alternativas"] = [q["alternativas"][i] if i == q["gabarito"] else ab.pop() for i in range(4)]; return q


MUT = dict(zip(TIPOS, [m_gabarito_trocado, m_duas_corretas, m_nenhuma_correta, m_enunciado_ambiguo,
                       m_explicacao_contraditoria, m_citacao_alterada, m_distratores_absurdos]))


def opaco(seed, orig, tipo):
    return "c-" + hashlib.sha1(f"{seed}|{orig}|{tipo}".encode()).hexdigest()[:10]


def gerar(n, seed, pool=None, out=OUT):
    rng = random.Random(seed)
    pool = list(pool if pool is not None else carregar())
    ordem = pool[:]; rng.shuffle(ordem)
    usados, itens = set(), []
    for i, t in enumerate(TIPOS):
        quota = n // len(TIPOS) + (i < n % len(TIPOS)); got = 0
        # citação: quem tem referências formais primeiro; demais tipos: ordem sorteada
        cand = sorted(ordem, key=lambda q: not q["referencias"]) if t == "citacao_alterada" else ordem
        for q in cand:
            if got >= quota: break
            if q["id"] in usados: continue
            c = MUT[t](json.loads(json.dumps(q)), rng, pool)
            if c and c != q: usados.add(q["id"]); got += 1; itens.append((c, t, q))
    nneg = n * 2 // 3
    for q in ordem:
        if nneg <= 0: break
        if q["id"] not in usados: usados.add(q["id"]); nneg -= 1; itens.append((json.loads(json.dumps(q)), None, q))
    rng.shuffle(itens)
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, "para_validador.jsonl"), "w", encoding="utf-8") as fv, \
         open(os.path.join(out, "verdade.jsonl"), "w", encoding="utf-8") as ft:
        for c, t, o in itens:
            i = opaco(seed, o["id"], t)
            fv.write(json.dumps({"id": i, "materia": c["materia"], "enunciado": c["enunciado"], "alternativas": c["alternativas"],
                                 "gabarito": c["gabarito"], "explicacao": c["explicacao"], "referencias": c["referencias"]},
                                ensure_ascii=False) + "\n")
            ft.write(json.dumps({"id": i, "defeito": t, "origem_id": o["id"], "fonte": o["fonte"]}, ensure_ascii=False) + "\n")
    return len(itens)


def avaliar(resp_path, verdade_path=None):
    verdade = rj(verdade_path or os.path.join(OUT, "verdade.jsonl"))
    resp = {r["id"]: r for r in rj(resp_path)}
    flag = lambda i: resp.get(i, {}).get("veredito") == "defeito"  # id ausente conta como "ok"
    sens = {}
    for t in TIPOS:
        ids = [v["id"] for v in verdade if v["defeito"] == t]
        if ids: sens[t] = sum(flag(i) for i in ids) / len(ids)
    ctrl = [v for v in verdade if v["defeito"]]; neg = [v["id"] for v in verdade if not v["defeito"]]
    tp = sum(flag(v["id"]) for v in ctrl); fn = len(ctrl) - tp; fp = sum(flag(i) for i in neg)
    esp = (len(neg) - fp) / len(neg) if neg else 0.0
    f1 = 2 * tp / (2 * tp + fp + fn) if tp else 0.0
    ok_tipo = sum(1 for v in ctrl if flag(v["id"]) and resp[v["id"]].get("tipo_defeito") == v["defeito"])
    return {"sensibilidade": sens, "especificidade": esp, "f1": f1, "tipo_correto_entre_detectados": f"{ok_tipo}/{tp}",
            "ausentes": sum(1 for v in verdade if v["id"] not in resp),
            "calibrado": bool(sens) and all(s >= 0.7 for s in sens.values()) and esp >= 0.85}


def main(argv=None):
    ap = argparse.ArgumentParser(); sp = ap.add_subparsers(dest="cmd", required=True)
    g = sp.add_parser("gerar"); g.add_argument("--n", type=int, default=60); g.add_argument("--seed", type=int, default=1)
    a = sp.add_parser("avaliar"); a.add_argument("resposta")
    x = ap.parse_args(argv)
    if x.cmd == "gerar":
        print("gerados:", gerar(x.n, x.seed), "->", OUT); return 0
    r = avaliar(x.resposta)
    for t, s in r["sensibilidade"].items(): print(f"sensibilidade {t:26s} {s:.2f}")
    print(f"especificidade {r['especificidade']:.2f} | F1 {r['f1']:.2f} | tipo correto: {r['tipo_correto_entre_detectados']} | ids ausentes: {r['ausentes']}")
    print("CALIBRADO" if r["calibrado"] else "NÃO CALIBRADO — não usar como prova de qualidade")
    return 0 if r["calibrado"] else 1


if __name__ == "__main__": sys.exit(main())
