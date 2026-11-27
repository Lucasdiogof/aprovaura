import contextlib
import io
import json
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import estimar
import executor

CHAVE = "sk-ant-TESTE-SEGREDO-123"


class FakeHttp:
    def __init__(self, falhas=None, usage=None):
        self.chamadas, self.falhas, self.batches = [], list(falhas or []), {}
        self.usage = usage or {"input_tokens": 1000, "output_tokens": 500}

    def request(self, metodo, url, headers, corpo=None):
        assert headers["x-api-key"] == CHAVE
        self.chamadas.append((metodo, url))
        if self.falhas:
            return self.falhas.pop(0)
        if url.endswith("/v1/messages"):
            return 200, json.dumps({"content": [{"type": "text", "text": "ok"}], "usage": self.usage})
        if url.endswith("/v1/messages/batches"):
            self.batches["b1"] = corpo["requests"]
            return 200, json.dumps({"id": "b1", "processing_status": "in_progress"})
        if url.endswith("/results"):
            return 200, "\n".join(json.dumps({"custom_id": r["custom_id"], "result": {"type": "succeeded", "message": {"content": [{"type": "text", "text": "ok"}], "usage": self.usage}}}) for r in self.batches["b1"])
        return 200, json.dumps({"id": "b1", "processing_status": "ended"})


def jobs(n):
    return [{"materia": "mat", "tarefa": "autoral", "lote": "L1", "prompt": f"p {i} " + "x" * 300, "max_tokens": 1000} for i in range(n)]


class T(unittest.TestCase):
    def setUp(self):
        self.d = tempfile.mkdtemp()

    def ex(self, http, orc=100.0, **k):
        return executor.Executor(self.d, CHAVE, http, orc, 0.30, dormir=lambda s: None, **k)

    def test_dry_run_nao_chama_nem_exige_chave(self):
        p = os.path.join(self.d, "in.jsonl")
        with open(p, "w", encoding="utf-8") as f:
            f.write("\n".join(json.dumps(j) for j in jobs(3)))
        os.environ.pop("ANTHROPIC_API_KEY", None)
        with contextlib.redirect_stdout(io.StringIO()) as o:
            self.assertEqual(executor.main(["--entrada", p, "--dir", self.d]), 0)
        self.assertIn("DRY-RUN", o.getvalue())
        self.assertFalse(os.path.exists(os.path.join(self.d, "uso", "uso.jsonl")))

    def test_executar_exige_autorizado_e_chave(self):
        p = os.path.join(self.d, "in.jsonl")
        with open(p, "w", encoding="utf-8") as f:
            f.write(json.dumps(jobs(1)[0]))
        os.environ.pop("ANTHROPIC_API_KEY", None)
        with contextlib.redirect_stderr(io.StringIO()), contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(executor.main(["--entrada", p, "--dir", self.d, "--executar"]), 3)  # sem AUTORIZADO
            open(os.path.join(self.d, "AUTORIZADO"), "w").close()
            self.assertEqual(executor.main(["--entrada", p, "--dir", self.d, "--executar"]), 3)  # sem chave

    def test_estimar_recusa_acima_do_orcamento(self):
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(estimar.main(["--tarefa", "autoral", "--n", "20000", "--modelo", "opus-5.5"]), 2)
            self.assertEqual(estimar.main(["--tarefa", "autoral", "--n", "10"]), 0)

    def test_teto_interrompe_antes_de_estourar(self):
        h = FakeHttp(usage={"input_tokens": 1000, "output_tokens": 1000})
        e = self.ex(h, orc=0.05)
        self.assertIn("INTERROMPIDO", e.rodar(jobs(10), "sonnet-5.5"))
        self.assertLessEqual(e.gasto, 0.05 / 1.3)
        self.assertLess(len(h.chamadas), 10)

    def test_retomada_e_dedupe(self):
        h = FakeHttp()
        self.ex(h).rodar(jobs(3) + jobs(3), "sonnet-5.5")  # duplicatas na entrada
        self.assertEqual(len(h.chamadas), 3)
        h2 = FakeHttp()
        e2 = self.ex(h2)
        e2.rodar(jobs(5), "sonnet-5.5")  # nova execucao: so 2 novos
        self.assertEqual(len(h2.chamadas), 2)
        self.assertAlmostEqual(e2.gasto, 5 * executor.custo_real("sonnet-5.5", h.usage, False))

    def test_retry_backoff_e_erro_fatal(self):
        h = FakeHttp(falhas=[(529, "overloaded"), (500, "x")])
        self.assertEqual(self.ex(h).rodar(jobs(1), "sonnet-5.5"), "CONCLUIDO")
        self.assertEqual(len(h.chamadas), 3)
        h = FakeHttp(falhas=[(429, '{"error":{"details":{"error_code":"enforced_spend_limit_reached"}}}')])
        self.assertIn("INTERROMPIDO", self.ex(h).rodar(jobs(2), "sonnet-5.5"))
        self.assertEqual(len(h.chamadas), 1)

    def test_batch_e_desconto(self):
        h = FakeHttp()
        e = self.ex(h, batch=True)
        self.assertEqual(e.rodar(jobs(3), "sonnet-5.5"), "CONCLUIDO")
        self.assertAlmostEqual(e.gasto, 3 * executor.custo_real("sonnet-5.5", h.usage, True))
        self.assertAlmostEqual(executor.custo_real("sonnet-5.5", h.usage, True) * 2, executor.custo_real("sonnet-5.5", h.usage, False))

    def test_chave_nao_vaza(self):
        h = FakeHttp(falhas=[(401, "invalid key " + CHAVE)])
        r = self.ex(h).rodar(jobs(1), "sonnet-5.5")
        self.assertNotIn(CHAVE, r)
        for raiz, _, fs in os.walk(self.d):
            for f in fs:
                with open(os.path.join(raiz, f), encoding="utf-8") as fh:
                    self.assertNotIn(CHAVE, fh.read())


if __name__ == "__main__":
    unittest.main()
