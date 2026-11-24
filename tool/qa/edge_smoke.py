"""Smoke test seguro das Edge Functions publicadas: só chamadas SEM credencial de usuário e sem efeito.
Prova que cada função recusa (falha fechada) enquanto os segredos/provedores não estão configurados.
Uso: SUPA_URL=https://<ref>.supabase.co SUPA_ANON=<chave publicável/anon> python tool/qa/edge_smoke.py
Nunca chama com sessão real, nunca envia pagamento, nunca grava dados."""
import json, os, sys, urllib.request, urllib.error

URL, ANON = os.environ["SUPA_URL"].rstrip("/"), os.environ["SUPA_ANON"]
passed, failed = 0, []


def call(fn, method="POST", body=None, headers=None, bearer=None):
    h = {"apikey": ANON, "content-type": "application/json", **(headers or {})}
    if bearer is not None:
        h["Authorization"] = "Bearer " + bearer
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(f"{URL}/functions/v1/{fn}", data=data, method=method, headers=h)
    try:
        r = urllib.request.urlopen(req, timeout=40)
        return r.status
    except urllib.error.HTTPError as e:
        return e.code


def expect(name, got, want):
    global passed
    ok = got in want
    print(("OK  " if ok else "FAIL"), f"{name}: HTTP {got} (esperado {sorted(want)})")
    if ok:
        passed += 1
    else:
        failed.append(name)


# funções com verify_jwt=true: sem JWT válido de usuário o gateway/função recusa
for fn in ("delete-account", "evaluate-essay", "mp-checkout", "admin-provision-partner"):
    expect(f"{fn} sem Authorization", call(fn, body={}), {401})
    # a chave pública é um JWT válido para o gateway, mas não é usuário: a função recusa (400/401/403), nunca 2xx
    expect(f"{fn} com chave pública (não é usuário)", call(fn, body={}, bearer=ANON), {400, 401, 403})

# webhooks (verify_jwt=false): a autenticidade vem de assinatura/segredo que ainda não existe => recusam
expect("mp-webhook GET", call("mp-webhook", "GET"), {405})
expect("mp-webhook sem assinatura", call("mp-webhook", body={"type": "payment", "data": {"id": "1"}}), {401})
expect("mp-webhook assinatura inventada", call("mp-webhook", body={"type": "payment", "data": {"id": "1"}},
       headers={"x-signature": "ts=1,v1=00", "x-request-id": "x"}), {401})
expect("payments-reconcile sem segredo", call("payments-reconcile", body={}), {401})
expect("payments-reconcile segredo errado", call("payments-reconcile", body={}, headers={"x-cron-secret": "errado"}), {401})
expect("payments-google RTDN sem OIDC", call("payments-google", body={"message": {"data": "e30=", "messageId": "1"}}), {401})
expect("payments-google compra sem usuário", call("payments-google", body={"purchaseToken": "x"}), {401})
expect("payments-google corpo vazio", call("payments-google", body={}), {400})
expect("payments-apple compra sem usuário", call("payments-apple", body={"signedTransaction": "x.y.z"}), {401})
expect("payments-apple JWS inválido", call("payments-apple", body={"signedPayload": "x.y.z"}), {400})
expect("payments-apple corpo vazio", call("payments-apple", body={}), {400})

print(f"\nEdge smoke: {passed} passaram, {len(failed)} falharam")
sys.exit(1 if failed else 0)
