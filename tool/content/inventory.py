"""Inventário REAL do acervo (produção, somente leitura). Gera state/inventory.json e docs/content/INVENTARIO_ACERVO.md.
Uso: python tool/content/inventory.py"""
import json, os, re, sys, hashlib, collections, datetime
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "lib"))
from prodread import select
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
STATE = os.path.join(ROOT, "tool", "content", "state"); os.makedirs(STATE, exist_ok=True)

def norm(s): return re.sub(r"\s+", " ", re.sub(r"[^\w\s]", "", (s or "").lower())).strip()

nodes = select("select id,subject,parent_id,title,manual_difficulty,region_count from catalog_nodes")
qs = select("select id,catalog_node_id,prompt,options,correct_index,explanation,difficulty from questions")
tr = select("select locale,count(*) n from question_translations group by 1")
ntr = select("select locale,count(*) n from catalog_node_translations group by 1")
dos = select("select area,status,count(*) n from dossiers group by 1,2 order by 1,2")
dq = select("select count(*) n, count(*) filter (where explanation is null or length(trim(explanation))<20) sem_expl from dossier_questions")
dtr = select("select locale,count(*) n from dossier_translations group by 1")
ess = select("select source_type,is_active,count(*) n from essay_themes group by 1,2")
mock = select("select count(*) n from mock_exams")
usage = select("""select (select count(*) from user_question_progress) progresso,
 (select count(*) from user_question_favorites) favoritos,(select count(*) from question_reports) reportes,
 (select count(*) from mock_exam_items) itens_simulado""")
try: errrev = select("select count(*) n from user_question_progress where is_correct is false")
except Exception as e: errrev = str(e)[:80]
regions = select("select subject, sum(region_count) r from catalog_nodes where region_count is not null group by 1")

byid = {n["id"]: n for n in nodes}
children = collections.Counter(n["parent_id"] for n in nodes if n["parent_id"])
def root_subject(n): return n["subject"]
leaves = {n["id"] for n in nodes if n["id"] not in children}
subj = collections.defaultdict(lambda: dict(nodes=0, leaves=0, questions=0, facil=0, medio=0, dificil=0, leaves_sem_questao=0))
for n in nodes:
    s = subj[n["subject"]]; s["nodes"] += 1
    if n["id"] in leaves: s["leaves"] += 1
qnode = collections.Counter()
issues = collections.defaultdict(list)
hashes = collections.defaultdict(list)
for q in qs:
    n = byid.get(q["catalog_node_id"])
    if not n: issues["orfa"].append(q["id"]); continue
    s = subj[n["subject"]]; s["questions"] += 1; s[q["difficulty"]] = s.get(q["difficulty"], 0) + 1
    qnode[q["catalog_node_id"]] += 1
    opts = q["options"] or []
    if len(opts) != 4: issues["n_alternativas_!=4"].append(q["id"])
    if not (0 <= q["correct_index"] < len(opts)): issues["gabarito_fora_do_intervalo"].append(q["id"])
    if len({norm(o) for o in opts}) != len(opts): issues["alternativas_duplicadas"].append(q["id"])
    if not q["explanation"] or len(q["explanation"].strip()) < 20: issues["sem_explicacao"].append(q["id"])
    elif len(q["explanation"].strip()) < 60: issues["explicacao_curta(<60)"].append(q["id"])
    if len(q["prompt"].strip()) < 15: issues["enunciado_curto"].append(q["id"])
    if re.search(r"<\s*(script|iframe|img|a)\b|javascript:", q["prompt"] + " ".join(opts) + (q["explanation"] or ""), re.I): issues["html_suspeito"].append(q["id"])
    hashes[hashlib.sha1(norm(q["prompt"]).encode()).hexdigest()].append(q["id"])
dups = [v for v in hashes.values() if len(v) > 1]
for n in nodes:
    if n["id"] in leaves and qnode[n["id"]] == 0: subj[n["subject"]]["leaves_sem_questao"] += 1
gab = collections.Counter(q["correct_index"] for q in qs)
longest = sum(1 for q in qs if q["options"] and max(range(len(q["options"])), key=lambda i: len(q["options"][i])) == q["correct_index"])
inv = dict(data_consulta=datetime.date.today().isoformat(), fonte="producao cesuqfgrtcitatxvokez (somente leitura)",
  totais=dict(questoes=len(qs), nos=len(nodes), folhas=len(leaves), materias=len(subj)),
  por_materia=subj, gabarito=dict(gab), gabarito_e_maior_alternativa=longest,
  problemas={k: len(v) for k, v in issues.items()}, grupos_duplicados_exatos=len(dups),
  questoes_em_duplicatas=sum(len(v) for v in dups), traducoes_questoes=tr, traducoes_nos=ntr,
  dossies=dos, dossie_questoes=dq, traducoes_dossies=dtr, redacao_temas=ess, simulados=mock,
  uso_usuarios=usage, regioes_mapa=regions)
json.dump(inv, open(os.path.join(STATE, "inventory.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1, default=str)
json.dump({k: v for k, v in issues.items()}, open(os.path.join(STATE, "inventory_issue_ids.json"), "w"), indent=0)
json.dump(dups, open(os.path.join(STATE, "inventory_duplicates.json"), "w"), indent=0)
print(json.dumps(inv, ensure_ascii=False, indent=1, default=str))
