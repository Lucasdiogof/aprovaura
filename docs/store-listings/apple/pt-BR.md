# Apple App Store — pt-BR

> Fonte: docs/release/FATOS_ETAPA09.md. Contagens verificadas por script. Limites de nome/descrição da assinatura e do grupo: [INCERTO — confirmar no App Store Connect]; os valores abaixo respeitam 30 (nome) e 45 (descrição) por prudência.

## Informações do app

### Nome (10/30 chars)
```text
AprovaAura
```

### Subtítulo (25/30 chars)
```text
ENEM, simulados e redação
```

### Texto promocional (144/170 chars)
```text
Questões, simulados, revisão de erros e redação para o ENEM e vestibulares. Comece com 3 dias de teste, sem cartão. Depois, assinatura opcional.
```

### Palavras-chave (bytes UTF-8, sem espaços) (89/100 bytes)
```text
enem,vestibular,simulado,redação,questões,estudo,provas,revisão,erros,exame,matérias
```

### Descrição (1419/4000 chars)
```text
AprovaAura é o app de estudos para quem se prepara para o ENEM, vestibulares e outras provas no Brasil. Questões, simulados, revisão de erros e redação num só fluxo de estudo.

O QUE VOCÊ FAZ NO APP
• Questões por matéria e por tópico, com trilhas por assunto e filtro de dificuldade
• Simulados personalizados: escolha matérias, nível e número de questões
• Revisão de erros e favoritos, para voltar ao que você mais erra
• Prática rápida: uma rodada só com questões que você ainda não respondeu
• Redação: escreva sobre temas de proposta, salve rascunhos e acompanhe seus textos
• Aura e níveis: cada acerto rende Aura; o mascote Aurudo reage a metas diárias, sequências e subidas de nível
• Temas claro e escuro; português, inglês e espanhol
• Mesma conta no celular e na web

ASSINATURA PREMIUM
• Teste de 3 dias sem cartão, após confirmar seu e-mail (uma vez por pessoa).
• Depois do teste, o acesso completo é por assinatura: R$ 19,90 por mês ou R$ 190,00 por ano (cerca de 20% de economia sobre 12 meses).
• A assinatura renova automaticamente, a menos que seja cancelada ao menos 24 horas antes do fim do período. O pagamento é cobrado na sua conta da Apple. Gerencie ou cancele em Ajustes do iPhone > seu nome > Assinaturas.

LINKS
Política de Privacidade: https://lucksrei.com/projects/aura/privacy/
Termos de Uso: https://lucksrei.com/projects/aura/terms/
Suporte: https://lucksrei.com/projects/aura/support/
```

### Novidades desta versão (159/4000 chars)
```text
Melhorias gerais de desempenho e estabilidade. Prática rápida com questões inéditas, recuperação de senha pelo app, nova identidade visual e Home reorganizada.
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
### Nome de exibição (25/30 chars)
```text
AprovaAura Premium Mensal
```

### Descrição (32/45 chars)
```text
Acesso completo, renova todo mês
```

#### `aprovaura_premium_annual` — duração 1 ano, preço-base BRL R$ 190,00
### Nome de exibição (24/30 chars)
```text
AprovaAura Premium Anual
```

### Descrição (32/45 chars)
```text
Acesso completo, renova todo ano
```

