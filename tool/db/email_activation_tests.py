"""Confirmação obrigatória de e-mail: prova de que a ativação coordenada se comporta como documentado,
SEM ligar nada em produção (banco local descartável). Cobre usuários novos, antigos, prova por código, atestado do dono
e reverificação de legados.
  DBSSL=disable DBURL=postgresql://postgres:x@127.0.0.1:55432/postgres python tool/db/email_activation_tests.py
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


def user(tag, confirmed=False, age_days=0):
    uid = str(uuid.uuid4())
    q("""insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at, email_confirmed_at)
         values (%s,'00000000-0000-0000-0000-000000000000','authenticated','authenticated',%s,'{}', now() - make_interval(days => %s), now(),
                 case when %s then now() end)""", uid, f"qa-{tag}-{uid[:8]}@example.invalid", age_days, confirmed)
    return uid


def must(uid):
    return one("select must_verify_email(%s)", uid)


try:
    legacy_autoconfirmed = user("legado", confirmed=True, age_days=30)   # como os 12 de hoje: autoconfirm, sem prova
    admin = user("admin", confirmed=True, age_days=60)
    q("select owner_attest_email(%s,'qa')", admin)
    ok("0 estado atual (desligado): ninguém precisa provar e-mail", not must(legacy_autoconfirmed) and not must(admin))

    q("update commercial_config set email_verification_required = true, email_verification_since = now()")
    new_unverified = user("novo", confirmed=False)
    ok("1 conta nova sem prova passa a exigir o código", must(new_unverified) is True)
    q("update auth.users set email_confirmed_at = now() where id=%s", new_unverified)
    ok("1 validar o código (GoTrue atualiza email_confirmed_at) grava a prova e libera", must(new_unverified) is False
       and one("select method from email_verifications where user_id=%s", new_unverified) == "otp")
    ok("2 legado SEM prazo definido continua liberado (nada quebra no dia da ativação)", must(legacy_autoconfirmed) is False)
    ok("2 admin atestado pelo dono continua liberado", must(admin) is False)

    q("update commercial_config set legacy_verification_deadline = now() + interval '30 days'")
    ok("3 legado dentro do prazo continua liberado", must(legacy_autoconfirmed) is False)
    q("select require_email_reverification(%s)", legacy_autoconfirmed)
    ok("3 reverificação zera a confirmação (login seguinte pede o código)", one("select email_confirmed_at is null from auth.users where id=%s", legacy_autoconfirmed) is True)
    q("update commercial_config set legacy_verification_deadline = now() - interval '1 minute'")
    ok("3 legado fora do prazo e sem prova passa a exigir", must(legacy_autoconfirmed) is True)
    q("update auth.users set email_confirmed_at = now() where id=%s", legacy_autoconfirmed)
    ok("3 legado que digita o código volta a ser liberado, dados preservados", must(legacy_autoconfirmed) is False
       and one("select count(*) from auth.users where id=%s", legacy_autoconfirmed) == 1)
    q("select require_email_reverification(%s)", admin)
    ok("3 reverificação ignora quem já tem prova (admin atestado)", one("select email_confirmed_at is not null from auth.users where id=%s", admin) is True)

    # 72 h só depois da prova
    q("update commercial_config set launch_marker = now() - interval '1 hour'")
    t = user("trial", confirmed=False)
    ok("4 sem prova não há teste gratuito", one("select count(*) from entitlements where user_id=%s", t) == 0)
    q("update auth.users set email_confirmed_at = now() where id=%s", t)
    d = one("select ends_at - starts_at from entitlements where user_id=%s and source='trial'", t)
    ok("4 teste de 72 h nasce na confirmação do e-mail", d is not None and abs(d.total_seconds() - 72 * 3600) < 5, d)

    # reverter
    q("update commercial_config set email_verification_required = false, email_verification_since = null, legacy_verification_deadline = null")
    ok("5 rollback: com a chave desligada ninguém é barrado", not must(new_unverified) and not must(legacy_autoconfirmed))
finally:
    conn.rollback()
    conn.close()

print(f"Confirmação de e-mail (ativação preparada): {passed} passed, {len(failed)} failed")
for f in failed:
    print("  FAIL:", f)
sys.exit(1 if failed else 0)
