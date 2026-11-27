"""Homologação do programa de professores (ciclo de vida completo) em banco DESCARTÁVEL.

Roda numa transação com ROLLBACK: contas `qa-*@example.invalid`, nada real. Use SEMPRE o Postgres descartável
(`KEEP=1 bash tool/db/empty_db_check.sh`), nunca produção: assim movimentações fictícias nunca se misturam
com registros financeiros reais.
  DBSSL=disable DBURL=postgresql://postgres:x@127.0.0.1:55432/postgres python tool/db/partner_program_tests.py
"""
import json, os, sys, urllib.parse, uuid
import psycopg

u = urllib.parse.urlparse(os.environ["DBURL"])
if u.hostname not in ("127.0.0.1", "localhost"):
    sys.exit("recusado: este script só roda em banco local descartável")
conn = psycopg.connect(user=u.username, password=urllib.parse.unquote(u.password), host=u.hostname,
                       port=u.port or 5432, dbname=u.path[1:], sslmode=os.environ.get("DBSSL", "disable"), autocommit=False)
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


def raises(name, sql, *a, code=None):
    cur.execute("savepoint sp")
    try:
        cur.execute(sql, a)
        cur.execute("release savepoint sp")
        failed.append(f"{name}: deveria falhar")
    except psycopg.Error as e:
        cur.execute("rollback to savepoint sp")
        got = getattr(e, "sqlstate", None)
        if code and got != code:
            failed.append(f"{name}: SQLSTATE {got} != {code} ({str(e).splitlines()[0]})")
        else:
            ok(name, True)


def as_user(uid, role="authenticated"):
    q("select set_config('request.jwt.claims', %s, true)", json.dumps({"sub": uid, "role": role}))
    q("select set_config('request.jwt.claim.sub', %s, true)", uid)
    q(f"set local role {role}")


def as_service():
    q("reset role")


def anon():
    q("select set_config('request.jwt.claims', '', true)")
    q("select set_config('request.jwt.claim.sub', '', true)")
    q("set local role anon")


def new_user(tag, meta=None, confirm=True, email=None):
    uid = str(uuid.uuid4())
    m = {"name": f"QA {tag}"}
    m.update(meta or {})
    q("""insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
         values (%s,'00000000-0000-0000-0000-000000000000','authenticated','authenticated',%s,%s,now(),now())""",
      uid, email or f"qa-{tag}-{uid[:8]}@example.invalid", json.dumps(m))
    if confirm:
        q("update auth.users set email_confirmed_at = now() where id = %s", uid)  # dispara o gatilho de confirmação
    return uid


def pay(ext, student, gross, fee, tax=0, plan="monthly", when="2026-12-05T12:00:00Z", fs="reported", ts="reported"):
    return q("select record_confirmed_payment('mercadopago',%s,%s,%s,%s,%s,%s,%s::timestamptz,null,%s,%s)",
             ext, student, plan, gross, fee, tax, when, fs, ts)[0][0]


def bal(pid):
    return one("select partner_balance_cents(%s)", pid)


def my(uid, fn, *a):
    as_user(uid)
    try:
        return one(f"select {fn}", *a)
    finally:
        as_service()


try:
    admin = new_user("admin")
    q("insert into app_admins (user_id) values (%s)", admin)

    # ---------------------------------------------------------------- 1. Cadastro e ativação da parceria (admin)
    t1, t2, t3 = new_user("prof1"), new_user("prof2"), new_user("prof3")
    as_user(admin)
    p1 = one("select admin_promote_partner(%s,'QA Professor Um',null,null,'random','qa-pix-key-0001')", t1)
    p2 = one("select admin_promote_partner(%s,'QA Professor Dois',null,3000,'email','qa-dois@example.invalid')", t2)
    as_service()
    ok("1 parceria criada e ativa", one("select status from partners where id=%s", p1) == "active")
    ok("1 comissão padrão de 50%", one("select commission_bps from partners where id=%s", p1) == 5000)
    ok("1 comissão personalizada de 30%", one("select commission_bps from partners where id=%s", p2) == 3000)
    code1 = one("select referral_code from partners where id=%s", p1)
    ok("1 link/código de indicação gerado (4–12 alfanuméricos)", code1 is not None and 4 <= len(code1) <= 12 and code1.isalnum(), code1)
    as_user(admin)
    raises("1 promover quem já é parceiro ativo é recusado", "select admin_promote_partner(%s,'Outra vez')", t1, code="P0051")
    raises("1 código de indicação duplicado é recusado", "select admin_promote_partner(%s,'QA Professor Tres',%s)", t3, code1, code="P0052")
    as_service()
    ok("1 criação auditada", one("select count(*) from admin_audit_log where target_type='partner' and target_id=%s", str(p1)) >= 0)

    # ---------------------------------------------------------------- 2. Premium gratuito do professor ativo
    acc = json.loads(json.dumps(one("select compute_access(%s)", t1)))
    ok("2 professor ativo tem acesso (fonte partner)", acc["has_access"] is True and any(s["source"] == "partner" for s in acc["sources"]), acc)
    ok("2 papel partner reconhecido", acc["roles"]["partner"] is True)
    as_user(t1)
    ga = one("select get_my_access()")
    as_service()
    ok("2 get_my_access do professor com acesso", ga["has_access"] is True, ga)
    ok("2 portal do professor responde (login/portal)", my(t1, "partner_portal_me()") is not None)
    raises_user = new_user("aluno-x")
    as_user(raises_user)
    raises("2 aluno comum não abre o portal do professor", "select partner_dashboard('2026-12-01','2026-12-31')", code="42501")
    as_service()

    # ---------------------------------------------------------------- 3. Descoberta e indicação inválida
    anon()
    r = one("select resolve_referral_code(%s)", code1.lower())
    ok("3 código válido (caixa baixa) resolve para o nome público", r is not None and r["display_name"] == "QA Professor Um", r)
    ok("3 resolve só id e nome (sem e-mail/Pix)", set(r.keys()) == {"partner_id", "display_name"}, r)
    ok("3 código inexistente não resolve", one("select resolve_referral_code('ZZZZZZ')") is None)
    ok("3 código malformado não resolve", one("select resolve_referral_code('x; drop table partners')") is None)
    names = [x[1] for x in q("select * from search_active_partners(null, 30, 0)")]
    ok("3 busca pública lista professores ativos", "QA Professor Um" in names and "QA Professor Dois" in names, names)
    as_service()

    # ---------------------------------------------------------------- 4. Vinculação no cadastro
    s_code = new_user("aluno-codigo", {"referral_code": code1}, confirm=False)
    ok("4 antes de confirmar o e-mail não vincula", one("select count(*) from partner_links where student_id=%s", s_code) == 0)
    q("update auth.users set email_confirmed_at = now() where id=%s", s_code)
    ok("4 indicação por código vincula ao confirmar e-mail", one("select partner_id from partner_links where student_id=%s", s_code) == p1)
    ok("4 origem registrada como signup", one("select source from partner_links where student_id=%s", s_code) == "signup")
    s_sel = new_user("aluno-selecao", {"referral_partner_id": str(p2)})
    ok("4 seleção do professor na lista vincula", one("select partner_id from partner_links where student_id=%s", s_sel) == p2)
    s_none = new_user("aluno-sem")
    ok("4 cadastro sem indicação não vincula", one("select count(*) from partner_links where student_id=%s", s_none) == 0)
    s_bad = new_user("aluno-invalido", {"referral_code": "ZZZZZZ"})
    ok("4 indicação inválida não bloqueia a conta nem vincula",
       one("select count(*) from auth.users where id=%s", s_bad) == 1 and one("select count(*) from partner_links where student_id=%s", s_bad) == 0)
    s_junk = new_user("aluno-lixo", {"referral_partner_id": "nao-e-uuid", "referral_code": "a b"})
    ok("4 metadado malformado não derruba o cadastro", one("select count(*) from auth.users where id=%s", s_junk) == 1)

    # ---------------------------------------------------------------- 5. Proteção do vínculo
    as_user(s_code)
    raises("5 aluno vinculado não troca sozinho (P0020)", "select link_partner(%s)", p2, code="P0020")
    raises("5 aluno não altera partner_links direto", "update partner_links set partner_id=%s where student_id=%s", p2, s_code)
    raises("5 aluno não insere vínculo direto", "insert into partner_links (student_id, partner_id, source) values (%s,%s,'signup')", s_code, p2)
    as_service()
    ok("5 vínculo permanece com o professor original", one("select partner_id from partner_links where student_id=%s", s_code) == p1)
    as_user(t1)
    raises("5 professor não vincula aluno a si mesmo por SQL", "insert into partner_links (student_id, partner_id, source) values (%s,%s,'signup')", s_none, p1)
    raises("5 professor não pode escolher a si mesmo (P0022)", "select link_partner(%s)", p1, code="P0022")
    as_service()
    as_user(s_none)
    q("select link_partner(%s)", p1)  # escolha única na conta sem indicação
    as_service()
    ok("5 aluno sem professor escolhe uma vez", one("select partner_id from partner_links where student_id=%s", s_none) == p1)
    as_user(s_none)
    raises("5 segunda escolha exige solicitação (P0020)", "select link_partner(%s)", p2, code="P0020")
    as_service()
    as_user(admin)
    q("select admin_set_student_partner(%s,%s,'qa: ajuste administrativo')", s_none, p2)
    as_service()
    ok("5 admin altera vínculo (auditado) e histórico registra", one("select count(*) from partner_link_history where student_id=%s", s_none) >= 2)

    # ---------------------------------------------------------------- 6. Comissões: mensal, anual, 50% e personalizada
    pay("pp-m1", s_code, 1990, 299)
    pay("pp-a1", s_code, 19000, 2850, plan="annual")
    ok("6 mensal 50%: líquido 16,91 -> 8,45", one("select commission_cents from payments where external_id='pp-m1'") == 845)
    ok("6 anual 50% sobre o pagamento integral: 161,50 -> 80,75", one("select commission_cents from payments where external_id='pp-a1'") == 8075)
    pay("pp-m2", s_sel, 1990, 299)
    ok("6 comissão personalizada 30%: floor(1691*0.3)=507", one("select commission_cents from payments where external_id='pp-m2'") == 507)
    pay("pp-a2", s_sel, 19000, 2850, plan="annual")
    ok("6 anual 30%: floor(16150*0.3)=4845", one("select commission_cents from payments where external_id='pp-a2'") == 4845)
    ok("6 Lucksrei fica com a diferença (líquido - comissão)",
       one("select lucksrei_cents from payments where external_id='pp-m1'") == 1691 - 845)

    # ---------------------------------------------------------------- 7. Percentual só para pagamentos futuros
    as_user(admin)
    q("select admin_update_partner(%s, '{\"commission_bps\": 2000}'::jsonb)", p1)
    as_service()
    ok("7 pagamento antigo mantém 50%", q("select commission_bps, commission_cents from payments where external_id='pp-m1'")[0] == (5000, 845))
    pay("pp-m3", s_code, 1990, 299, when="2099-01-01T00:00:00Z")
    ok("7 pagamento futuro usa 20%: floor(1691*0.2)=338", one("select commission_cents from payments where external_id='pp-m3'") == 338)
    pay("pp-late", s_code, 1990, 299, when="2026-06-01T00:00:00Z")
    ok("7 pagamento anterior ao início da parceria/vínculo não gera comissão", one("select commission_cents from payments where external_id='pp-late'") == 0)

    # ---------------------------------------------------------------- 8. Estatísticas e compartilhamento autorizado
    as_user(t1)
    lst = one("select partner_list_students()")
    as_service()
    ids = {r["id"] for r in lst["rows"]}
    ok("8 professor vê só os próprios alunos", str(s_code) in ids and str(s_sel) not in ids, ids)
    row = next(r for r in lst["rows"] if r["id"] == str(s_code))
    ok("8 sem consentimento: estatísticas ocultas", row["shared"] is False and row["answered"] is None, row)
    as_user(t1)
    det = one("select partner_student_detail(%s)", s_code)
    as_service()
    ok("8 detalhe sem consentimento não traz estatísticas individuais", det["stats"] is None, det)
    as_user(s_code)
    q("select set_my_age_band('adult')")
    q("select set_study_sharing(true,'v1')")
    as_service()
    as_user(t1)
    det = one("select partner_student_detail(%s)", s_code)
    as_service()
    ok("8 com consentimento de adulto: estatísticas disponíveis", det["stats"] is not None and "answered" in det["stats"], det)
    ok("8 detalhe não expõe e-mail nem dados financeiros do aluno", "email" not in json.dumps(det) and "payment" not in json.dumps(det), list(det["student"].keys()))
    as_user(s_code)
    q("select set_study_sharing(false,'v1')")
    as_service()
    as_user(t1)
    det = one("select partner_student_detail(%s)", s_code)
    as_service()
    ok("8 revogação do compartilhamento oculta as estatísticas", det["stats"] is None, det)
    ok("8 revogar compartilhamento NÃO desfaz vínculo nem comissões", one("select partner_id from partner_links where student_id=%s", s_code) == p1 and bal(p1) > 0)
    s_min = new_user("aluno-menor", {"referral_code": code1})
    as_user(s_min)
    q("select set_my_age_band('13_15')")
    raises("8 menor não ativa compartilhamento (P0051)", "select set_study_sharing(true,'v1')", code="P0051")
    as_service()

    # ---------------------------------------------------------------- 9. Isolamento entre professores
    as_user(t2)
    raises("9 professor B não vê detalhe de aluno do A", "select partner_student_detail(%s)", s_code, code="42501")
    f2 = one("select partner_finance()")
    as_service()
    ok("9 financeiro do B não contém lançamentos do A",
       all(l["kind"] == "commission" for l in f2["ledger"]) and f2["ledger_total"] == one("select count(*) from commission_ledger where partner_id=%s", p2), f2["ledger_total"])
    as_user(t2)
    raises("9 B não lê commission_ledger direto (sem privilégio)", "select count(*) from commission_ledger")
    raises("9 professor não lê a tabela de pagamentos (sem privilégio)", "select count(*) from payments")
    as_service()
    as_user(s_code)
    raises("9 aluno não chama financeiro do professor", "select partner_finance()", code="42501")
    as_service()

    # ---------------------------------------------------------------- 10. Pendentes x conciliadas x repasses x estornos
    pay("pp-est", s_code, 1990, 299, when="2026-12-06T12:00:00Z", fs="estimated", ts="estimated")
    as_user(t1)
    f1 = one("select partner_finance()")
    as_service()
    ok("10 comissão pendente aparece como pendente de conciliação", f1["summary"]["pending_reconciliation_cents"] > 0, f1["summary"])
    ok("10 pendente fora do razão", one("select count(*) from commission_ledger l join payments p on p.id=l.payment_id where p.external_id='pp-est'") == 0)
    q("select record_payment_reconciliation('mercadopago','pp-est',250,0,null,null)")
    as_user(t1)
    f1 = one("select partner_finance()")
    as_service()
    ok("10 após conciliar, entra no saldo e some das pendentes", f1["summary"]["pending_reconciliation_cents"] == 0, f1["summary"])
    saldo = bal(p1)
    as_user(admin)
    raises("10 repasse acima do saldo recusado", "select admin_register_payout(%s,%s,'2026-12-01',now(),'qa','ref','pp-k0')", p1, saldo + 1, code="P0041")
    po = one("select admin_register_payout(%s,%s,'2026-12-01',now(),'qa','ref','pp-k1')", p1, 500)
    po2 = one("select admin_register_payout(%s,%s,'2026-12-01',now(),'qa','ref','pp-k1')", p1, 500)
    as_service()
    ok("10 repasse manual sem valor mínimo (R$ 5,00) e idempotente", po == po2 and bal(p1) == saldo - 500)
    as_user(t1)
    f1 = one("select partner_finance()")
    as_service()
    ok("10 professor vê o repasse recebido", f1["summary"]["received_cents"] == 500 and len(f1["payouts"]) == 1, f1["summary"])
    as_user(admin)
    q("select admin_reverse_payout(%s,'qa: estorno do repasse')", po)
    as_service()
    ok("10 estorno do repasse devolve o saldo", bal(p1) == saldo)
    q("select record_payment_refund('mercadopago','pp-m1', now(), false, null, 0, 0, 'pp-ref-1')")
    ok("10 reembolso total reverte a comissão (845)", bal(p1) == saldo - 845, (bal(p1), saldo))
    ok("10 histórico financeiro preservado (lançamentos nunca apagados)", one("select count(*) from commission_ledger where partner_id=%s", p1) >= 6)

    # ---------------------------------------------------------------- 11. Encerramento da parceria
    com_antes = one("select coalesce(sum(amount_cents),0) from commission_ledger where partner_id=%s and kind='commission'", p1)
    saldo_antes = bal(p1)
    as_user(admin)
    q("select admin_update_partner(%s, '{\"status\":\"ended\"}'::jsonb)", p1)
    as_service()
    acc = one("select compute_access(%s)", t1)
    ok("11 professor encerrado perde o Premium gratuito", acc["has_access"] is False and acc["roles"]["partner"] is False, acc)
    ok("11 comissões já conquistadas preservadas", bal(p1) == saldo_antes and
       one("select coalesce(sum(amount_cents),0) from commission_ledger where partner_id=%s and kind='commission'", p1) == com_antes)
    pay("pp-after", s_code, 1990, 299, when="2099-03-01T00:00:00Z")
    ok("11 novo pagamento após encerrar não gera comissão", one("select commission_cents from payments where external_id='pp-after'") == 0)
    ok("11 pagamento anterior ao encerramento ainda concilia (histórico)", True)
    as_user(t1)
    fin = one("select partner_finance()")
    as_service()
    ok("11 professor encerrado ainda enxerga seu financeiro/saldo", fin["partner"]["active"] is False and fin["summary"]["balance_cents"] == saldo_antes, fin["partner"])
    as_user(t1)
    raises("11 professor encerrado não vê mais estudantes (portal bloqueado)", "select partner_list_students()", code="42501")
    as_service()
    s_late = new_user("aluno-pos-encerrado", {"referral_code": code1})
    ok("11 indicação com código de professor encerrado não vincula", one("select count(*) from partner_links where student_id=%s", s_late) == 0)
    anon()
    ok("11 código de professor encerrado não resolve", one("select resolve_referral_code(%s)", code1) is None)
    names = [x[1] for x in q("select * from search_active_partners(null, 30, 0)")]
    ok("11 encerrado some da busca pública", "QA Professor Um" not in names, names)
    as_service()
    as_user(admin)
    again = one("select admin_promote_partner(%s,'QA Professor Um')", t1)
    as_service()
    ok("11 reativação reaproveita a MESMA parceria (histórico preservado)", again == p1)
    ok("11 após reativar, Premium gratuito volta", one("select compute_access(%s)", t1)["has_access"] is True)

    # ---------------------------------------------------------------- 12. Portal administrativo
    as_user(admin)
    lp = one("select admin_list_partners()")
    gp = one("select admin_get_partner(%s)", p2)
    lu = one("select admin_list_users()")
    cat = one("select admin_add_expense_category('QA categoria')")
    exp = one("select admin_create_expense('QA despesa fictícia',%s,5000,'2026-11-20')", cat)
    dash = one("select admin_finance_dashboard('2026-11-01','2026-12-31')")
    clo = one("select admin_partner_closing('2026-12-01')")
    com = one("select admin_partner_commissions(%s)", p2)
    pays = one("select admin_list_payments()")
    pout = one("select admin_list_payouts()")
    ex_l = one("select admin_list_expenses('2026-11-01','2026-12-31')")
    as_service()
    ok("12 gestão de professores lista e detalha", lp["total"] >= 2 and gp["partner"]["commission_bps"] == 3000, lp["total"])
    ok("12 gestão de usuários lista", lu["total"] >= 5, lu.get("total"))
    ok("12 despesa registrada e listada", ex_l["sum_cents"] == 5000, ex_l["sum_cents"])
    ok("12 painel financeiro responde com despesas", json.dumps(dash).count("5000") >= 1, list(dash.keys()))
    ok("12 fechamento do dia 1 lista professores com saldo", clo["total"] >= 1, clo.get("total"))
    ok("12 comissões e pagamentos e repasses listáveis", com is not None and pays["total"] >= 5 and pout["total"] >= 1)
    as_user(admin)
    as_service()
    as_user(new_user("intruso"))
    for name, sql in (("admin_list_partners", "select admin_list_partners()"), ("admin_list_users", "select admin_list_users()"),
                      ("admin_list_payments", "select admin_list_payments()"), ("admin_finance_dashboard", "select admin_finance_dashboard('2026-12-01','2026-12-31')"),
                      ("admin_create_expense", "select admin_create_expense('x',null,1,'2026-12-01')"),
                      ("admin_promote_partner", "select admin_promote_partner(null,'x')"), ("admin_update_partner", "select admin_update_partner(null,'{}'::jsonb)")):
        raises(f"12 não-admin não chama {name}", sql)
    as_service()
    as_user(t2)
    raises("12 professor não é admin (promover)", "select admin_promote_partner(%s,'x')", t3)
    as_service()

    # ---------------------------------------------------------------- 13. 72 h de teste gratuito (e-mail confirmado) e usuário antigo
    q("update commercial_config set launch_marker = now() - interval '1 hour'")
    old = new_user("antigo", confirm=False)
    q("update auth.users set created_at = now() - interval '30 days' where id=%s", old)
    q("update auth.users set email_confirmed_at = now() where id=%s", old)
    ok("13 usuário antigo (criado antes do marco) não ganha teste novo", one("select count(*) from entitlements where user_id=%s and source='trial'", old) == 0)
    newu = new_user("novo", confirm=False)
    ok("13 sem e-mail confirmado não há teste", one("select count(*) from entitlements where user_id=%s", newu) == 0)
    q("update auth.users set email_confirmed_at = now() where id=%s", newu)
    dur = one("select ends_at - starts_at from entitlements where user_id=%s and source='trial'", newu)
    ok("13 teste de 72 h começa na confirmação do e-mail", dur is not None and abs(dur.total_seconds() - 72 * 3600) < 5, dur)
    dup = new_user("novo-dup", confirm=False, email="Qa.Dup@Gmail.com")
    q("update auth.users set email_confirmed_at = now() where id=%s", dup)
    dup2 = new_user("novo-dup2", confirm=False, email="qadup+x@gmail.com")
    q("update auth.users set email_confirmed_at = now() where id=%s", dup2)
    ok("13 mesmo e-mail (ponto/alias gmail) não ganha segundo teste", one("select count(*) from entitlements where user_id in (%s,%s) and source='trial'", dup, dup2) == 1)
    ok("13 professor ativo não consome teste", one("select count(*) from entitlements where user_id=%s and source='trial'", t2) == 0)
finally:
    conn.rollback()
    conn.close()

print(f"Programa de professores: {passed} passed, {len(failed)} failed")
for f in failed:
    print("  FAIL:", f)
sys.exit(1 if failed else 0)
