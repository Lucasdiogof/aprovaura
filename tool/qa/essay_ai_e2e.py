"""E2E da correção multi-provedor com usuário de TESTE e redações SINTÉTICAS (nada de aluno real).
Entra como o aluno de teste (credenciais do cofre global, nunca impressas), cria rascunho, envia, chama a função
(FUNC_URL, padrão: servidor local contra o banco real) e lê o resultado pela RPC do próprio app.
Uso: python tool/qa/essay_ai_e2e.py <caso>   (casos: saude_mediana|agua_forte|dados_fuga|dados_manipulacao)"""
import json, os, subprocess, sys, time, urllib.request, uuid

URL = "https://cesuqfgrtcitatxvokez.supabase.co"
FUNC = os.environ.get("FUNC_URL", "http://localhost:8000")
V = os.path.expanduser("~/.config/claude-secrets/vault.ps1")


def vault(svc, purpose):
    return subprocess.check_output(["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", V, "get", "--service", svc,
                                    "--project", "aprovaura", "--environment", "production", "--purpose", purpose]).decode().strip()


ANON = vault("supabase", "publishable-key")
CASES = {k: tuple(v) for k, v in json.load(open(os.path.join(os.path.dirname(__file__), "essay_ai_synthetic.json"), encoding="utf-8")).items()}  # caso -> (trecho do tema, redação sintética)


def req(method, path, body=None, token=None, base=URL, extra=None):
    h = {"apikey": ANON, "Content-Type": "application/json", "Authorization": "Bearer " + (token or ANON), **(extra or {})}
    r = urllib.request.Request(base + path, data=json.dumps(body).encode() if body is not None else None, method=method, headers=h)
    try:
        resp = urllib.request.urlopen(r, timeout=150)
        t = resp.read().decode()
        return resp.status, (json.loads(t) if t else None)
    except urllib.error.HTTPError as e:
        t = e.read().decode()
        try:
            return e.code, json.loads(t)
        except Exception:
            return e.code, t[:300]


def main():
    L = os.environ.get("QA_USER", "aluno")
    case = sys.argv[1]
    s, tok = req("POST", "/auth/v1/token?grant_type=password",
                 {"email": vault("supabase-auth-test", f"qa-redacao-{L}-email"), "password": vault("supabase-auth-test", f"qa-redacao-{L}-password")})
    jwt = tok["access_token"]
    s, themes = req("POST", "/rest/v1/rpc/list_essay_themes_for_user", {}, jwt)
    frag, body = CASES[case]
    theme = next(t for t in themes if frag.lower() in t["title"].lower())
    print("tema:", theme["title"][:70])
    print("rascunho:", req("POST", "/rest/v1/rpc/save_essay_draft", {"p_theme_id": theme["id"], "p_body": body}, jwt)[0])
    s, sub = req("POST", "/rest/v1/rpc/submit_essay_draft", {"p_theme_id": theme["id"], "p_client_request_id": str(uuid.uuid4())}, jwt)
    print("envio:", s)
    sid = sub[0]["id"]
    t0 = time.time()
    s, r = req("POST", "/functions/v1/evaluate-essay" if FUNC.startswith("https") else "/", {"submission_id": sid, "locale": "pt-BR"}, jwt, base=FUNC)
    print("função:", s, r, f"{time.time()-t0:.1f}s")
    s, d = req("POST", "/rest/v1/rpc/get_essay_submission", {"p_submission_id": sid}, jwt)
    row = d[0] if isinstance(d, list) else d
    sys.stdout.reconfigure(encoding="utf-8"); print(json.dumps({k: (v if k not in ("body",) else "...") for k, v in row.items()}, ensure_ascii=False)[:2500])


main()
