# Política de Privacidade — AprovaAura

> Minuta para revisão jurídica — não constitui parecer; versão 2026-12-01; vigência só após publicação coordenada.

Esta Política explica quais dados o AprovaAura trata, para quê, com quem os compartilhamos e quais são seus direitos (Lei Geral de Proteção de Dados — LGPD). Substitui a política de 28/09/2026 quando for publicada.

## 1. Controlador e contato

Controlador: Lucas Diogo Franca (marca Lucksrei), CNPJ 54.868.173/0001-55, **[PENDENTE-DONO: endereço]**.
Encarregado pelo tratamento de dados (DPO): o próprio controlador, pelo canal marketing@lucksrei.com (dispensa de encarregado a confirmar com advogado: Res. CD/ANPD 2/2022).
Canal de privacidade e suporte: marketing@lucksrei.com · https://lucksrei.com/projects/aura/support/

## 2. Dados que tratamos

| Categoria | Exemplos |
|---|---|
| Conta | e-mail, senha (protegida pelo provedor de autenticação), confirmação de e-mail |
| Perfil | nome, nome de usuário e foto (opcionais), objetivo de estudo, ano do exame, matérias de interesse, idioma, tema |
| Faixa etária | **apenas a faixa declarada** (menor de 13, 13–15, 16–17 ou adulto). **Não coletamos data de nascimento.** |
| Estudo | respostas, progresso por matéria/tópico, simulados, sequência de dias e pontos |
| Redações | tema, texto, rascunho e resultado da correção (nota estimada e comentários) |
| Professor | vínculo com professor parceiro (quando existir) e seus consentimentos |
| Assinatura e pagamentos | plano, período, valores e identificadores de transação. **Não recebemos nem guardamos número de cartão.** |
| Aceites | registro de qual versão dos Termos e desta Política você aceitou, e quando |
| Registros de acesso | endereço IP e data/hora de acesso, conforme exige a lei |

## 3. Finalidades e bases legais (LGPD, art. 7º)

| Finalidade | Base legal |
|---|---|
| Criar e manter sua conta, autenticar, confirmar e-mail, enviar e-mails transacionais | Execução de contrato (art. 7º, V) |
| Prestar o Serviço: questões, simulados, progresso, personalização por matérias | Execução de contrato (art. 7º, V) |
| Corrigir redações por IA quando você solicitar | Execução de contrato (art. 7º, V), a seu pedido; veja o item 5 |
| Cobrança, acesso pago, conciliação financeira, cortesias | Execução de contrato (art. 7º, V) e obrigação legal (art. 7º, II) |
| Guarda de registros de acesso e de dados fiscais/financeiros | Obrigação legal (art. 7º, II) |
| Compartilhar suas estatísticas com o professor que o indicou | **Consentimento** específico e revogável (art. 7º, I) |
| Segurança, prevenção a fraude e abuso, diagnóstico de falhas | Legítimo interesse (art. 7º, IX), com análise de impacto e sem prejudicar seus direitos |
| Registrar seus aceites de Termos e Política | Obrigação legal e exercício regular de direitos (art. 7º, II e VI) |

Não vendemos dados, **não fazemos perfilamento comportamental nem publicidade comportamental**.

## 4. Com quem compartilhamos (operadores)

Estes provedores tratam dados em nosso nome, na medida necessária:

| Provedor | O que recebe |
|---|---|
| **Supabase** (banco, autenticação, funções, armazenamento) | conta, perfil, progresso, respostas, redações, vínculo com professor, consentimentos, registros de pagamento (valores e IDs de transação, sem cartão) e aceites |
| **Cloudflare** (hospedagem web e entrega de conteúdo) | dados de rede necessários para entregar o app web (como IP), conteúdo servido |
| **Provedores de IA gratuitos** (Groq e Cloudflare Workers AI; Google Gemini só se for habilitado) | apenas tema, textos de apoio, texto da redação e critérios, **sem seus identificadores** |
| **Resend** (e-mails transacionais) | seu e-mail e o conteúdo da mensagem (por exemplo, o código de confirmação) |
| **Apple (App Store)** e **Google Play** | dados da compra/assinatura feita na respectiva loja, conforme as políticas delas; não vemos seu cartão |
| **Mercado Pago** | dados de pagamento na web (cartão ou Pix), tratados pelo Mercado Pago; não vemos seu cartão |
| **Professor parceiro** (só com seu consentimento) | apenas estatísticas de desempenho, item 9 |

Também podemos divulgar dados quando a lei ou ordem de autoridade exigir.

## 5. Correção de redação e provedores de IA

- **Situação atual: a correção de redação por IA está desativada e nenhuma redação é enviada a provedores de IA.** O recurso só será ativado depois de homologado e de atualizarmos este texto. A IA serve **exclusivamente** para corrigir redações: não há chatbot nem conversa livre. O limite é de **3 correções por dia** por usuário, somado entre todos os provedores.
- Quando ativada, a correção usa **provedores de IA em plano gratuito**, em ordem de prioridade, com troca automática se o primeiro estiver indisponível ou sem franquia: **Groq** e **Cloudflare Workers AI**. O **Google Gemini** permanece integrado, mas **desabilitado por padrão**, porque os termos do plano gratuito do Google exigem 18 anos ou mais e permitem o uso do conteúdo para melhorar produtos. Você não precisa saber qual provedor processou a sua redação; a escolha é interna.
- Enviamos **sem identificadores**: nenhum nome, e-mail, ID de conta ou nome de usuário. O texto da redação, porém, é conteúdo que **você escreveu**; evite incluir dados pessoais seus ou de terceiros. Não registramos em nossos logs o texto da redação nem a resposta completa da IA; guardamos apenas contagens de uso e códigos de erro, sem conteúdo.
- Segundo a documentação oficial consultada em 26/11/2026: a Cloudflare informa que o conteúdo enviado ao Workers AI não é usado para treinar modelos e não é retido após a resposta; a Groq informa que, por padrão, entradas e saídas não são retidas, podendo haver logs por até 30 dias para confiabilidade e prevenção de abuso. Esses provedores podem processar dados fora do Brasil. **[PENDENTE-ADVOGADO: ler o Groq Services Agreement/DPA e os termos da Cloudflare quanto a menores de idade e LGPD antes de ativar para o público adolescente.]**
- A nota é **apoio ao estudo e estimativa de treino, não nota oficial do ENEM**. Se preferir, não use a correção por IA: o restante do app não depende dela.

## 6. Transferência internacional

Nossos provedores (como Supabase, Cloudflare, Groq, Google, Resend, Apple e Mercado Pago) podem processar dados em outros países, inclusive fora do Brasil. Fazemos a transferência conforme a LGPD (arts. 33 e seguintes), com as garantias contratuais e de segurança dos provedores. **[PENDENTE-DONO: confirmar mecanismo de transferência e regiões de cada provedor.]**

## 7. Retenção

- **Conta, perfil, progresso e redações**: enquanto a conta existir; apagados na exclusão (item 8).
- **Registros de acesso**: **6 meses**, por obrigação legal (Marco Civil da Internet, art. 15).
- **Dados financeiros** (valores, datas, IDs de transação): **anonimizados e preservados** pelo prazo exigido por obrigação legal/fiscal. Prazo exato: **[PENDENTE-DONO/contador: prazo de guarda fiscal]**.
- **Registro de aceites**: pelo tempo necessário para comprovar o consentimento e o cumprimento de obrigações. **[PENDENTE-DONO: prazo]**.
- Dados enviados aos provedores de IA: sem retenção por padrão, segundo a documentação de cada um (a Groq pode manter logs por até 30 dias); não controlamos esse prazo.

## 8. Exclusão de conta

Você pode excluir a conta **no app (Perfil → Excluir conta)** ou pelo link https://lucksrei.com/projects/aura/data-deletion/. A ação é permanente.

- **Apagado**: perfil, progresso, respostas, redações, vínculos e consentimentos associados, dados de login.
- **Anonimizado e preservado**: registros financeiros, sem vínculo com você, por obrigação legal.
- **Retido por lei**: registros de acesso por 6 meses.
- A exclusão **não cancela assinaturas feitas em lojas** (Apple/Google): cancele-as na loja.

## 9. Indicação de professor e compartilhamento de estatísticas

**Indicação comercial (vínculo)**: se você usar o link/código de um professor parceiro ou escolhê-lo no cadastro, ele passa a ver, no portal dele, seu **nome, nome de usuário, data do vínculo e a situação comercial** (teste, assinatura ou cortesia, e o plano), porque isso é necessário para calcular a comissão. Isso **não inclui** estatísticas de estudo, redações nem respostas. **[DECISÃO DO DONO/advogado: para menores de 18 anos, exibir ao professor apenas um identificador reduzido em vez do nome completo (minimização, LGPD art. 6º, III).]**

**Compartilhamento de estatísticas (autorização separada)**: Só ocorre se você consentir, após convite de um professor parceiro. O professor vê **apenas estatísticas de desempenho** e **nunca** sua redação completa, senhas, credenciais, dados financeiros ou respostas individuais desnecessárias. Nesta versão, **só usuários adultos** podem compartilhar; quem declara faixa de menor não compartilha, e declarar-se menor encerra compartilhamento ativo. Você revoga em **Perfil → Privacidade e termos**. A revogação interrompe o acesso do professor às suas estatísticas, mas não apaga comissões já geradas nem desfaz o vínculo comercial do professor conosco.

## 10. Crianças e adolescentes

Tratamos dados de crianças e adolescentes no seu **melhor interesse** (LGPD, art. 14) e conforme a legislação aplicável (incluindo o ECA Digital, Lei 15.211/2025).

- Coletamos só a **faixa etária declarada**, sem data de nascimento. A autodeclaração não é verificação rigorosa de idade.
- **Sem perfilamento comportamental e sem publicidade comportamental.** O app não usa recursos de uso compulsivo.
- **Compartilhamento com professor: somente adultos.**
- O AprovaAura **não é restrito a maiores de 18 anos**: atende estudantes do ENEM e vestibulandos, inclusive adolescentes. Decisão do dono (24/11/2026).
- Para crianças (menores de 12 anos), a LGPD pede consentimento específico de ao menos um dos pais ou responsável legal. **[PENDENTE-DONO/advogado: idade mínima do serviço (hoje o app aceita a faixa "menor de 13"), forma de obter consentimento dos responsáveis e regra de assinatura por menores (pagamento pelo responsável).]**
- Responsáveis podem solicitar acesso, correção ou exclusão dos dados de um menor pelo canal de privacidade.

## 11. Seus direitos

Nos termos do art. 18 da LGPD, você pode solicitar: confirmação do tratamento; acesso; correção; anonimização, bloqueio ou eliminação de dados desnecessários; portabilidade; informação sobre compartilhamentos; informação sobre a possibilidade de não consentir e suas consequências; revogação do consentimento; e revisão de decisões automatizadas. Peça pelo canal de privacidade/encarregado. Você também pode reclamar à Autoridade Nacional de Proteção de Dados (ANPD).

## 12. Segurança

Usamos HTTPS, controle de acesso em nível de linha (cada usuário acessa apenas seus dados), senhas nunca em texto simples, segregação de operadores e acesso administrativo auditado. Nenhum sistema é 100% seguro; em caso de incidente relevante, comunicaremos você e a ANPD conforme a lei.

## 13. Mudanças nesta Política

Mudanças materiais serão avisadas com antecedência e, quando exigido, pediremos novo aceite. Cada versão tem número e data de vigência.
