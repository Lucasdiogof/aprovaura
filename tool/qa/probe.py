import sys
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    b = p.chromium.launch(channel="chrome", headless=True)
    pg = b.new_page(viewport={"width": 390, "height": 844})
    logs = []
    pg.on("console", lambda m: logs.append(m.type + ": " + m.text[:150]))
    pg.goto("http://127.0.0.1:8099/")
    pg.wait_for_timeout(6000)
    pg.screenshot(path=sys.argv[1])
    print(pg.evaluate("document.querySelectorAll('flt-semantics-placeholder').length"), pg.title())
    print("\n".join(logs[:8]))
    b.close()
