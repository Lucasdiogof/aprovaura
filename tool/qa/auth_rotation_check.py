"""Checagem pós-rotação de chaves JWT (produção, usuário TEMPORÁRIO apagado no fim).

Uso: SUPA_URL=... SUPA_PUB=<sb_publishable_> SUPA_SEC=<sb_secret_> python tool/qa/auth_rotation_check.py
Cobre: criar usuário, login por senha, algoritmo/kid do token, renovação por refresh token, RPC
autenticada, Edge Functions com usuário real (auth passa => não-401) e delete-account (apaga o
usuário de teste). Nunca imprime chaves nem tokens.
"""
import base64, json, os, secrets, sys, urllib.error, urllib.request

URL = os.environ["SUPA_URL"].rstrip("/")
PUB, SEC = os.environ["SUPA_PUB"], os.environ["SUPA_SEC"]
fails = 0


def call(method, path, key=PUB, bearer=None, body=None):
    h = {"apikey": key, "content-type": "application/json"}
    if bearer:
        h["Authorization"] = "Bearer " + bearer
    req = urllib.request.Request(URL + path, method=method, headers=h,
                                 data=None if body is None else json.dumps(body).encode())
    try:
        r = urllib.request.urlopen(req, timeout=60)
        t = r.read().decode()
        return r.status, (json.loads(t) if t else None)
    except urllib.error.HTTPError as e:
        t = e.read().decode()
        try:
            return e.code, json.loads(t)
        except Exception:
            return e.code, None


def check(label, ok, extra=""):
    global fails
    fails += 0 if ok else 1
    print(("OK   " if ok else "FALHA ") + label + (f" ({extra})" if extra else ""))


def header(token):
    p = token.split(".")[0]
    return json.loads(base64.urlsafe_b64decode(p + "=" * (-len(p) % 4)))


email = f"rotacao-{secrets.token_hex(5)}@example.com"
pw = "Tmp-" + secrets.token_urlsafe(12)
s, u = call("POST", "/auth/v1/admin/users", SEC, SEC, {"email": email, "password": pw, "email_confirm": True})
check("criar usuário temporário (chave secret)", s == 200 and u and u.get("id"), s)
if not (s == 200 and u):
    sys.exit(1)
uid = u["id"]
try:
    s, t = call("POST", "/auth/v1/token?grant_type=password", body={"email": email, "password": pw})
    check("login por senha", s == 200 and t and t.get("access_token"), s)
    acc, ref = t["access_token"], t["refresh_token"]
    h = header(acc)
    print(f"INFO alg={h.get('alg')} kid={'sim' if h.get('kid') else 'não'}")
    s, t2 = call("POST", "/auth/v1/token?grant_type=refresh_token", body={"refresh_token": ref})
    check("renovação de sessão (refresh token)", s == 200 and t2 and t2.get("access_token"), s)
    acc = t2["access_token"] if s == 200 else acc
    s, _ = call("GET", "/auth/v1/user", bearer=acc)
    check("GET /auth/v1/user com token novo", s == 200, s)
    s, a = call("POST", "/rest/v1/rpc/get_my_access", bearer=acc, body={})
    check("RPC autenticada get_my_access", s == 200 and isinstance(a, dict), s)
    s, _ = call("POST", "/rest/v1/rpc/admin_payments_status", bearer=acc, body={})
    check("RPC admin negada a usuário comum", s in (401, 403), s)
    s, _ = call("POST", "/functions/v1/evaluate-essay", bearer=acc, body={})
    check("evaluate-essay: autenticação passa (400 corpo inválido, não 401)", s == 400, s)
    s, r = call("POST", "/functions/v1/mp-checkout", bearer=acc, body={"action": "status"})
    check("mp-checkout status autenticado", s == 200, s)
    s, _ = call("POST", "/functions/v1/admin-provision-partner", bearer=acc, body={})
    check("admin-provision-partner nega usuário comum", s == 403, s)
    s, _ = call("POST", "/functions/v1/delete-account", bearer=acc, body={})
    check("delete-account com usuário real", s == 200, s)
    s, _ = call("POST", "/auth/v1/token?grant_type=password", body={"email": email, "password": pw})
    check("usuário apagado não entra mais", s in (400, 401), s)
finally:
    call("DELETE", f"/auth/v1/admin/users/{uid}", SEC, SEC)  # idempotente: garante limpeza
print(f"\nrotação: {'TUDO OK' if not fails else str(fails) + ' falha(s)'}")
sys.exit(1 if fails else 0)
