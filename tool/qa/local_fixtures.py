"""Cenários de demonstração para QA visual, SOMENTE em Supabase local descartável (loopback).

Pré-requisitos: stack local no ar (API 127.0.0.1:56321, banco 127.0.0.1:56322) com a base legada, as migrações
comerciais e perguntas de demonstração. Variáveis: LOCAL_SERVICE_KEY (a chave de serviço do stack local).
Nada aqui existe no app nem em produção; recusa rodar fora do loopback.
Todas as contas usam o domínio reservado .invalid e a senha de teste abaixo (só vale neste banco local).
"""
import json, os, sys, urllib.request, uuid
import psycopg

API = "http://127.0.0.1:56321"
KEY = os.environ["LOCAL_SERVICE_KEY"]
PASSWORD = "QaLocal#2026"
assert API.startswith("http://127.0.0.1"), "somente stack local"
db = psycopg.connect(host="127.0.0.1", port=56322, user="postgres", password="postgres", dbname="postgres", autocommit=True)


def q(sql, *a):
    cur = db.execute(sql, a)
    return cur.fetchall() if cur.description else None


def create_user(tag, name):
    email = f"{tag}@qa.invalid"
    body = json.dumps({"email": email, "password": PASSWORD, "email_confirm": True,
                       "user_metadata": {"name": name, "username": tag}}).encode()
    req = urllib.request.Request(API + "/auth/v1/admin/users", data=body, method="POST",
                                 headers={"apikey": KEY, "Authorization": "Bearer " + KEY, "Content-Type": "application/json"})
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read())["id"]


def verify(uid):
    q("insert into email_verifications (user_id, method, verified_at) values (%s,'otp',now()) on conflict do nothing", uid)


# 0. Limpeza do banco LOCAL (rerodável)
q("truncate payouts, commission_ledger, payments, partner_links, partners, entitlements, trial_grants, app_admins cascade")
q("delete from auth.users where email like '%%@qa.invalid'")


# 1. Usuário existente (anterior ao marco: sem teste) e depois liga o modelo comercial LOCAL
existing = create_user("existente", "Usuário Existente")
q("update commercial_config set enforcement_enabled=true, launch_marker=now() + interval '2 seconds'")
q("select pg_sleep(3)")

users = {}
for tag, name in (("trial", "Teste Ativo"), ("expirado", "Teste Expirado"), ("mensal", "Assinante Mensal"),
                  ("anual", "Assinante Anual"), ("semplano", "Sem Premium"), ("admin", "Admin QA"),
                  ("prof", "Prof. Ana Souza"), ("profencerrado", "Prof. Encerrado"),
                  ("aluno1", "Aluno Um"), ("aluno2", "Aluno Dois"), ("aluno3", "Aluno Três"),
                  ("extenso", "Nome De Usuário Muito Longo Para Testar Quebra De Linha Em Telas Pequenas")):
    users[tag] = create_user(tag, name)
users["existente"] = existing

for t in ("trial", "expirado", "mensal", "anual", "semplano", "aluno1", "aluno2", "aluno3", "extenso"):
    verify(users[t])
    q("select maybe_grant_trial(%s)", users[t])
# trial expirado
q("update entitlements set ends_at = now() - interval '2 days', starts_at = now() - interval '5 days' where user_id=%s and source='trial'", users["expirado"])
# semplano: sem trial e sem plano (trial vencido e sem assinatura)
q("update entitlements set ends_at = now() - interval '1 day', starts_at = now() - interval '4 days' where user_id=%s and source='trial'", users["semplano"])
# mensal / anual
q("update entitlements set state='expired', ends_at=now() - interval '1 hour' where user_id in (%s,%s) and source='trial'", users["mensal"], users["anual"])
q("insert into entitlements (user_id, source, state, plan, starts_at, ends_at, auto_renew, external_ref) values (%s,'web','active','monthly',now() - interval '10 days', now() + interval '20 days', true,'qa-m-1')", users["mensal"])
q("insert into entitlements (user_id, source, state, plan, starts_at, ends_at, auto_renew, external_ref) values (%s,'apple','active','annual',now() - interval '30 days', now() + interval '335 days', true,'qa-a-1')", users["anual"])

# 2. Admin
q("insert into app_admins (user_id) values (%s)", users["admin"])
verify(users["admin"])

# 3. Professores
def mk_partner(uid, name, started="2026-01-01"):
    return q("""insert into partners (user_id, display_name, referral_code, commission_bps, started_at, pix_key_type, pix_key)
                values (%s,%s,%s,5000,%s,'random','qa-pix-key-0001') returning id""", uid, name, ("Q" + uuid.uuid4().hex[:7]).upper(), started)[0][0]


verify(users["prof"]); verify(users["profencerrado"])
p1 = mk_partner(users["prof"], "Prof. Ana Souza")
p2 = mk_partner(users["profencerrado"], "Prof. Encerrado")
for s in ("aluno1", "aluno2", "aluno3"):
    q("insert into partner_links (student_id, partner_id, source, linked_at) values (%s,%s,'admin_manual','2026-02-01')", users[s], p1)

# 4. Pagamentos, reembolso, repasse, conciliação (sessão como admin)
q("select set_config('request.jwt.claim.sub', %s, false)", users["admin"])
def pay(ext, who, gross, fee, tax=0, fs="reported", ts="reported", prov="mercadopago"):
    q("select record_confirmed_payment(%s,%s,%s,'monthly',%s,%s,%s,now() - interval '20 days',null,%s,%s)", prov, ext, users[who], gross, fee, tax, fs, ts)

pay("QA-P1", "aluno1", 1990, 299)
pay("QA-P2", "aluno2", 19000, 2850)
pay("QA-P3", "aluno3", 1990, 299, fs="estimated", ts="estimated", prov="google")   # pendente de conciliação
pay("QA-P4", "aluno1", 1990, 299)
q("select record_payment_refund('mercadopago','QA-P4', now() - interval '2 days', false)")      # reembolso
q("select admin_register_payout(%s, 5000, date_trunc('month', now() - interval '20 days')::date, now() - interval '1 hour', 'Repasse QA', 'ref-qa-1', 'qa-k1')", p1)

# 5. Documento legal exigindo reaceite (NÃO publicado em produção): ativa só no cenário "reaceite"
print(json.dumps({"password": PASSWORD, "users": {k: f"{k}@qa.invalid" for k in users}, "partners": {"ativo": str(p1), "encerrado": str(p2)}}, indent=1))
