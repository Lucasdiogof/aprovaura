"""Gera curriculum/curriculum.json, docs/content/MATRIZ_CURRICULAR.md e docs/content/FONTES_E_LICENCAS.md.
Entrada: curriculum/materias_novas.txt, curriculum/sources.json, state/inventory*.json, state/sources_check.json."""
import json, os
D = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(D, "..", ".."))
LV = {"F": "fundamental", "I": "intermediário", "A": "avançado"}
EXIST = {  # slug: (Nome, área, cats, meta)
 "portugues": ("Português", "Linguagens", "E,V,C", 1200), "literatura": ("Literatura", "Linguagens", "E,V", 450),
 "artes": ("Artes", "Linguagens", "E,V", 300), "educacao_fisica": ("Educação Física", "Linguagens", "E,V", 300),
 "ingles": ("Inglês", "Linguagens", "E,V,C", 600), "espanhol": ("Espanhol", "Linguagens", "E,V", 400),
 "historia": ("História", "Humanas", "E,V", 900), "geografia": ("Geografia", "Humanas", "E,V", 900),
 "filosofia": ("Filosofia", "Humanas", "E,V", 400), "sociologia": ("Sociologia", "Humanas", "E,V", 400),
 "biologia": ("Biologia", "Natureza", "E,V", 800), "fisica": ("Física", "Natureza", "E,V", 700),
 "quimica": ("Química", "Natureza", "E,V", 700), "matematica": ("Matemática", "Matemática e Raciocínio", "E,V,C", 1500),
 "atualidades": ("Atualidades", "Humanas", "E,V,C", 600), "redacao": ("Redação", "Linguagens", "E,V,C", 0)}
src = {s["id"]: s for s in json.load(open(os.path.join(D, "curriculum/sources.json"), encoding="utf-8"))["sources"]}
chk = json.load(open(os.path.join(D, "state/sources_check.json"), encoding="utf-8"))
inv = json.load(open(os.path.join(D, "state/inventory.json"), encoding="utf-8"))
l1 = json.load(open(os.path.join(D, "state/inventory_topics_l1.json"), encoding="utf-8"))
mats, cur = [], None
for ln in open(os.path.join(D, "curriculum/materias_novas.txt"), encoding="utf-8"):
    ln = ln.rstrip("\n")
    if not ln or ln.startswith("#"): continue
    p = ln.split("|")
    if p[0] == "M":
        cur = dict(slug=p[1], nome=p[2], area=p[3], categorias=p[4].split(","), decisao=p[5], fase=p[6], meta=int(p[7]),
                   descricao=p[8], competencias=p[9], fontes=[x for x in p[10].split(",") if x], topicos=[])
        mats.append(cur)
    else:
        cur["topicos"].append(dict(id=f"{cur['slug']}.{p[1]}", nome=p[2], nivel=LV[p[3]],
                                   prerequisitos=[f"{cur['slug']}.{x}" for x in p[4].split(",") if x]))
errs = []
for m in mats:
    for f in m["fontes"]:
        if f not in src: errs.append(f"fonte inexistente {f} em {m['slug']}")
    ids = {t["id"] for t in m["topicos"]}
    for t in m["topicos"]:
        for q in t["prerequisitos"]:
            if q not in ids: errs.append(f"pré-requisito inexistente {q}")
    if m["decisao"].startswith("incluir") and not m["topicos"]: errs.append(f"matéria vazia {m['slug']}")
assert not errs, errs
inc = [m for m in mats if m["decisao"].startswith("incluir")]
meta_new = sum(m["meta"] for m in inc); meta_old = sum(v[3] for v in EXIST.values())
fmt = lambda n: f"{n:,}".replace(",", ".")
out = dict(existentes={k: dict(nome=v[0], area=v[1], categorias=v[2].split(","), meta=v[3]) for k, v in EXIST.items()}, novas=mats)
json.dump(out, open(os.path.join(D, "curriculum/curriculum.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
L = ["# Matriz curricular — expansão do acervo\n",
 "Gerada por `tool/content/gen_matrix.py` a partir de `tool/content/curriculum/` (fonte da verdade, versionada). **Proposta de planejamento: nada aqui foi aplicado ao banco nem publicado.**\n",
 "## Resumo\n",
 f"- Matérias existentes: **{len(EXIST)}** (14 com banco de questões + Atualidades + Redação). Preservadas integralmente.",
 f"- Matérias novas **incluídas**: **{len(inc)}** · agrupadas: {sum(1 for m in mats if m['decisao'].startswith('agrupar'))} · adiadas: {sum(1 for m in mats if m['decisao']=='adiar')}.",
 f"- Total de matérias no plano: **{len(EXIST)+len(inc)}** (referência do dono: ~57+).",
 f"- Meta de planejamento de questões **aprovadas**: existentes {fmt(meta_old)} (hoje há 2.609) + novas {fmt(meta_new)} = **{fmt(meta_old+meta_new)}**. É meta, **não** estoque; o progresso real está em `docs/content/COBERTURA.md`.",
 "- Categorias: E = ENEM, V = Vestibulares, C = Concursos. Uma matéria/tópico/questão pode ter 1, 2 ou 3, **sem duplicar a entidade** (ver `docs/content/ARQUITETURA_CLASSIFICACAO.md`).",
 "- Níveis do tópico: fundamental / intermediário / avançado (preserva `facil/medio/dificil` das questões; distribuição sugerida 30/45/25 sem forçar).",
 "- Matérias de Direito, Gestão, Finanças, TI e Educação no app exigem código novo (enum `Subject`) — fora do escopo desta etapa.\n",
 "## Critérios de inclusão, agrupamento e adiamento\n",
 "- **Incluir** só com (a) escopo bem delimitado, (b) fontes livres/oficiais suficientes para elaborar questões autorais e (c) meta mínima de 200 questões e ao menos 2 tópicos.",
 "- **Agrupar** quando o tema é parte natural de outra matéria (Direito Financeiro e Finanças Públicas → AFO; Algoritmos → Lógica de Programação; SFN → Conhecimentos Bancários).",
 "- **Adiar** quando exigiria fontes por ente (Direito Militar) ou cobertura livre insuficiente (Criminologia): não criamos matéria vazia.",
 "- Fases: 1 = primeiros lotes; 2 = depois da validação do fluxo; 3 = matérias de meta reduzida.\n",
 "## Matérias existentes (dados reais do banco, consulta " + inv["data_consulta"] + ")\n",
 "| Matéria | Área | Categorias propostas | Questões hoje | Meta | Temas de 1º nível (questões) |", "|---|---|---|---:|---:|---|"]
for k, v in EXIST.items():
    qn = inv["por_materia"].get(k, {}).get("questions", 0)
    tops = "; ".join(f"{t[0]} ({t[1]})" for t in l1.get(k, {}).get("tops", [])[:6])
    extra = "5 temas de redação" if k == "redacao" else "7 dossiês (1 por área)" if k == "atualidades" else ""
    L.append(f"| {v[0]} | {v[1]} | {v[2]} | {qn} | {v[3]} | {tops or extra} |")
L += ["\n**Lacunas das existentes (ver inventário):** viés de alternativa correta mais longa (62%); 227 explicações curtas; 35 questões com alternativas equivalentes; Geografia com 45 folhas sem questão (mapas); nenhuma classificação por categoria; Atualidades com 1 dossiê por área; Redação só com 5 temas de treino; Português/Matemática precisam de profundidade para concursos.\n",
 "Os tópicos das existentes mantêm os **ids reais** (`catalog_nodes.id`); as categorias serão aplicadas por tabela de ligação, nunca recriando nós.\n",
 "## Matérias novas — decisão, tópicos e metas\n"]
for m in mats:
    L.append(f"### {m['nome']} (`{m['slug']}`) — {m['area']}\n")
    L.append(f"Categorias: {', '.join(m['categorias'])} · Decisão: **{m['decisao']}** · Fase: {m['fase']} · Meta: {m['meta']}\n")
    L.append(f"{m['descricao']}\n")
    if m["competencias"]: L.append(f"Competências: {m['competencias']} · Fontes: {', '.join(m['fontes'])}\n")
    if m["topicos"]:
        L.append("| Tópico (id estável) | Nome | Nível | Pré-requisitos |\n|---|---|---|---|")
        for t in m["topicos"]:
            pr = ", ".join("`" + p.split(".", 1)[1] + "`" for p in t["prerequisitos"]) or "—"
            L.append(f"| `{t['id']}` | {t['nome']} | {t['nivel']} | {pr} |")
        L.append("")
open(os.path.join(ROOT, "docs/content/MATRIZ_CURRICULAR.md"), "w", encoding="utf-8").write("\n".join(L))
F = ["# Fontes, licenças e política de uso\n", "Gerado por `tool/content/gen_matrix.py` + `verify_sources.py`. Fonte da verdade: `tool/content/curriculum/sources.json`; verificação HTTP em `tool/content/state/sources_check.json`.\n",
 "## Regras permanentes\n", "1. **Não copiamos** bancos/plataformas comerciais (Qconcursos, Gran, Estratégia, TEC e similares), não fazemos scraping que viole termos e não republicamos provas protegidas.",
 "2. Documentos oficiais servem para **matriz e estilo**; as questões são **autorais originais** (sem paráfrase disfarçada, sem atribuir a banca/instituição real).",
 "3. Questão oficial só entra com autorização/licença/domínio público **documentados** (origem `oficial_autorizada` + URL + licença + data).",
 "4. Legislação e atos oficiais não são objeto de proteção autoral (Lei 9.610/98, art. 8º, IV). Texto de lei só vale com **artigo + data de vigência verificada**.",
 "5. 'a confirmar' em licença = não confirmado; a fonte só alimenta a matriz, sem reprodução.\n",
 f"## Registro ({len(src)} fontes)\n", "| ID | Fonte | URL | Uso | Licença documentada | HTTP | Consulta |", "|---|---|---|---|---|---|---|"]
nota = {"403": "bloqueio anti-bot: abrir manualmente", "404": "URL a corrigir"}
for s in src.values():
    c = chk.get(s["id"], {}); st = str(c.get("status", "?"))
    F.append(f"| `{s['id']}` | {s['nome']} | {s['url']} | {s['uso']} | {s['licenca']} | {st}{' — ' + nota[st] if st in nota else ''} | {c.get('consultado_em', '')} |")
F.append("\nFontes com HTTP diferente de 200 **não foram validadas**; nenhum conteúdo delas foi usado ainda. O 200 comprova só que a URL responde, não a licença.\n")
open(os.path.join(ROOT, "docs/content/FONTES_E_LICENCAS.md"), "w", encoding="utf-8").write("\n".join(F))
print(len(inc), "incluídas; meta nova", meta_new, "meta total", meta_old + meta_new)
