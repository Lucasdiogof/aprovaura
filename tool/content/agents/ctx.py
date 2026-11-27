"""Contexto vivo de uma matéria para os agentes: `python tool/content/agents/ctx.py <slug>` (somente leitura, sem rede).
Imprime matriz, metas, cobertura atual (acervo legado + lotes), pendências e fontes. Os agentes chamam isto em vez de
carregar dados mutáveis dentro das próprias instruções."""
import collections, glob, json, os, sys
C = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
ld = lambda p: json.load(open(os.path.join(C, p), encoding="utf-8"))

def main(slug):
    cur = ld("curriculum/curriculum.json"); src = {s["id"]: s for s in ld("curriculum/sources.json")["sources"]}
    inv = ld("state/inventory.json"); l1 = ld("state/inventory_topics_l1.json")
    ex = cur["existentes"].get(slug); nv = next((m for m in cur["novas"] if m["slug"] == slug), None)
    if not (ex or nv): sys.exit(f"matéria desconhecida: {slug}. Matérias: " + ", ".join(sorted(list(cur['existentes']) + [m['slug'] for m in cur['novas'] if m['decisao'].startswith('incluir')])))
    print(f"# {slug}\n")
    if ex:
        print(f"Existente · {ex['nome']} · área {ex['area']} · categorias {ex['categorias']} · meta {ex['meta']}")
        r = inv["por_materia"].get(slug)
        if r: print(f"Acervo legado (produção {inv['data_consulta']}): {r['questions']} questões (fácil {r['facil']}, médio {r['medio']}, difícil {r['dificil']}); folhas sem questão: {r['leaves_sem_questao']}")
        print("Temas de 1º nível (id de tópico = `<slug>.<tema>`):")
        for t in l1.get(slug, {}).get("tops", []): print(f"  - {t[0]} ({t[1]} questões)")
    else:
        print(f"Nova · {nv['nome']} · área {nv['area']} · categorias {nv['categorias']} · decisão {nv['decisao']} · fase {nv['fase']} · meta {nv['meta']}")
        print(f"Descrição: {nv['descricao']}\nCompetências: {nv['competencias']}\nTópicos:")
        for t in nv["topicos"]: print(f"  - {t['id']} [{t['nivel']}] {t['nome']}" + (f" (pré: {', '.join(t['prerequisitos'])})" if t["prerequisitos"] else ""))
        print("Fontes:")
        for f in nv["fontes"]: s = src.get(f, {}); print(f"  - {f}: {s.get('nome')} · {s.get('url')} · uso={s.get('uso')} · licença={s.get('licenca')}")
    est = collections.Counter(); mot = collections.Counter(); por_t = collections.Counter(); dif = collections.Counter()
    for f in glob.glob(os.path.join(C, "batches", "*", "estado", "questoes.jsonl")):
        for l in open(f, encoding="utf-8"):
            q = json.loads(l)
            if q["materia"] != slug: continue
            est[q["estado"]] += 1; por_t[(q["topico"], q["estado"])] += 1
            if q["estado"] in ("publicavel", "revisao_especializada_pendente"): dif[q["dificuldade"]] += 1
            if q["estado"] == "rejeitada": mot.update(m[:80] for m in q.get("motivos", [])[:1])
    print(f"\nLotes (estado atual): {dict(est) or 'nenhuma questão nova ainda'}")
    if dif: print(f"Dificuldade (publicável + espec. pendente): {dict(dif)}")
    for k, n in mot.most_common(8): print(f"  rejeição: {n}× {k}")
    print("\nRegras: ler docs/content/agentes/PROTOCOLO_ESPECIALISTA.md; formato em tool/content/pipeline/SCHEMA.md; nada vai a produção.")

if __name__ == "__main__":
    if len(sys.argv) != 2: sys.exit(__doc__)
    main(sys.argv[1])
