# Apple App Store — es

> Fonte: docs/release/FATOS_ETAPA09.md. Contagens verificadas por script. Limites de nome/descrição da assinatura e do grupo: [INCERTO — confirmar no App Store Connect]; os valores abaixo respeitam 30 (nome) e 45 (descrição) por prudência.

## Informações do app

### Nome (10/30 chars)
```text
AprovaAura
```

### Subtítulo (28/30 chars)
```text
ENEM, simulacros y redacción
```

### Texto promocional (148/170 chars)
```text
Preguntas, simulacros, repaso de errores y redacción con corrección por IA para el ENEM. 3 días de prueba sin tarjeta. Suscripción opcional después.
```

### Palavras-chave (bytes UTF-8, sem espaços) (83/100 bytes)
```text
enem,vestibular,simulacro,redacción,preguntas,estudio,examen,repaso,errores,brasil
```

### Descrição (1672/4000 chars)
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
• La suscripción se renueva automáticamente salvo que se cancele al menos 24 horas antes del fin del período. El pago se carga a tu cuenta de Apple. Gestiona o cancela en Ajustes del iPhone > tu nombre > Suscripciones.

SOBRE LA CORRECCIÓN POR IA
La nota de la redacción es una estimación hecha por inteligencia artificial para apoyar tu práctica. No garantiza resultado en ningún examen ni sustituye la evaluación de un profesor.

ENLACES
Política de Privacidad: https://lucksrei.com/projects/aura/privacy/
Términos de Uso: https://lucksrei.com/projects/aura/terms/
Soporte: https://lucksrei.com/projects/aura/support/
```

### Novidades desta versão (167/4000 chars)
```text
Mejoras generales de rendimiento y estabilidad. Práctica rápida con preguntas nuevas, recuperación de contraseña en la app, nueva identidad visual y Home reorganizada.
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
AprovaAura Premium Mensual
```

### Descrição (34/45 chars)
```text
Acceso completo, se renueva al mes
```

#### `aprovaura_premium_annual` — duração 1 ano, preço-base BRL R$ 190,00
### Nome de exibição (24/30 chars)
```text
AprovaAura Premium Anual
```

### Descrição (34/45 chars)
```text
Acceso completo, se renueva al año
```

