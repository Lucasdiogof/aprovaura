"""python -m unittest discover -s tool/content/agents  — garante 1 agente por matéria, frontmatter válido e especialização própria."""
import json, os, re, unittest
D = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(D, "..", "..", ".."))
AG = os.path.join(ROOT, ".claude", "agents")
cur = json.load(open(os.path.join(D, "..", "curriculum", "curriculum.json"), encoding="utf-8"))
SLUGS = list(cur["existentes"]) + [m["slug"] for m in cur["novas"] if m["decisao"].startswith("incluir")]
TRANSV = ["coordenador-pedagogico", "revisor-enem", "revisor-vestibulares", "revisor-concursos", "valida-gabaritos",
          "revisor-pedagogico", "auditor-duplicidades", "auditor-fontes-licencas", "auditor-legislacao", "gestor-acervo"]

class Agentes(unittest.TestCase):
    def test_um_agente_por_materia(self):
        for s in SLUGS: self.assertTrue(os.path.exists(os.path.join(AG, f"esp-{s}.md")), f"falta esp-{s}")
    def test_sem_agentes_orfaos(self):
        esperados = {f"esp-{s}.md" for s in SLUGS} | {f"{t}.md" for t in TRANSV}
        self.assertEqual(set(os.listdir(AG)) - esperados, set())
    def test_frontmatter_e_isolamento(self):
        for f in os.listdir(AG):
            t = open(os.path.join(AG, f), encoding="utf-8").read()
            m = re.match(r"---\nname: (.+)\ndescription: (.+)\ntools: (.+)\n---\n", t)
            self.assertTrue(m, f); self.assertEqual(m.group(1), f[:-3])
            self.assertNotIn("mcp__", m.group(3), f"{f}: sem MCP (banco/credenciais)")
            if f != "coordenador-pedagogico.md": self.assertNotIn("Agent", m.group(3), f"{f}: só o coordenador aciona agentes")
    def test_especializacao_nao_generica(self):
        corpos = {}
        for s in SLUGS:
            t = open(os.path.join(AG, f"esp-{s}.md"), encoding="utf-8").read()
            corpos[s] = t.split("## Seu conhecimento específico")[1].split("## O que você faz")[0]
        self.assertEqual(len(set(corpos.values())), len(SLUGS), "há agentes com especialização idêntica")
    def test_ctx_funciona(self):
        import subprocess, sys
        for s in ("matematica", "dir_penal", "redes"):
            r = subprocess.run([sys.executable, os.path.join(D, "ctx.py"), s], capture_output=True, text=True, encoding="utf-8", env={**os.environ, "PYTHONIOENCODING": "utf-8"})
            self.assertEqual(r.returncode, 0, r.stderr)

if __name__ == "__main__": unittest.main()
