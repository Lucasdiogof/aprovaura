#!/usr/bin/env python3
"""Estimativa de custo (DRY-RUN; nunca chama rede). Precos: platform.claude.com/docs/en/about-claude/pricing (consulta 2026-11-27).
Uso: python estimar.py --tarefa autoral --n 500 --modelo sonnet-5.5 --batch --cache [--orcamento 100 --margem 0.30]
     python estimar.py --tabela            (compara modelos/tarefas por 1 questao e quantas cabem no orcamento)
     python estimar.py --arquivo jobs.jsonl --modelo haiku-5.5 --batch   (tokens aproximados a partir do texto)
"""
import argparse, json, math, sys

# USD por 1M tokens: entrada, saida, leitura de cache (escrita 5m = 1.25x entrada). Batch = 50% em tudo.
PRECOS = {
    "haiku-5.5": {"id": "claude-haiku-5-5", "in": 0.10, "out": 0.50, "cache_read": 0.01},   # ate 100k tokens de prompt
    "sonnet-5.5": {"id": "claude-sonnet-5-5", "in": 2.0, "out": 10.0, "cache_read": 0.10},
    "opus-5.5": {"id": "claude-opus-5-5", "in": 4.0, "out": 20.0, "cache_read": 0.20},
    "fable-5.2": {"id": "claude-fable-5-2", "in": 8.0, "out": 40.0, "cache_read": 0.20},
}
BATCH_DESC = 0.5
CACHE_WRITE = 1.25
# Premissas (tokens por questao; tokenizer novo ~ +30%): entrada total, parte cacheavel (instrucoes fixas), saida.
TAREFAS = {
    "autoral": {"in": 1500, "cache": 1200, "out": 900},
    "validacao": {"in": 1500, "cache": 1000, "out": 400},
    "revisao_explicacao": {"in": 1300, "cache": 900, "out": 500},
    "classificacao": {"in": 900, "cache": 700, "out": 100},
    "traducao": {"in": 1200, "cache": 600, "out": 1300},
}

def tokens_aprox(texto):
    """~3 caracteres/token para pt-BR no tokenizer novo (conservador)."""
    return math.ceil(len(texto) / 3.0)

def custo_chamada(modelo, tin, tout, batch=False, cache_tokens=0, cache_hit=False):
    """Custo USD de uma chamada. cache_tokens: parte de tin cacheada (escrita se nao hit, leitura se hit)."""
    p = PRECOS[modelo]
    normal = tin - cache_tokens
    c = normal * p["in"]
    c += cache_tokens * (p["cache_read"] if cache_hit else p["in"] * CACHE_WRITE)
    c += tout * p["out"]
    c /= 1e6
    return c * (BATCH_DESC if batch else 1)

def custo_questao(modelo, tarefa, batch=False, cache=False, n=1):
    t = TAREFAS[tarefa]
    if not cache:
        return custo_chamada(modelo, t["in"], t["out"], batch) * n
    # 1 escrita + (n-1) leituras (otimista: cache vivo; batch nao garante hit -> conservador abaixo)
    hits = (n - 1) * 0.5 if batch else (n - 1)  # shortcut: em batch assume so 50% de hits
    w = n - hits
    return (custo_chamada(modelo, t["in"], t["out"], batch, t["cache"], False) * w
            + custo_chamada(modelo, t["in"], t["out"], batch, t["cache"], True) * hits)

def pipeline_completo(modelo, batch, cache, n=1):
    return sum(custo_questao(modelo, t, batch, cache, n) for t in TAREFAS)

def checar_orcamento(estimado, orcamento, margem):
    """Retorna (ok, estimado_com_margem)."""
    com = estimado * (1 + margem)
    return com <= orcamento, com

def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--tarefa", choices=list(TAREFAS))
    ap.add_argument("--n", type=int, default=1)
    ap.add_argument("--modelo", choices=list(PRECOS), default="sonnet-5.5")
    ap.add_argument("--batch", action="store_true")
    ap.add_argument("--cache", action="store_true")
    ap.add_argument("--orcamento", type=float, default=100.0, help="USD maximo")
    ap.add_argument("--margem", type=float, default=0.30)
    ap.add_argument("--arquivo", help="JSONL de jobs {materia,system,prompt,max_tokens}; estima por materia")
    ap.add_argument("--tabela", action="store_true")
    a = ap.parse_args(argv)
    if a.tabela:
        print(f"{'modelo':11}{'batch':6}{'cache':6}{'pipeline/q USD':>15}{'q em orcamento (margem)':>26}")
        for m in PRECOS:
            for b in (False, True):
                for c in (False, True):
                    cq = pipeline_completo(m, b, c, n=100) / 100
                    print(f"{m:11}{str(b):6}{str(c):6}{cq:15.4f}{int(a.orcamento / (1 + a.margem) / cq):26d}")
        for t in TAREFAS:
            print(t, {m: round(custo_questao(m, t, True, True, 100) / 100, 5) for m in PRECOS}, "(batch+cache, USD/q)")
        return 0
    if a.arquivo:
        por = {}
        with open(a.arquivo, encoding="utf-8") as f:
            for ln in f:
                if ln.strip():
                    j = json.loads(ln)
                    tin = tokens_aprox(j.get("system", "") + j["prompt"])
                    c = custo_chamada(a.modelo, tin, j.get("max_tokens", 1000), a.batch)  # pior caso: usa max_tokens
                    d = por.setdefault(j.get("materia", "?"), [0, 0.0]); d[0] += 1; d[1] += c
        total = sum(v[1] for v in por.values())
        for k, (n, c) in sorted(por.items()): print(f"{k}: {n} jobs, ~USD {c:.4f}")
    else:
        if not a.tarefa: ap.error("informe --tarefa, --arquivo ou --tabela")
        total = custo_questao(a.modelo, a.tarefa, a.batch, a.cache, a.n)
    ok, com = checar_orcamento(total, a.orcamento, a.margem)
    print(f"estimado USD {total:.4f}; com margem {a.margem:.0%}: USD {com:.4f}; orcamento USD {a.orcamento:.2f}")
    if not ok:
        print("RECUSADO: estimativa+margem excede o orcamento.", file=sys.stderr)
        return 2
    print("OK (dry-run: nada foi executado).")
    return 0

if __name__ == "__main__":
    sys.exit(main())
