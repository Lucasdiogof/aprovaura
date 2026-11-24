"""Envia os 3 modelos x 3 idiomas (usando os templates REAIS do Supabase) a destinatários AUTORIZADOS.

Uso: SUPA_URL=... SUPA_PUB=... SUPA_SEC=... python tool/qa/email_send_samples.py <dest1> [<dest2> ...]
- Não toca contas existentes: usa usuários temporários (para endereços do Gmail, o alias `+tag`;
  para os demais, uma conta temporária com o endereço exato, que NÃO pode existir antes).
- Sobe temporariamente rate_limit_email_sent e baixa smtp_max_frequency, e RESTAURA no fim.
- Apaga todas as contas temporárias. Nunca imprime chaves.
"""
import json, os, secrets, sys, time, urllib.error, urllib.request

sys.path.insert(0, os.path.dirname(__file__))
URL = os.environ["SUPA_URL"].rstrip("/")
PUB, SEC = os.environ["SUPA_PUB"], os.environ["SUPA_SEC"]
PAT = os.environ["SUPA_PAT"]
REF = URL.split("//")[1].split(".")[0]
MODELS = {"signup": {"confirmed": False}, "recovery": {"confirmed": True}, "partner": {"confirmed": False, "partner": True}}


def call(method, path, key=PUB, body=None, base=URL, auth=None):
    h = {"content-type": "application/json", "User-Agent": "curl/8"}
    if auth:
        h["Authorization"] = "Bearer " + auth
    else:
        h["apikey"] = key
        if key == SEC:
            h["Authorization"] = "Bearer " + SEC
    req = urllib.request.Request(base + path, method=method, headers=h, data=None if body is None else json.dumps(body).encode())
    try:
        r = urllib.request.urlopen(req, timeout=60)
        t = r.read().decode()
        return r.status, (json.loads(t) if t else None)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()[:200]


def cfg(patch):
    return call("PATCH", f"/v1/projects/{REF}/config/auth", base="https://api.supabase.com", auth=PAT, body=patch)


s, cur = call("GET", f"/v1/projects/{REF}/config/auth", base="https://api.supabase.com", auth=PAT)
orig = {k: cur[k] for k in ("rate_limit_email_sent", "smtp_max_frequency")}
assert cur["mailer_autoconfirm"] is True
created, results = [], []
try:
    cfg({"rate_limit_email_sent": 40, "smtp_max_frequency": 1})
    time.sleep(6)
    for dest in sys.argv[1:]:
        local, domain = dest.split("@")
        shared = None  # conta única reaproveitada quando não dá para usar alias
        for kind, spec in MODELS.items():
            for lang in ("pt", "en", "es"):
                meta = {"lang": lang, "name": "Teste", "partner": True if spec.get("partner") else None}
                if domain == "gmail.com":
                    email = f"{local}+aura{kind}{lang}{secrets.token_hex(2)}@gmail.com"
                    s, u = call("POST", "/auth/v1/admin/users", SEC, {"email": email, "password": "Tmp-" + secrets.token_urlsafe(12),
                                "email_confirm": spec["confirmed"], "user_metadata": {k: v for k, v in meta.items() if v is not None}})
                    if s == 200:
                        created.append(u["id"])
                else:
                    email = dest
                    if shared is None:
                        s, u = call("POST", "/auth/v1/admin/users", SEC, {"email": email, "password": "Tmp-" + secrets.token_urlsafe(12),
                                    "email_confirm": False, "user_metadata": {"lang": lang}})
                        if s == 200:
                            shared = u["id"]; created.append(shared)
                    else:
                        # a ordem signup -> recovery -> partner mantém a conta não confirmada até o fim
                        s, _ = call("PUT", f"/auth/v1/admin/users/{shared}", SEC, {"user_metadata": meta})
                if s != 200:
                    results.append((dest, kind, lang, f"criação/atualização falhou {s}")); continue
                if kind == "signup":
                    s, _ = call("POST", "/auth/v1/resend", PUB, {"type": "signup", "email": email})
                else:
                    s, _ = call("POST", "/auth/v1/recover", PUB, {"email": email})
                results.append((dest, kind, lang, "enviado (200)" if s == 200 else f"FALHA {s}"))
                time.sleep(2.5)
finally:
    for uid in created:
        call("DELETE", f"/auth/v1/admin/users/{uid}", SEC)
    cfg(orig)
    s, back = call("GET", f"/v1/projects/{REF}/config/auth", base="https://api.supabase.com", auth=PAT)
    print("restaurado:", {k: back[k] for k in orig}, "| contas temporárias apagadas:", len(created))
for r in results:
    print(*r, sep=" | ")
ok = sum(1 for r in results if r[3].startswith("enviado"))
print(f"{ok}/{len(results)} enviados")
