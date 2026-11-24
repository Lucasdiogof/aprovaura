# Apple App Store — en

> Fonte: docs/release/FATOS_ETAPA09.md. Contagens verificadas por script. Limites de nome/descrição da assinatura e do grupo: [INCERTO — confirmar no App Store Connect]; os valores abaixo respeitam 30 (nome) e 45 (descrição) por prudência.

## Informações do app

### Nome (10/30 chars)
```text
AprovaAura
```

### Subtítulo (24/30 chars)
```text
ENEM mock exams & essays
```

### Texto promocional (146/170 chars)
```text
Questions, mock exams, mistake review and essay practice for Brazil's ENEM. Start with a 3-day trial, no card needed. Optional subscription after.
```

### Palavras-chave (bytes UTF-8, sem espaços) (89/100 bytes)
```text
enem,vestibular,mock exam,essay,questions,study,exam prep,review,mistakes,brazil,practice
```

### Descrição (1358/4000 chars)
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
• The subscription renews automatically unless canceled at least 24 hours before the end of the period. Payment is charged to your Apple account. Manage or cancel in iPhone Settings > your name > Subscriptions.

LINKS
Privacy Policy: https://lucksrei.com/projects/aura/privacy/
Terms of Use: https://lucksrei.com/projects/aura/terms/
Support: https://lucksrei.com/projects/aura/support/
```

### Novidades desta versão (158/4000 chars)
```text
General performance and stability improvements. Quick practice with new questions, password recovery in the app, a new visual identity and a reorganized Home.
```

## URLs

| Campo | Valor |
|---|---|
| URL de suporte | https://lucksrei.com/projects/aura/support/ |
| URL de privacidade (obrigatória) | https://lucksrei.com/projects/aura/privacy/ |
| URL de marketing | https://lucksrei.com/projects/aura/ |
| Termos de Uso (EULA) | https://lucksrei.com/projects/aura/terms/ — ver observação abaixo |

**Observação sobre EULA:** o que o App Store Connect aceita como EULA próprio × padrão Apple (Licensed Application EULA) é **[INCERTO — confirmar no App Store Connect]**. Os Termos de Uso próprios ainda NÃO estão publicados em `legal_documents` (FATOS §8): a URL acima só pode ser usada quando a página existir. Até lá, manter o EULA padrão da Apple e linkar a Política de Privacidade (que existe). **[PENDENTE-DONO: decidir EULA padrão × próprio.]**

## Assinaturas (grupo e produtos)

- Grupo de assinatura (nome de referência): AprovaAura Premium
- Product IDs (catálogo semeado em `supabase/migrations/20261129000100_payment_integrations.sql`; confirmar que o ID criado no App Store Connect é idêntico): `aprovaura_premium_monthly`, `aprovaura_premium_annual`.
- Sem oferta introdutória Apple: o teste de 72h é do próprio app (sem cartão) e não é cadastrado na Apple.

#### `aprovaura_premium_monthly` — duração 1 mês, preço-base BRL R$ 19,90
### Nome de exibição (26/30 chars)
```text
AprovaAura Premium Monthly
```

### Descrição (27/45 chars)
```text
Full access, renews monthly
```

#### `aprovaura_premium_annual` — duração 1 ano, preço-base BRL R$ 190,00
### Nome de exibição (25/30 chars)
```text
AprovaAura Premium Yearly
```

### Descrição (26/45 chars)
```text
Full access, renews yearly
```

