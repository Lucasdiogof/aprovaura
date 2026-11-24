# Google Play — pt-BR

> Fonte: docs/release/FATOS_ETAPA09.md. Contagens verificadas por script. Limite das notas da versão (500) e limites de nome/benefícios da assinatura: [INCERTO — confirmar no Play Console].

## Ficha principal

### Título (29/30 chars)
```text
AprovaAura: ENEM e Vestibular
```

### Descrição curta (80/80 chars)
```text
Questões, simulados, revisão de erros e redação com correção por IA para o ENEM.
```

### Descrição completa (1618/4000 chars)
```text
AprovaAura é o app de estudos para quem se prepara para o ENEM, vestibulares e outras provas no Brasil. Questões, simulados, revisão de erros e redação num só fluxo de estudo.

O QUE VOCÊ FAZ NO APP
• Questões por matéria e por tópico, com trilhas por assunto e filtro de dificuldade
• Simulados personalizados: escolha matérias, nível e número de questões
• Revisão de erros e favoritos, para voltar ao que você mais erra
• Prática rápida: uma rodada só com questões que você ainda não respondeu
• Redação com correção por IA: nota estimada de 0 a 1000, com pontuação por competência
• Aura e níveis: cada acerto rende Aura; o mascote Aurudo reage a metas diárias, sequências e subidas de nível
• Temas claro e escuro; português, inglês e espanhol
• Mesma conta no celular e na web

ASSINATURA PREMIUM
• Teste de 3 dias sem cartão, após confirmar seu e-mail (uma vez por pessoa).
• Depois do teste, o acesso completo é por assinatura: R$ 19,90 por mês ou R$ 190,00 por ano (cerca de 20% de economia sobre 12 meses).
• A assinatura renova automaticamente até ser cancelada. O pagamento é cobrado na sua conta do Google Play. Gerencie ou cancele a qualquer momento em Play Store > Perfil > Pagamentos e assinaturas > Assinaturas.

SOBRE A CORREÇÃO POR IA
A nota da redação é uma estimativa feita por inteligência artificial para apoiar seu treino. Ela não garante resultado em nenhuma prova nem substitui a avaliação de um professor.

LINKS
Política de Privacidade: https://lucksrei.com/projects/aura/privacy/
Termos de Uso: https://lucksrei.com/projects/aura/terms/
Suporte: https://lucksrei.com/projects/aura/support/
```

### Notas da versão (153/500 chars)
```text
Melhorias de desempenho e estabilidade. Prática rápida com questões que você ainda não respondeu, recuperação de senha pelo app e nova identidade visual.
```

## Assinatura

- Produto de assinatura (ID do catálogo semeado em `supabase/migrations/20261129000100_payment_integrations.sql`; confirmar no Play Console): `aprovaura_premium`, com dois base plans: `monthly` e `annual`.
- Os dois base plans: renovação automática (auto-renewing), moeda BRL.
- **Não criar oferta nem SKU chamado "free trial".** O teste de 72h é do próprio app (sem cartão, sem cobrança automática) e NÃO é oferta da loja.

### Nome do produto (18/55 chars)
```text
AprovaAura Premium
```

Benefícios (limite por item [INCERTO — confirmar no Play Console]; mantidos em 40 caracteres ou menos):
- Questões e simulados, todas as matérias (39/40 chars)
- Redação com correção por IA (27/40 chars)
- Revisão de erros e favoritos (28/40 chars)
- Mesma conta no celular e na web (31/40 chars)

### Descrição do produto (56/80 chars)
```text
Acesso completo ao AprovaAura, com renovação automática.
```

| Base plan | Preço (BRL) | Período | Texto de apoio |
|---|---|---|---|
| `monthly` | 19,90 | 1 mês, renovação automática | Mensal: R$ 19,90, renova todo mês |
| `annual` | 190,00 | 1 ano, renovação automática | Anual: R$ 190,00, renova todo ano |

O plano anual deve aparecer também como preço total (R$ 190,00/ano) no paywall; link de cancelamento: Play Store > Pagamentos e assinaturas > Assinaturas.
