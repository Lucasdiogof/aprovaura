"""Leitura SOMENTE-SELECT da produção do AprovaAura (Management API). Token vem do cofre local, nunca é impresso."""
import json, os, re, subprocess, urllib.request
REF = "cesuqfgrtcitatxvokez"
VAULT = os.path.expanduser("~/.config/claude-secrets/vault.ps1")

def _pat():
    out = subprocess.run(["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", VAULT, "get",
                          "--id", "supabase.aprovaura.production.pat"], capture_output=True, text=True, check=True).stdout
    return out.strip()

def select(sql):
    s = sql.strip().rstrip(";")
    if not re.match(r"(?is)^(with|select)\b", s) or re.search(r"(?i)\b(insert|update|delete|drop|alter|create|truncate|grant|call)\b\s", s.split("--")[0]) and False:
        raise ValueError("somente SELECT/WITH")
    if re.search(r"(?i)\b(insert\s+into|update\s+\w+\s+set|delete\s+from|drop\s|alter\s|truncate\s|create\s)", s):
        raise ValueError("comando de escrita bloqueado")
    req = urllib.request.Request(f"https://api.supabase.com/v1/projects/{REF}/database/query",
        data=json.dumps({"query": s, "read_only": True}).encode(),
        headers={"Authorization": "Bearer " + _pat(), "Content-Type": "application/json", "User-Agent": "aura-content-inventory/1"})
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.loads(r.read().decode("utf-8"))
