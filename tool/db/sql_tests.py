"""Testes SQL (financeiro, conciliação, idade/compartilhamento, permissões).

Rodam em UMA transação com ROLLBACK ao final: nada é gravado no banco, nenhum e-mail/usuário real é tocado
(os usuários de teste usam o domínio reservado .invalid e somem com o rollback). Uso:
  DBURL=<cofre> python tool/db/sql_tests.py
Requer: pip install "psycopg[binary]"
"""
import json, os, sys, urllib.parse, uuid
import psycopg

u = urllib.parse.urlparse(os.environ["DBURL"].replace("[", "").replace("]", ""))
conn = psycopg.connect(user=u.username, password=urllib.parse.unquote(u.password), host=u.hostname,
                       port=u.port or 5432, dbname=u.path[1:], sslmode="require", autocommit=False)
cur = conn.cursor()
passed, failed = 0, []


def q(sql, *args):
    cur.execute(sql, args)
    return cur.fetchall() if cur.description else None


def one(sql, *args):
    r = q(sql, *args)
    return r[0][0] if r else None


def ok(name, cond, detail=""):
    global passed
    if cond:
        passed += 1
    else:
        failed.append(f"{name} {detail}")


def raises(name, sql, *args, code=None):
    """Executa dentro de um savepoint e espera erro (opcionalmente com SQLSTATE `code`)."""
    cur.execute("savepoint sp")
    try:
        cur.execute(sql, args)
        cur.execute("release savepoint sp")
        failed.append(f"{name}: deveria falhar")
    except psycopg.Error as e:
        cur.execute("rollback to savepoint sp")
        got = getattr(e, "sqlstate", None)
        if code and got != code:
            failed.append(f"{name}: SQLSTATE {got} != {code} ({str(e).splitlines()[0]})")
        else:
            ok(name, True)


def new_user(tag):
    uid = str(uuid.uuid4())
    q("""insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
         values (%s, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', %s, %s, now(), now())""",
      uid, f"qa-{tag}-{uid[:8]}@example.invalid", json.dumps({"name": f"QA {tag}"}))
    # Gatilhos de cadastro podem zerar a confirmação: confirma depois (só nesta transação de teste).
    q("update auth.users set email_confirmed_at = now() where id = %s", uid)
    return uid


def as_user(uid, role="authenticated"):
    q("select set_config('request.jwt.claims', %s, true)", json.dumps({"sub": uid, "role": role}))
    q("select set_config('request.jwt.claim.sub', %s, true)", uid)
    q(f"set local role {role}")


def as_service():
    q("reset role")


def anon():
    q("select set_config('request.jwt.claims', '', true)")
    q("set local role anon")


def partner(uid, bps=5000, started="2026-01-01"):
    pid = one("""insert into partners (user_id, display_name, referral_code, commission_bps, started_at, pix_key_type, pix_key)
                 values (%s, 'QA Professor', %s, %s, %s, 'random', 'qa-pix-key-0001') returning id""",
              uid, ("Q" + uuid.uuid4().hex[:7]).upper(), bps, started)
    return pid


def link(student, pid, at="2026-02-01"):
    q("insert into partner_links (student_id, partner_id, source, linked_at) values (%s,%s,'admin_manual',%s)", student, pid, at)


def pay(ext, student, gross, fee, tax=0, when="2026-12-05T12:00:00Z", fs="reported", ts="reported", prov="mercadopago"):
    return q("select record_confirmed_payment(%s, %s, %s, 'monthly', %s, %s, %s, %s::timestamptz, null, %s, %s)",
             prov, ext, student, gross, fee, tax, when, fs, ts)[0][0]


def avail(pid):
    return one("select coalesce(sum(amount_cents),0) from commission_ledger where partner_id=%s", pid)


try:
    admin_uid = new_user("admin")
    q("insert into app_admins (user_id) values (%s)", admin_uid)
    teacher_uid, stud_a, stud_b, plain = new_user("t1"), new_user("sa"), new_user("sb"), new_user("plain")
    pid = partner(teacher_uid)
    link(stud_a, pid)

    # ------------------------------------------------------------------ Exemplos financeiros A–D
    a = pay("qa-A", stud_a, 1990, 299)
    ok("A criado", a["created"] is True)
    row = q("select net_cents, commission_cents, lucksrei_cents from payments where external_id='qa-A'")[0]
    ok("A líquido 16,91", row[0] == 1691, row)
    ok("A comissão 50% arredonda para baixo (8,45)", row[1] == 845, row)
    ok("A soma exata das parcelas", row[1] + row[2] == row[0], row)

    pay("qa-B", stud_a, 19000, 2850)
    row = q("select net_cents, commission_cents, lucksrei_cents from payments where external_id='qa-B'")[0]
    ok("B líquido 161,50 / comissão 80,75 / Lucksrei 80,75", row == (16150, 8075, 8075), row)

    # Reprocesso do webhook: não duplica pagamento nem razão
    again = pay("qa-B", stud_a, 19000, 2850)
    ok("webhook repetido é idempotente", again["created"] is False)
    ok("um único lançamento por pagamento", one("select count(*) from commission_ledger l join payments p on p.id=l.payment_id where p.external_id='qa-B' and l.kind='commission'") == 1)

    # C: saldo 500,00 -> repasse 500,00 -> saldo 0 -> nova comissão 8,46
    teacher2, stud_c = new_user("t2"), new_user("sc")
    pid2 = partner(teacher2)
    link(stud_c, pid2)
    pay("qa-C1", stud_c, 100000, 0)
    ok("C saldo 500,00", avail(pid2) == 50000, avail(pid2))
    as_user(admin_uid)
    raises("C repasse acima do saldo é recusado", "select admin_register_payout(%s, 50001, '2026-12-01', now(), 'qa', 'ref', 'k0')", pid2, code="P0041")
    p1 = one("select admin_register_payout(%s, 50000, '2026-12-01', now(), 'qa', 'ref', 'k1')", pid2)
    p1b = one("select admin_register_payout(%s, 50000, '2026-12-01', now(), 'qa', 'ref', 'k1')", pid2)
    ok("C clique duplo (mesma chave) devolve o mesmo repasse", p1 == p1b)
    as_service()
    ok("C saldo 0,00", avail(pid2) == 0, avail(pid2))
    pay("qa-C2", stud_c, 1992, 300)
    ok("C nova comissão 8,46 => saldo 8,46", avail(pid2) == 846, avail(pid2))

    # D: comissão já repassada + reembolso => ajuste negativo, histórico preservado, compensação futura
    q("select record_payment_refund('mercadopago','qa-C1', now(), false, null, 0, 0, 'qa-ref-1')")
    ok("D ajuste negativo registrado", avail(pid2) == 846 - 50000, avail(pid2))
    ok("D repasse original preservado", one("select status from payouts where id=%s", p1) == "paid")
    ok("D reembolso duplicado não repete", q("select record_payment_refund('mercadopago','qa-C1', now(), false, null, 0, 0, 'qa-ref-1')")[0][0]["changed"] is False)
    pay("qa-C3", stud_c, 1992, 300)
    ok("D compensação em comissões futuras", avail(pid2) == 846 * 2 - 50000, avail(pid2))

    # Reembolso parcial
    stud_d = new_user("sd")
    link(stud_d, pid)
    pay("qa-P1", stud_d, 1990, 299)
    before = avail(pid)
    r1 = q("select record_payment_refund('mercadopago','qa-P1', now(), false, 995, 0, 0, 'qa-p-1')")[0][0]
    ok("parcial reverte floor(845*995/1990)=422", r1["commission_reversed_cents"] == 422, r1)
    r2 = q("select record_payment_refund('mercadopago','qa-P1', now(), false, 995, 0, 0, 'qa-p-2')")[0][0]
    ok("segundo parcial fecha o total (845 no acumulado)", 422 + r2["commission_reversed_cents"] == 845, r2)
    raises("reembolso acima do bruto restante", "select record_payment_refund('mercadopago','qa-P1', now(), false, 1, 0, 0, 'qa-p-3')", code="P0043")
    ok("status final refunded", one("select status from payments where external_id='qa-P1'") == "refunded")

    # Estimado não vira comissão liberável; conciliação libera
    stud_e = new_user("se")
    link(stud_e, pid)
    pay("qa-E1", stud_e, 1990, 299, 0, fs="estimated", ts="estimated")
    ok("comissão sobre taxa estimada fica fora do razão", one("select count(*) from commission_ledger l join payments p on p.id=l.payment_id where p.external_id='qa-E1'") == 0)
    ok("pagamento marcado pendente de conciliação", one("select reconciliation_status from payments where external_id='qa-E1'") == "pending")
    q("select record_payment_reconciliation('mercadopago','qa-E1', 250, 0, null, null)")
    ok("após conciliar, comissão entra (floor(1740*0.5)=870)", one("select coalesce(sum(l.amount_cents),0) from commission_ledger l join payments p on p.id=l.payment_id where p.external_id='qa-E1'") == 870)

    # Percentual muda depois; evento antigo usa o percentual da época; professor encerrado
    stud_f = new_user("sf")
    link(stud_f, pid)
    q("update partners set commission_bps = 3000 where id = %s", pid)
    pay("qa-F-new", stud_f, 1000, 0, when="2099-01-01T00:00:00Z")
    ok("pagamento novo usa o novo percentual (30%)", one("select commission_bps from payments where external_id='qa-F-new'") == 3000)
    pay("qa-F-old", stud_f, 1000, 0, when="2026-06-01T00:00:00Z")
    ok("evento antigo recebido com atraso mantém 50%", one("select commission_bps from payments where external_id='qa-F-old'") == 5000)
    q("update partners set status='ended', ended_at='2026-12-31' where id = %s", pid)
    pay("qa-F-ended", stud_f, 1000, 0, when="2099-02-01T00:00:00Z")
    ok("após encerrar a parceria não há comissão", one("select commission_cents from payments where external_id='qa-F-ended'") == 0)

    # Validações de entrada
    raises("pagamento com taxa maior que o bruto", "select record_confirmed_payment('mercadopago','qa-bad',%s,'monthly',100,200,0,now())", stud_a, code="P0050")
    raises("pagamento com bruto zero", "select record_confirmed_payment('mercadopago','qa-bad2',%s,'monthly',0,0,0,now())", stud_a, code="P0050")

    # ------------------------------------------------------------------ Importação de relatório
    stud_g = new_user("sg")
    link(stud_g, pid2)
    pay("GPA.QA1", stud_g, 1990, 299, 0, fs="estimated", ts="estimated", prov="google")
    as_user(admin_uid)
    sha = uuid.uuid4().hex + uuid.uuid4().hex
    lines = [
        {"ref": "GPA.QA1", "gross_cents": 1990, "fee_cents": 299, "tax_cents": 0, "net_cents": 1691},
        {"ref": "GPA.QA1-DIV", "gross_cents": 5, "fee_cents": 1, "tax_cents": 0},
        {"ref": "GPA.NAO-EXISTE", "gross_cents": 1990, "fee_cents": 299, "tax_cents": 0},
    ]
    q("select admin_import_report('google','google_earnings','2026-12-15','qa.csv',%s,%s::jsonb)", sha, json.dumps(lines))
    as_service()
    imp = q("select id, matched, divergent, unmatched from financial_report_imports where file_sha256=%s", sha)[0]
    as_user(admin_uid)
    ok("import: 1 pronta, 0 divergente (id extra não existe), 2 sem par", (imp[1], imp[2], imp[3]) == (1, 0, 2), imp)
    raises("import: mesmo arquivo não entra duas vezes", "select admin_import_report('google','google_earnings','2026-12-15','qa.csv',%s,%s::jsonb)", sha, json.dumps(lines), code="P0061")
    raises("import: tipo incompatível com o provedor", "select admin_import_report('google','apple_sales','2026-12-15','x',%s,%s::jsonb)", "a" * 64, json.dumps(lines), code="P0060")
    # divergência de valor bruto
    sha2 = uuid.uuid4().hex + uuid.uuid4().hex
    q("select admin_import_report('google','google_earnings','2026-12-15','qa2.csv',%s,%s::jsonb)", sha2,
      json.dumps([{"ref": "GPA.QA1", "gross_cents": 2000, "fee_cents": 299, "tax_cents": 0}]))
    as_service()
    ok("valor bruto diferente => divergente (nunca aplicado)", one("select divergent from financial_report_imports where file_sha256=%s", sha2) == 1)
    as_user(admin_uid)
    ap = q("select admin_apply_report(%s)", imp[0])[0][0]
    ok("apply concilia a linha pronta", ap["applied"] == 1, ap)
    ok("apply de novo é inerte", q("select admin_apply_report(%s)", imp[0])[0][0].get("already") is True)
    as_service()
    ok("pagamento ficou conciliado com taxa oficial", q("select reconciliation_status, fee_cents, fee_source from payments where external_id='GPA.QA1' and provider='google'")[0] == ("reconciled", 299, "reported"))
    ok("comissão liberada só após conciliar (845)", one("select coalesce(sum(l.amount_cents),0) from commission_ledger l join payments p on p.id=l.payment_id where p.external_id='GPA.QA1'") == 845)
    ok("divergência não alterou o pagamento", one("select gross_cents from payments where external_id='GPA.QA1' and provider='google'") == 1990)

    # ------------------------------------------------------------------ Idade e compartilhamento
    minor = new_user("minor")
    as_user(minor)
    raises("menor/desconhecido não ativa compartilhamento", "select set_study_sharing(true, 'v1')", code="P0051")
    q("select set_my_age_band('adult')")
    q("select set_study_sharing(true, 'v1')")
    as_service()
    ok("adulto com consentimento compartilha", one("select _student_shares(%s)", minor) is True)
    as_user(minor)
    q("select set_my_age_band('13_15')")
    as_service()
    ok("declarar-se menor encerra o compartilhamento", one("select _student_shares(%s)", minor) is False)

    # ------------------------------------------------------------------ Permissões (negativas)
    for who, setter in (("anônimo", anon), ("usuário comum", lambda: as_user(plain))):
        setter()
        for fn, sql in (("admin_finance_dashboard", "select admin_finance_dashboard('2026-12-01','2026-12-31')"),
                        ("admin_register_payout", "select admin_register_payout(%s, 1, '2026-12-01')" % ("'" + str(pid2) + "'")),
                        ("admin_import_report", "select admin_import_report('google','google_earnings','2026-12-01','x','%s','[{}]'::jsonb)" % ("b" * 64)),
                        ("record_confirmed_payment", "select record_confirmed_payment('mercadopago','x','%s','monthly',100,0,0,now())" % str(plain)),
                        ("publish_legal_version", "select publish_legal_version('terms','9','u','{}'::jsonb, now())")):
            cur.execute("savepoint sp")
            try:
                cur.execute(sql)
                cur.execute("release savepoint sp")
                failed.append(f"{who} conseguiu chamar {fn}")
            except psycopg.Error:
                cur.execute("rollback to savepoint sp")
                ok(f"{who} não chama {fn}", True)
        for tbl in ("payments", "commission_ledger", "payouts", "financial_report_imports", "user_age_declarations"):
            cur.execute("savepoint sp")
            try:
                cur.execute(f"select count(*) from {tbl}")
                n = cur.fetchone()[0]
                cur.execute("release savepoint sp")
                ok(f"{who} não lê {tbl}", n == 0, f"leu {n} linhas")
            except psycopg.Error:
                cur.execute("rollback to savepoint sp")
                ok(f"{who} sem acesso a {tbl}", True)
        as_service()

    # Professor comum não vê o aluno de outro professor
    as_user(teacher2)
    raises("professor não lê aluno de outro professor", "select partner_student_detail(%s)", stud_a)
    as_service()
finally:
    conn.rollback()
    conn.close()

print(f"SQL tests: {passed} passed, {len(failed)} failed")
for f in failed:
    print("  FAIL:", f)
sys.exit(1 if failed else 0)
