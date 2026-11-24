"""Modelo de custo da correção de redação por IA (OpenAI API). Cálculo puro: NENHUMA chamada de rede, nenhum custo.

Preços: página oficial developers.openai.com/api/docs/pricing lida em 2026-11-24 (sem data/versão visível na página;
conferir na página ao vivo antes de contratar). USD por 1M tokens, tier Standard, contexto curto.
Uso: python tool/qa/essay_ai_cost_model.py            (imprime as tabelas em Markdown)
     python tool/qa/essay_ai_cost_model.py --check     (autoteste das contas)
Todas as premissas de uso são HIPÓTESES (não há uso real: 6 redações de teste em produção)."""
import sys

FX = 5.50            # R$ por US$ (premissa; sensibilidade abaixo)
PRICE = 19.90        # mensalidade bruta (R$)
NET = 16.91          # líquido após taxa do provedor (caso A homologado: 19,90 - 2,99)
COMMISSION = 0.50    # comissão padrão do professor sobre o LÍQUIDO (piso do líquido x bps)
BUFFER = 0.10        # folga p/ IOF/tributos de importação de serviço e variação de câmbio (premissa)

# modelo: (entrada, entrada em cache, saída) em US$/1M tokens
MODELS = {
    "gpt-6-luna": (0.10, 0.01, 0.50),
    "gpt-6.1-terra": (1.00, 0.05, 5.00),
    "gpt-6.2-sol": (2.00, 0.10, 10.00),
}
# tokens por correção (entrada, saída). Medido no Gemini: ~850 in + ~900 out em redação curta sintética.
# Redação real (900 palavras) + rubrica + tema/textos motivadores: ~2.400 in. Saída inclui raciocínio (cobrado como saída: PREMISSA, não confirmado na página).
TOKENS = {
    "leve (sem raciocínio)": (2400, 1000),
    "moderado (com raciocínio)": (2400, 3000),
    "máximo (texto longo + raciocínio alto)": (4000, 6000),
}
# correções por assinante por mês
PROFILES = {"ocasional": 2, "médio": 8, "intenso": 30, "máximo da franquia (3/dia x 30)": 90}
# mistura de assinantes (ocasional, médio, intenso, máximo): HIPÓTESES
MIXES = {"conservadora": (0.70, 0.25, 0.05, 0.00), "esperada": (0.50, 0.35, 0.12, 0.03), "estresse": (0.20, 0.30, 0.30, 0.20)}
SUBS = (100, 500, 1000, 5000)


def per_correction_usd(model, tok, cached_share=0.0):
    pin, pc, pout = MODELS[model]
    tin, tout = TOKENS[tok]
    cin = tin * cached_share  # parte estática do prompt servida do cache
    return ((tin - cin) * pin + cin * pc + tout * pout) / 1e6


def brl(usd):
    return usd * FX * (1 + BUFFER)


def mix_avg_corrections(mix):
    return sum(p * n for p, n in zip(mix, PROFILES.values()))


def margin_per_sub(avg_cost_brl, teacher_share):
    # Lucksrei fica com o líquido menos a comissão (só dos alunos vinculados) menos o custo de IA
    return NET - NET * COMMISSION * teacher_share - avg_cost_brl


def main():
    print(f"Premissas: US$1 = R${FX:.2f}; folga {BUFFER:.0%}; mensalidade R${PRICE}; líquido R${NET} (taxa R${PRICE-NET:.2f}); comissão {COMMISSION:.0%} do líquido.\n")
    print("### Custo por correção (R$, com câmbio e folga)\n")
    print("| Modelo | " + " | ".join(TOKENS) + " |\n|---|" + "---|" * len(TOKENS))
    for m in MODELS:
        print(f"| {m} | " + " | ".join(f"R$ {brl(per_correction_usd(m, t)):.4f}" for t in TOKENS) + " |")
    print("\n### Custo mensal por assinante (cenário de tokens 'moderado')\n")
    print("| Modelo | " + " | ".join(PROFILES) + " |\n|---|" + "---|" * len(PROFILES))
    for m in MODELS:
        c = brl(per_correction_usd(m, "moderado (com raciocínio)"))
        print(f"| {m} | " + " | ".join(f"R$ {c*n:.2f} ({c*n/NET:.1%} do líquido)" for n in PROFILES.values()) + " |")
    print("\n### Pior caso por assinante (90 correções/mês com tokens 'máximo')\n")
    for m in MODELS:
        c = brl(per_correction_usd(m, "máximo (texto longo + raciocínio alto)")) * 90
        print(f"- {m}: R$ {c:.2f}/mês = {c/NET:.0%} do líquido de R${NET}")
    print("\n### Custo mensal total e margem (tokens 'moderado')\n")
    for m in MODELS:
        c = brl(per_correction_usd(m, "moderado (com raciocínio)"))
        print(f"\n**{m}**\n\n| Mistura | Corr./assin./mês | Assinantes | Custo IA/mês | % do líquido | Margem/assin. sem professor | Margem/assin. 100% com professor |\n|---|---|---|---|---|---|---|")
        for mn, mix in MIXES.items():
            avg = mix_avg_corrections(mix)
            for s in SUBS:
                cost = c * avg * s
                print(f"| {mn} | {avg:.1f} | {s} | R$ {cost:,.0f} | {c*avg/NET:.1%} | R$ {margin_per_sub(c*avg,0):.2f} | R$ {margin_per_sub(c*avg,1):.2f} |")
    print(f"\n### Ponto de equilíbrio: correções/mês por assinante em que a IA consome 10% / 25% / 50% da margem do Lucksrei (com professor, R$ {NET * (1 - COMMISSION):.2f})\n")
    for m in MODELS:
        c = brl(per_correction_usd(m, "moderado (com raciocínio)"))
        print(f"- {m}: " + " / ".join(f"{NET*(1-COMMISSION)*f/c:.0f}" for f in (0.10, 0.25, 0.50)))
    print("\n### Sensibilidade ao câmbio (gpt-6.1-terra, moderado, mistura esperada, 1000 assinantes)\n")
    avg = mix_avg_corrections(MIXES["esperada"])
    for fx in (5.0, 5.5, 6.0, 6.5):
        c = per_correction_usd("gpt-6.1-terra", "moderado (com raciocínio)") * fx * (1 + BUFFER)
        print(f"- US$1 = R${fx:.2f}: R$ {c*avg*1000:,.0f}/mês")
    print("\n### Efeito do cache do prompt estático (900 de 2.400 tokens de entrada), gpt-6.1-terra, moderado\n")
    a = per_correction_usd("gpt-6.1-terra", "moderado (com raciocínio)")
    b = per_correction_usd("gpt-6.1-terra", "moderado (com raciocínio)", cached_share=900 / 2400)
    print(f"- sem cache US$ {a:.5f}; com cache US$ {b:.5f} ({1-b/a:.1%} menos). A saída domina o custo; cache importa pouco.")
    print("\n### Custo da bateria de avaliação futura (NÃO executada; exige autorização)\n")
    n_calls = 40 * 3 * len(MODELS)
    tot = sum(per_correction_usd(m, "moderado (com raciocínio)") * 40 * 3 for m in MODELS)
    print(f"- 40 redações x 3 repetições x {len(MODELS)} modelos = {n_calls} chamadas ≈ US$ {tot:.2f} (≈ R$ {brl(tot):.2f}).")


def check():
    # luna, leve: (2400*0.10 + 1000*0.50)/1e6 = 0.00074 USD
    assert abs(per_correction_usd("gpt-6-luna", "leve (sem raciocínio)") - 0.00074) < 1e-9
    # terra, moderado: (2400*1 + 3000*5)/1e6 = 0.0174
    assert abs(per_correction_usd("gpt-6.1-terra", "moderado (com raciocínio)") - 0.0174) < 1e-9
    # cache nunca encarece
    assert per_correction_usd("gpt-6.1-terra", "leve (sem raciocínio)", 0.4) < per_correction_usd("gpt-6.1-terra", "leve (sem raciocínio)")
    # mistura soma 1 e margem com professor < sem professor
    assert all(abs(sum(m) - 1) < 1e-9 for m in MIXES.values())
    assert margin_per_sub(1.0, 1) < margin_per_sub(1.0, 0)
    print("ok")


if __name__ == "__main__":
    check() if "--check" in sys.argv else main()
