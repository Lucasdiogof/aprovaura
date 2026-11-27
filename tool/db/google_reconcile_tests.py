"""Google Play sem RTDN: a conciliação periódica (payments-reconcile) reaplica o estado oficial pelo MESMO caminho
dos webhooks (`payments_ingest_event`). Aqui valida-se, em banco local descartável, a seleção do lote e o efeito de
cada estado oficial sobre acesso Premium e comissões. A chamada HTTP à API do Google está nos testes Deno (mock) e
na homologação real em emulador (docs/qa/GOOGLE_PLAY_HOMOLOGACAO.md §9–10).
  DBSSL=disable DBURL=postgresql://postgres:x@127.0.0.1:55432/postgres python tool/db/google_reconcile_tests.py
"""
import json, os, sys, urllib.parse, uuid
import psycopg

u = urllib.parse.urlparse(os.environ["DBURL"])
if u.hostname not in ("127.0.0.1", "localhost"):
    sys.exit("recusado: só roda em banco local descartável")
conn = psycopg.connect(user=u.username, password=urllib.parse.unquote(u.password), host=u.hostname, port=u.port or 5432,
                       dbname=u.path[1:], sslmode=os.environ.get("DBSSL", "disable"), autocommit=False)
cur = conn.cursor()
passed, failed = 0, []


def q(sql, *a):
    cur.execute(sql, a)
    return cur.fetchall() if cur.description else None


def one(sql, *a):
    r = q(sql, *a)
    return r[0][0] if r else None


def ok(name, cond, detail=""):
    global passed
    if cond:
        passed += 1
    else:
        failed.append(f"{name} {detail}")


def new_user(tag):
    uid = str(uuid.uuid4())
    q("""insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
         values (%s,'00000000-0000-0000-0000-000000000000','authenticated','authenticated',%s,'{}',now(),now())""",
      uid, f"qa-{tag}-{uid[:8]}@example.invalid")
    q("update auth.users set email_confirmed_at = now() where id=%s", uid)
    return uid


def access(uid):
    return one("select compute_access(%s)", uid)["has_access"]


def commission_sum(pid):
    return one("select coalesce(sum(amount_cents),0) from commission_ledger where partner_id=%s", pid)


def ev(eid, typ, tok, state, at, end, pay=None, refund=None, plan="monthly", auto=True, acct=None):
    return q("select payments_ingest_event('google','production',%s,%s,%s::timestamptz,%s::uuid,%s,%s,%s,null,%s::timestamptz,%s,%s::jsonb,%s::jsonb)",
             eid, typ, at, acct, tok, plan, state, end, auto,
             json.dumps(pay) if pay else None, json.dumps(refund) if refund else None)[0][0]


try:
    teacher, student = new_user("prof"), new_user("aluno")
    admin = new_user("adm")
    q("insert into app_admins (user_id) values (%s)", admin)
    q("select set_config('request.jwt.claims', %s, true)", json.dumps({"sub": admin, "role": "authenticated"}))
    q("select set_config('request.jwt.claim.sub', %s, true)", admin)
    q("set local role authenticated")
    pid = one("select admin_promote_partner(%s,'QA Prof Google')", teacher)
    q("reset role")
    q("insert into partner_links (student_id, partner_id, source) values (%s,%s,'signup')", student, pid)
    q("insert into purchase_account_tokens (user_id) values (%s) on conflict (user_id) do nothing", student)
    acct = one("select token from purchase_account_tokens where user_id=%s", student)
    now = one("select now()")
    T = lambda days: one("select (now() + make_interval(days => %s))", days)
    TOK = "qa-google-token-1"

    # 1. Compra inicial (verificação pelo app) -> acesso e comissão pendente (taxa estimada)
    r = ev("g:buy:1", "app_verify", TOK, "active", T(0), T(30), {"external_id": "GPA.QA-0001", "gross_cents": 1990, "fee_source": "estimated"}, acct=acct)
    ok("1 compra inicial processada", r["status"] == "processed", r)
    ok("1 acesso Premium ativo (fonte google)", access(student) and one("select count(*) from entitlements where user_id=%s and source='google' and state='active'", student) == 1)
    ok("1 comissão estimada fica fora do razão até conciliar", commission_sum(pid) == 0)

    # 2. Seleção do lote da conciliação
    ok("2 assinatura longe do vencimento NÃO entra no lote", TOK not in json.dumps(one("select service_subscriptions_to_check(50)")))
    q("update provider_subscriptions set period_end = now() + interval '1 day' where original_ref=%s", TOK)
    ok("2 assinatura perto do vencimento entra no lote", TOK in json.dumps(one("select service_subscriptions_to_check(50)")))
    sid = one("select id from provider_subscriptions where original_ref=%s", TOK)
    q("select service_mark_checked(%s)", sid)
    ok("2 depois de marcada, não repete dentro de 12 h", TOK not in json.dumps(one("select service_subscriptions_to_check(50)")))

    # 3. Renovação detectada na conciliação (novo ciclo + novo pagamento) e idempotência
    renew = {"external_id": "GPA.QA-0002", "gross_cents": 1990, "fee_cents": 299, "fee_source": "reported", "tax_source": "reported", "tax_cents": 0}
    r = ev("recon:google:T:h1", "reconcile", TOK, "active", T(30), T(60), renew)
    ok("3 renovação: novo ciclo e acesso mantido", r["status"] == "processed" and access(student), r)
    ok("3 renovação gera segundo pagamento", one("select count(*) from payments where provider='google' and user_id=%s", student) == 2)
    ok("3 comissão da renovação (taxa informada): floor(1691*0.5)=845", commission_sum(pid) == 845, commission_sum(pid))
    r = ev("recon:google:T:h1", "reconcile", TOK, "active", T(30), T(60), renew)
    ok("3 mesma conciliação repetida é inerte (sem pagamento duplicado)", r.get("duplicate") is True and one("select count(*) from payments where provider='google' and user_id=%s", student) == 2)
    r = ev("recon:google:T:h2", "reconcile", TOK, "active", T(30), T(60), renew)
    ok("3 renovação relida em outra hora não duplica o pagamento", one("select count(*) from payments where provider='google' and user_id=%s", student) == 2, r)
    q("select record_payment_reconciliation('google','GPA.QA-0001',299,0,null,null)")
    ok("3 conciliar o 1º pagamento libera a comissão (845+845)", commission_sum(pid) == 1690, commission_sum(pid))

    # 4. Cancelamento: acesso até o fim do período; depois expira
    r = ev("recon:google:T:c1", "reconcile", TOK, "canceled", T(31), T(60), auto=False)
    ok("4 cancelada: mantém acesso até o fim", access(student) and one("select state from provider_subscriptions where original_ref=%s", TOK) == "canceled", r)
    r = ev("recon:google:T:c2", "reconcile", TOK, "expired", T(61), T(60), auto=False)
    # evento "futuro" com fim <= agora: expira de fato
    ok("4 expiração remove o acesso", not access(student) and one("select state from provider_subscriptions where original_ref=%s", TOK) == "expired", r)

    # 5. Recuperação (hold -> pagamento corrigido): Google em 'expired' <= 60 dias volta a ser relido
    q("update provider_subscriptions set period_end = now() - interval '5 days', last_checked_at = null where original_ref=%s", TOK)
    ok("5 expirada há <=60 dias é relida (permite recuperação/hold)", TOK in json.dumps(one("select service_subscriptions_to_check(50)")))
    q("update provider_subscriptions set period_end = now() - interval '90 days', last_checked_at = null where original_ref=%s", TOK)
    ok("5 expirada há >60 dias sai do lote", TOK not in json.dumps(one("select service_subscriptions_to_check(50)")))
    rec = {"external_id": "GPA.QA-0003", "gross_cents": 1990, "fee_cents": 299, "fee_source": "reported", "tax_source": "reported", "tax_cents": 0}
    r = ev("recon:google:T:r1", "reconcile", TOK, "active", T(62), T(92), rec)
    ok("5 recuperação: acesso volta e novo pagamento/comissão", access(student) and one("select count(*) from payments where provider='google' and user_id=%s", student) == 3 and commission_sum(pid) == 2535, (r, commission_sum(pid)))

    # 6. Carência e retenção (account hold)
    r = ev("recon:google:T:g1", "reconcile", TOK, "grace", T(63), T(70))
    ok("6 período de tolerância (grace) mantém acesso", access(student) and one("select state from entitlements where user_id=%s and source='google' order by created_at desc limit 1", student) in ("grace", "active"), r)
    r = ev("recon:google:T:h9", "reconcile", TOK, "expired", T(64), T(60))
    ok("6 retenção de conta (hold = expired) remove o acesso sem tocar nas comissões", not access(student) and commission_sum(pid) == 2535)

    # 7. Estorno/revogação (voidedpurchases) -> reverte a comissão e encerra o acesso
    ev("recon:google:T:r2", "reconcile", TOK, "active", T(65), T(95), {"external_id": "GPA.QA-0004", "gross_cents": 1990, "fee_cents": 299, "fee_source": "reported", "tax_source": "reported", "tax_cents": 0})
    antes = commission_sum(pid)
    r = ev("google:void:GPA.QA-0004", "voided", TOK, "refunded", T(66), T(0),
           refund={"external_id": "GPA.QA-0004", "at": str(T(66)), "charged_back": False, "external_ref": "google-void:GPA.QA-0004"})
    ok("7 compra anulada: pagamento refunded, comissão revertida (845) e sem acesso",
       one("select status from payments where external_id='GPA.QA-0004'") == "refunded" and commission_sum(pid) == antes - 845 and not access(student), (r, antes, commission_sum(pid)))
    r2 = ev("google:void:GPA.QA-0004", "voided", TOK, "refunded", T(66), T(0),
            refund={"external_id": "GPA.QA-0004", "at": str(T(66)), "charged_back": False, "external_ref": "google-void:GPA.QA-0004"})
    ok("7 anulação repetida na lista oficial é inerte", r2.get("duplicate") is True and commission_sum(pid) == antes - 845)
    r = ev("recon:google:T:rv", "reconcile", TOK, "revoked", T(67), T(0))
    ok("7 revogação (revoked) mantém sem acesso", not access(student), r)

    # 8. Isolamento: conta divergente não toma a assinatura
    other = new_user("outro")
    q("insert into purchase_account_tokens (user_id) values (%s) on conflict (user_id) do nothing", other)
    otok = one("select token from purchase_account_tokens where user_id=%s", other)
    r = ev("g:conflict:1", "app_verify", TOK, "active", T(70), T(100), acct=otok)
    ok("8 outra conta tentando usar o mesmo token gera conflito e nenhum acesso", r["status"] == "conflict" and not access(other), r)
finally:
    conn.rollback()
    conn.close()

print(f"Google conciliação: {passed} passed, {len(failed)} failed")
for f in failed:
    print("  FAIL:", f)
sys.exit(1 if failed else 0)
