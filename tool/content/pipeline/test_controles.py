import json, os, sys, tempfile, unittest
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import controles as C


def mk(i, mat="m"):
    return {"id": f"q{i}", "materia": mat, "enunciado": f"Segundo o art. {10+i} da norma, em {i+3} dias, qual a regra aplicável ao caso descrito?",
            "alternativas": [f"Regra correta número {i} aplicada", f"Distrator um {i} plausível", f"Distrator dois {i} plausível", f"Distrator três {i} plausível"],
            "gabarito": i % 4, "explicacao": "Explicação longa " * 5, "referencias": [{"fonte": "x", "citacao": f"art. {10+i}, lei"}], "fonte": "legado"}


class T(unittest.TestCase):
    def setUp(self):
        self.pool = [mk(i) for i in range(60)]; self.d = tempfile.mkdtemp()

    def gen(self, seed=1):
        C.gerar(18, seed, self.pool, self.d)
        r = lambda n: C.rj(os.path.join(self.d, n))
        return r("para_validador.jsonl"), r("verdade.jsonl")

    def test_deterministico_e_contagem(self):
        a = self.gen(); b = self.gen()
        self.assertEqual(a, b); pv, vd = a
        self.assertEqual(len(pv), 18 + 12); self.assertEqual(sum(1 for v in vd if not v["defeito"]), 12)
        self.assertEqual({v["defeito"] for v in vd} - {None}, set(C.TIPOS))

    def test_sem_vazamento(self):
        pv, vd = self.gen()
        for l in open(os.path.join(self.d, "para_validador.jsonl"), encoding="utf-8"):
            for t in C.TIPOS: self.assertNotIn(t, l)
            self.assertNotRegex(l, r'"q\d+"')
        self.assertEqual(set(pv[0]), {"id", "materia", "enunciado", "alternativas", "gabarito", "explicacao", "referencias"})
        self.assertEqual([p["id"] for p in pv], [v["id"] for v in vd])
        self.assertTrue(all(p["id"].startswith("c-") for p in pv))

    def test_mutacoes(self):
        pv, vd = self.gen(); orig = {q["id"]: q for q in self.pool}
        for p, v in zip(pv, vd):
            o = orig[v["origem_id"]]
            if v["defeito"] is None: self.assertEqual(p["alternativas"], o["alternativas"]); self.assertEqual(p["gabarito"], o["gabarito"])
            if v["defeito"] == "gabarito_trocado": self.assertNotEqual(p["gabarito"], o["gabarito"])
            if v["defeito"] == "citacao_alterada": self.assertNotEqual(p["referencias"], o["referencias"])

    def test_avaliar(self):
        _, vd = self.gen(); f = os.path.join(self.d, "r.jsonl"); vf = os.path.join(self.d, "verdade.jsonl")

        def resp(fn):
            with open(f, "w", encoding="utf-8") as h:
                for v in vd: h.write(json.dumps({"id": v["id"], "veredito": fn(v)}) + "\n")
            return C.avaliar(f, vf)
        perfeito = resp(lambda v: "defeito" if v["defeito"] else "ok")
        self.assertTrue(perfeito["calibrado"]); self.assertEqual(perfeito["f1"], 1.0)
        cego = resp(lambda v: "ok")  # concordância total: não calibrado
        self.assertFalse(cego["calibrado"]); self.assertEqual(cego["especificidade"], 1.0)
        paranoico = resp(lambda v: "defeito")
        self.assertFalse(paranoico["calibrado"]); self.assertEqual(paranoico["especificidade"], 0.0)


if __name__ == "__main__": unittest.main()
