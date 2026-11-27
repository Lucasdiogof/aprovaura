"""Controles de qualidade determinísticos do pipeline de conteúdo (sem rede, sem custo).
Cada função devolve (erros_duros, avisos). Erro duro => questão rejeitada com motivo."""
import hashlib, json, os, re, subprocess, sys, tempfile, unicodedata

D = os.path.dirname(os.path.abspath(__file__))
CONTENT = os.path.abspath(os.path.join(D, ".."))
ESTADOS = ("rascunho", "aguardando_revisao", "em_revisao", "aprovada_validacao_automatizada",
           "revisao_especializada_pendente", "rejeitada", "desatualizada", "publicavel")
CATEGORIAS = ("enem", "vestibular", "concurso")
DIFICULDADES = ("facil", "medio", "dificil")
ORIGENS = ("autoral", "autoral_baseada_em_referencias", "oficial_autorizada")
# Matérias cujo conteúdo é normativo: exigem referência verificável (artigo/dispositivo) e data de referência.
NORMATIVAS = {"dir_constitucional", "dir_administrativo", "dir_penal", "dir_proc_penal", "dir_civil", "dir_proc_civil",
              "dir_tributario", "dir_trabalho", "dir_proc_trabalho", "dir_eleitoral", "dir_ambiental", "dir_empresarial",
              "dir_previdenciario", "direitos_humanos", "legislacao_especifica", "dir_consumidor", "dir_internacional_publico",
              "etica_servico_publico", "licitacoes_contratos", "legislacao_educacional", "afo", "contabilidade_publica",
              "redacao_oficial", "saude_publica_sus", "arquivologia", "educacao_inclusiva", "gestao_escolar"}
# Dentre elas, as que exigem revisão especializada humana antes de 'publicavel'.
ESPECIALISTA = NORMATIVAS - {"arquivologia"}  # Redação Oficial: manual só conferido em cópia secundária
MUTAVEIS = NORMATIVAS | {"atualidades", "economia", "conhecimentos_bancarios"}  # mat. financeira/educação financeira usam taxas hipotéticas
IDIOMA_MATERIA = {"ingles": "en", "espanhol": "es"}
BANCAS = r"\b(cespe|cebraspe|fgv|fcc|vunesp|cesgranrio|idecan|ibfc|quadrix|fuvest|unicamp|unesp|uerj|ufrgs|enem\s*20\d\d|inep)\b"
PROIBIDOS = [r"todas as (anteriores|alternativas)", r"nenhuma das (anteriores|alternativas)", r"\b[abcd]\s*e\s*[abcd]\s+(est[aã]o|s[aã]o)\s+corret",
             r"na (figura|imagem|charge|tirinha|foto)\b", r"no gr[aá]fico (abaixo|a seguir|acima)", r"<\s*/?\s*(script|iframe|img|a|b|i|p|div|span|br)\b", r"javascript:"]


def nfc(s): return unicodedata.normalize("NFC", s)

def norm_text(s):
    s = unicodedata.normalize("NFD", (s or "").lower())
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    return re.sub(r"\s+", " ", re.sub(r"[^\w\s]", " ", s)).strip()

def normalizar(q):
    """Normalização: NFC, espaços, strip. Não muda o sentido."""
    q = dict(q)
    for k in ("enunciado", "explicacao"):
        if isinstance(q.get(k), str): q[k] = re.sub(r"[ \t]+", " ", nfc(q[k]).strip())
    if isinstance(q.get("alternativas"), list): q["alternativas"] = [re.sub(r"\s+", " ", nfc(str(a)).strip()) for a in q["alternativas"]]
    return q

def content_hash(q):
    base = json.dumps({k: q.get(k) for k in ("materia", "topico", "categorias", "idioma", "dificuldade", "enunciado", "alternativas",
                                              "gabarito", "explicacao", "referencias", "data_referencia", "verificacao")}, sort_keys=True, ensure_ascii=False)
    return hashlib.sha256(base.encode()).hexdigest()[:16]

def carregar_curriculo():
    c = json.load(open(os.path.join(CONTENT, "curriculum", "curriculum.json"), encoding="utf-8"))
    l1 = json.load(open(os.path.join(CONTENT, "state", "inventory_topics_l1.json"), encoding="utf-8")) if os.path.exists(
        os.path.join(CONTENT, "state", "inventory_topics_l1.json")) else {}
    mats = {}
    for slug, v in c["existentes"].items():
        mats[slug] = dict(categorias=set(v["categorias"]), topicos={f"{slug}.{t[0]}" for t in l1.get(slug, {}).get("tops", [])}, existente=True)
    for m in c["novas"]:
        if m["decisao"].startswith("incluir"):
            mats[m["slug"]] = dict(categorias=set(m["categorias"]), topicos={t["id"] for t in m["topicos"]}, existente=False)
    return mats

CAT_MAP = {"E": "enem", "V": "vestibular", "C": "concurso"}

def fontes_texto_oficial():
    s = json.load(open(os.path.join(CONTENT, "curriculum", "sources.json"), encoding="utf-8"))["sources"]
    return {x["id"]: x for x in s}


def estrutura(q, mats=None, fontes=None):
    mats = mats or carregar_curriculo(); fontes = fontes or fontes_texto_oficial()
    e, w = [], []
    for k in ("id", "materia", "topico", "categorias", "dificuldade", "enunciado", "alternativas", "gabarito", "explicacao", "origem"):
        if k not in q or q[k] in (None, "", []): e.append(f"campo_ausente:{k}")
    if e: return e, w
    m = mats.get(q["materia"])
    if not m: return [f"materia_desconhecida:{q['materia']}"], w
    if q["materia"] == "atualidades" and q["topico"].startswith("atualidades."):
        w.append("tema_atualidades_a_mapear_para_dossie")  # Atualidades não tem nós de catálogo (é por dossiê)
    elif q["topico"] not in m["topicos"]: e.append(f"topico_desconhecido:{q['topico']}")
    cats = q["categorias"]
    if not isinstance(cats, list) or not cats or any(c not in CATEGORIAS for c in cats) or len(set(cats)) != len(cats): e.append("categorias_invalidas")
    else:
        permitidas = {CAT_MAP.get(c, c) for c in m["categorias"]}
        if not set(cats) <= permitidas: e.append(f"categoria_fora_da_materia:{sorted(set(cats) - permitidas)}")
    if q["dificuldade"] not in DIFICULDADES: e.append("dificuldade_invalida")
    if q["origem"] not in ORIGENS: e.append("origem_invalida")
    if q["origem"] == "oficial_autorizada": e.append("oficial_autorizada_exige_documentacao_manual")
    alts = q["alternativas"]
    if not isinstance(alts, list) or len(alts) != 4 or not all(isinstance(a, str) and a.strip() for a in alts): e.append("alternativas_nao_4")
    else:
        if len({re.sub(r"\s+", " ", a.strip().lower()).rstrip(".;") for a in alts}) != 4: e.append("alternativas_duplicadas")
        if not isinstance(q["gabarito"], int) or isinstance(q["gabarito"], bool) or not 0 <= q["gabarito"] < 4: e.append("gabarito_fora_do_intervalo")
    if len(q["enunciado"]) < 40: e.append("enunciado_curto")
    if len(q["explicacao"]) < 200: e.append("explicacao_curta")
    texto = " ".join([q["enunciado"], q["explicacao"]] + [str(a) for a in alts if isinstance(a, str)])
    for p in PROIBIDOS:
        if re.search(p, texto, re.I): e.append(f"padrao_proibido:{p[:25]}")
    if re.search(BANCAS, texto, re.I): e.append("cita_banca_ou_instituicao")
    idioma = q.get("idioma", "pt-BR")
    if idioma not in ("pt-BR", "en", "es"): e.append("idioma_invalido")
    esperado = IDIOMA_MATERIA.get(q["materia"], "pt-BR")
    if idioma != esperado: w.append(f"idioma_inesperado:{idioma}")
    if q["materia"] in NORMATIVAS:
        refs = q.get("referencias") or []
        if not refs: e.append("sem_referencia_normativa")
        for r in refs:
            f = fontes.get(r.get("fonte"))
            if not f: e.append(f"referencia_fonte_desconhecida:{r.get('fonte')}")
            elif f["uso"] != "texto_oficial": w.append(f"fonte_nao_texto_oficial:{r.get('fonte')}")
            if not re.search(r"(art|§|súmula|sumula|inciso|decreto|manual|item|cap)", r.get("citacao", ""), re.I): e.append("citacao_sem_dispositivo")
    if q["materia"] in MUTAVEIS and not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(q.get("data_referencia", ""))): e.append("sem_data_referencia")
    if not q.get("explicacao") or not re.search(r"\b[A-Da-d]\)|alternativa\s+[A-Da-d]|letra\s+[A-Da-d]", q["explicacao"]): w.append("explicacao_nao_cita_alternativas")
    return e, w


def gabarito_mais_longa(q):
    a = q["alternativas"]
    return max(range(len(a)), key=lambda i: len(a[i])) == q["gabarito"] and sorted(len(x) for x in a)[-1] > sorted(len(x) for x in a)[-2]


_WRAP = r'''
import json, sys
src = json.load(open(sys.argv[1], encoding="utf-8"))["codigo"]
ns = {}
exec(compile(src, "verificacao", "exec"), ns)
import sympy
def eq(a, b):
    try:
        if isinstance(a, str) or isinstance(b, str): return str(a).strip().lower() == str(b).strip().lower()
        d = sympy.nsimplify(a) - sympy.nsimplify(b) if not (isinstance(a, float) or isinstance(b, float)) else None
        if d is not None: return sympy.simplify(d) == 0
        return abs(float(a) - float(b)) <= 1e-6 * max(1.0, abs(float(b)))
    except Exception: return a == b
v, c = ns["valores"], ns["correta"]
print(json.dumps([i for i, x in enumerate(v) if eq(x, c)]))
'''
_DENY = re.compile(r"(import\s+(os|sys|subprocess|socket|shutil|pathlib|requests|urllib)|__import__|open\s*\(|eval\s*\(|exec\s*\(|input\s*\()")


def _rodar_sandbox(codigo, timeout):
    """Docker descartável sem rede/FS/credenciais; código entra por stdin. Retorna (rc, stdout, stderr)."""
    import uuid
    nome = "aura-verif-" + uuid.uuid4().hex[:10]
    payload = json.dumps({"codigo": codigo})
    cmd = ["docker", "run", "--rm", "-i", "--name", nome, "--network", "none", "--read-only", "--cap-drop", "ALL",
           "--security-opt", "no-new-privileges", "--memory", "256m", "--memory-swap", "256m", "--cpus", "1",
           "--pids-limit", "64", "--tmpfs", "/tmp:size=16m,noexec", "aura-verif", "python", "-I", "-c", _WRAP_STDIN]
    try:
        r = subprocess.run(cmd, input=payload, capture_output=True, text=True, encoding="utf-8", timeout=timeout)
    except subprocess.TimeoutExpired:
        subprocess.run(["docker", "kill", nome], capture_output=True)
        return None, "", "timeout"
    except FileNotFoundError:
        return -1, "", "sandbox_indisponivel"
    if r.returncode == 125 or "Unable to find image" in r.stderr or "Cannot connect" in r.stderr:
        return -1, "", "sandbox_indisponivel"
    return r.returncode, r.stdout, r.stderr


_WRAP_STDIN = _WRAP.replace('json.load(open(sys.argv[1], encoding="utf-8"))', 'json.load(sys.stdin)')


def verificar_calculo(q, timeout=30):
    """Executa `verificacao.codigo` em sandbox Docker (ver tool/content/sandbox). Retorna (erros, avisos)."""
    v = q.get("verificacao")
    if not v: return [], []
    if v.get("tipo") != "python" or not isinstance(v.get("codigo"), str): return ["verificacao_invalida"], []
    if _DENY.search(v["codigo"]): return ["verificacao_codigo_proibido"], []
    if os.environ.get("AURA_SANDBOX") == "local":  # INSEGURO: só depuração
        with tempfile.TemporaryDirectory() as td:
            pj, pw = os.path.join(td, "v.json"), os.path.join(td, "w.py")
            json.dump({"codigo": v["codigo"]}, open(pj, "w", encoding="utf-8")); open(pw, "w", encoding="utf-8").write(_WRAP)
            try: r = subprocess.run([sys.executable, "-I", pw, pj], capture_output=True, text=True, timeout=timeout, cwd=td)
            except subprocess.TimeoutExpired: return ["verificacao_timeout"], []
        rc, out, err = r.returncode, r.stdout, r.stderr
    else:
        rc, out, err = _rodar_sandbox(v["codigo"], timeout)
        if rc is None: return ["verificacao_timeout"], []
        if rc == -1: return ["verificacao_sandbox_indisponivel"], []
    if rc != 0: return ["verificacao_erro_execucao:" + (err.strip().splitlines() or ["?"])[-1][:120]], []
    try: idx = json.loads(out.strip().splitlines()[-1])
    except Exception: return ["verificacao_saida_invalida"], []
    if idx != [q["gabarito"]]: return [f"verificacao_diverge:calculo_aponta={idx}_gabarito={q['gabarito']}"], []
    return [], []


def expira_em(q):
    """Data de expiração sugerida para conteúdo mutável (revisão obrigatória até lá)."""
    import datetime
    if q["materia"] not in MUTAVEIS or not q.get("data_referencia"): return None
    dias = 180 if q["materia"] == "atualidades" else 365
    return (datetime.date.fromisoformat(q["data_referencia"]) + datetime.timedelta(days=dias)).isoformat()
