"""Valida os fluxos de e-mail do Auth em produção SEM tocar usuários reais.

Usa só endereços `delivered+<tag>@resend.dev` (sumidouro de teste da Resend: aceita, não entrega a
ninguém) em contas temporárias criadas e APAGADAS aqui. Confere que o GoTrue aceita o envio pelo
SMTP configurado (200) e consulta o log de Auth do Supabase por erros de SMTP.
Uso: SUPA_URL=... SUPA_PUB=<publishable> SUPA_SEC=<secret> python tool/qa/email_flow_check.py
Limite: não lê o corpo entregue (a chave Resend é só de envio); o HTML é validado por
build_templates.py + leitura da configuração. Nunca imprime chaves.
"""
import json, os, secrets, sys, time, urllib.error, urllib.request

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
            return e.code, t[:200]


def check(label, ok, extra=""):
    global fails
    fails += 0 if ok else 1
    print(("OK   " if ok else "FALHA ") + label + (f" ({extra})" if extra else ""))


made = []


def user(tag, meta, confirmed):
    email = f"delivered+{tag}{secrets.token_hex(3)}@resend.dev"
    s, u = call("POST", "/auth/v1/admin/users", SEC, SEC,
                {"email": email, "password": "Tmp-" + secrets.token_urlsafe(10), "email_confirm": confirmed, "user_metadata": meta})
    if s == 200:
        made.append(u["id"])
    return email, s


try:
    for lang in ("pt", "en", "es"):
        email, s = user("rec" + lang, {"lang": lang}, True)
        s, r = call("POST", "/auth/v1/recover", body={"email": email})
        check(f"recuperação de senha ({lang}) aceita pelo SMTP", s == 200, s)
        time.sleep(1.2)  # limite de 10 req/s da Resend
    email, s = user("old", {}, True)  # usuário antigo, sem lang (cai em português)
    s, r = call("POST", "/auth/v1/recover", body={"email": email})
    check("recuperação sem lang (usuário antigo) aceita", s == 200, s)
    time.sleep(1.2)
    email, s = user("prof", {"lang": "pt", "partner": True, "name": "Teste"}, False)
    s, r = call("POST", "/auth/v1/recover", body={"email": email})
    check("definição de senha do professor (partner) aceita", s == 200, s)
    time.sleep(1.2)
    email, s = user("conf", {"lang": "en"}, False)
    s, r = call("POST", "/auth/v1/resend", body={"type": "signup", "email": email})
    check("código de confirmação de cadastro aceito", s == 200, s)
    time.sleep(3)
finally:
    for uid in made:
        call("DELETE", f"/auth/v1/admin/users/{uid}", SEC, SEC)
    print(f"{len(made)} usuário(s) de teste apagado(s)")
print("\ne-mail:", "TUDO OK" if not fails else f"{fails} falha(s)")
sys.exit(1 if fails else 0)
