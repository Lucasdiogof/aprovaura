"""Pipeline de conteúdo retomável e auditável. Uso: python tool/content/pipeline/run.py <comando> <lote>
Comandos (nesta ordem): ingest · dedupe · blind-export · ingest-resolution · ingest-review · status · export-sql · report
Estado persistido em batches/<lote>/estado/questoes.jsonl (+ historico por questão). Reexecutar é seguro (idempotente):
só reprocessa questão cujo conteúdo mudou. Nunca grava no banco; nunca apaga questão existente."""
import collections, datetime, glob, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qc
from dedupe import Index

ROOT = os.path.abspath(os.path.join(qc.CONTENT, "..", ".."))
HOJE = datetime.date.today().isoformat()

def bdir(lote): return os.path.join(qc.CONTENT, "batches", lote)
def estado_path(lote): return os.path.join(bdir(lote), "estado", "questoes.jsonl")

def read_jsonl(p):
    if not os.path.exists(p): return []
    return [json.loads(l) for l in open(p, encoding="utf-8") if l.strip()]

def write_jsonl(p, rows):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    tmp = p + ".tmp"
    with open(tmp, "w", encoding="utf-8", newline="\n") as f:
        for r in rows: f.write(json.dumps(r, ensure_ascii=False, sort_keys=True) + "\n")
    os.replace(tmp, p)  # checkpoint atômico

def mover(q, estado, etapa, motivo=None):
    q["estado"] = estado
    q.setdefault("historico", []).append({"etapa": etapa, "estado": estado, "em": HOJE, **({"motivo": motivo} if motivo else {})})
    if motivo: q.setdefault("motivos", []).append(f"{etapa}:{motivo}")
    elif estado != "rejeitada": pass

def rejeitar(q, etapa, motivos):
    for m in (motivos if isinstance(motivos, list) else [motivos]): mover(q, "rejeitada", etapa, m)

def load(lote): return {q["id"]: q for q in read_jsonl(estado_path(lote))}
def save(lote, qs): write_jsonl(estado_path(lote), sorted(qs.values(), key=lambda q: q["id"]))


def cmd_ingest(lote):
    qs = load(lote); mats = qc.carregar_curriculo(); fontes = qc.fontes_texto_oficial(); novos = alt = 0
    for f in sorted(glob.glob(os.path.join(bdir(lote), "autoria", "*.jsonl"))):
        area = os.path.basename(f)[:-6]
        if area in ("redacao_propostas", "teoria"): continue
        for raw in read_jsonl(f):
            q = qc.normalizar(raw); q["area"] = area; q["hash"] = qc.content_hash(q)
            q.pop("estado", None)
            ant = qs.get(q.get("id"))
            if ant and ant["hash"] == q["hash"]: continue  # inalterada: mantém o progresso
            if ant: alt += 1
            else: novos += 1
            q["historico"] = [{"etapa": "autoria", "estado": "rascunho", "em": HOJE}]; q["estado"] = "rascunho"; q["motivos"] = []
            if not q.get("id"): continue
            e, w = qc.estrutura(q, mats, fontes)
            if not e:
                e2, _ = qc.verificar_calculo(q); e += e2
            q["avisos"] = w; q["gabarito_mais_longa"] = qc.gabarito_mais_longa(q) if not e else None
            q["expira_em"] = qc.expira_em(q) if not e else None
            if e: rejeitar(q, "validacao_estrutural", e)
            else: mover(q, "aguardando_revisao", "validacao_estrutural")
            qs[q["id"]] = q
    save(lote, qs); print(f"ingest: {novos} novas, {alt} alteradas; total {len(qs)}")
    cmd_status(lote)


def acervo_index():
    p = os.path.join(qc.CONTENT, "state", "existing_questions.jsonl")
    ix = Index()
    for r in read_jsonl(p): ix.add("acervo:" + r["id"], r["prompt"], r.get("options") or [])
    return ix, os.path.exists(p)


def cmd_dedupe(lote):
    qs = load(lote); ix, tem = acervo_index()
    if not tem: print("AVISO: state/existing_questions.jsonl ausente (rode fetch_existing.py); dedupe só dentro do lote/lotes anteriores")
    for other in sorted(glob.glob(os.path.join(qc.CONTENT, "batches", "*", "estado", "questoes.jsonl"))):  # outros lotes: já aceitos
        if os.path.dirname(os.path.dirname(other)) == bdir(lote): continue
        for r in read_jsonl(other):
            if r["estado"] != "rejeitada": ix.add("lote:" + r["id"], r["enunciado"], r["alternativas"])
    n = 0
    for q in sorted(qs.values(), key=lambda x: x["id"]):
        if q["estado"] == "rejeitada" or q.get("dedupe_ok") == q["hash"]: continue
        hit, s, tipo = ix.query(q["enunciado"], q["alternativas"], skip="lote:" + q["id"])
        if hit:
            n += 1; rejeitar(q, "deduplicacao", f"{tipo}:{hit}:{s:.2f}")
        else:
            q["dedupe_ok"] = q["hash"]; ix.add("lote:" + q["id"], q["enunciado"], q["alternativas"])  # a primeira ocorrência fica
    save(lote, qs); print(f"dedupe: {n} duplicatas rejeitadas (nada foi apagado do acervo)")


def cmd_blind_export(lote):
    qs = load(lote); por_area = collections.defaultdict(list)
    for q in qs.values():
        if q["estado"] == "aguardando_revisao":
            por_area[q["area"]].append({k: q[k] for k in ("id", "materia", "topico", "idioma", "enunciado", "alternativas") if k in q})
            mover(q, "em_revisao", "exportada_para_resolucao_cega")
    for a, rows in por_area.items(): write_jsonl(os.path.join(bdir(lote), "resolucao", f"{a}_cego.jsonl"), rows)
    save(lote, qs); print("blind-export:", {a: len(r) for a, r in por_area.items()})


def cmd_ingest_resolution(lote):
    qs = load(lote); ok = bad = 0
    for f in glob.glob(os.path.join(bdir(lote), "resolucao", "*_respostas.jsonl")):
        for r in read_jsonl(f):
            q = qs.get(r["id"])
            if not q or q["estado"] != "em_revisao": continue
            q["resolucao"] = {k: r.get(k) for k in ("resposta", "confianca", "ambigua", "comentario")}
            if r.get("ambigua") or r.get("resposta") != q["gabarito"]:
                bad += 1; rejeitar(q, "resolucao_independente", f"divergente_ou_ambigua:resolvedor={r.get('resposta')}_gabarito={q['gabarito']}_ambigua={bool(r.get('ambigua'))}")
            else: ok += 1; q["resolucao_ok"] = True
    save(lote, qs); print(f"ingest-resolution: {ok} concordam, {bad} rejeitadas")


def cmd_ingest_review(lote):
    qs = load(lote); fontes = qc.fontes_texto_oficial(); cont = collections.Counter()
    for f in glob.glob(os.path.join(bdir(lote), "revisao", "*_revisao.jsonl")):
        for r in read_jsonl(f):
            q = qs.get(r["id"])
            if not q or q["estado"] != "em_revisao" or not q.get("resolucao_ok"): continue
            q["revisao"] = {k: r.get(k) for k in ("parecer", "qualidade_explicacao", "distratores", "fonte_verificada", "fonte_nota", "motivos")}
            p = r.get("parecer"); mot = r.get("motivos") or []
            if p != "aprovado": rejeitar(q, "revisao_pedagogica", [f"{p}:" + "; ".join(mot)[:200]]); cont["rejeitada"] += 1; continue
            if (r.get("qualidade_explicacao") or 0) < 3 or r.get("distratores") == "fracos":
                rejeitar(q, "revisao_pedagogica", "explicacao_ou_distratores_abaixo_do_minimo"); cont["rejeitada"] += 1; continue
            normativa = q["materia"] in qc.NORMATIVAS
            if normativa and r.get("fonte_verificada") is not True:
                rejeitar(q, "verificacao_fontes", "sem_referencia_verificada"); cont["rejeitada"] += 1; continue
            mover(q, "aprovada_validacao_automatizada", "revisao_pedagogica")
            if q["materia"] in qc.ESPECIALISTA: mover(q, "revisao_especializada_pendente", "politica_juridica_contabil"); cont["especialista"] += 1
            else: mover(q, "publicavel", "gates_concluidos"); cont["publicavel"] += 1
    save(lote, qs); print("ingest-review:", dict(cont))


def cmd_status(lote):
    qs = load(lote); c = collections.Counter((q["area"], q["estado"]) for q in qs.values())
    est = collections.Counter(q["estado"] for q in qs.values()); print("estados:", dict(est))
    for a in sorted({k[0] for k in c}): print(f"  {a}: " + ", ".join(f"{e}={n}" for (aa, e), n in sorted(c.items()) if aa == a))
    for a in sorted({q["area"] for q in qs.values()}):
        arr = [q for q in qs.values() if q["area"] == a and q.get("gabarito_mais_longa") is not None]
        if arr:
            r = sum(q["gabarito_mais_longa"] for q in arr) / len(arr); g = collections.Counter(q["gabarito"] for q in arr)
            print(f"  [{a}] correta=mais longa em {r:.0%} (alerta >35%){' <<< VIÉS' if r > .35 else ''}; gabarito A-D {[g[i] for i in range(4)]}")


def sql_str(s): return "'" + str(s).replace("'", "''") + "'"
def sql_arr(a): return "array[" + ",".join(sql_str(x) for x in a) + "]"

def cmd_export_sql(lote):
    qs = [q for q in load(lote).values() if q["estado"] == "publicavel"]
    out = [f"-- Lote {lote}: SOMENTE staging (invisível ao app). Gerado por pipeline/run.py. Promoção ao catálogo só com autorização do dono.",
           "begin;", f"insert into content_batches (code, version, description, status) values ({sql_str(lote)}, 1, 'lote gerado pelo pipeline', 'em_staging') on conflict (code) do nothing;"]
    for q in sorted(qs, key=lambda x: x["id"]):
        prov = {"origin": q["origem"], "refs": q.get("referencias", [])}
        out.append("insert into content_question_staging (batch_id, source_key, subject, topic_key, categories, locale, prompt, options, correct_index, explanation, difficulty, provenance, validation_state, reference_date, expires_at) "
                   f"select b.id, {sql_str(q['id'])}, {sql_str(q['materia'])}, {sql_str(q['topico'])}, {sql_arr(q['categorias'])}, {sql_str(q.get('idioma', 'pt-BR'))}, {sql_str(q['enunciado'])}, {sql_arr(q['alternativas'])}, {q['gabarito']}, {sql_str(q['explicacao'])}, {sql_str(q['dificuldade'])}, {sql_str(json.dumps(prov, ensure_ascii=False))}::jsonb, 'publicavel', "
                   f"{sql_str(q['data_referencia']) + '::date' if q.get('data_referencia') else 'null'}, {sql_str(q['expira_em']) + '::date' if q.get('expira_em') else 'null'} from content_batches b where b.code = {sql_str(lote)} on conflict (batch_id, source_key) do nothing;")
    out.append("commit;")
    p = os.path.join(bdir(lote), "export", f"staging_{lote}.sql"); os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n"); print(f"export-sql: {len(qs)} questões publicáveis -> {p}")


def cmd_report(lote=None):
    inv = json.load(open(os.path.join(qc.CONTENT, "state", "inventory.json"), encoding="utf-8"))
    allq = []
    for f in sorted(glob.glob(os.path.join(qc.CONTENT, "batches", "*", "estado", "questoes.jsonl"))):
        allq += [dict(q, lote=os.path.basename(os.path.dirname(os.path.dirname(f)))) for q in read_jsonl(f)]
    est = collections.Counter(q["estado"] for q in allq)
    uniq = {q["id"] for q in allq}  # cada questão é UM registro com várias categorias: total único não soma duplicidade
    L = ["# Cobertura do acervo (atualizável)\n", f"Gerado por `python tool/content/pipeline/run.py report` em {HOJE}. **Planejado ≠ concluído**: só `publicavel` conta como aprovada; nada foi publicado a usuários.\n",
         "## Totais únicos\n", f"- Acervo ativo hoje (produção, {inv['data_consulta']}): **{inv['totais']['questoes']}** questões (legado; sem classificação por categoria; origem 'legado não registrado').",
         f"- Questões novas produzidas nos lotes: **{len(uniq)}** (únicas por id).",
         f"- Aprovadas e publicáveis (todos os gates, ficam em staging): **{est['publicavel']}**.", f"- Aprovadas na validação automatizada, **revisão especializada humana pendente**: **{est['revisao_especializada_pendente']}**.",
         f"- Rejeitadas: **{est['rejeitada']}** · em andamento (rascunho/aguardando/em revisão): **{est['rascunho'] + est['aguardando_revisao'] + est['em_revisao'] + est['aprovada_validacao_automatizada']}** · desatualizadas: {est['desatualizada']}.",
         f"- Total único potencial no catálogo se tudo for autorizado: {inv['totais']['questoes']} + {est['publicavel']} (+ {est['revisao_especializada_pendente']} após revisão humana).\n",
         "## Por matéria (novas, estado atual)\n", "| Matéria | publicável | espec. pendente | rejeitada | outras |", "|---|---:|---:|---:|---:|"]
    pm = collections.defaultdict(collections.Counter)
    for q in allq: pm[q["materia"]][q["estado"]] += 1
    for m, c in sorted(pm.items()): L.append(f"| {m} | {c['publicavel']} | {c['revisao_especializada_pendente']} | {c['rejeitada']} | {sum(c.values()) - c['publicavel'] - c['revisao_especializada_pendente'] - c['rejeitada']} |")
    L += ["\n## Por categoria (questões únicas; uma questão em 2 categorias aparece nas duas linhas mas conta 1 no total)\n", "| Categoria | publicável | espec. pendente |", "|---|---:|---:|"]
    for cat in qc.CATEGORIAS:
        L.append(f"| {cat} | {sum(1 for q in allq if cat in q['categorias'] and q['estado'] == 'publicavel')} | {sum(1 for q in allq if cat in q['categorias'] and q['estado'] == 'revisao_especializada_pendente')} |")
    L += ["\n## Por dificuldade (publicável + espec. pendente)\n", "| Dificuldade | n |", "|---|---:|"]
    ok = [q for q in allq if q["estado"] in ("publicavel", "revisao_especializada_pendente")]
    for d in qc.DIFICULDADES: L.append(f"| {d} | {sum(1 for q in ok if q['dificuldade'] == d)} |")
    L += ["\n## Por origem\n", "| Origem | n |", "|---|---:|", f"| legado_nao_registrado | {inv['totais']['questoes']} |"]
    for o in qc.ORIGENS: L.append(f"| {o} | {sum(1 for q in allq if q['origem'] == o)} |")
    L += ["\n## Motivos de rejeição (etapa)\n", "| Etapa | n |", "|---|---:|"]
    mot = collections.Counter(m.split(":")[0] for q in allq if q["estado"] == "rejeitada" for m in q.get("motivos", [])[:1])
    for k, n in mot.most_common(): L.append(f"| {k} | {n} |")
    L.append("\n## Metas (ver MATRIZ_CURRICULAR.md)\n\nA meta de 20 mil questões aprovadas é de planejamento; o estoque real é o das tabelas acima.\n")
    open(os.path.join(ROOT, "docs", "content", "COBERTURA.md"), "w", encoding="utf-8", newline="\n").write("\n".join(L)); print("report: docs/content/COBERTURA.md")


CMDS = {"ingest": cmd_ingest, "dedupe": cmd_dedupe, "blind-export": cmd_blind_export, "ingest-resolution": cmd_ingest_resolution,
        "ingest-review": cmd_ingest_review, "status": cmd_status, "export-sql": cmd_export_sql, "report": cmd_report}

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in CMDS: sys.exit(__doc__)
    CMDS[sys.argv[1]](*(sys.argv[2:3] or []))
