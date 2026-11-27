"""Backfill de categorias do legado.  python tool/content/backfill.py <status|merge|export-sql|report>
merge: valida saídas dos agentes (state/backfill/out) contra as entradas e grava registro/backfill_categorias.jsonl (auditável, versionado).
export-sql: gera supabase/backfill/20261210000100_backfill_question_categories.sql (idempotente; NÃO aplicado em produção sem autorização)."""
import collections, glob, json, os, sys
D = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(D, "..", ".."))
IN, OUT = os.path.join(D, "state", "backfill", "in"), os.path.join(D, "state", "backfill", "out")
REG = os.path.join(D, "registro", "backfill_categorias.jsonl")
FLAGS = {"gabarito_duvidoso", "ambigua", "alternativas_equivalentes", "explicacao_ausente_ou_fraca", "dificuldade_inadequada",
         "desatualizada", "referencia_inexistente", "distratores_fracos", "correta_pista_formal", "duplicata_provavel"}
CATS = ("enem", "vestibular", "concurso")


def lines(p): return [json.loads(l) for l in open(p, encoding="utf-8") if l.strip()]


def validar(rec):
    e = []
    if not any(rec.get(c) is True for c in CATS): e.append("sem_categoria")
    if any(not isinstance(rec.get(c), bool) for c in CATS): e.append("categoria_nao_booleana")
    if rec.get("confianca") not in ("alta", "media", "baixa"): e.append("confianca_invalida")
    if not isinstance(rec.get("flags", []), list) or set(rec.get("flags", [])) - FLAGS: e.append("flag_invalida")
    if rec.get("flags") and not str(rec.get("nota", "")).strip(): e.append("flag_sem_nota")
    return e


def merge():
    entradas = {os.path.basename(f): lines(f) for f in sorted(glob.glob(os.path.join(IN, "*.jsonl")))}
    ok, pend, erros, regs = 0, [], [], []
    for fn, rows in entradas.items():
        op = os.path.join(OUT, fn)
        if not os.path.exists(op): pend.append(fn); continue
        out = {}
        for r in lines(op): out[r.get("id")] = r
        ids = {r["id"] for r in rows}
        falt = ids - set(out); extra = set(out) - ids
        if falt or extra: erros.append((fn, f"faltam={len(falt)} extras={len(extra)}")); continue
        bad = [(i, validar(r)) for i, r in out.items() if validar(r)]
        if bad: erros.append((fn, f"{len(bad)} inválidas ex={bad[0]}")); continue
        by_in = {r["id"]: r for r in rows}
        for i, r in out.items():
            regs.append({"id": i, "materia": by_in[i]["materia"], "enem": r["enem"], "vestibular": r["vestibular"], "concurso": r["concurso"],
                         "confianca": r["confianca"], "motivo": r.get("motivo", ""), "flags": r.get("flags", []), "nota": r.get("nota", ""),
                         "dificuldade_sugerida": r.get("dificuldade_sugerida"), "origem": "backfill_ia"})
        ok += 1
    if regs:
        regs.sort(key=lambda r: r["id"])
        with open(REG, "w", encoding="utf-8", newline="\n") as f:
            for r in regs: f.write(json.dumps(r, ensure_ascii=False) + "\n")
    print(f"arquivos ok={ok} pendentes={len(pend)} com_erro={len(erros)} questoes_registradas={len(regs)}")
    for p in pend: print("  pendente:", p)
    for e in erros: print("  ERRO:", e)
    return ok, pend, erros


def export_sql():
    regs = lines(REG)
    rows = [f"('{r['id']}'::uuid,'{c}')" for r in regs for c in CATS if r[c]]
    p = os.path.join(ROOT, "supabase", "backfill"); os.makedirs(p, exist_ok=True)
    fp = os.path.join(p, "20261210000100_backfill_question_categories.sql")
    with open(fp, "w", encoding="utf-8", newline="\n") as f:
        f.write("-- Backfill de categorias do legado (classificação por IA, ver docs/content/BACKFILL_CRITERIOS.md). NÃO aplicado em produção sem autorização do dono.\n")
        f.write("-- Idempotente: só insere para questões existentes; não apaga nem altera nada.\nbegin;\n")
        for i in range(0, len(rows), 500):
            f.write("insert into question_categories (question_id, category)\nselect v.q, v.c from (values\n" + ",\n".join(rows[i:i + 500]) +
                    "\n) as v(q, c) where exists (select 1 from questions x where x.id = v.q)\non conflict (question_id, category) do nothing;\n")
        f.write("commit;\n")
    print(len(rows), "vínculos ->", fp)


def report():
    regs = lines(REG); c = collections.Counter(); m = collections.defaultdict(collections.Counter); fl = collections.Counter(); conf = collections.Counter()
    for r in regs:
        key = "+".join(k for k in CATS if r[k]); c[key] += 1; m[r["materia"]][key] += 1; conf[r["confianca"]] += 1
        for f in r["flags"]: fl[f] += 1
    print("questões:", len(regs)); print("combinações:", dict(c)); print("confiança:", dict(conf)); print("flags:", dict(fl))
    for k in sorted(m): print(k, dict(m[k]))


if __name__ == "__main__":
    {"merge": merge, "export-sql": export_sql, "report": report, "status": merge}[sys.argv[1] if len(sys.argv) > 1 else "status"]()
