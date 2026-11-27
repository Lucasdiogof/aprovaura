#!/usr/bin/env python3
"""Executor da API Anthropic com teto de orcamento. NAO executa nada por padrao (dry-run).
Para executar: --executar + variavel de ambiente com a chave (padrao ANTHROPIC_API_KEY) + arquivo AUTORIZADO
criado a mao pelo dono em tool/content/api/. A chave so e lida do ambiente e nunca e impressa/gravada.
Entrada (--entrada): JSONL {"materia","tarefa","lote","system","prompt","max_tokens","modelo"?}.
Saidas em <dir>/uso/: uso.jsonl (tokens/custo por chamada), resultados.jsonl, estado.json (batches pendentes).
"""
import argparse, hashlib, json, os, sys, time, urllib.error, urllib.request
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import estimar

BASE = "https://api.anthropic.com"
VERSAO = "2023-06-01"


class Parar(Exception):
    """Erro fatal: teto de gasto, autenticacao ou orcamento esgotado. Nao ha retry."""


class HttpReal:
    def request(self, metodo, url, headers, corpo=None):
        data = json.dumps(corpo).encode() if corpo is not None else None
        req = urllib.request.Request(url, data=data, headers=headers, method=metodo)
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                return r.status, r.read().decode("utf-8")
        except urllib.error.HTTPError as e:
            return e.code, e.read().decode("utf-8", "replace")


def hash_job(j, modelo):
    s = json.dumps([modelo, j.get("system", ""), j["prompt"], j.get("max_tokens", 1000)], ensure_ascii=False)
    return hashlib.sha256(s.encode()).hexdigest()


def lerjsonl(p):
    if not os.path.exists(p):
        return []
    with open(p, encoding="utf-8") as f:
        return [json.loads(l) for l in f if l.strip()]


def custo_real(modelo, u, batch):
    p = estimar.PRECOS[modelo]
    c = u.get("input_tokens", 0) * p["in"] + u.get("output_tokens", 0) * p["out"]
    c += u.get("cache_creation_input_tokens", 0) * p["in"] * estimar.CACHE_WRITE + u.get("cache_read_input_tokens", 0) * p["cache_read"]
    return c / 1e6 * (estimar.BATCH_DESC if batch else 1)


class Executor:
    def __init__(self, dir_, chave, http, orcamento, margem, batch=False, tam_lote=100, dormir=time.sleep, tentativas=5, espera_batch=30):
        self.uso_dir = os.path.join(dir_, "uso")
        os.makedirs(self.uso_dir, exist_ok=True)
        self.f_uso = os.path.join(self.uso_dir, "uso.jsonl")
        self.f_res = os.path.join(self.uso_dir, "resultados.jsonl")
        self.f_est = os.path.join(self.uso_dir, "estado.json")
        self._chave, self.http, self.batch = chave, http, batch
        self.teto = orcamento / (1 + margem)  # margem de seguranca embutida no teto
        self.tam_lote, self.dormir, self.tentativas, self.espera_batch = tam_lote, dormir, tentativas, espera_batch
        self.gasto = sum(r["custo_usd"] for r in lerjsonl(self.f_uso))
        self.feitos = {r["hash"] for r in lerjsonl(self.f_res)}

    def _h(self):
        return {"x-api-key": self._chave, "anthropic-version": VERSAO, "content-type": "application/json"}

    def _scrub(self, t):
        return str(t).replace(self._chave, "***") if self._chave else str(t)

    def _req(self, metodo, url, corpo=None):
        st = 0
        for i in range(self.tentativas):
            st, txt = self.http.request(metodo, url, self._h(), corpo)
            if st == 200:
                return txt
            low = txt.lower()
            if (st == 429 and "enforced_spend_limit_reached" in txt) or "specified api usage limits" in low or "credit balance" in low:
                raise Parar("teto de gasto/credito atingido no Console; interrompido (sem retry)")
            if st in (400, 401, 402, 403, 404):
                raise Parar(f"erro fatal HTTP {st}: {self._scrub(txt)[:300]}")
            self.dormir(min(2 ** i, 60))  # 429/5xx/529: backoff exponencial
        raise Parar(f"falha apos {self.tentativas} tentativas (HTTP {st})")

    def _pior_caso(self, j, modelo):
        return estimar.custo_chamada(modelo, estimar.tokens_aprox(j.get("system", "") + j["prompt"]), j.get("max_tokens", 1000), self.batch)

    def _registrar(self, j, modelo, h, msg, batch):
        u = msg.get("usage", {})
        c = custo_real(modelo, u, batch)
        self.gasto += c
        txt = "".join(b.get("text", "") for b in msg.get("content", []))
        with open(self.f_uso, "a", encoding="utf-8") as f:
            f.write(json.dumps({"hash": h, "materia": j.get("materia"), "lote": j.get("lote"), "tarefa": j.get("tarefa"), "modelo": modelo,
                                "batch": batch, "tokens": u, "custo_usd": c, "ts": time.time()}, ensure_ascii=False) + "\n")
        with open(self.f_res, "a", encoding="utf-8") as f:
            f.write(json.dumps({"hash": h, "id": j.get("id"), "materia": j.get("materia"), "texto": txt}, ensure_ascii=False) + "\n")
        self.feitos.add(h)

    def _params(self, j, modelo):
        p = {"model": estimar.PRECOS[modelo]["id"], "max_tokens": j.get("max_tokens", 1000), "messages": [{"role": "user", "content": j["prompt"]}]}
        if j.get("system"):  # instrucoes fixas viram prefixo cacheavel
            p["system"] = [{"type": "text", "text": j["system"], "cache_control": {"type": "ephemeral"}}]
        return p

    def rodar(self, jobs, modelo_padrao):
        pend, vistos = [], set(self.feitos)
        for j in jobs:  # dedupe por hash do prompt (retomada + repeticoes na entrada)
            m = j.get("modelo", modelo_padrao)
            h = hash_job(j, m)
            if h in vistos:
                continue
            vistos.add(h)
            pend.append((j, m, h))
        try:
            if self.batch:
                for bid in list(self._estado()):  # retoma batches ja enviados (nao reenvia nem paga 2x)
                    self._aguardar(bid)
                self._rodar_batch([p for p in pend if p[2] not in self.feitos])
            else:
                for j, m, h in pend:
                    if self.gasto + self._pior_caso(j, m) > self.teto:
                        raise Parar(f"orcamento atingido (gasto USD {self.gasto:.4f}, teto USD {self.teto:.4f})")
                    msg = json.loads(self._req("POST", BASE + "/v1/messages", self._params(j, m)))
                    self._registrar(j, m, h, msg, False)
        except Parar as e:
            return f"INTERROMPIDO: {self._scrub(e)}"
        return "CONCLUIDO"

    def _estado(self, novo=None):
        if novo is not None:
            with open(self.f_est, "w", encoding="utf-8") as f:
                json.dump(novo, f)
        if os.path.exists(self.f_est):
            with open(self.f_est, encoding="utf-8") as f:
                return json.load(f)
        return {}

    def _rodar_batch(self, pend):
        # shortcut: um batch por vez (envia, espera, contabiliza); simples e o teto vale sempre. Paralelizar so se o prazo exigir.
        for i in range(0, len(pend), self.tam_lote):
            parte = pend[i:i + self.tam_lote]
            pior = sum(self._pior_caso(j, m) for j, m, _ in parte)
            if self.gasto + pior > self.teto:
                raise Parar(f"orcamento atingido antes de enviar lote (gasto {self.gasto:.4f} + pior caso {pior:.4f} > teto {self.teto:.4f})")
            reqs = [{"custom_id": h, "params": self._params(j, m)} for j, m, h in parte]
            b = json.loads(self._req("POST", BASE + "/v1/messages/batches", {"requests": reqs}))
            est = self._estado()
            est[b["id"]] = {"jobs": {h: [j, m] for j, m, h in parte}}
            self._estado(est)
            self._aguardar(b["id"])

    def _aguardar(self, bid):
        while True:
            b = json.loads(self._req("GET", f"{BASE}/v1/messages/batches/{bid}"))
            if b.get("processing_status") == "ended":
                break
            self.dormir(self.espera_batch)
        est = self._estado()
        jobs = est.get(bid, {}).get("jobs", {})
        for ln in self._req("GET", b.get("results_url") or f"{BASE}/v1/messages/batches/{bid}/results").splitlines():
            if not ln.strip():
                continue
            r = json.loads(ln)
            h = r["custom_id"]
            if r["result"]["type"] == "succeeded" and h in jobs and h not in self.feitos:
                j, m = jobs[h]
                self._registrar(j, m, h, r["result"]["message"], True)
        est.pop(bid, None)
        self._estado(est)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--entrada", required=True)
    ap.add_argument("--modelo", choices=list(estimar.PRECOS), default="sonnet-5.5")
    ap.add_argument("--orcamento", type=float, default=100.0)
    ap.add_argument("--margem", type=float, default=0.30)
    ap.add_argument("--batch", action="store_true")
    ap.add_argument("--executar", action="store_true")
    ap.add_argument("--env-chave", default="ANTHROPIC_API_KEY", help="NOME da variavel de ambiente com a chave")
    ap.add_argument("--dir", default=os.path.dirname(os.path.abspath(__file__)))
    a = ap.parse_args(argv)
    jobs = lerjsonl(a.entrada)
    tot = sum(estimar.custo_chamada(j.get("modelo", a.modelo), estimar.tokens_aprox(j.get("system", "") + j["prompt"]), j.get("max_tokens", 1000), a.batch) for j in jobs)
    ok, com = estimar.checar_orcamento(tot, a.orcamento, a.margem)
    print(f"{len(jobs)} jobs; pior caso USD {tot:.4f}; com margem USD {com:.4f}; orcamento USD {a.orcamento:.2f}")
    if not a.executar:
        print("DRY-RUN (use --executar, chave no ambiente e arquivo AUTORIZADO para rodar de verdade).")
        return 0
    if not os.path.exists(os.path.join(a.dir, "AUTORIZADO")):
        print("RECUSADO: falta o arquivo AUTORIZADO (so o dono cria).", file=sys.stderr)
        return 3
    chave = os.environ.get(a.env_chave)
    if not chave:
        print(f"RECUSADO: variavel de ambiente {a.env_chave} ausente.", file=sys.stderr)
        return 3
    if not ok:
        print("RECUSADO: estimativa+margem excede o orcamento.", file=sys.stderr)
        return 2
    ex = Executor(a.dir, chave, HttpReal(), a.orcamento, a.margem, a.batch)
    print(ex.rodar(jobs, a.modelo), f"| gasto acumulado USD {ex.gasto:.4f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
