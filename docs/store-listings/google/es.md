# Google Play — es

> Fonte: docs/release/FATOS_ETAPA09.md. Contagens verificadas por script. Limite das notas da versão (500) e limites de nome/benefícios da assinatura: [INCERTO — confirmar no Play Console].

## Ficha principal

### Título (29/30 chars)
```text
AprovaAura: ENEM y Vestibular
```

### Descrição curta (73/80 chars)
```text
Preguntas, simulacros, repaso de errores y redacción con IA para el ENEM.
```

### Descrição completa (1663/4000 chars)
```text
AprovaAura es la app de estudio para quien se prepara para el ENEM, exámenes de ingreso universitario y otras pruebas en Brasil. Preguntas, simulacros, repaso de errores y redacción en un solo flujo de estudio.

QUÉ PUEDES HACER
• Preguntas por materia y por tema, con rutas por asunto y filtro de dificultad
• Simulacros personalizados: elige materias, nivel y número de preguntas
• Repaso de errores y favoritos, para volver a lo que más fallas
• Práctica rápida: una ronda solo con preguntas que aún no respondiste
• Redacción con corrección por IA: nota estimada de 0 a 1000, con puntuación por competencia
• Aura y niveles: cada acierto da Aura; la mascota Aurudo reacciona a metas diarias, rachas y subidas de nivel
• Temas claro y oscuro; portugués, inglés y español
• Una misma cuenta en el móvil y en la web

SUSCRIPCIÓN PREMIUM
• Prueba de 3 días sin tarjeta, después de confirmar tu correo (una vez por persona).
• Pasada la prueba, el acceso completo es por suscripción: R$ 19,90 al mes o R$ 190,00 al año (cerca de 20% menos que 12 meses).
• La suscripción se renueva automáticamente hasta que la canceles. El pago se carga a tu cuenta de Google Play. Gestiona o cancela cuando quieras en Play Store > Perfil > Pagos y suscripciones > Suscripciones.

SOBRE LA CORRECCIÓN POR IA
La nota de la redacción es una estimación hecha por inteligencia artificial para apoyar tu práctica. No garantiza resultado en ningún examen ni sustituye la evaluación de un profesor.

ENLACES
Política de Privacidad: https://lucksrei.com/projects/aura/privacy/
Términos de Uso: https://lucksrei.com/projects/aura/terms/
Soporte: https://lucksrei.com/projects/aura/support/
```

### Notas da versão (150/500 chars)
```text
Mejoras de rendimiento y estabilidad. Práctica rápida con preguntas que no respondiste, recuperación de contraseña en la app y nueva identidad visual.
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
- Preguntas y simulacros completos (32/40 chars)
- Redacción con corrección por IA (31/40 chars)
- Repaso de errores y favoritos (29/40 chars)
- Una cuenta en móvil y web (25/40 chars)

### Descrição do produto (56/80 chars)
```text
Acceso completo a AprovaAura, con renovación automática.
```

| Base plan | Preço (BRL) | Período | Texto de apoio |
|---|---|---|---|
| `monthly` | 19,90 | 1 mês, renovação automática | Mensual: R$ 19,90, se renueva cada mes |
| `annual` | 190,00 | 1 ano, renovação automática | Anual: R$ 190,00, se renueva cada año |

O plano anual deve aparecer também como preço total (R$ 190,00/ano) no paywall; link de cancelamento: Play Store > Pagamentos e assinaturas > Assinaturas.
