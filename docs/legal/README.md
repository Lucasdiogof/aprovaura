# docs/legal — Minutas jurídicas do AprovaAura

> Minuta para revisão jurídica — não constitui parecer; versão 2026-12-01; vigência só após publicação coordenada.

## Índice

| Documento | pt-BR | en | es |
|---|---|---|---|
| Termos de Uso | TERMOS_DE_USO.pt-BR.md | TERMOS_DE_USO.en.md | TERMOS_DE_USO.es.md |
| Política de Privacidade | POLITICA_DE_PRIVACIDADE.pt-BR.md | POLITICA_DE_PRIVACIDADE.en.md | POLITICA_DE_PRIVACIDADE.es.md |

Fonte de fatos: `docs/release/FATOS_ETAPA09.md`. EN/ES são traduções do pt-BR (mesmos preços e condições); em divergência vale o pt-BR. Política atual em produção: `aprovaura_privacy_policy.md` (2026-09-28), a ser substituída.

## Versionamento

- **Versão**: `2026-12-01` (data de emissão da minuta). Cada documento publicado tem número de versão e data de vigência próprios.
- **Vigência**: só após publicação coordenada com a ativação comercial (flags `enforcement_enabled`, confirmação de e-mail e provedores hoje desligados). Termos ainda não estão em `legal_documents`; privacidade publicada é a de 2026-09-28.
- **Idiomas**: pt-BR, en, es — publicar os três da mesma versão, juntos.
- **Publicação**: RPC `publish_legal_version` (migration 20261201000100), que grava a versão em `legal_documents`.
- **Re-aceite**: mudança material (preço, renovação, direitos/deveres, finalidades de dados) exige nova versão e novo aceite do usuário (registro de aceites por versão); mudança editorial não exige. Aviso prévio razoável antes da vigência.
- URLs públicas: Termos https://lucksrei.com/projects/aura/terms/ · Privacidade https://lucksrei.com/projects/aura/privacy/ (não quebrar) · Exclusão https://lucksrei.com/projects/aura/data-deletion/ · Suporte https://lucksrei.com/projects/aura/support/.

## Lacunas [PENDENTE-DONO] consolidadas

Dados do responsável (Termos e Política):
1. Razão social: **preenchido** (Lucas Diogo Franca, marca Lucksrei, como no site oficial)
2. CNPJ: **preenchido** (54.868.173/0001-55, do site oficial)
3. Endereço: **ÚNICO dado indispensável ainda faltante (dono)**
4. Canal de suporte/privacidade: **preenchido** (marketing@lucksrei.com, já publicado em `…/support/`)
5. Encarregado: minutas indicam o próprio controlador; dispensa a confirmar com advogado (Res. CD/ANPD 2/2022)

Decisões bloqueadoras:
6. Idade mínima do serviço. **Decidido (24/11): app NÃO restrito a 18+** (público ENEM/vestibular, inclui adolescentes). Resta definir o piso (hoje o app aceita a faixa "menor de 13") com advogado
7. Regras para menores de 18 anos; uso por menores de 12 e consentimento dos responsáveis; vínculo com professor para menores; assinatura por menores (Family Sharing/Ask to Buy, Family Link)
8. Gemini: **decidido (24/11)**: integração mantida, envio SUSPENSO até haver solução compatível com termos do provedor e adolescentes; sem IA paga; sem novos provedores; IA só para correção de redação (sem chatbot), 3/dia. Minutas já refletem isso
9. Informar na Política a camada/provedor efetivos **somente ao reativar o envio** (hoje: suspenso, nada é enviado)
10. Prazo de guarda fiscal dos dados financeiros (contador)
11. Prazo de guarda do registro de aceites
12. Mecanismo de transferência internacional e regiões de cada provedor
13. RIPD e revisão por advogado de todas as minutas

Incertos (do FATOS, não afirmados nos textos): aplicação do CDC art. 49 a assinatura digital in-app; reembolso via Apple/Google conforme política da loja; prazo exato dos logs do Gemini (camada paga); nível de verificação de idade exigido pela ANPD.

## Fontes legais citadas (todas do FATOS_ETAPA09)

- CDC (Lei 8.078/1990), art. 49 — arrependimento de 7 dias
- Decreto 7.962/2013 — contratação eletrônica (identificação do fornecedor, cancelamento eletrônico, resposta em até 5 dias)
- LGPD (Lei 13.709/2018): art. 7º (bases legais), art. 14 (crianças e adolescentes; melhor interesse), arts. 15–16 (término do tratamento), art. 18 (direitos); Enunciado CD/ANPD 1/2023
- Marco Civil da Internet, art. 15 — registros de acesso por 6 meses
- ECA Digital (Lei 15.211/2025) e Decreto 12.880/2026; ECA art. 2º (definição de criança)
- Código Civil — capacidade (menores de 16 e 16–17; art. 180)
- Termos da API Gemini: https://aistudio.google.com/docs/terms (efetivo 23/03/2026)

Observação: os arts. 18 e 33 da LGPD aparecem nos textos como referência de direitos do titular e de transferência internacional, mas o FATOS não os detalha; o revisor jurídico deve confirmá-los.
