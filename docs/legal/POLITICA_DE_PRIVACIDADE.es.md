# Política de Privacidad — AprovaAura

> Borrador para revisión jurídica — no constituye dictamen; versión 2026-12-01; vigencia solo tras publicación coordinada.
> (Traducción del borrador en portugués de Brasil. En caso de divergencia, prevalece el texto pt-BR.)

Esta Política explica qué datos trata AprovaAura, para qué, con quién los compartimos y cuáles son tus derechos (Ley General de Protección de Datos de Brasil — LGPD). Sustituye a la política del 28/09/2026 cuando se publique.

## 1. Responsable y contacto

Responsable: **[PENDENTE-DONO: razón social]**, CNPJ **[PENDENTE-DONO: CNPJ]**, **[PENDENTE-DONO: dirección]**.
Delegado de protección de datos (DPO): **[PENDENTE-DONO: nombre y contacto del encargado]**.
Canal de privacidad y soporte: **[PENDENTE-DONO: correo/canal oficial]** · https://lucksrei.com/projects/aura/support/

## 2. Datos que tratamos

| Categoría | Ejemplos |
|---|---|
| Cuenta | correo, contraseña (protegida por el proveedor de autenticación), confirmación de correo |
| Perfil | nombre, nombre de usuario y foto (opcionales), objetivo de estudio, año del examen, materias de interés, idioma, tema |
| Rango de edad | **solo el rango declarado** (menor de 13, 13–15, 16–17 o adulto). **No recopilamos fecha de nacimiento.** |
| Estudio | respuestas, progreso por materia/tema, simulacros, racha de días y puntos |
| Redacciones | tema, texto, borrador y resultado de la corrección (nota estimada y comentarios) |
| Profesor | vínculo con un profesor asociado (cuando exista) y tus consentimientos |
| Suscripción y pagos | plan, período, importes e identificadores de transacción. **No recibimos ni guardamos números de tarjeta.** |
| Aceptaciones | registro de qué versión de los Términos y de esta Política aceptaste, y cuándo |
| Registros de acceso | dirección IP y fecha/hora de acceso, según exige la ley |

## 3. Finalidades y bases legales (LGPD, art. 7)

| Finalidad | Base legal |
|---|---|
| Crear y mantener tu cuenta, autenticar, confirmar correo, enviar correos transaccionales | Ejecución de contrato (art. 7, V) |
| Prestar el Servicio: preguntas, simulacros, progreso, personalización por materias | Ejecución de contrato (art. 7, V) |
| Corregir redacciones por IA cuando lo solicites | Ejecución de contrato (art. 7, V), a tu pedido; ver apartado 5 |
| Cobro, acceso de pago, conciliación financiera, cortesías | Ejecución de contrato (art. 7, V) y obligación legal (art. 7, II) |
| Conservación de registros de acceso y de datos fiscales/financieros | Obligación legal (art. 7, II) |
| Compartir tus estadísticas con el profesor que te refirió | **Consentimiento** específico y revocable (art. 7, I) |
| Seguridad, prevención de fraude y abuso, diagnóstico de fallas | Interés legítimo (art. 7, IX), con evaluación de impacto y sin perjudicar tus derechos |
| Registrar tus aceptaciones de Términos y Política | Obligación legal y ejercicio regular de derechos (art. 7, II y VI) |

No vendemos datos, y **no hacemos perfilado conductual ni publicidad conductual**.

## 4. Con quién compartimos (encargados del tratamiento)

Estos proveedores tratan datos en nuestro nombre, en la medida necesaria:

| Proveedor | Qué recibe |
|---|---|
| **Supabase** (base de datos, autenticación, funciones, almacenamiento) | cuenta, perfil, progreso, respuestas, redacciones, vínculo con profesor, consentimientos, registros de pago (importes e IDs de transacción, sin tarjeta) y aceptaciones |
| **Cloudflare** (alojamiento web y entrega de contenido) | datos de red necesarios para entregar la app web (como la IP), contenido servido |
| **Google Gemini** (API de IA) | solo tema, textos de apoyo, texto de la redacción y criterios, **sin tus identificadores** |
| **Resend** (correos transaccionales) | tu correo y el contenido del mensaje (por ejemplo, el código de confirmación) |
| **Apple (App Store)** y **Google Play** | datos de la compra/suscripción hecha en la respectiva tienda, según sus políticas; no vemos tu tarjeta |
| **Mercado Pago** | datos de pago en la web (tarjeta o Pix), tratados por Mercado Pago; no vemos tu tarjeta |
| **Profesor asociado** (solo con tu consentimiento) | solo estadísticas de rendimiento, apartado 9 |

También podemos divulgar datos cuando la ley o una orden de autoridad lo exija.

## 5. Corrección de redacciones y Google Gemini

- **Situación actual: la corrección de redacciones por IA está temporalmente suspendida y ninguna redacción se envía a proveedores de IA.** Se reactivará solo tras avisarlo aquí y con una solución compatible con los términos del proveedor y con el público adolescente. La IA se usa **solo** para corregir redacciones (sin chatbot), con límite de **3 correcciones por día** por usuario (configurable).
- Al reactivarse, la corrección usará la API de Google Gemini (integración mantenida). Enviamos **sin identificadores**: ningún nombre, correo, ID de cuenta ni nombre de usuario. El texto de la redacción, sin embargo, es contenido que **tú escribiste**; evita incluir datos personales tuyos o de terceros.
- **Las condiciones de Google sobre uso y conservación de estos datos dependen del nivel de servicio contratado.** En el nivel gratuito, según la documentación de Google, el contenido puede usarse para mejorar productos de Google y puede ser leído por revisores humanos, y Google recomienda no enviar datos personales ni confidenciales. En el nivel de pago, Google afirma que no usa el contenido para mejorar productos, pero registra datos por un período limitado para prevención de abuso y obligaciones legales. **No garantizamos que el contenido no se use para entrenamiento** mientras se aplique el nivel gratuito.
- Decisión del titular (24/11/2026): sin contratación de IA de pago. El nivel gratuito **no se usará con redacciones de usuarios reales** mientras el envío esté suspendido; antes de reactivar, esta sección indicará el nivel y proveedor efectivos.
- La nota es **apoyo al estudio y estimación de práctica, no nota oficial**. Si prefieres, no uses la corrección por IA: el resto de la app no depende de ella.
- Los términos de Google exigen 18 años o más y vedan apps probablemente accesibles a menores. Como AprovaAura atiende estudiantes de todas las edades (incluidos adolescentes), **el envío sigue suspendido** hasta que exista una solución compatible.

## 6. Transferencia internacional

Nuestros proveedores (como Supabase, Cloudflare, Google, Resend, Apple y Mercado Pago) pueden procesar datos en otros países, incluso fuera de Brasil. Realizamos la transferencia conforme a la LGPD (arts. 33 y siguientes), con las garantías contractuales y de seguridad de los proveedores. **[PENDENTE-DONO: confirmar mecanismo de transferencia y regiones de cada proveedor.]**

## 7. Conservación

- **Cuenta, perfil, progreso y redacciones**: mientras exista la cuenta; se borran al eliminarla (apartado 8).
- **Registros de acceso**: **6 meses**, por obligación legal (Marco Civil de Internet de Brasil, art. 15).
- **Datos financieros** (importes, fechas, IDs de transacción): **anonimizados y conservados** por el plazo exigido por obligación legal/fiscal. Plazo exacto: **[PENDENTE-DONO/contador: plazo de conservación fiscal]**.
- **Registro de aceptaciones**: el tiempo necesario para probar el consentimiento y el cumplimiento. **[PENDENTE-DONO: plazo]**.
- Datos enviados a Google Gemini: sujetos a las reglas de Google (apartado 5); no controlamos el plazo.

## 8. Eliminación de cuenta

Puedes eliminar tu cuenta **en la app (Perfil → Eliminar cuenta)** o en https://lucksrei.com/projects/aura/data-deletion/. La acción es permanente.

- **Se borra**: perfil, progreso, respuestas, redacciones, vínculos y consentimientos asociados, datos de acceso.
- **Se anonimiza y conserva**: registros financieros, sin vínculo contigo, por obligación legal.
- **Se retiene por ley**: registros de acceso durante 6 meses.
- La eliminación **no cancela las suscripciones de las tiendas** (Apple/Google): cancélalas en la tienda.

## 9. Compartición con el profesor

Solo ocurre si consientes, tras la invitación de un profesor asociado. El profesor ve **solo estadísticas de rendimiento** y **nunca** tu redacción completa, contraseñas, credenciales, datos financieros ni respuestas individuales innecesarias. En esta versión, **solo usuarios adultos** pueden compartir; quien declara un rango de menor no comparte, y declararse menor pone fin a la compartición activa. Revocas en **Perfil → Privacidad y términos**. La revocación detiene el acceso del profesor a tus estadísticas, pero no borra comisiones ya generadas ni deshace la relación comercial del profesor con nosotros.

## 10. Niños y adolescentes

Tratamos datos de niños y adolescentes en su **mejor interés** (LGPD, art. 14) y conforme a la legislación aplicable (incluido el ECA Digital, Ley 15.211/2025).

- Recopilamos solo el **rango de edad declarado**, sin fecha de nacimiento. La autodeclaración no es una verificación rigurosa de edad.
- **Sin perfilado conductual y sin publicidad conductual.** La app no usa recursos de uso compulsivo.
- **Compartición con profesor: solo adultos.**
- AprovaAura **no está restringida a mayores de 18 años**: atiende estudiantes de ENEM y vestibulares, incluidos adolescentes (decisión del titular, 24/11/2026).
- Para niños (menores de 12 años), la LGPD exige consentimiento específico de al menos uno de los padres o responsable legal. **[PENDENTE-DONO/abogado: edad mínima del servicio (hoy la app acepta la franja "menor de 13"), forma de obtener el consentimiento de los responsables y regla de suscripción por menores.]**
- Los responsables pueden solicitar acceso, corrección o eliminación de los datos de un menor por el canal de privacidad.

## 11. Tus derechos

Según el art. 18 de la LGPD, puedes solicitar: confirmación del tratamiento; acceso; corrección; anonimización, bloqueo o eliminación de datos innecesarios; portabilidad; información sobre comparticiones; información sobre la posibilidad de no consentir y sus consecuencias; revocación del consentimiento; y revisión de decisiones automatizadas. Solicítalo por el canal de privacidad/DPO. También puedes reclamar ante la Autoridad Nacional de Protección de Datos de Brasil (ANPD).

## 12. Seguridad

Usamos HTTPS, control de acceso a nivel de fila (cada usuario accede solo a sus datos), contraseñas nunca en texto plano, segregación de encargados y acceso administrativo auditado. Ningún sistema es 100 % seguro; ante un incidente relevante, te lo comunicaremos a ti y a la ANPD según la ley.

## 13. Cambios en esta Política

Los cambios materiales se avisarán con antelación y, cuando se exija, pediremos nueva aceptación. Cada versión tiene número y fecha de vigencia.
