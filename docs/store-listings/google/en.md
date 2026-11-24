# Google Play — en

> Fonte: docs/release/FATOS_ETAPA09.md. Contagens verificadas por script. Limite das notas da versão (500) e limites de nome/benefícios da assinatura: [INCERTO — confirmar no Play Console].

## Ficha principal

### Título (26/30 chars)
```text
AprovaAura: ENEM Exam Prep
```

### Descrição curta (75/80 chars)
```text
Questions, mock exams, mistake review and essay practice for Brazil's ENEM.
```

### Descrição completa (1344/4000 chars)
```text
AprovaAura is a study app for Brazil's ENEM, university entrance exams and other tests. Questions, mock exams, mistake review and essay writing in a single study flow.

WHAT YOU CAN DO
• Questions by subject and topic, with subject paths and a difficulty filter
• Custom mock exams: pick subjects, level and number of questions
• Mistake review and favorites, to go back to what you miss the most
• Quick practice: one round of questions you have never answered
• Essays: write on exam-style prompts, save drafts and track your texts
• Aura and levels: every correct answer earns Aura; the mascot Aurudo reacts to daily goals, streaks and level-ups
• Light and dark themes; Portuguese, English and Spanish
• One account on your phone and on the web

PREMIUM SUBSCRIPTION
• 3-day trial with no card, after you confirm your email (once per person).
• After the trial, full access is by subscription: R$ 19.90 per month or R$ 190.00 per year (about 20% less than 12 months).
• The subscription renews automatically until canceled. Payment is charged to your Google Play account. Manage or cancel anytime in Play Store > Profile > Payments & subscriptions > Subscriptions.

LINKS
Privacy Policy: https://lucksrei.com/projects/aura/privacy/
Terms of Use: https://lucksrei.com/projects/aura/terms/
Support: https://lucksrei.com/projects/aura/support/
```

### Notas da versão (144/500 chars)
```text
Performance and stability improvements. Quick practice with questions you have not answered, in-app password recovery and a new visual identity.
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
- Questions and mock exams, all subjects (38/40 chars)
- Essay writing with saved drafts (31/40 chars)
- Mistake review and favorites (28/40 chars)
- One account on phone and web (28/40 chars)

### Descrição do produto (50/80 chars)
```text
Full access to AprovaAura, with automatic renewal.
```

| Base plan | Preço (BRL) | Período | Texto de apoio |
|---|---|---|---|
| `monthly` | 19,90 | 1 mês, renovação automática | Monthly: R$ 19.90, renews every month |
| `annual` | 190,00 | 1 ano, renovação automática | Yearly: R$ 190.00, renews every year |

O plano anual deve aparecer também como preço total (R$ 190,00/ano) no paywall; link de cancelamento: Play Store > Pagamentos e assinaturas > Assinaturas.
