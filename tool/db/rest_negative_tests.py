"""Testes negativos de segurança na API pública (PostgREST) com a chave ANÔNIMA.
# app_pre_request fica de fora: é o gancho do gate, concedido a anon de propósito, retorna void e não tem efeito.
Somente leitura/recusa: nada é criado. Exige env SUPA_URL e SUPA_ANON (chave publicável)."""
import json, os, sys, urllib.request, urllib.error

URL, KEY = os.environ["SUPA_URL"].rstrip("/"), os.environ["SUPA_ANON"]
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}", "Content-Type": "application/json"}
failed, passed = [], 0


def call(method, path, body=None):
    req = urllib.request.Request(URL + path, method=method, headers=H, data=json.dumps(body).encode() if body is not None else None)
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def deny(name, method, path, body=None):
    global passed
    st, txt = call(method, path, body)
    # negado = erro HTTP, ou 200 com lista vazia (RLS filtrando)
    leaked = st == 200 and txt.strip() not in ("[]", "", "null")
    if leaked or st in (201, 204):
        failed.append(f"{name}: HTTP {st} {txt[:80]}")
    else:
        passed += 1


for t in ("payments", "commission_ledger", "payouts", "partners", "partner_links", "app_admins", "legal_acceptances",
          "email_verifications", "financial_report_imports", "financial_report_lines", "user_age_declarations",
          "entitlements", "commercial_config", "audit_log", "study_sharing_consents", "essay_submissions", "profiles"):
    deny(f"anon lê {t}", "GET", f"/rest/v1/{t}?select=*&limit=1")
for t in ("payments", "commission_ledger", "app_admins", "commercial_config", "legal_documents"):
    deny(f"anon escreve em {t}", "POST", f"/rest/v1/{t}", {})
for fn, body in (("admin_finance_dashboard", {"p_from": "2026-01-01", "p_to": "2026-12-31"}),
                 ("admin_register_payout", {}), ("admin_import_report", {}), ("admin_apply_report", {}),
                 ("record_confirmed_payment", {}), ("record_payment_refund", {}), ("publish_legal_version", {}),
                 ("get_my_access", {}), ("refresh_broken_streak", {"p_user_id": "00000000-0000-4000-8000-000000000001", "p_today": "2099-01-01"}), ("get_legal_status", {}), ("set_my_age_band", {"p_band": "adult"}),
                 ("app_lock_tables", {}), ("app_grant_functions", {})):
    deny(f"anon chama {fn}", "POST", f"/rest/v1/rpc/{fn}", body)
print(f"REST negative tests: {passed} passed, {len(failed)} failed")
for f in failed:
    print("  FAIL:", f)
sys.exit(1 if failed else 0)
