"""Biblioteca de QA visual (Playwright + Chrome) contra o app web de DEPURAÇÃO ligado ao Supabase LOCAL.
Detecta overflows pelo console do Flutter (só aparecem em build de depuração)."""
import re, time
from playwright.sync_api import sync_playwright

BASE = "http://127.0.0.1:8098"
PASSWORD = "QaLocal#2026"
WIDTHS = {320: 640, 360: 740, 390: 844, 430: 932, 768: 1024, 1024: 768, 1440: 900, 1920: 1080}


class Session:
    def __init__(self, width=390, locale="pt-BR", dark=False):
        self.pw = sync_playwright().start()
        self.browser = self.pw.chromium.launch(channel="chrome", headless=True)
        self.ctx = self.browser.new_context(
            viewport={"width": width, "height": WIDTHS.get(width, 800)}, locale=locale,
            color_scheme="dark" if dark else "light")
        self.ctx.add_init_script("try{localStorage.setItem('flutter.intro_seen_v1','true')}catch(e){}")
        self.page = self.ctx.new_page()
        self.issues = []
        self.page.on("console", self._console)
        self.page.on("pageerror", lambda e: self.issues.append("pageerror: " + str(e)[:200]))

    def _console(self, m):
        t = m.text
        if re.search(r"overflow|RenderFlex|exception|Exception|assertion", t, re.I) and "Injecting" not in t:
            self.issues.append(t[:220].replace("\n", " "))

    def open(self, path="/", wait=5000):
        self.page.goto(BASE + path)
        self.page.wait_for_timeout(wait)
        self.enable_semantics()

    def enable_semantics(self):
        try:
            self.page.evaluate("document.querySelector('flt-semantics-placeholder')?.click()")
            self.page.wait_for_timeout(500)
        except Exception:
            pass

    def text(self):
        self.enable_semantics()
        return self.page.evaluate("document.body.innerText") + " " + " ".join(
            self.page.evaluate("[...document.querySelectorAll('flt-semantics')].map(e=>e.getAttribute('aria-label')||e.innerText||'')"))

    def click_text(self, label, timeout=8000, nth=0):
        """Clica no botão/aba/link cujo nome COMEÇA com `label` (semântica do Flutter)."""
        self.enable_semantics()
        loc = self.page.locator("flt-semantics[role='button'], flt-semantics[role='tab'], flt-semantics[role='link'], flt-semantics[role='menuitem'], flt-semantics[role='checkbox'], flt-semantics[role='radio']").filter(
            has_text=re.compile(r"^\s*" + r"\s+".join(re.escape(w) for w in label.split()), re.I)).nth(nth)
        loc.click(timeout=timeout)
        self.page.wait_for_timeout(900)

    def fill_by_label(self, label, value):
        self.enable_semantics()
        el = self.page.locator(f"input[aria-label*='{label}'], textarea[aria-label*='{label}']").first
        el.click()
        el.fill(value)

    def shot(self, path):
        self.page.screenshot(path=path)

    def close(self):
        self.browser.close()
        self.pw.stop()


def login(s, user, wait=13000):
    s.open("/login", 8000)
    s.page.locator("input").nth(0).fill(f"{user}@qa.invalid")
    s.page.locator("input").nth(1).fill(PASSWORD)
    s.page.keyboard.press("Enter")
    s.page.wait_for_timeout(wait)
    s.enable_semantics()
    return s.page.url


def labels(s):
    s.enable_semantics()
    return sorted(set(x.strip() for x in s.page.evaluate(
        "[...document.querySelectorAll('flt-semantics')].map(e=>(e.getAttribute('aria-label')||e.innerText||'').split(String.fromCharCode(10))[0])") if x.strip()))


DENY = re.compile(r"sair|excluir|apagar|reset|remover|logout|cancelar|encerrar|delete|sign out|salir|eliminar|borrar|log out|remove|clear|limpar", re.I)
TABS = {"início", "praticar", "perfil", "home", "practice", "profile", "inicio", "practicar"}


def buttons(s):
    s.enable_semantics()
    out = s.page.evaluate(r"""[...document.querySelectorAll("flt-semantics[role='button'], flt-semantics[role='link'], flt-semantics[role='tab']")]
        .filter(e=>{const r=e.getBoundingClientRect();return r.width>0&&r.height>0&&r.bottom>0&&r.top<innerHeight})
        .map(e=>(e.getAttribute('aria-label')||e.innerText||'').split(String.fromCharCode(10))[0].trim())""")
    seen, res = set(), []
    for t in out:
        k = t.lower()
        if not t or k in seen or k in TABS or DENY.search(t):
            continue
        seen.add(k)
        res.append(t)
    return res


def slug(t):
    return re.sub(r"[^a-z0-9]+", "-", t.lower())[:28].strip("-")


def crawl(s, outdir, tag, entry="/home", depth=2, per_page=8, base=(), log=print):
    """Explora a UI clicando nos botões de cada tela (profundidade limitada), com captura e coleta de issues.
    Devolve lista de (caminho, issues_novas, arquivo)."""
    import os
    os.makedirs(outdir, exist_ok=True)
    results = []

    def snap(path):
        before = len(s.issues)
        s.page.wait_for_timeout(700)
        fn = os.path.join(outdir, f"{tag}__{'__'.join(slug(p) for p in list(base) + path) or 'raiz'}.png")
        s.page.screenshot(path=fn)
        results.append(("/".join(path) or "raiz", list(s.issues[before - 0:]) if False else [], fn))

    def go_entry():
        s.open(entry, 4500)
        for b in base:
            s.click_text(b)

    def replay(path):
        go_entry()
        for p in path:
            try:
                s.click_text(p, timeout=3000)
            except Exception:
                return False
        return True

    def explore(path, d):
        labs = buttons(s)[:per_page]
        for lab in labs:
            mark = len(s.issues)
            try:
                s.click_text(lab, timeout=3000)
            except Exception:
                continue
            np = path + [lab]
            snap(np)
            new = s.issues[mark:]
            results[-1] = (results[-1][0], list(new), results[-1][2])
            if d + 1 < depth:
                explore(np, d + 1)
            # volta à tela anterior
            s.page.go_back()
            s.page.wait_for_timeout(1200)
            s.enable_semantics()
            if lab not in " ".join(labels(s)):
                if not replay(path):
                    return
    go_entry()
    snap([])
    explore([], 0)
    return results
