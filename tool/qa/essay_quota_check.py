"""Cota, concorrência e idempotência da correção de redação (produção, usuário TEMPORÁRIO apagado no fim).

NÃO chama o Gemini: exercita só as RPCs start/fail_essay_evaluation e submit_essay_draft com texto sintético.
Uso: SUPA_URL=... SUPA_PUB=<publishable> SUPA_SEC=<secret> python tool/qa/essay_quota_check.py
Cobre: submit idempotente (mesmo client_request_id), uma correção em voo por usuário sob concorrência,
teto de 3 correções/dia, retentativa da mesma redação sem novo débito, limpeza. Nunca imprime chaves.
"""
import json, os, secrets, sys, threading, urllib.error, urllib.request, uuid

URL = os.environ["SUPA_URL"].rstrip("/")
PUB, SEC = os.environ["SUPA_PUB"], os.environ["SUPA_SEC"]
fails = 0


def call(method, path, key=PUB, bearer=None, body=None):
    h = {"apikey": key, "content-type": "application/json"}
    if bearer:
        h["Authorization"] = "Bearer " + bearer
    req = urllib.request.Request(URL + path, method=method, headers=h, data=None if body is None else json.dumps(body).encode())
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


email = f"redacao-{secrets.token_hex(5)}@example.com"
pw = "Tmp-" + secrets.token_urlsafe(12)
s, u = call("POST", "/auth/v1/admin/users", SEC, SEC, {"email": email, "password": pw, "email_confirm": True})
if s != 200:
    sys.exit("não criou usuário temporário")
uid = u["id"]
try:
    s, t = call("POST", "/auth/v1/token?grant_type=password", body={"email": email, "password": pw})
    acc = t["access_token"]
    rpc = lambda name, body: call("POST", "/rest/v1/rpc/" + name, bearer=acc, body=body)
    s, themes = rpc("list_essay_themes_for_user", {})
    check("lista temas", s == 200 and themes, s)
    tid = themes[0]["id"]
    body = ("O cuidado dentro de casa é um trabalho importante e pouco reconhecido na sociedade. " * 20).strip()
    subs = []
    for i in range(4):
        rid = str(uuid.uuid4())
        s, d = rpc("save_essay_draft", {"p_theme_id": tid, "p_body": body + f" Variação sintética {i}."})
        s, r1 = rpc("submit_essay_draft", {"p_theme_id": tid, "p_client_request_id": rid})
        s2, r2 = rpc("submit_essay_draft", {"p_theme_id": tid, "p_client_request_id": rid})
        id1 = (r1[0] if isinstance(r1, list) else r1 or {}).get("id") if s == 200 else None
        id2 = (r2[0] if isinstance(r2, list) else r2 or {}).get("id") if s2 == 200 else None
        subs.append(id1)
        if i == 0:
            check("submit idempotente (mesmo client_request_id => mesma redação)", id1 and id1 == id2, f"{s}/{s2}")
    check("4 redações sintéticas criadas", all(subs), subs.count(None))

    # concorrência: duas correções ao mesmo tempo para o mesmo usuário
    res = {}
    def go(k, sid):
        res[k] = rpc("start_essay_evaluation", {"p_submission_id": sid})
    th = [threading.Thread(target=go, args=(k, subs[k])) for k in (0, 1)]
    [x.start() for x in th]; [x.join() for x in th]
    codes = sorted(res[k][0] for k in res)
    check("concorrência: só uma correção em voo (200 + 4xx)", codes[0] == 200 and codes[1] >= 400, codes)
    won = [k for k in res if res[k][0] == 200][0]
    lost = 1 - won
    lc = res[lost][1].get("code") if isinstance(res[lost][1], dict) else None
    check("a perdedora recebe erro de 'já corrigindo' (23505/P0005)", lc in ("23505", "P0005"), lc)
    s, _ = rpc("start_essay_evaluation", {"p_submission_id": subs[won]})
    check("repetir a mesma redação em voo é recusada", s >= 400, s)

    rpc("fail_essay_evaluation", {"p_submission_id": subs[won], "p_reason": "provider_unavailable"})
    s, q = rpc("get_essay_quota", {})
    used1 = (q[0] if isinstance(q, list) else q) if s == 200 else None
    s, _ = rpc("start_essay_evaluation", {"p_submission_id": subs[won]})
    check("retentar a mesma redação falha não debita de novo", s == 200, s)
    s, q2 = rpc("get_essay_quota", {})
    check("cota idêntica após retentativa", s == 200 and q2 == q, [used1, q2])
    rpc("fail_essay_evaluation", {"p_submission_id": subs[won], "p_reason": "provider_unavailable"})
    ok_codes = []
    for k in [lost] + [2, 3]:
        s, r = rpc("start_essay_evaluation", {"p_submission_id": subs[k]})
        ok_codes.append(s if s == 200 else (r or {}).get("code"))
        if s == 200:
            rpc("fail_essay_evaluation", {"p_submission_id": subs[k], "p_reason": "provider_unavailable"})
    check("2ª e 3ª correções do dia passam; a 4ª bate no teto (P0006)", ok_codes[:1] == [200] and ok_codes[-1] == "P0006", ok_codes)
finally:
    call("DELETE", f"/auth/v1/admin/users/{uid}", SEC, SEC)
    print("usuário temporário apagado")
print("\nredação/cota:", "TUDO OK" if not fails else f"{fails} falha(s)")
sys.exit(1 if fails else 0)
