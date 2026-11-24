"""Matriz de QA visual: percorre as telas (roteiros por clique/URL) para uma combinação usuário x largura x idioma x tema.
Uso: python tool/qa/run_matrix.py <usuario> <largura> <pt-BR|en|es> <light|dark> <pasta> [grupo]
grupos: pub (telas públicas) | app (estudo) | conta (perfil/assinatura) | portal-admin | portal-prof | paywall
Imprime JSON com telas, issues (overflow/exceções do console de depuração) e arquivos de captura."""
import json, os, sys, re
sys.path.insert(0, os.path.dirname(__file__))
from qa_lib import *

user, width, locale, theme, outdir = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4], sys.argv[5]
group = sys.argv[6] if len(sys.argv) > 6 else "app"
os.makedirs(outdir, exist_ok=True)
tag = f"{group}-{user}-{width}-{locale}-{theme}"
results = []


def snap(s, name, mark):
    s.page.wait_for_timeout(900)
    fn = os.path.join(outdir, f"{tag}__{name}.png")
    s.page.screenshot(path=fn)
    results.append({"tela": name, "issues": list(s.issues[mark:]), "arquivo": fn, "url": s.page.url})


def step(s, name, fn):
    mark = len(s.issues)
    try:
        fn()
    except Exception as e:  # clique/rota não encontrados: registra como falha de roteiro, não de UI
        s.issues.append("ROTEIRO: " + str(e).splitlines()[0][:120])
    snap(s, name, mark)


def label_exists(s, prefix):
    return any(l.lower().startswith(prefix.lower()) for l in labels(s))


def first_content_button(s):
    skip = {"todos", "fácil", "médio", "difícil", "facil", "medio", "dificil", "easy", "medium", "hard", "all", "todas", "fácil ", "difícil "}
    for b in buttons(s):
        if b.lower() not in skip and "voltar" not in b.lower() and "back" not in b.lower():
            return b
    return None


def goto(s, path, wait=5500):
    s.page.goto(BASE + path)
    s.page.wait_for_timeout(wait)
    s.enable_semantics()


intro_flag = group != "pub-intro"
s = Session(width, locale, theme == "dark")

if group == "pub":
    step_open = lambda p: (lambda: goto(s, p, 7000))
    s.page.goto(BASE + "/login"); s.page.wait_for_timeout(7000); s.enable_semantics()
    step(s, "login", lambda: None)
    step(s, "cadastro", lambda: goto(s, "/cadastro", 7000))
    goto(s, "/login", 7000)
    step(s, "recuperar-senha", lambda: s.click_text({"pt-BR": "Esqueci", "en": "Forgot", "es": "Olvid"}[locale]))
    s.ctx.add_init_script("try{localStorage.removeItem('flutter.intro_seen_v1')}catch(e){}")
    step(s, "apresentacao", lambda: goto(s, "/apresentacao", 7000))
elif group == "app":
    login(s, user)
    step(s, "home", lambda: None)
    step(s, "praticar", lambda: s.click_text("Praticar" if locale != "en" else "Practice"))
    step(s, "materia-geografia", lambda: s.click_text("Geografia" if locale == "pt-BR" else ("Geography" if locale == "en" else "Geograf")))
    s.page.wait_for_timeout(1500)
    step(s, "trilha-no", lambda: s.click_text(first_content_button(s)))
    s.page.wait_for_timeout(1500)
    step(s, "trilha-no-2", lambda: s.click_text(first_content_button(s)))
    for _ in range(3):
        if "?" in " ".join(labels(s)) and any(l.lower().startswith(("alternativa", "option")) for l in labels(s)):
            break
        b = first_content_button(s)
        if not b:
            break
        try:
            s.click_text(b); s.page.wait_for_timeout(1500)
        except Exception:
            break
    step(s, "questao", lambda: None)
    # responder: clica na primeira alternativa
    step(s, "questao-proxima", lambda: s.click_text({"pt-BR": "Próxima", "en": "Next", "es": "Siguiente"}[locale]))
    goto(s, "/home", 6500)
    tabs_in = {"pt-BR": ("Início", "Prática rápida", "Montar simulado", "Revisar erros", "Favoritos"),
               "en": ("Home", "Quick practice", "Build mock exam", "Review mistakes", "Favorites"),
               "es": ("Inicio", "Práctica rápida", "Armar simulacro", "Revisar errores", "Favoritos")}[locale]
    for nome, lab in (("pratica-rapida", tabs_in[1]), ("simulado", tabs_in[2]), ("revisar-erros", tabs_in[3]), ("favoritos", tabs_in[4])):
        step(s, nome, lambda lab=lab: s.click_text(lab))
        goto(s, "/home", 6000)
elif group == "conta":
    login(s, user)
    step(s, "perfil", lambda: s.click_text({"pt-BR": "Perfil", "en": "Profile", "es": "Perfil"}[locale]))
    for nome, lab in (("configuracoes", {"pt-BR": "Configurações", "en": "Settings", "es": "Configuración"}[locale]),
                      ("minha-assinatura", {"pt-BR": "Minha assinatura", "en": "My subscription", "es": "Mi suscripción"}[locale]),
                      ("privacidade-termos", {"pt-BR": "Privacidade e termos", "en": "Privacy and terms", "es": "Privacidad y términos"}[locale]),
                      ("minha-conta", {"pt-BR": "Minha conta", "en": "My account", "es": "Mi cuenta"}[locale])):
        step(s, nome, lambda lab=lab: s.click_text(lab))
        goto(s, "/home", 5500)
        s.click_text({"pt-BR": "Perfil", "en": "Profile", "es": "Perfil"}[locale])
elif group == "paywall":
    login(s, user)
    step(s, "paywall", lambda: None)
    step(s, "paywall-minha-assinatura", lambda: goto(s, "/minha-assinatura", 6000))
    step(s, "paywall-privacidade", lambda: goto(s, "/privacidade", 6000))
    step(s, "paywall-deep-link-home", lambda: goto(s, "/home", 6000))
elif group in ("portal-admin", "portal-prof"):
    login(s, user)
    paths = ["/partners", "/partners/users", "/partners/teachers", "/partners/requests", "/partners/subscriptions",
             "/partners/finance", "/partners/integrations", "/partners/audit", "/partners/settings"] if group == "portal-admin" else \
            ["/partners", "/partners/students", "/partners/stats", "/partners/finance", "/partners/referrals", "/partners/me"]
    for p in paths:
        step(s, p.strip("/").replace("/", "-") or "portal", lambda p=p: goto(s, p, 6500))

print(json.dumps({"tag": tag, "telas": len(results), "com_issue": sum(1 for r in results if r["issues"]),
                  "resultados": [{"tela": r["tela"], "url": r["url"].replace(BASE, ""), "issues": r["issues"][:3]} for r in results]},
                 ensure_ascii=False))
s.close()
