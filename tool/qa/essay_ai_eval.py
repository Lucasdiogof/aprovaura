"""Avaliação técnica da IA de correção (Etapa 10C, serviço 3) com redações SINTÉTICAS.

Usa o prompt e o schema REAIS de supabase/functions/evaluate-essay/index.ts (lidos do arquivo) e chama o
Gemini direto, fora do app e do banco: nada de usuário, redação real ou dado pessoal. Mede nota por
competência, consistência entre repetições, tokens (usageMetadata) e latência.
Uso: GEMINI_KEY=... python tool/qa/essay_ai_eval.py <modelo> [repeticoes_do_caso_medio]
Nunca imprime a chave. Respeita o free tier: pausa entre chamadas e para no primeiro 429.
"""
import json, os, re, sys, time, urllib.error, urllib.request

KEY = os.environ["GEMINI_KEY"]
MODEL = sys.argv[1]
REPS = int(sys.argv[2]) if len(sys.argv) > 2 else 3
SRC = open(os.path.join(os.path.dirname(__file__), "..", "..", "supabase", "functions", "evaluate-essay", "index.ts"),
           encoding="utf-8").read()

titles = dict(re.findall(r"^\s+(c[1-5]): '([^']+)',", SRC.split("const COMPETENCY_TITLES")[1].split("};")[0], re.M))
rub = SRC.split("function rubric(locale: Locale): string {\n  return `")[1].split("`;\n}")[0]
for k, v in titles.items():
    rub = rub.replace("${COMPETENCY_TITLES.%s}" % k, v)
rub = rub.replace("${FEEDBACK_LANGUAGE[locale]}", 'português do Brasil, dirigindo-se a quem escreveu por "você"')
assert "${" not in rub, "placeholder não resolvido"

comp = {"type": "OBJECT", "properties": {
    "score": {"type": "INTEGER"}, "summary": {"type": "STRING"},
    "strengths": {"type": "ARRAY", "items": {"type": "STRING"}},
    "improvements": {"type": "ARRAY", "items": {"type": "STRING"}},
    "evidence": {"type": "ARRAY", "items": {"type": "STRING"}}},
    "required": ["score", "summary", "strengths", "improvements"]}
SCHEMA = {"type": "OBJECT", "properties": {
    **{k: comp for k in ("c1", "c2", "c3", "c4", "c5")},
    "general_feedback": {"type": "STRING"}, "strengths": {"type": "ARRAY", "items": {"type": "STRING"}},
    "priority_improvements": {"type": "ARRAY", "items": {"type": "STRING"}},
    "possible_theme_deviation": {"type": "BOOLEAN"}, "insufficient_text": {"type": "BOOLEAN"}},
    "required": ["c1", "c2", "c3", "c4", "c5", "general_feedback", "strengths", "priority_improvements",
                 "possible_theme_deviation", "insufficient_text"]}

THEME = "Desafios para valorizar o trabalho de cuidado realizado no ambiente doméstico no Brasil"
PROMPT_TXT = ("Em texto dissertativo-argumentativo, discuta os desafios para valorizar o trabalho de cuidado "
              "realizado no ambiente doméstico no Brasil, propondo uma intervenção que respeite os direitos humanos.")
SUPPORT = ("Texto 1 (sintético)\nPesquisas de uso do tempo indicam que mulheres dedicam mais horas semanais a "
           "tarefas domésticas e de cuidado do que homens, sem remuneração.")

ESSAYS = {
    "fraca": "O trabalho de casa e importante mais ninguem valoriza. As mulher faz tudo e os home não ajuda "
             "por que acha que é coisa de mulher. Isso é um problema muito grande no brasil e tem que acabar. "
             "O governo deve fazer alguma coisa. Tambem as pessoas devem mudar. Então concluo que é preciso "
             "melhorar isso pra todo mundo ficar feliz.",
    "media": "O trabalho de cuidado realizado dentro de casa, como cuidar de crianças, idosos e das tarefas "
             "domésticas, ainda é pouco valorizado no Brasil. Isso acontece, em primeiro lugar, porque existe "
             "uma cultura machista que atribui esse papel quase exclusivamente às mulheres. Além disso, por não "
             "gerar renda, esse trabalho não aparece nas estatísticas econômicas e fica invisível. Como "
             "consequência, muitas mulheres abandonam os estudos ou o emprego. Portanto, o Governo deve criar "
             "campanhas educativas que mostrem a importância da divisão das tarefas, e as escolas devem discutir "
             "o tema, para que a sociedade passe a reconhecer esse trabalho.",
    "forte": "A invisibilidade do trabalho de cuidado doméstico no Brasil, herança de uma divisão sexual do "
             "trabalho que atravessa séculos, impede que milhões de pessoas sejam reconhecidas como agentes "
             "econômicos. Sob a perspectiva da socióloga Arlie Hochschild, o conceito de \"segundo turno\" "
             "descreve a jornada não remunerada que se soma ao emprego formal, e a realidade brasileira "
             "corrobora essa leitura: segundo pesquisas de uso do tempo, as mulheres dedicam substancialmente "
             "mais horas semanais a essas tarefas. Nesse sentido, a naturalização do cuidado como \"vocação "
             "feminina\" e a ausência desse trabalho nas contas nacionais perpetuam a desigualdade. Ademais, a "
             "falta de creches e de serviços públicos de apoio a idosos transfere ao núcleo familiar uma "
             "responsabilidade que deveria ser compartilhada com o Estado. Portanto, cabe ao Ministério da "
             "Educação, por meio da inclusão do tema em projetos escolares, promover o debate sobre "
             "corresponsabilidade, a fim de desconstruir estereótipos de gênero. Cabe também ao Governo Federal "
             "ampliar a rede de creches e de centros-dia, mediante financiamento, para que o cuidado deixe de "
             "ser um fardo individual e passe a ser valorizado como direito social.",
    "fuga": "O futebol brasileiro é um dos mais vitoriosos do mundo, com cinco títulos mundiais. Os clubes "
            "investem em categorias de base e os torcedores acompanham os campeonatos com paixão. Por isso, "
            "o governo deve construir mais estádios e apoiar os times pequenos, garantindo que o esporte "
            "continue sendo motivo de orgulho nacional para as próximas gerações.",
    "curta": "O cuidado em casa é importante. As pessoas devem valorizar.",
}


def gen(essay):
    prompt = "\n\n---\n\n".join([rub, f"TEMA\n{THEME}", f"PROPOSTA\n{PROMPT_TXT}", f"TEXTOS MOTIVADORES\n{SUPPORT}",
                                  f"REDAÇÃO DO ESTUDANTE\n{essay}"])
    body = {"contents": [{"role": "user", "parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.2, "responseMimeType": "application/json", "responseSchema": SCHEMA}}
    req = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent", method="POST",
        headers={"Content-Type": "application/json", "x-goog-api-key": KEY}, data=json.dumps(body).encode())
    t0 = time.time()
    try:
        r = json.load(urllib.request.urlopen(req, timeout=90))
    except urllib.error.HTTPError as e:
        return {"http": e.code, "s": round(time.time() - t0, 1)}
    u = r.get("usageMetadata", {})
    try:
        d = json.loads(r["candidates"][0]["content"]["parts"][0]["text"])
    except Exception:
        return {"invalid": True, "tok": u, "s": round(time.time() - t0, 1)}
    sc = [d[k]["score"] for k in ("c1", "c2", "c3", "c4", "c5")]
    ok_mult = all(isinstance(s, int) and 0 <= s <= 200 and s % 40 == 0 for s in sc)
    ev_ok = all(e in essay for k in ("c1", "c2", "c3", "c4", "c5") for e in d[k].get("evidence", []) if len(e) > 8)
    return {"sc": sc, "total": sum(sc), "mult40": ok_mult, "evid_literal": ev_ok, "dev": d["possible_theme_deviation"],
            "short": d["insufficient_text"], "n_prio": len(d["priority_improvements"]),
            "empty_txt": any(not d[k]["summary"].strip() for k in ("c1", "c2", "c3", "c4", "c5")),
            "tok": {"in": u.get("promptTokenCount"), "out": u.get("candidatesTokenCount"),
                    "think": u.get("thoughtsTokenCount", 0), "total": u.get("totalTokenCount")}, "s": round(time.time() - t0, 1)}


print("modelo:", MODEL)
for name, text in ESSAYS.items():
    for i in range(REPS if name == "media" else 1):
        r = gen(text)
        tries = 1
        while r.get("http") == 503 and tries < 6:  # sobrecarga do provedor: backoff, e conta quantas tentativas
            time.sleep(20); r = gen(text); tries += 1
        r["tentativas"] = tries
        print(name, i + 1, json.dumps(r, ensure_ascii=False))
        if r.get("http") == 429:
            print("429: cota esgotada, parando"); sys.exit(2)
        time.sleep(7)
