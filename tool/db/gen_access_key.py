"""Gera a chave RSA-2048 de assinatura das autorizações offline e grava a parte
PRIVADA em server_secrets('access_rsa'). Imprime só a chave PÚBLICA (N em hex),
que vai para lib/features/access/data/access_keys.dart. Não substitui chave existente.
Uso: DBURL=... python tool/db/gen_access_key.py [kid]   (kid padrão: k1)
Requer: pip install "psycopg[binary]" cryptography
"""
import os, sys, json, urllib.parse
import psycopg
from cryptography.hazmat.primitives.asymmetric import rsa

kid = sys.argv[1] if len(sys.argv) > 1 else "k1"
u = urllib.parse.urlparse(os.environ["DBURL"].replace("[", "").replace("]", ""))
with psycopg.connect(user=u.username, password=urllib.parse.unquote(u.password), host=u.hostname,
                     port=u.port or 5432, dbname=u.path[1:], sslmode="require") as conn:
    if conn.execute("select 1 from server_secrets where name='access_rsa'").fetchone():
        sys.exit("já existe uma chave; para girar, veja docs/PREMIUM_PARTNERS.md")
    k = rsa.generate_private_key(65537, 2048); nu = k.private_numbers()
    conn.execute("insert into server_secrets(name, value) values('access_rsa', %s::jsonb)",
                 (json.dumps({"kid": kid, "n": "%x" % nu.public_numbers.n, "d": "%x" % nu.d}),))
    print("kid=%s N_HEX=%x" % (kid, nu.public_numbers.n))
