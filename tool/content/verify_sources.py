"""Consulta cada fonte de curriculum/sources.json (GET leve) e grava state/sources_check.json (status HTTP + data).
Não baixa nem salva conteúdo; só registra se a URL responde. Uso: python tool/content/verify_sources.py"""
import json, os, datetime, urllib.request, urllib.error, ssl
D = os.path.dirname(os.path.abspath(__file__))
src = json.load(open(os.path.join(D, "curriculum", "sources.json"), encoding="utf-8"))["sources"]
res = {}
ctx = ssl.create_default_context()
for s in src:
    st = None
    try:
        req = urllib.request.Request(s["url"], headers={"User-Agent": "Mozilla/5.0 (aura-content-source-check)"})
        with urllib.request.urlopen(req, timeout=25, context=ctx) as r:
            st = r.status; final = r.geturl()
    except urllib.error.HTTPError as e: st = e.code; final = s["url"]
    except Exception as e: st = "erro:" + type(e).__name__; final = s["url"]
    res[s["id"]] = dict(status=st, consultado_em=datetime.date.today().isoformat(), url_final=final)
    print(s["id"], st)
json.dump(res, open(os.path.join(D, "state", "sources_check.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
