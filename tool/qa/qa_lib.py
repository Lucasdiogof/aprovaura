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

    def click_text(self, label, exact=False, timeout=4000):
        self.enable_semantics()
        loc = self.page.get_by_text(label, exact=exact).first if False else self.page.locator(f"flt-semantics:has-text('{label}')").first
        loc.click(timeout=timeout)
        self.page.wait_for_timeout(800)

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
