"""Aplica (ou ensaia) migrations de supabase/migrations no banco de produção.

Nunca use `supabase db push` neste projeto. Uso:
  DBURL=<connection string, vem do cofre; nunca em argumento> \
  python tool/db/apply_migration.py dry   <arquivo.sql> [...]   # roda e dá ROLLBACK
  python tool/db/apply_migration.py apply <arquivo.sql> [...]   # roda tudo numa transação e COMMIT
Requer: pip install "psycopg[binary]"
"""
import os, sys, urllib.parse
import psycopg

u = urllib.parse.urlparse(os.environ["DBURL"].replace("[", "").replace("]", ""))
mode, files = sys.argv[1], sys.argv[2:]
assert mode in ("dry", "apply")
with psycopg.connect(user=u.username, password=urllib.parse.unquote(u.password), host=u.hostname,
                     port=u.port or 5432, dbname=u.path[1:], sslmode="require") as conn:
    for f in files:
        conn.execute(open(f, encoding="utf-8").read())
        print("ok", os.path.basename(f))
    if mode == "dry":
        conn.rollback(); print("ROLLED BACK")
    else:
        conn.commit(); print("COMMITTED")
