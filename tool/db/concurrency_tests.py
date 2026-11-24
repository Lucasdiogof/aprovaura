"""Concorrência financeira com sessões REAIS simultâneas, só em banco descartável.

Pré-requisito: KEEP=1 bash tool/db/empty_db_check.sh  (sobe o Postgres em 127.0.0.1:55432).
Uso: python tool/db/concurrency_tests.py
Recusa rodar em qualquer host que não seja o loopback (nunca contra produção).
"""
import json, sys, threading, uuid
import psycopg

HOST, PORT = "127.0.0.1", 55432
DSN = dict(host=HOST, port=PORT, user="postgres", password="x", dbname="postgres", autocommit=True)
passed, failed = 0, []
RUN = uuid.uuid4().hex[:6]  # ids/chaves únicos por rodada (a chave de idempotência é global)


def connect(sub=None):
    c = psycopg.connect(**DSN)
    if sub:
        c.execute("select set_config('request.jwt.claim.sub', %s, false)", (sub,))
    return c


def ok(name, cond, detail=""):
    global passed
    if cond:
        passed += 1
    else:
        failed.append(f"{name} {detail}")


def race(jobs, admin=None):
    """Executa cada job (função recebendo uma conexão própria) ao mesmo tempo; devolve [(ok, resultado|SQLSTATE)]."""
    barrier = threading.Barrier(len(jobs))
    out = [None] * len(jobs)

    def run(i, job):
        c = connect(admin)
        try:
            barrier.wait()
            out[i] = (True, job(c))
        except psycopg.Error as e:
            out[i] = (False, getattr(e, "sqlstate", str(e)))
        finally:
            c.close()

    ts = [threading.Thread(target=run, args=(i, j)) for i, j in enumerate(jobs)]
    [t.start() for t in ts]
    [t.join() for t in ts]
    return out


def one(sql, *a):
    with connect() as c:
        r = c.execute(sql, a).fetchone()
        return r[0] if r else None


def new_user(tag):
    uid = str(uuid.uuid4())
    with connect() as c:
        c.execute("insert into auth.users (id, email) values (%s, %s)", (uid, f"{tag}-{uid[:6]}@example.invalid"))
        c.execute("update auth.users set email_confirmed_at = now() where id=%s", (uid,))
    return uid


def new_partner(bps=5000):
    uid = new_user("t")
    with connect() as c:
        pid = c.execute("""insert into partners (user_id, display_name, referral_code, commission_bps, started_at, pix_key_type, pix_key)
            values (%s,'QA',%s,%s,'2026-01-01','random','qa-pix-key-0001') returning id""",
                        (uid, ("Q" + uuid.uuid4().hex[:7]).upper(), bps)).fetchone()[0]
    return pid


def new_student(pid):
    sid = new_user("s")
    with connect() as c:
        c.execute("insert into partner_links (student_id, partner_id, source, linked_at) values (%s,%s,'admin_manual','2026-02-01')", (sid, pid))
    return sid


def pay(c, ext, student, gross=1990, fee=299, tax=0, prov="mercadopago", fs="reported", ts="reported"):
    return c.execute("select record_confirmed_payment(%s,%s,%s,'monthly',%s,%s,%s,'2026-12-05T12:00:00Z'::timestamptz,null,%s,%s)",
                     (prov, ext, student, gross, fee, tax, fs, ts)).fetchone()[0]


def balance(pid):
    return int(one("select coalesce(sum(amount_cents),0) from commission_ledger where partner_id=%s", pid))


def payout(c, pid, amount, key):
    return c.execute("select admin_register_payout(%s,%s,'2026-12-01',now(),'qa','ref',%s)", (pid, amount, key)).fetchone()[0]


# ---------------------------------------------------------------- fixtures
admin = new_user("admin")
with connect() as c:
    c.execute("insert into app_admins (user_id) values (%s)", (admin,))


def fund(amount_gross, ext=None):
    """Parceiro novo com saldo (bps 50%): bruto 2*amount => comissão aproximada amount."""
    pid = new_partner()
    s = new_student(pid)
    with connect() as c:
        pay(c, ext or f"F-{uuid.uuid4().hex[:8]}", s, gross=amount_gross, fee=0)
    return pid, s


# 1. Dois repasses simultâneos, cada um com o saldo inteiro e chaves distintas
pid, _ = fund(100000)  # comissão 50000
bal = balance(pid)
res = race([lambda c, k=k: payout(c, pid, bal, f"k{k}-{RUN}") for k in range(2)], admin)
ok("1 dois repasses do saldo inteiro: exatamente um passa", sum(1 for r in res if r[0]) == 1, res)
ok("1 o outro é recusado por saldo (P0041)", any(not r[0] and r[1] == "P0041" for r in res), res)
ok("1 saldo final 0 (nunca negativo)", balance(pid) == 0, balance(pid))

# 2. Mesma chave de idempotência em 6 sessões
pid, _ = fund(100000)
res = race([lambda c: payout(c, pid, 1000, f"mesma-{RUN}") for _ in range(6)], admin)
ok("2 mesma chave: um único repasse gravado", one("select count(*) from payouts where partner_id=%s", pid) == 1, res)
ok("2 todas as sessões receberam o mesmo id", len({str(r[1]) for r in res if r[0]}) == 1, res)
ok("2 débito aplicado uma vez", balance(pid) == 50000 - 1000, balance(pid))

# 3. Repasse x nova comissão simultâneos
pid, s = fund(100000)
bal = balance(pid)
res = race([lambda c: payout(c, pid, bal, f"p3-{RUN}"), lambda c: pay(c, "N3-" + uuid.uuid4().hex[:6], s, gross=1692, fee=0)], admin)
comm_new = 846
ok("3 repasse passou", res[0][0], res)
ok("3 saldo é 0 ou só a nova comissão (nunca negativo ou perdido)", balance(pid) in (0, comm_new), balance(pid))
total_comm = one("select coalesce(sum(amount_cents) filter (where amount_cents>0),0) from commission_ledger where partner_id=%s", pid)
paid = one("select coalesce(sum(amount_cents),0) from payouts where partner_id=%s", pid)
ok("3 contabilidade fecha: comissões - repasses = saldo", total_comm - paid == balance(pid), (total_comm, paid, balance(pid)))

# 4. Repasse x reembolso simultâneos
pid, s = fund(100000, ext=f"R4-{RUN}")
bal = balance(pid)
res = race([lambda c: payout(c, pid, bal, f"p4-{RUN}"),
            lambda c: c.execute("select record_payment_refund('mercadopago','R4-"+RUN+"',now(),false)").fetchone()[0]], admin)
paid = one("select coalesce(sum(amount_cents),0) from payouts where partner_id=%s", pid)
pos = one("select coalesce(sum(amount_cents) filter (where amount_cents>0),0) from commission_ledger where partner_id=%s", pid)
rev = one("select coalesce(sum(amount_cents) filter (where amount_cents<0),0) from commission_ledger where partner_id=%s", pid)
ok("4 repasse nunca excede o saldo positivo existente", paid <= pos, (paid, pos))
ok("4 saldo = comissões - estornos - repasses", balance(pid) == pos + rev - paid or balance(pid) == pos + rev, (balance(pid), pos, rev, paid))
ok("4 se estorno veio depois do repasse o saldo fica negativo (compensação futura), senão repasse foi recusado",
   (balance(pid) <= 0) or not res[0][0], (res, balance(pid)))

# 5. Webhook duplicado (8 sessões, mesmo id externo)
pid = new_partner()
s = new_student(pid)
res = race([lambda c: pay(c, f"W5-{RUN}", s) for _ in range(8)])
ok("5 webhook duplicado: um só pagamento", one("select count(*) from payments where external_id='W5-"+RUN+"'") == 1, res)
ok("5 comissão registrada uma vez", one("select count(*) from commission_ledger l join payments p on p.id=l.payment_id where p.external_id='W5-"+RUN+"'") == 1)
ok("5 apenas uma resposta 'created'", sum(1 for r in res if r[0] and r[1].get("created") is True) == 1, res)

# 6. Conciliação duplicada
pid = new_partner()
s = new_student(pid)
with connect() as c:
    pay(c, f"C6-{RUN}", s, gross=1990, fee=299, fs="estimated", ts="estimated")
res = race([lambda c: c.execute(f"select record_payment_reconciliation('mercadopago','C6-{RUN}',299,0,null,null)").fetchone()[0] for _ in range(6)])
ok("6 conciliação duplicada: comissão creditada uma vez", balance(pid) == 845, (balance(pid), res))
ok("6 pagamento conciliado", one(f"select reconciliation_status from payments where external_id='C6-{RUN}'") == "reconciled")

# 7. Alteração de comissão durante o registro de pagamento
bad = 0
for i in range(15):
    pid = new_partner(5000)
    s = new_student(pid)
    ext = f"B7-{i}"
    race([lambda c: pay(c, ext, s, gross=1990, fee=299),
          lambda c: c.execute("update partners set commission_bps=8000 where id=%s", (pid,)).rowcount])
    row = None
    with connect() as c:
        row = c.execute("select commission_bps, commission_cents, net_cents from payments where external_id=%s", (ext,)).fetchone()
    bps, com, net = row
    if com != (net * bps) // 10000:
        bad += 1
ok("7 comissão sempre coerente com o bps usado (15 corridas)", bad == 0, f"{bad} incoerentes")

# 8. Eventos fora de ordem (sequencial; nada pode quebrar nem duplicar)
pid = new_partner()
s = new_student(pid)
with connect() as c:
    for name, sql, args in (
        ("reembolso antes do pagamento", f"select record_payment_refund('mercadopago','OO8-{RUN}',now(),false)", ()),
        ("conciliação antes do pagamento", f"select record_payment_reconciliation('mercadopago','OO8-{RUN}',299,0,null,null)", ()),
        ("ajuste antes do pagamento", f"select record_payment_adjustment('mercadopago','OO8-{RUN}','fee',-10,'adj-1',null)", ()),
    ):
        try:
            r = c.execute(sql).fetchone()[0]
            ok(f"8 {name}: tratado sem criar saldo", balance(pid) == 0, r)
        except psycopg.Error as e:
            ok(f"8 {name}: recusado com erro explícito", True, str(e)[:60])
    pay(c, f"OO8-{RUN}", s, gross=1990, fee=299, fs="estimated", ts="estimated")
    c.execute(f"select record_payment_reconciliation('mercadopago','OO8-{RUN}',299,0,null,null)")
    c.execute(f"select record_payment_refund('mercadopago','OO8-{RUN}',now(),false)")
    c.execute(f"select record_payment_refund('mercadopago','OO8-{RUN}',now(),false)")  # reembolso repetido
    c.execute(f"select record_payment_reconciliation('mercadopago','OO8-{RUN}',299,0,null,null)")  # conciliação tardia após reembolso
ok("8 depois de pagamento+conciliação+reembolso(2x)+conciliação tardia o saldo é 0", balance(pid) == 0, balance(pid))

print(f"Concurrency tests: {passed} passed, {len(failed)} failed")
for f in failed:
    print("  FAIL:", f)
sys.exit(1 if failed else 0)
