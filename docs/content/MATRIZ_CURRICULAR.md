# Matriz curricular — expansão do acervo

Gerada por `tool/content/gen_matrix.py` a partir de `tool/content/curriculum/` (fonte da verdade, versionada). **Proposta de planejamento: nada aqui foi aplicado ao banco nem publicado.**

## Resumo

- Matérias existentes: **16** (14 com banco de questões + Atualidades + Redação). Preservadas integralmente.
- Matérias novas **incluídas**: **59** · agrupadas: 1 · adiadas: 2.
- Total de matérias no plano: **75** (referência do dono: ~57+).
- Meta de planejamento de questões **aprovadas**: existentes 10.150 (hoje há 2.609) + novas 27.400 = **37.550**. É meta, **não** estoque; o progresso real está em `docs/content/COBERTURA.md`.
- Categorias: E = ENEM, V = Vestibulares, C = Concursos. Uma matéria/tópico/questão pode ter 1, 2 ou 3, **sem duplicar a entidade** (ver `docs/content/ARQUITETURA_CLASSIFICACAO.md`).
- Níveis do tópico: fundamental / intermediário / avançado (preserva `facil/medio/dificil` das questões; distribuição sugerida 30/45/25 sem forçar).
- Matérias de Direito, Gestão, Finanças, TI e Educação no app exigem código novo (enum `Subject`) — fora do escopo desta etapa.

## Critérios de inclusão, agrupamento e adiamento

- **Incluir** só com (a) escopo bem delimitado, (b) fontes livres/oficiais suficientes para elaborar questões autorais e (c) meta mínima de 200 questões e ao menos 2 tópicos.
- **Agrupar** quando o tema é parte natural de outra matéria (Direito Financeiro e Finanças Públicas → AFO; Algoritmos → Lógica de Programação; SFN → Conhecimentos Bancários).
- **Adiar** quando exigiria fontes por ente (Direito Militar) ou cobertura livre insuficiente (Criminologia): não criamos matéria vazia.
- Fases: 1 = primeiros lotes; 2 = depois da validação do fluxo; 3 = matérias de meta reduzida.

## Matérias existentes (dados reais do banco, consulta 2026-11-27)

| Matéria | Área | Categorias propostas | Questões hoje | Meta | Temas de 1º nível (questões) |
|---|---|---|---:|---:|---|
| Português | Linguagens | E,V,C | 169 | 1200 | Compreensão textual (6); Tema e assunto (6); Ideia principal (5); Informações explícitas (6); Informações implícitas (5); Inferência (6) |
| Literatura | Linguagens | E,V | 126 | 450 | Versificação (6); Figuras de linguagem (8); Gêneros literários (8); Cordel e literatura popular (6); Literatura afro-brasileira e indígena (6); Prosa romântica (6) |
| Artes | Linguagens | E,V | 126 | 300 | Artes visuais (8); Artes cênicas (6); Barroco (6); Arte contemporânea brasileira (6); Modernismo (6); Impressionismo (6) |
| Educação Física | Linguagens | E,V | 127 | 300 | Danças urbanas e contemporâneas (6); Danças brasileiras (6); Atletismo (6); Ginástica (6); Natação e esportes aquáticos (6); Voleibol (6) |
| Inglês | Linguagens | E,V,C | 127 | 600 | Phrasal verbs (6); Idioms comuns (7); Identificando a ideia central (6); Skimming e scanning (6); Textos de opinião e argumentativos (6); Trechos literários (8) |
| Espanhol | Linguagens | E,V | 127 | 400 | Textos de opinião e argumentativos (6); Trechos literários (6); Textos informativos e científicos (6); Países de língua espanhola (6); Linguagem funcional do dia a dia (6); Modismos comuns (6) |
| História | Humanas | E,V | 177 | 900 | Povos indígenas (6); Brasil Colonial (8); Independência do Brasil (6); Brasil Império (6); República Velha (6); Era Vargas (59) |
| Geografia | Humanas | E,V | 388 | 900 | Território (5); Hidrografia (55); Relevo (5); Biomas e vegetação (5); Clima (5); Cidades (5) |
| Filosofia | Humanas | E,V | 127 | 400 | Filosofia medieval (6); Escolas helenísticas (6); Teoria do conhecimento (8); Lógica e argumentação (8); Nietzsche (6); Existencialismo (6) |
| Sociologia | Humanas | E,V | 126 | 400 | Senso comum e imaginação sociológica (7); Surgimento da sociologia (6); Émile Durkheim (7); Max Weber (6); Karl Marx (6); Cultura e etnocentrismo (7) |
| Biologia | Natureza | E,V | 329 | 800 | Membrana plasmática (25); Organelas (40); Ciclo celular, mitose e meiose (5); Conceitos fundamentais (30); Leis de Mendel e padrões de herança (37); Cadeias e teias alimentares (22) |
| Física | Natureza | E,V | 226 | 700 | Cinemática (38); Dinâmica (47); Trabalho e energia (7); Gravitação (7); Termologia e Termodinâmica (11); Ondulatória (12) |
| Química | Natureza | E,V | 234 | 700 | Estrutura atômica (28); Modelos atômicos (23); Tabela periódica (39); Ligações e Estrutura (8); Estequiometria (12); Soluções (11) |
| Matemática | Matemática e Raciocínio | E,V,C | 200 | 1500 | Números (naturais, inteiros, racionais, irracionais, reais) (6); Operações básicas e ordem das operações (6); Frações (6); Números decimais (5); Potenciação e radiciação (5); Divisibilidade (22) |
| Atualidades | Humanas | E,V,C | 0 | 600 | 7 dossiês (1 por área) |
| Redação | Linguagens | E,V,C | 0 | 0 | 5 temas de redação |

**Lacunas das existentes (ver inventário):** viés de alternativa correta mais longa (62%); 227 explicações curtas; 35 questões com alternativas equivalentes; Geografia com 45 folhas sem questão (mapas); nenhuma classificação por categoria; Atualidades com 1 dossiê por área; Redação só com 5 temas de treino; Português/Matemática precisam de profundidade para concursos.

Os tópicos das existentes mantêm os **ids reais** (`catalog_nodes.id`); as categorias serão aplicadas por tabela de ligação, nunca recriando nós.

## Matérias novas — decisão, tópicos e metas

### Raciocínio Lógico (`raciocinio_logico`) — Matemática e Raciocínio

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 450

Lógica proposicional, argumentação, sequências e análise combinatória aplicada a provas de concurso.

Competências: Traduzir enunciados em proposições; avaliar validade de argumentos; contar casos · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `raciocinio_logico.proposicoes_conectivos` | Proposições e conectivos | fundamental | — |
| `raciocinio_logico.tabela_verdade` | Tabelas-verdade e equivalências | fundamental | `proposicoes_conectivos` |
| `raciocinio_logico.negacao` | Negação de proposições e quantificadores | intermediário | `tabela_verdade` |
| `raciocinio_logico.argumentos_validade` | Argumentos e validade | intermediário | `tabela_verdade` |
| `raciocinio_logico.diagramas_conjuntos` | Diagramas lógicos e conjuntos | fundamental | — |
| `raciocinio_logico.sequencias_padroes` | Sequências e padrões | fundamental | — |
| `raciocinio_logico.analise_combinatoria` | Análise combinatória e probabilidade | intermediário | — |
| `raciocinio_logico.problemas_verdade_mentira` | Problemas de verdade/mentira e associação | avançado | `argumentos_validade` |

### Informática (`informatica`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 450

Noções de informática cobradas em concursos: SO, editores, planilhas, internet, segurança básica.

Competências: Operar conceitos de software/hardware; reconhecer funções de planilha; boas práticas de segurança · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `informatica.hardware_software` | Hardware e software | fundamental | — |
| `informatica.windows_arquivos` | Sistemas operacionais e gerenciamento de arquivos | fundamental | `hardware_software` |
| `informatica.editores_texto` | Editores de texto | fundamental | — |
| `informatica.planilhas` | Planilhas eletrônicas e fórmulas | intermediário | — |
| `informatica.internet_navegadores` | Internet, navegadores e e-mail | fundamental | — |
| `informatica.seguranca_basica` | Segurança básica, malware e backup | intermediário | — |
| `informatica.nuvem_colaboracao` | Armazenamento em nuvem e colaboração | intermediário | — |

### Matemática Financeira (`matematica_financeira`) — Matemática e Raciocínio

Categorias: C, E · Decisão: **incluir** · Fase: 1 · Meta: 450

Juros, descontos, equivalência de capitais, amortização e análise de investimentos.

Competências: Calcular juros e prazos; comparar alternativas financeiras · Fontes: bancas-programas, bcb

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `matematica_financeira.porcentagem_variacao` | Porcentagem e variação | fundamental | — |
| `matematica_financeira.juros_simples` | Juros simples | fundamental | `porcentagem_variacao` |
| `matematica_financeira.juros_compostos` | Juros compostos | intermediário | `juros_simples` |
| `matematica_financeira.descontos` | Descontos simples e compostos | intermediário | `juros_compostos` |
| `matematica_financeira.taxas_equivalentes` | Taxas equivalentes, nominais e efetivas | intermediário | `juros_compostos` |
| `matematica_financeira.series_pagamentos` | Séries de pagamentos | avançado | `taxas_equivalentes` |
| `matematica_financeira.sistemas_amortizacao` | Sistemas de amortização (SAC, Price) | avançado | `series_pagamentos` |
| `matematica_financeira.vpl_tir` | Valor presente líquido e taxa interna de retorno | avançado | `series_pagamentos` |

### Estatística (`estatistica`) — Matemática e Raciocínio

Categorias: E, V, C · Decisão: **incluir** · Fase: 1 · Meta: 550

Estatística descritiva, probabilidade e inferência básica; leitura crítica de gráficos e tabelas.

Competências: Interpretar dados; calcular medidas; avaliar probabilidades · Fontes: inep-matriz-enem, bancas-programas, ibge

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `estatistica.leitura_graficos` | Leitura de gráficos e tabelas | fundamental | — |
| `estatistica.media_mediana_moda` | Média, mediana e moda | fundamental | — |
| `estatistica.dispersao` | Variância e desvio padrão | intermediário | `media_mediana_moda` |
| `estatistica.probabilidade_basica` | Probabilidade básica | fundamental | — |
| `estatistica.probabilidade_condicional` | Probabilidade condicional e Bayes | intermediário | `probabilidade_basica` |
| `estatistica.distribuicoes` | Distribuição binomial e normal | avançado | `probabilidade_condicional` |
| `estatistica.amostragem_inferencia` | Amostragem e inferência | avançado | `dispersao` |
| `estatistica.correlacao_regressao` | Correlação e regressão simples | avançado | `dispersao` |

### Educação Financeira (`educacao_financeira`) — Matemática e Raciocínio

Categorias: E, C · Decisão: **incluir-meta-reduzida** · Fase: 2 · Meta: 250

Orçamento pessoal, consumo, crédito, poupança, investimento e inflação (tema transversal da BNCC).

Competências: Planejar orçamento; comparar crédito; reconhecer riscos · Fontes: bncc, bcb

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `educacao_financeira.orcamento` | Orçamento e planejamento | fundamental | — |
| `educacao_financeira.inflacao_poder_compra` | Inflação e poder de compra | fundamental | — |
| `educacao_financeira.credito_juros` | Crédito, juros e endividamento | intermediário | — |
| `educacao_financeira.poupanca_investimentos` | Poupança e investimentos | intermediário | — |
| `educacao_financeira.previdencia_seguros` | Previdência e seguros | intermediário | — |
| `educacao_financeira.consumo_consciente` | Consumo consciente e fraudes | fundamental | — |

### Direito Constitucional (`dir_constitucional`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 900

Princípios, direitos fundamentais, organização do Estado e dos Poderes, controle de constitucionalidade.

Competências: Aplicar texto constitucional; identificar competência e garantia · Fontes: planalto-cf88, stf-jurisprudencia, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_constitucional.principios_fundamentais` | Princípios fundamentais (arts. 1º a 4º) | fundamental | — |
| `dir_constitucional.direitos_garantias` | Direitos e garantias fundamentais (art. 5º) | fundamental | `principios_fundamentais` |
| `dir_constitucional.direitos_sociais_nacionalidade` | Direitos sociais, nacionalidade e direitos políticos | intermediário | `direitos_garantias` |
| `dir_constitucional.organizacao_estado` | Organização político-administrativa | intermediário | — |
| `dir_constitucional.poder_legislativo` | Poder Legislativo e processo legislativo | intermediário | `organizacao_estado` |
| `dir_constitucional.poder_executivo` | Poder Executivo | intermediário | `organizacao_estado` |
| `dir_constitucional.poder_judiciario` | Poder Judiciário e funções essenciais | intermediário | `organizacao_estado` |
| `dir_constitucional.controle_constitucionalidade` | Controle de constitucionalidade | avançado | `poder_judiciario` |
| `dir_constitucional.ordem_economica_social` | Ordem econômica, financeira e social | intermediário | — |
| `dir_constitucional.tributacao_orcamento_cf` | Sistema tributário e orçamento na CF | avançado | `ordem_economica_social` |

### Direito Administrativo (`dir_administrativo`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 900

Princípios, organização administrativa, atos, poderes, serviços, agentes, responsabilidade civil, improbidade e processo administrativo.

Competências: Classificar atos e entes; aplicar Lei 9.784 e Lei 8.112 · Fontes: planalto-cf88, planalto-lei9784, planalto-lei8112, planalto-lei8429, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_administrativo.principios_adm` | Princípios da Administração Pública | fundamental | — |
| `dir_administrativo.organizacao_administrativa` | Organização administrativa (direta e indireta) | fundamental | — |
| `dir_administrativo.atos_administrativos` | Atos administrativos | intermediário | `principios_adm` |
| `dir_administrativo.poderes_administrativos` | Poderes administrativos | intermediário | `principios_adm` |
| `dir_administrativo.servicos_publicos` | Serviços públicos e concessões | intermediário | `organizacao_administrativa` |
| `dir_administrativo.agentes_publicos` | Agentes públicos e Lei 8.112/90 | intermediário | — |
| `dir_administrativo.responsabilidade_civil_estado` | Responsabilidade civil do Estado | intermediário | — |
| `dir_administrativo.improbidade` | Improbidade administrativa | avançado | `principios_adm` |
| `dir_administrativo.processo_administrativo` | Processo administrativo federal (Lei 9.784/99) | intermediário | — |
| `dir_administrativo.controle_adm` | Controle da Administração | avançado | `atos_administrativos` |

### Direito Penal (`dir_penal`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 800

Teoria da lei penal, crime, pena, extinção da punibilidade e parte especial do Código Penal.

Competências: Subsumir fatos a tipos penais; aplicar institutos da parte geral · Fontes: planalto-cp, stf-jurisprudencia, stj-jurisprudencia, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_penal.principios_lei_penal` | Princípios e aplicação da lei penal | fundamental | — |
| `dir_penal.teoria_crime` | Teoria do crime (fato típico, ilicitude, culpabilidade) | intermediário | `principios_lei_penal` |
| `dir_penal.tentativa_concurso` | Iter criminis, tentativa e concurso de pessoas | intermediário | `teoria_crime` |
| `dir_penal.penas` | Penas, dosimetria e execução | intermediário | `teoria_crime` |
| `dir_penal.extincao_punibilidade` | Extinção da punibilidade e prescrição | avançado | `penas` |
| `dir_penal.crimes_pessoa` | Crimes contra a pessoa | intermediário | `teoria_crime` |
| `dir_penal.crimes_patrimonio` | Crimes contra o patrimônio | intermediário | `teoria_crime` |
| `dir_penal.crimes_adm_publica` | Crimes contra a Administração Pública | intermediário | `teoria_crime` |

### Direito Processual Penal (`dir_proc_penal`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 600

Inquérito, ação penal, provas, prisões, procedimentos e recursos.

Competências: Identificar fase, competência e nulidade · Fontes: planalto-cpp, stf-jurisprudencia, stj-jurisprudencia, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_proc_penal.principios_inquerito` | Princípios e inquérito policial | fundamental | — |
| `dir_proc_penal.acao_penal` | Ação penal | intermediário | `principios_inquerito` |
| `dir_proc_penal.competencia` | Competência e jurisdição | intermediário | — |
| `dir_proc_penal.provas` | Provas | intermediário | — |
| `dir_proc_penal.prisoes_cautelares` | Prisões e medidas cautelares | avançado | `provas` |
| `dir_proc_penal.procedimentos_juri` | Procedimentos e Tribunal do Júri | avançado | `acao_penal` |
| `dir_proc_penal.nulidades_recursos` | Nulidades e recursos | avançado | `procedimentos_juri` |

### Direito Civil (`dir_civil`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 700

Parte geral, obrigações, contratos, responsabilidade civil, coisas, família e sucessões.

Competências: Aplicar o Código Civil a casos · Fontes: planalto-cc, stj-jurisprudencia, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_civil.lindb_pessoas` | LINDB e pessoas naturais e jurídicas | fundamental | — |
| `dir_civil.bens_fatos_juridicos` | Bens e fatos jurídicos | intermediário | `lindb_pessoas` |
| `dir_civil.prescricao_decadencia` | Prescrição e decadência | intermediário | `bens_fatos_juridicos` |
| `dir_civil.obrigacoes` | Obrigações | intermediário | — |
| `dir_civil.contratos` | Contratos | intermediário | `obrigacoes` |
| `dir_civil.responsabilidade_civil` | Responsabilidade civil | intermediário | `obrigacoes` |
| `dir_civil.direito_coisas` | Direito das coisas | intermediário | — |
| `dir_civil.familia_sucessoes` | Família e sucessões | avançado | — |

### Direito Processual Civil (`dir_proc_civil`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 650

CPC/2015: normas gerais, partes, atos, tutelas, procedimento comum, recursos, execução.

Competências: Aplicar prazos e institutos do CPC · Fontes: planalto-cpc, stj-jurisprudencia, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_proc_civil.normas_fundamentais` | Normas fundamentais e jurisdição | fundamental | — |
| `dir_proc_civil.partes_litisconsorcio` | Partes, procuradores e litisconsórcio | intermediário | `normas_fundamentais` |
| `dir_proc_civil.atos_prazos` | Atos processuais e prazos | intermediário | — |
| `dir_proc_civil.tutelas_provisorias` | Tutelas provisórias | intermediário | — |
| `dir_proc_civil.procedimento_comum` | Procedimento comum | intermediário | `atos_prazos` |
| `dir_proc_civil.provas_sentenca` | Provas, sentença e coisa julgada | avançado | `procedimento_comum` |
| `dir_proc_civil.recursos_civeis` | Recursos | avançado | `provas_sentenca` |
| `dir_proc_civil.execucao_cumprimento` | Cumprimento de sentença e execução | avançado | `provas_sentenca` |

### Direito Tributário (`dir_tributario`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 650

Sistema tributário, competência, obrigação e crédito tributário, limitações ao poder de tributar.

Competências: Aplicar CTN e CF · Fontes: planalto-ctn, planalto-cf88, stf-jurisprudencia, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_tributario.sistema_tributario` | Sistema tributário e espécies | fundamental | — |
| `dir_tributario.limitacoes_poder` | Limitações ao poder de tributar | intermediário | `sistema_tributario` |
| `dir_tributario.competencia_tributaria` | Competência tributária e repartição | intermediário | `sistema_tributario` |
| `dir_tributario.obrigacao_tributaria` | Obrigação tributária | intermediário | — |
| `dir_tributario.credito_tributario` | Crédito tributário (constituição, suspensão, extinção) | avançado | `obrigacao_tributaria` |
| `dir_tributario.impostos_especie` | Impostos em espécie | avançado | `competencia_tributaria` |
| `dir_tributario.processo_tributario` | Administração e processo tributário | avançado | `credito_tributario` |

### Direito do Trabalho (`dir_trabalho`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 650

Relação de emprego, contrato, jornada, remuneração, estabilidades, FGTS, rescisão e direito coletivo.

Competências: Aplicar CLT e CF · Fontes: planalto-clt, planalto-cf88, tst-jurisprudencia, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_trabalho.relacao_emprego` | Relação de emprego e sujeitos | fundamental | — |
| `dir_trabalho.contrato_trabalho` | Contrato de trabalho | intermediário | `relacao_emprego` |
| `dir_trabalho.jornada_descansos` | Jornada, descansos e férias | intermediário | `contrato_trabalho` |
| `dir_trabalho.remuneracao_fgts` | Remuneração, salário e FGTS | intermediário | `contrato_trabalho` |
| `dir_trabalho.extincao_contrato` | Extinção do contrato e verbas rescisórias | avançado | `remuneracao_fgts` |
| `dir_trabalho.estabilidades_seguranca` | Estabilidades e segurança do trabalho | intermediário | `contrato_trabalho` |
| `dir_trabalho.direito_coletivo` | Direito coletivo do trabalho | avançado | — |

### Direito Processual do Trabalho (`dir_proc_trabalho`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 450

Organização da Justiça do Trabalho, competência, procedimentos e recursos trabalhistas.

Competências: Identificar prazo, competência e recurso · Fontes: planalto-clt, tst-jurisprudencia, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_proc_trabalho.justica_trabalho` | Organização e competência da Justiça do Trabalho | fundamental | — |
| `dir_proc_trabalho.reclamacao_audiencia` | Reclamação, audiência e revelia | intermediário | `justica_trabalho` |
| `dir_proc_trabalho.provas_trabalhistas` | Provas no processo do trabalho | intermediário | `reclamacao_audiencia` |
| `dir_proc_trabalho.procedimentos_rito` | Procedimentos (ordinário, sumaríssimo) | intermediário | `reclamacao_audiencia` |
| `dir_proc_trabalho.recursos_trabalhistas` | Recursos trabalhistas | avançado | `procedimentos_rito` |
| `dir_proc_trabalho.execucao_trabalhista` | Execução trabalhista | avançado | `recursos_trabalhistas` |

### Direito Eleitoral (`dir_eleitoral`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 350

Direitos políticos, partidos, registro de candidaturas, propaganda, justiça eleitoral e crimes eleitorais.

Competências: Aplicar Código Eleitoral e leis esparsas · Fontes: planalto-codigo-eleitoral, tse-legislacao, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_eleitoral.justica_eleitoral` | Justiça Eleitoral e organização | fundamental | — |
| `dir_eleitoral.partidos_candidaturas` | Partidos e candidaturas | intermediário | `justica_eleitoral` |
| `dir_eleitoral.elegibilidade_inelegibilidade` | Elegibilidade e inelegibilidades | avançado | `partidos_candidaturas` |
| `dir_eleitoral.propaganda_financiamento` | Propaganda e financiamento de campanha | intermediário | `partidos_candidaturas` |
| `dir_eleitoral.crimes_eleitorais` | Crimes eleitorais e processo | avançado | `justica_eleitoral` |

### Direito Ambiental (`dir_ambiental`) — Direito

Categorias: C, E · Decisão: **incluir** · Fase: 2 · Meta: 350

Princípios, PNMA, licenciamento, áreas protegidas, responsabilidade ambiental.

Competências: Aplicar Lei 6.938 e CF art. 225 · Fontes: planalto-cf88, planalto-lei6938, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_ambiental.principios_ambientais` | Princípios e art. 225 da CF | fundamental | — |
| `dir_ambiental.pnma_sisnama` | PNMA e SISNAMA | intermediário | `principios_ambientais` |
| `dir_ambiental.licenciamento` | Licenciamento ambiental | intermediário | `pnma_sisnama` |
| `dir_ambiental.areas_protegidas` | Unidades de conservação e áreas protegidas | intermediário | — |
| `dir_ambiental.responsabilidade_ambiental` | Responsabilidade civil, administrativa e penal ambiental | avançado | `pnma_sisnama` |

### Direito Empresarial (`dir_empresarial`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 400

Empresário, sociedades, títulos de crédito, recuperação e falência.

Competências: Distinguir tipos societários e títulos · Fontes: planalto-cc, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_empresarial.empresario_estabelecimento` | Empresário e estabelecimento | fundamental | — |
| `dir_empresarial.sociedades` | Sociedades empresárias | intermediário | `empresario_estabelecimento` |
| `dir_empresarial.titulos_credito` | Títulos de crédito | intermediário | — |
| `dir_empresarial.contratos_empresariais` | Contratos empresariais | intermediário | — |
| `dir_empresarial.recuperacao_falencia` | Recuperação judicial e falência | avançado | `sociedades` |

### Direito Previdenciário (`dir_previdenciario`) — Direito

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 400

Seguridade social, RGPS, benefícios, custeio e RPPS.

Competências: Aplicar Leis 8.212/8.213 e emendas · Fontes: planalto-lei8213, planalto-cf88, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_previdenciario.seguridade_principios` | Seguridade social e princípios | fundamental | — |
| `dir_previdenciario.segurados_dependentes` | Segurados e dependentes | intermediário | `seguridade_principios` |
| `dir_previdenciario.beneficios_rgps` | Benefícios do RGPS | intermediário | `segurados_dependentes` |
| `dir_previdenciario.custeio` | Custeio da seguridade | intermediário | `seguridade_principios` |
| `dir_previdenciario.rpps` | Regimes próprios de previdência | avançado | `beneficios_rgps` |

### Direitos Humanos (`direitos_humanos`) — Direito

Categorias: E, C · Decisão: **incluir** · Fase: 2 · Meta: 450

Teoria geral, tratados, sistemas global e interamericano, grupos vulneráveis.

Competências: Relacionar tratados e Constituição · Fontes: planalto-cf88, onu-oea-tratados, inep-matriz-enem, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `direitos_humanos.teoria_geral_dh` | Teoria geral e gerações de direitos | fundamental | — |
| `direitos_humanos.sistema_global` | Sistema global (ONU) | intermediário | `teoria_geral_dh` |
| `direitos_humanos.sistema_interamericano` | Sistema interamericano | intermediário | `teoria_geral_dh` |
| `direitos_humanos.dh_brasil` | Direitos humanos na ordem constitucional brasileira | intermediário | `teoria_geral_dh` |
| `direitos_humanos.grupos_vulneraveis` | Grupos vulneráveis e proteção | intermediário | `dh_brasil` |

### Legislação Específica (`legislacao_especifica`) — Direito

Categorias: C · Decisão: **incluir-meta-reduzida** · Fase: 3 · Meta: 300

Legislação de carreira/órgão (estatutos, leis orgânicas); conteúdo só com texto oficial verificável.

Competências: Localizar e aplicar o dispositivo · Fontes: planalto-lei8112, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `legislacao_especifica.estatutos_servidores` | Estatutos de servidores públicos | intermediário | — |
| `legislacao_especifica.leis_organicas` | Leis orgânicas e carreiras | intermediário | — |
| `legislacao_especifica.lai_lgpd` | Lei de Acesso à Informação e LGPD | intermediário | — |

### Direito do Consumidor (`dir_consumidor`) — Direito

Categorias: C, E · Decisão: **incluir** · Fase: 2 · Meta: 300

CDC: relação de consumo, responsabilidade, práticas abusivas, proteção contratual.

Competências: Aplicar Lei 8.078/90 · Fontes: planalto-cdc, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_consumidor.relacao_consumo` | Relação de consumo e princípios | fundamental | — |
| `dir_consumidor.responsabilidade_produto_servico` | Responsabilidade pelo fato e vício | intermediário | `relacao_consumo` |
| `dir_consumidor.praticas_abusivas` | Práticas comerciais e publicidade | intermediário | `relacao_consumo` |
| `dir_consumidor.protecao_contratual` | Proteção contratual e cobrança | intermediário | — |

### Direito Internacional Público (`dir_internacional_publico`) — Direito

Categorias: C · Decisão: **incluir-meta-reduzida** · Fase: 3 · Meta: 200

Fontes, sujeitos, tratados, responsabilidade internacional.

Competências: Distinguir fontes e sujeitos · Fontes: onu-oea-tratados, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `dir_internacional_publico.fontes_dip` | Fontes e tratados | intermediário | — |
| `dir_internacional_publico.sujeitos_dip` | Sujeitos e organizações internacionais | intermediário | — |
| `dir_internacional_publico.responsabilidade_dip` | Responsabilidade internacional do Estado | avançado | — |

### Direito Financeiro (`dir_financeiro`) — Direito

Categorias: C · Decisão: **agrupar:afo** · Fase: - · Meta: 0

Lei 4.320/64 e LRF tratadas como parte de AFO/Finanças Públicas para não duplicar entidade.

### Direito Militar (`dir_militar`) — Direito

Categorias: C · Decisão: **adiar** · Fase: - · Meta: 0

Nicho (PM/CBM/Forças) com legislação estadual variável; exige fontes por ente. Nenhuma matéria vazia será criada.

### Criminologia (`criminologia`) — Direito

Categorias: C · Decisão: **adiar** · Fase: - · Meta: 0

Cobrada em carreiras policiais/MP; fontes livres insuficientes para meta mínima agora; reavaliar após Penal/Proc. Penal.

### Administração Geral (`adm_geral`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 650

Teorias, funções administrativas, estrutura organizacional, liderança, cultura.

Competências: Relacionar teorias a práticas · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `adm_geral.teorias_administrativas` | Teorias da administração | fundamental | — |
| `adm_geral.planejamento_estrategico` | Planejamento e estratégia | intermediário | — |
| `adm_geral.organizacao_estrutura` | Organização e estruturas | intermediário | — |
| `adm_geral.direcao_lideranca` | Direção, liderança e motivação | intermediário | — |
| `adm_geral.controle_desempenho` | Controle e desempenho | intermediário | — |
| `adm_geral.cultura_mudanca` | Cultura e mudança organizacional | avançado | — |

### Administração Pública (`adm_publica`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 550

Modelos de gestão pública, reforma gerencial, governança, transparência.

Competências: Distinguir patrimonialismo, burocracia e gerencialismo · Fontes: planalto-cf88, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `adm_publica.modelos_gestao_publica` | Modelos: patrimonialista, burocrático, gerencial | fundamental | — |
| `adm_publica.reforma_gerencial` | Reforma gerencial e agências | intermediário | `modelos_gestao_publica` |
| `adm_publica.governo_eletronico` | Governo digital e transparência | intermediário | — |
| `adm_publica.accountability` | Accountability e controle social | intermediário | — |

### Ética no Serviço Público (`etica_servico_publico`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 350

Decreto 1.171/94 (Código de Ética), Lei 8.112 deveres e proibições, conflito de interesses.

Competências: Aplicar normas éticas a casos · Fontes: planalto-lei8112, planalto-decreto1171, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `etica_servico_publico.etica_conceitos` | Ética e moral | fundamental | — |
| `etica_servico_publico.codigo_etica_decreto1171` | Código de Ética (Decreto 1.171/94) | fundamental | `etica_conceitos` |
| `etica_servico_publico.conflito_interesses` | Conflito de interesses e comissões de ética | intermediário | — |

### Arquivologia (`arquivologia`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 400

Princípios, gestão documental, classificação, avaliação, preservação e Lei 8.159/91.

Competências: Aplicar ciclo de vida dos documentos · Fontes: planalto-lei8159, conarq, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `arquivologia.conceitos_arquivo` | Conceitos e princípios arquivísticos | fundamental | — |
| `arquivologia.ciclo_vital` | Gestão documental e teoria das três idades | intermediário | `conceitos_arquivo` |
| `arquivologia.classificacao_avaliacao` | Classificação e avaliação | intermediário | `ciclo_vital` |
| `arquivologia.preservacao_digital` | Preservação e documentos digitais | avançado | `ciclo_vital` |

### Gestão de Pessoas (`gestao_pessoas`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 450

Recrutamento, treinamento, desempenho, remuneração, clima e comportamento organizacional.

Competências: Escolher prática de GP adequada · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `gestao_pessoas.gp_estrategica` | Gestão estratégica de pessoas | fundamental | — |
| `gestao_pessoas.recrutamento_selecao` | Recrutamento e seleção | intermediário | — |
| `gestao_pessoas.treinamento_desenvolvimento` | Treinamento e desenvolvimento | intermediário | — |
| `gestao_pessoas.avaliacao_desempenho` | Avaliação de desempenho | intermediário | — |
| `gestao_pessoas.comportamento_organizacional` | Comportamento organizacional e clima | avançado | — |

### Gestão de Projetos (`gestao_projetos`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 400

Ciclo de vida, escopo, prazo, custo, riscos e metodologias (conceitos gerais; sem copiar guias pagos).

Competências: Planejar e controlar projetos · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `gestao_projetos.ciclo_vida_projeto` | Ciclo de vida e partes interessadas | fundamental | — |
| `gestao_projetos.escopo_prazo_custo` | Escopo, prazo e custo (EAP, cronograma, EVM) | intermediário | `ciclo_vida_projeto` |
| `gestao_projetos.riscos_qualidade` | Riscos e qualidade | intermediário | `ciclo_vida_projeto` |
| `gestao_projetos.metodos_ageis` | Métodos ágeis e híbridos | intermediário | — |

### Administração de Materiais (`adm_materiais`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 350

Gestão de estoques, classificação ABC, compras e patrimônio.

Competências: Calcular estoques e classificar itens · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `adm_materiais.classificacao_abc` | Classificação de materiais e curva ABC | fundamental | — |
| `adm_materiais.gestao_estoques` | Gestão de estoques (lote econômico, ponto de pedido) | intermediário | `classificacao_abc` |
| `adm_materiais.compras_patrimonio` | Compras e gestão patrimonial | intermediário | — |

### Logística (`logistica`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 300

Cadeia de suprimentos, transporte, armazenagem e indicadores.

Competências: Escolher modal e dimensionar armazenagem · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `logistica.cadeia_suprimentos` | Cadeia de suprimentos | fundamental | — |
| `logistica.transportes_modais` | Transporte e modais | intermediário | — |
| `logistica.armazenagem_distribuicao` | Armazenagem e distribuição | intermediário | — |

### Licitações e Contratos (`licitacoes_contratos`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 600

Lei 14.133/2021: modalidades, fases, contratação direta, contratos e sanções.

Competências: Aplicar Lei 14.133 (vigência verificada) · Fontes: planalto-lei14133, tcu-orientacoes, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `licitacoes_contratos.principios_licitacao` | Princípios e agentes da licitação | fundamental | — |
| `licitacoes_contratos.modalidades_criterios` | Modalidades e critérios de julgamento | intermediário | `principios_licitacao` |
| `licitacoes_contratos.fases_licitacao` | Fases do processo licitatório | intermediário | `modalidades_criterios` |
| `licitacoes_contratos.contratacao_direta` | Dispensa e inexigibilidade | intermediário | `principios_licitacao` |
| `licitacoes_contratos.contratos_adm` | Contratos administrativos | avançado | `fases_licitacao` |
| `licitacoes_contratos.sancoes_nulidades` | Sanções, nulidades e controle | avançado | `contratos_adm` |

### Gestão de Processos e Qualidade (`gestao_processos_qualidade`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 300

BPM, mapeamento, indicadores, ferramentas da qualidade.

Competências: Modelar e melhorar processos · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `gestao_processos_qualidade.mapeamento_processos` | Mapeamento e modelagem de processos | fundamental | — |
| `gestao_processos_qualidade.ferramentas_qualidade` | Ferramentas da qualidade (PDCA, Pareto, Ishikawa) | fundamental | — |
| `gestao_processos_qualidade.indicadores_melhoria` | Indicadores e melhoria contínua | intermediário | — |

### Governança, Riscos e Controle (`governanca_controle`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 350

Governança pública, gestão de riscos, controle interno e externo, integridade.

Competências: Distinguir linhas de defesa e instâncias · Fontes: planalto-cf88, cgu-publicacoes, tcu-orientacoes, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `governanca_controle.governanca_publica` | Governança pública | intermediário | — |
| `governanca_controle.gestao_riscos` | Gestão de riscos | intermediário | — |
| `governanca_controle.controle_interno_externo` | Controle interno e externo | intermediário | — |
| `governanca_controle.integridade_compliance` | Integridade e compliance | avançado | — |

### Políticas Públicas (`politicas_publicas`) — Gestão

Categorias: C · Decisão: **incluir** · Fase: 3 · Meta: 250

Ciclo das políticas públicas, avaliação, atores e instrumentos.

Competências: Identificar etapa do ciclo e instrumento · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `politicas_publicas.ciclo_politicas` | Ciclo de políticas públicas | fundamental | — |
| `politicas_publicas.avaliacao_politicas` | Monitoramento e avaliação | intermediário | — |
| `politicas_publicas.atores_instrumentos` | Atores e instrumentos | intermediário | — |

### Contabilidade Geral (`contabilidade_geral`) — Finanças

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 800

Patrimônio, escrituração, demonstrações contábeis, CPC, análise de balanços.

Competências: Registrar fatos e elaborar demonstrações; sem copiar normas pagas · Fontes: cpc-pronunciamentos, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `contabilidade_geral.patrimonio_equacao` | Patrimônio e equação fundamental | fundamental | — |
| `contabilidade_geral.escrituracao_debito_credito` | Escrituração e contas | fundamental | `patrimonio_equacao` |
| `contabilidade_geral.estoques_inventario` | Estoques e custo das mercadorias | intermediário | `escrituracao_debito_credito` |
| `contabilidade_geral.demonstracoes` | Demonstrações contábeis (BP, DRE, DFC, DMPL) | intermediário | `escrituracao_debito_credito` |
| `contabilidade_geral.depreciacao_ativos` | Depreciação e ativo imobilizado | intermediário | `demonstracoes` |
| `contabilidade_geral.analise_balancos` | Análise das demonstrações | avançado | `demonstracoes` |

### Contabilidade Pública (`contabilidade_publica`) — Finanças

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 650

Princípios, plano de contas, variações patrimoniais, demonstrações do setor público (MCASP/NBC TSP).

Competências: Classificar fatos pelo regime patrimonial/orçamentário · Fontes: stn-mcasp, cfc-nbc-tsp, planalto-lei4320, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `contabilidade_publica.campo_aplicacao_principios` | Campo de aplicação e princípios | fundamental | — |
| `contabilidade_publica.receita_despesa_orcamentaria` | Receita e despesa orçamentárias | intermediário | `campo_aplicacao_principios` |
| `contabilidade_publica.vpa_vpd` | Variações patrimoniais | intermediário | `receita_despesa_orcamentaria` |
| `contabilidade_publica.demonstracoes_setor_publico` | Demonstrações aplicadas ao setor público | avançado | `vpa_vpd` |
| `contabilidade_publica.patrimonio_publico` | Patrimônio e dívida pública | intermediário | — |

### Economia (`economia`) — Finanças

Categorias: E, V, C · Decisão: **incluir** · Fase: 1 · Meta: 900

Micro, macro, economia brasileira, setor externo, política monetária e fiscal.

Competências: Interpretar indicadores e modelos · Fontes: inep-matriz-enem, bcb, ibge, tesouro-transparente, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `economia.conceitos_escassez` | Conceitos básicos, escassez e fluxo circular | fundamental | — |
| `economia.oferta_demanda` | Oferta, demanda e elasticidade | fundamental | `conceitos_escassez` |
| `economia.estruturas_mercado` | Estruturas e falhas de mercado | intermediário | `oferta_demanda` |
| `economia.teoria_consumidor_firma` | Teoria do consumidor e da firma | avançado | `oferta_demanda` |
| `economia.contas_nacionais` | Contas nacionais, PIB e inflação | fundamental | — |
| `economia.politica_monetaria_fiscal` | Política monetária e fiscal | intermediário | `contas_nacionais` |
| `economia.setor_externo` | Setor externo e câmbio | intermediário | `contas_nacionais` |
| `economia.economia_brasileira` | Economia brasileira | intermediário | — |

### Administração Financeira e Orçamentária (`afo`) — Finanças

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 650

Orçamento público (Lei 4.320, LRF), ciclo orçamentário, receitas, despesas, responsabilidade fiscal. Agrupa Direito Financeiro e Finanças Públicas.

Competências: Classificar receitas/despesas; aplicar limites da LRF · Fontes: planalto-cf88, planalto-lei4320, planalto-lrf, tesouro-transparente, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `afo.principios_orcamentarios` | Princípios orçamentários | fundamental | — |
| `afo.ppa_ldo_loa` | PPA, LDO e LOA | intermediário | `principios_orcamentarios` |
| `afo.receita_publica` | Receita pública | intermediário | — |
| `afo.despesa_publica` | Despesa pública e estágios | intermediário | — |
| `afo.creditos_adicionais` | Créditos adicionais | avançado | `ppa_ldo_loa` |
| `afo.lrf` | Lei de Responsabilidade Fiscal | avançado | `ppa_ldo_loa` |
| `afo.divida_publica_afo` | Dívida pública e resultado fiscal | avançado | `lrf` |

### Auditoria (`auditoria`) — Finanças

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 450

Auditoria governamental e independente, normas, riscos, materialidade, evidências, relatórios.

Competências: Planejar e avaliar trabalho de auditoria · Fontes: cgu-publicacoes, tcu-orientacoes, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `auditoria.conceitos_auditoria` | Conceitos e tipos de auditoria | fundamental | — |
| `auditoria.planejamento_riscos` | Planejamento, risco e materialidade | intermediário | `conceitos_auditoria` |
| `auditoria.evidencias_papeis` | Evidências e papéis de trabalho | intermediário | `planejamento_riscos` |
| `auditoria.relatorios_opiniao` | Relatórios e opinião | intermediário | `evidencias_papeis` |
| `auditoria.controles_internos_aud` | Controles internos | intermediário | — |

### Contabilidade de Custos e Gerencial (`contabilidade_custos`) — Finanças

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 400

Classificação de custos, métodos de custeio, ponto de equilíbrio, orçamento empresarial.

Competências: Calcular custos e margem · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `contabilidade_custos.classificacao_custos` | Classificação e terminologia de custos | fundamental | — |
| `contabilidade_custos.custeio_absorcao_variavel` | Custeio por absorção e variável | intermediário | `classificacao_custos` |
| `contabilidade_custos.ponto_equilibrio` | Ponto de equilíbrio e margem de contribuição | intermediário | `custeio_absorcao_variavel` |
| `contabilidade_custos.custeio_abc_padrao` | Custeio ABC e custo-padrão | avançado | `custeio_absorcao_variavel` |

### Conhecimentos Bancários e SFN (`conhecimentos_bancarios`) — Finanças

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 450

SFN, BCB, CMN, produtos bancários, mercado financeiro e prevenção à lavagem de dinheiro.

Competências: Reconhecer produtos e regras do SFN · Fontes: bcb, planalto-lei4595, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `conhecimentos_bancarios.estrutura_sfn` | Estrutura do Sistema Financeiro Nacional | fundamental | — |
| `conhecimentos_bancarios.produtos_bancarios` | Produtos e serviços bancários | intermediário | — |
| `conhecimentos_bancarios.mercado_capitais` | Mercado de capitais e de câmbio | intermediário | — |
| `conhecimentos_bancarios.pld_etica_bancaria` | Prevenção à lavagem de dinheiro e ética | intermediário | — |

### Segurança da Informação (`seguranca_informacao`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 550

Princípios CID, criptografia, ameaças, controles, gestão de incidentes, LGPD.

Competências: Escolher controle adequado · Fontes: nist-publicacoes, planalto-lgpd, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `seguranca_informacao.principios_cid` | Confidencialidade, integridade e disponibilidade | fundamental | — |
| `seguranca_informacao.criptografia` | Criptografia, hash e certificação digital | intermediário | `principios_cid` |
| `seguranca_informacao.ameacas_malware` | Ameaças, ataques e malware | intermediário | `principios_cid` |
| `seguranca_informacao.controles_acesso` | Controles de acesso e autenticação | intermediário | `principios_cid` |
| `seguranca_informacao.gestao_incidentes` | Gestão de riscos e incidentes | avançado | `ameacas_malware` |
| `seguranca_informacao.lgpd` | LGPD | intermediário | — |

### Banco de Dados (`banco_dados`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 550

Modelagem, SQL, normalização, transações e noções de BI/NoSQL.

Competências: Escrever consultas e projetar esquemas · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `banco_dados.modelo_er` | Modelo entidade-relacionamento | fundamental | — |
| `banco_dados.sql_basico` | SQL: consultas e junções | fundamental | — |
| `banco_dados.normalizacao` | Normalização | intermediário | `modelo_er` |
| `banco_dados.transacoes_acid` | Transações e ACID | intermediário | — |
| `banco_dados.indices_desempenho` | Índices e desempenho | avançado | `sql_basico` |
| `banco_dados.nosql_bi` | NoSQL e data warehouse | avançado | — |

### Redes de Computadores (`redes`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 500

Modelos OSI/TCP-IP, endereçamento, roteamento, protocolos de aplicação e Wi-Fi.

Competências: Diagnosticar camada e protocolo · Fontes: rfc-editor, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `redes.modelos_osi_tcpip` | Modelos OSI e TCP/IP | fundamental | — |
| `redes.enderecamento_ip` | Endereçamento IP e sub-redes | intermediário | `modelos_osi_tcpip` |
| `redes.protocolos_aplicacao` | Protocolos de aplicação (HTTP, DNS, SMTP) | intermediário | `modelos_osi_tcpip` |
| `redes.roteamento_comutacao` | Roteamento e comutação | avançado | `enderecamento_ip` |
| `redes.redes_sem_fio_seguranca` | Redes sem fio e segurança de rede | intermediário | — |

### Lógica de Programação e Algoritmos (`logica_programacao`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 600

Algoritmos, estruturas de controle, estruturas de dados, complexidade e POO. Agrupa Algoritmos.

Competências: Ler e escrever algoritmos · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `logica_programacao.variaveis_tipos` | Variáveis, tipos e operadores | fundamental | — |
| `logica_programacao.estruturas_controle` | Estruturas de controle | fundamental | `variaveis_tipos` |
| `logica_programacao.funcoes_recursao` | Funções e recursão | intermediário | `estruturas_controle` |
| `logica_programacao.estruturas_dados` | Estruturas de dados (listas, pilhas, filas, árvores) | intermediário | `funcoes_recursao` |
| `logica_programacao.complexidade` | Complexidade de algoritmos | avançado | `estruturas_dados` |
| `logica_programacao.poo` | Orientação a objetos | intermediário | — |

### Engenharia de Software (`engenharia_software`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 500

Processos, requisitos, projeto, UML, testes, métodos ágeis e qualidade.

Competências: Escolher modelo e prática · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `engenharia_software.processos_software` | Processos e ciclo de vida | fundamental | — |
| `engenharia_software.requisitos` | Engenharia de requisitos | intermediário | `processos_software` |
| `engenharia_software.uml_projeto` | UML e padrões de projeto | intermediário | `requisitos` |
| `engenharia_software.testes` | Testes de software | intermediário | — |
| `engenharia_software.agil_devops` | Métodos ágeis e DevOps | intermediário | — |

### Sistemas Operacionais (`sistemas_operacionais`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 350

Processos, memória, arquivos, Linux e Windows.

Competências: Relacionar conceito a comportamento do SO · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `sistemas_operacionais.processos_threads` | Processos e threads | fundamental | — |
| `sistemas_operacionais.escalonamento_memoria` | Escalonamento e memória | intermediário | `processos_threads` |
| `sistemas_operacionais.sistemas_arquivos` | Sistemas de arquivos | intermediário | — |
| `sistemas_operacionais.linux_comandos` | Linux: comandos e permissões | intermediário | — |

### Arquitetura de Computadores (`arquitetura_computadores`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 300

CPU, memória, E/S, representação numérica e desempenho.

Competências: Converter bases e avaliar desempenho · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `arquitetura_computadores.representacao_numerica` | Sistemas de numeração e representação | fundamental | — |
| `arquitetura_computadores.cpu_memoria` | CPU, pipeline e hierarquia de memória | intermediário | — |
| `arquitetura_computadores.entrada_saida_barramentos` | Entrada/saída e barramentos | intermediário | — |

### Governança de TI (`governanca_ti`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir** · Fase: 2 · Meta: 350

COBIT, ITIL, gestão de serviços e contratações de TI (conceitos gerais).

Competências: Distinguir frameworks e processos · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `governanca_ti.conceitos_governanca_ti` | Conceitos de governança e gestão de TI | fundamental | — |
| `governanca_ti.gestao_servicos` | Gestão de serviços de TI | intermediário | — |
| `governanca_ti.contratacao_ti` | Contratação de soluções de TI | avançado | — |

### Computação em Nuvem (`computacao_nuvem`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir-meta-reduzida** · Fase: 3 · Meta: 200

Modelos IaaS/PaaS/SaaS, virtualização, contêineres.

Competências: Escolher modelo de serviço · Fontes: nist-publicacoes, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `computacao_nuvem.modelos_servico` | Modelos de serviço e implantação | fundamental | — |
| `computacao_nuvem.virtualizacao_conteineres` | Virtualização e contêineres | intermediário | — |

### Ciência de Dados e Inteligência Artificial (`ciencia_dados_ia`) — Tecnologia e Computação

Categorias: C · Decisão: **incluir-meta-reduzida** · Fase: 3 · Meta: 250

Mineração de dados, aprendizado de máquina, ética em IA.

Competências: Distinguir técnicas e métricas · Fontes: bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `ciencia_dados_ia.mineracao_dados` | Mineração de dados e BI | intermediário | — |
| `ciencia_dados_ia.aprendizado_maquina` | Aprendizado de máquina | intermediário | — |
| `ciencia_dados_ia.etica_ia` | Ética e uso responsável de IA | fundamental | — |

### Pedagogia (`pedagogia`) — Educação

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 550

Fundamentos, teorias da aprendizagem, currículo e avaliação.

Competências: Relacionar teoria e prática · Fontes: bncc, planalto-ldb, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `pedagogia.fundamentos_historicos` | Fundamentos históricos e filosóficos da educação | fundamental | — |
| `pedagogia.teorias_aprendizagem` | Teorias da aprendizagem | intermediário | — |
| `pedagogia.curriculo_bncc` | Currículo e BNCC | intermediário | — |
| `pedagogia.avaliacao_aprendizagem` | Avaliação da aprendizagem | intermediário | — |
| `pedagogia.projeto_politico_pedagogico` | Projeto político-pedagógico | intermediário | — |

### Didática (`didatica`) — Educação

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 400

Planejamento, métodos, recursos e mediação do ensino.

Competências: Planejar aulas · Fontes: bncc, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `didatica.planejamento_ensino` | Planejamento de ensino | fundamental | — |
| `didatica.metodos_estrategias` | Métodos e estratégias | intermediário | — |
| `didatica.relacao_professor_aluno` | Mediação e relação professor-aluno | intermediário | — |

### Legislação Educacional (`legislacao_educacional`) — Educação

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 450

LDB (Lei 9.394/96), ECA, PNE e diretrizes.

Competências: Aplicar LDB e PNE · Fontes: planalto-ldb, planalto-cf88, planalto-eca, planalto-pne, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `legislacao_educacional.educacao_na_cf` | Educação na Constituição | fundamental | — |
| `legislacao_educacional.ldb_estrutura` | LDB: organização da educação nacional | intermediário | `educacao_na_cf` |
| `legislacao_educacional.eca_educacao` | ECA e direito à educação | intermediário | — |
| `legislacao_educacional.pne` | Plano Nacional de Educação | intermediário | — |

### Redação Oficial (`redacao_oficial`) — Educação

Categorias: C · Decisão: **incluir** · Fase: 1 · Meta: 350

Manual de Redação da Presidência: ofícios, memorandos, pronomes de tratamento, padrão ofício.

Competências: Redigir documentos oficiais · Fontes: manual-redacao-presidencia, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `redacao_oficial.principios_redacao_oficial` | Princípios e características | fundamental | — |
| `redacao_oficial.padrao_oficio` | Padrão ofício e documentos | intermediário | `principios_redacao_oficial` |
| `redacao_oficial.pronomes_fechos` | Pronomes de tratamento e fechos | fundamental | — |
| `redacao_oficial.correspondencia_digital` | Correspondência eletrônica e atos normativos | intermediário | — |

### Psicologia da Educação (`psicologia_educacao`) — Educação

Categorias: C · Decisão: **incluir-meta-reduzida** · Fase: 3 · Meta: 250

Desenvolvimento humano, aprendizagem e motivação.

Competências: Associar teoria a situações escolares · Fontes: bncc, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `psicologia_educacao.desenvolvimento_humano` | Desenvolvimento humano | intermediário | — |
| `psicologia_educacao.aprendizagem_motivacao` | Aprendizagem e motivação | intermediário | — |

### Educação Inclusiva (`educacao_inclusiva`) — Educação

Categorias: C · Decisão: **incluir-meta-reduzida** · Fase: 3 · Meta: 250

Política de educação especial na perspectiva inclusiva, AEE, Lei Brasileira de Inclusão.

Competências: Aplicar LBI e política nacional · Fontes: planalto-lbi, planalto-ldb, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `educacao_inclusiva.politica_inclusiva` | Política nacional e LBI | intermediário | — |
| `educacao_inclusiva.aee_adaptacoes` | AEE e adaptações curriculares | intermediário | — |

### Gestão Escolar (`gestao_escolar`) — Educação

Categorias: C · Decisão: **incluir-meta-reduzida** · Fase: 3 · Meta: 250

Gestão democrática, conselhos, financiamento e PPP.

Competências: Aplicar gestão democrática · Fontes: planalto-ldb, planalto-pne, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `gestao_escolar.gestao_democratica` | Gestão democrática | fundamental | — |
| `gestao_escolar.financiamento_educacao` | Financiamento da educação | intermediário | — |

### Saúde Pública e SUS (`saude_publica_sus`) — Saúde e Sociedade

Categorias: C · Decisão: **incluir-meta-reduzida** · Fase: 3 · Meta: 300

Lacuna identificada: Leis 8.080/90 e 8.142/90, princípios do SUS, atenção básica, vigilância.

Competências: Aplicar leis orgânicas do SUS · Fontes: planalto-lei8080, bancas-programas

| Tópico (id estável) | Nome | Nível | Pré-requisitos |
|---|---|---|---|
| `saude_publica_sus.principios_sus` | Princípios e organização do SUS | fundamental | — |
| `saude_publica_sus.atencao_vigilancia` | Atenção básica e vigilância em saúde | intermediário | — |
| `saude_publica_sus.financiamento_controle_social` | Financiamento e controle social | intermediário | — |
