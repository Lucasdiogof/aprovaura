"""Segurança com JWTs REAIS de papéis diferentes, só no stack Supabase LOCAL (loopback).
Pré-requisito: stack local com fixtures (tool/qa/local_fixtures.py). Env: LOCAL_SERVICE_KEY, LOCAL_ANON (chave publicável local).
Cobre: isolamento entre usuários e entre professores, chamadas indevidas a RPCs, consentimento/revogação, gabarito."""
import json, os, sys, urllib.request, urllib.error, uuid
import psycopg

API = "http://127.0.0.1:56321"
ANON = os.environ["LOCAL_ANON"]
SERVICE = os.environ["LOCAL_SERVICE_KEY"]
PASSWORD = "QaLocal#2026"
db = psycopg.connect(host="127.0.0.1", port=56322, user="postgres", password="postgres", dbname="postgres", autocommit=True)
passed, failed = 0, []


def http(method, path, token=None, body=None, key=None):
    h = {"apikey": key or ANON, "Authorization": "Bearer " + (token or key or ANON), "Content-Type": "application/json"}
    req = urllib.request.Request(API + path, method=method, headers=h, data=json.dumps(body).encode() if body is not None else None)
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            t = r.read().decode()
            return r.status, (json.loads(t) if t else None)
    except urllib.error.HTTPError as e:
        t = e.read().decode()
        try:
            return e.code, json.loads(t)
        except Exception:
            return e.code, t


def login(user):
    st, j = http("POST", "/auth/v1/token?grant_type=password", body={"email": f"{user}@qa.invalid", "password": PASSWORD})
    assert st == 200, (user, st, j)
    return j["access_token"]


def ok(name, cond, detail=""):
    global passed
    if cond:
        passed += 1
    else:
        failed.append(f"{name} {str(detail)[:140]}")


def rpc(token, fn, **body):
    return http("POST", f"/rest/v1/rpc/{fn}", token, body)


def denied(st, body):
    return st >= 400 or body in ([], None, {})


uid = lambda tag: db.execute("select id from auth.users where email=%s", (f"{tag}@qa.invalid",)).fetchone()[0]

# --- fixtures extras: 2º professor com aluno próprio e aluno adulto com consentimento
pid1 = db.execute("select id from partners where display_name='Prof. Ana Souza'").fetchone()[0]
t2 = str(uuid.uuid4())
st, j = http("POST", "/auth/v1/admin/users", key=SERVICE, body={"email": "prof2@qa.invalid", "password": PASSWORD, "email_confirm": True, "user_metadata": {"name": "Prof Dois"}}) if db.execute("select count(*) from auth.users where email='prof2@qa.invalid'").fetchone()[0] == 0 else (200, None)
st, j = http("POST", "/auth/v1/admin/users", key=SERVICE, body={"email": "aluno4@qa.invalid", "password": PASSWORD, "email_confirm": True, "user_metadata": {"name": "Aluno Quatro"}}) if db.execute("select count(*) from auth.users where email='aluno4@qa.invalid'").fetchone()[0] == 0 else (200, None)
u_t2, u_s4 = uid("prof2"), uid("aluno4")
db.execute("insert into email_verifications (user_id, method, verified_at) values (%s,'otp',now()),(%s,'otp',now()) on conflict do nothing", (u_t2, u_s4))
if db.execute("select count(*) from partners where user_id=%s", (u_t2,)).fetchone()[0] == 0:
    pid2 = db.execute("""insert into partners (user_id, display_name, referral_code, commission_bps, started_at, pix_key_type, pix_key)
        values (%s,'Prof Dois',%s,5000,'2026-01-01','random','pix-dois-0001') returning id""", (u_t2, ("Q" + uuid.uuid4().hex[:7]).upper())).fetchone()[0]
    db.execute("insert into partner_links (student_id, partner_id, source, linked_at) values (%s,%s,'admin_manual','2026-02-01')", (u_s4, pid2))
pid2 = db.execute("select id from partners where user_id=%s", (u_t2,)).fetchone()[0]
db.execute("insert into entitlements (user_id, source, state, plan, starts_at, ends_at, external_ref) select %s,'web','active','monthly',now(), now()+interval '30 days','qa-s4' where not exists (select 1 from entitlements where external_ref='qa-s4')", (u_s4,))

tk = {u: login(u) for u in ("aluno1", "aluno4", "prof", "prof2", "admin", "semplano")}
s1, s4 = str(uid("aluno1")), str(u_s4)

# 1. Tabelas sensíveis: usuário comum, aluno e professor não leem dados de terceiros nem financeiro
for who in ("semplano", "aluno1", "prof"):
    for t in ("payments", "commission_ledger", "payouts", "app_admins", "financial_report_imports", "audit_log", "commercial_config",
              "email_verifications", "user_age_declarations", "study_sharing_consents", "legal_acceptances", "entitlements", "partner_links"):
        st, b = http("GET", f"/rest/v1/{t}?select=*&limit=1", tk[who])
        ok(f"1 {who} não lê {t}", denied(st, b), (st, str(b)[:60]))

# 2. RPCs administrativas e de serviço: só admin
for who in ("semplano", "aluno1", "prof"):
    for fn, body in (("admin_dashboard", {"p_from": "2026-01-01", "p_to": "2026-12-31"}), ("admin_finance_dashboard", {"p_from": "2026-01-01", "p_to": "2026-12-31"}),
                     ("admin_list_users", {}), ("admin_list_payments", {}), ("admin_get_config", {}), ("admin_list_audit", {}),
                     ("admin_register_payout", {"p_partner": str(pid1), "p_amount_cents": 1, "p_competence": "2026-12-01"}),
                     ("admin_get_partner_pix", {"p_partner": str(pid1)}),
                     ("admin_grant_courtesy", {"p_user": s1, "p_ends_at": "2030-01-01T00:00:00Z"}),
                     ("admin_set_admin", {"p_user": s1, "p_enable": True}),
                     ("record_confirmed_payment", {"p_provider": "mercadopago", "p_external_id": "x", "p_user_id": s1, "p_plan": "monthly", "p_gross_cents": 100, "p_fee_cents": 0, "p_tax_cents": 0, "p_paid_at": "2026-12-01T00:00:00Z"})):
        st, b = rpc(tk[who], fn, **body)
        ok(f"2 {who} não chama {fn}", st >= 400, (st, str(b)[:60]))
ok("2 ninguém virou admin", db.execute("select count(*) from app_admins where user_id=%s", (s1,)).fetchone()[0] == 0)
ok("2 nenhuma cortesia concedida", db.execute("select count(*) from entitlements where user_id=%s and source='courtesy'", (s1,)).fetchone()[0] == 0)

# 3. RPCs de professor: aluno e usuário comum não
for who in ("semplano", "aluno1"):
    for fn in ("partner_dashboard", "partner_list_students", "partner_finance", "partner_my_summary"):
        st, b = rpc(tk[who], fn, **({"p_from": "2026-01-01", "p_to": "2026-12-31"} if fn == "partner_dashboard" else {}))
        ok(f"3 {who} não chama {fn}", st >= 400, (st, str(b)[:60]))

# 4. Isolamento entre professores
st, b = rpc(tk["prof2"], "partner_student_detail", p_student=s1)
ok("4 prof2 não vê aluno do prof1", st >= 400, (st, str(b)[:60]))
st, b = rpc(tk["prof"], "partner_student_detail", p_student=s4)
ok("4 prof1 não vê aluno do prof2", st >= 400, (st, str(b)[:60]))
st, b = rpc(tk["prof"], "partner_list_students")
ids = json.dumps(b)
ok("4 lista do prof1 não contém aluno do prof2", s4 not in ids and "Aluno Quatro" not in ids, ids[:100])
st, b = rpc(tk["prof2"], "partner_finance")
ok("4 financeiro do prof2 não mostra comissão do prof1", st < 400 and "QA-P1" not in json.dumps(b), (st, str(b)[:80]))
st, b = rpc(tk["prof"], "partner_finance")
ok("4 prof1 acessa o próprio financeiro", st < 400, (st, str(b)[:80]))

# 5. Consentimento: menor/sem faixa nunca compartilha; adulto compartilha e revoga
st, b = rpc(tk["aluno1"], "set_study_sharing", p_granted=True, p_version="2026-12-01")
ok("5 sem faixa adulta o compartilhamento é recusado (P0051)", st >= 400, (st, str(b)[:60]))
st, b = rpc(tk["aluno1"], "set_my_age_band", p_band="13_15")
st, b = rpc(tk["aluno1"], "set_study_sharing", p_granted=True, p_version="2026-12-01")
ok("5 menor de 18 também é recusado", st >= 400, (st, str(b)[:60]))
st, b = rpc(tk["prof"], "partner_student_detail", p_student=s1)
ok("5 prof vê o aluno vinculado, mas sem estatísticas (não compartilhadas)", st < 400 and b.get("stats") is None, (st, str(b)[:80]))
st, b = rpc(tk["aluno1"], "set_my_age_band", p_band="adult")
st, b = rpc(tk["aluno1"], "set_study_sharing", p_granted=True, p_version="2026-12-01")
ok("5 adulto consegue compartilhar", st < 400, (st, str(b)[:60]))
st, b = rpc(tk["prof"], "partner_student_detail", p_student=s1)
ok("5 com consentimento o professor vê estatísticas", st < 400 and b.get("stats") is not None, (st, str(b)[:80]))
st, b = rpc(tk["prof2"], "partner_student_detail", p_student=s1)
ok("5 consentimento não abre acesso a OUTRO professor", st >= 400, (st, str(b)[:60]))
st, b = rpc(tk["aluno1"], "set_study_sharing", p_granted=False, p_version="2026-12-01")
st, b = rpc(tk["prof"], "partner_student_detail", p_student=s1)
ok("5 revogação encerra a visibilidade imediatamente", st < 400 and b.get("stats") is None, (st, str(b)[:80]))
st, b = rpc(tk["aluno1"], "set_my_age_band", p_band="13_15")
db.execute("insert into study_sharing_consents (user_id, granted, consent_version) values (%s,true,'x')", (s1,))   # simula consentimento antigo gravado
st, b = rpc(tk["prof"], "partner_student_detail", p_student=s1)
ok("5 declarar-se menor encerra o compartilhamento mesmo com consentimento antigo", st < 400 and b.get("stats") is None, (st, str(b)[:80]))

# 6. Perfil/dados de outro usuário
st, b = http("GET", f"/rest/v1/profiles?id=eq.{s4}&select=*", tk["aluno1"])
ok("6 aluno não lê perfil de outro aluno", denied(st, b), (st, str(b)[:80]))
st, b = http("PATCH", f"/rest/v1/profiles?id=eq.{s4}", tk["aluno1"], {"name": "hack"})
ok("6 aluno não altera perfil alheio", db.execute("select count(*) from profiles where id=%s and name='hack'", (s4,)).fetchone()[0] == 0, (st, b))
st, b = http("GET", f"/rest/v1/user_question_progress?user_id=eq.{s4}&select=*", tk["aluno1"])
ok("6 aluno não lê progresso alheio", denied(st, b), (st, str(b)[:80]))

# 7. Gabarito (documentado): usuário autenticado lê correct_index; anônimo?
st, b = http("GET", "/rest/v1/questions?select=id,correct_index&limit=1", tk["aluno1"])
print("INFO gabarito exposto a autenticado (esperado, necessário ao offline):", st, "correct_index" in json.dumps(b))
st, b = http("GET", "/rest/v1/questions?select=id,correct_index&limit=1")
print("INFO gabarito exposto a anônimo:", st, "correct_index" in json.dumps(b))

# 8. Auto-promoção / escrita direta em tabelas protegidas
for t, body in (("app_admins", {"user_id": s1}), ("entitlements", {"user_id": s1, "source": "courtesy", "state": "active"}),
                ("partners", {"user_id": s1, "display_name": "x"}), ("commercial_config", {"enforcement_enabled": False})):
    st, b = http("POST", f"/rest/v1/{t}", tk["aluno1"], body)
    ok(f"8 aluno não escreve em {t}", st >= 400, (st, str(b)[:60]))
st, b = http("PATCH", "/rest/v1/commercial_config?id=eq.true", tk["aluno1"], {"enforcement_enabled": False})
ok("8 aluno não altera commercial_config", db.execute("select enforcement_enabled from commercial_config").fetchone()[0] is True)

print(f"REST authenticated tests: {passed} passed, {len(failed)} failed")
for f in failed:
    print("  FAIL:", f)
sys.exit(1 if failed else 0)
