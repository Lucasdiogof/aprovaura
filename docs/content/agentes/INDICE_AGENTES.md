# Índice de agentes do AprovaAura (conteúdo)

Gerado por `python tool/content/agents/gen_agents.py` — **não edite à mão**: altere `tool/content/agents/especializacoes.py` ou o gerador e rode de novo. Definições versionadas em `.claude/agents/`.

Total: **75 especialistas de matéria** + **10 transversais**.

## Como acionar

- Um especialista: em linguagem natural ("use o agente esp-dir_penal para revisar Penas") ou `claude --agent esp-dir_penal`; no código, `Agent(subagent_type="esp-dir_penal")`.
- Tarefas multi-matéria: `claude --agent coordenador-pedagogico` e peça, ex.: "adicione 200 questões de Física, foco em difíceis". O coordenador grava um plano em `tool/content/plans/`, aciona poucos agentes por vez e consolida. (Subagentes não acionam outros subagentes: fora da sessão principal o coordenador só entrega o plano.)
- Contexto vivo de qualquer matéria: `python tool/content/agents/ctx.py <slug>`. Protocolo comum: `docs/content/agentes/PROTOCOLO_ESPECIALISTA.md`.
- **Matéria nova**: (1) incluir em `tool/content/curriculum/materias_novas.txt` e `python tool/content/gen_matrix.py`; (2) adicionar entrada em `especializacoes.py`; (3) `python tool/content/agents/gen_agents.py`; (4) `python -m unittest discover -s tool/content/agents` (falha se faltar agente).
- Independência: especialista produz; **outro** agente resolve em modo cego (`valida-gabaritos`), revisa (`revisor-pedagogico`, `revisor-<categoria>`, auditores); o pipeline decide o estado. Validação por IA não é revisão humana.

## Transversais

| Agente | Responsabilidade |
|---|---|
| `coordenador-pedagogico` | Coordenador pedagógico do acervo do AprovaAura. Use para pedidos que envolvem várias matérias, lotes ou validações (ex.: 'adicione 500 questões de Matemática', 'revise todo Direito Constitucional', 'ache matérias com baixa cobertura em Concursos'). Planeja o lote, escolhe especialistas e validadores, consolida resultados. |
| `revisor-enem` | Revisor específico de ENEM: confere adequação à Matriz de Referência do INEP (competências e habilidades), estilo de situação-problema, interdisciplinaridade e contextualização das questões classificadas como `enem`. |
| `revisor-vestibulares` | Revisor específico de Vestibulares: confere aprofundamento, programas de vestibulares próprios, questões dissertativas/objetivas conforme o app e adequação por nível; classifica a categoria `vestibular`. |
| `revisor-concursos` | Revisor específico de Concursos: confere aderência a conteúdos programáticos de bancas, rigor técnico/normativo, vigência e estilo de múltipla escolha de 4 alternativas; classifica a categoria `concurso`. |
| `valida-gabaritos` | Validador independente de gabaritos: resolve as questões SEM ver o gabarito (arquivo *_cego.jsonl), usa python/sympy/sqlite/ipaddress para cálculo e registra divergências e ambiguidades. Nunca o autor do lote. |
| `revisor-pedagogico` | Revisor pedagógico: avalia clareza, nível, qualidade dos distratores e das explicações (devem ensinar e justificar as alternativas erradas pelo conteúdo, não pela posição), coerência da dificuldade e ausência de viés (correta mais longa). |
| `auditor-duplicidades` | Auditor de duplicidades: detecta questões iguais ou quase iguais (hash, normalização, n-gramas/MinHash locais) dentro do lote, entre lotes e contra o acervo; nunca apaga questão com histórico. |
| `auditor-fontes-licencas` | Auditor de fontes e licenciamento: confere se cada referência existe, está registrada em sources.json com licença/uso adequados, e se nenhuma questão copia ou parafraseia provas, bancos comerciais ou textos protegidos. |
| `auditor-legislacao` | Auditor de legislação: confere artigos, incisos, vigência, revogações, alterações recentes e jurisprudência citada nas questões e teorias jurídicas/normativas; mantém datas de revisão. Não substitui revisão humana especializada. |
| `gestor-acervo` | Gestor e consolidador do acervo: acompanha lotes, estados, cobertura, metas, pendências e relatórios; mantém docs/content/COBERTURA.md, o registro de pendências e o roadmap fiéis ao progresso real. |

## Especialistas de matéria

| Agente | Matéria | Categorias | Origem |
|---|---|---|---|
| `esp-portugues` | Português | ENEM, Vestibulares, Concursos | existente |
| `esp-literatura` | Literatura | ENEM, Vestibulares | existente |
| `esp-artes` | Artes | ENEM, Vestibulares | existente |
| `esp-educacao_fisica` | Educação Física | ENEM, Vestibulares | existente |
| `esp-ingles` | Inglês | ENEM, Vestibulares, Concursos | existente |
| `esp-espanhol` | Espanhol | ENEM, Vestibulares | existente |
| `esp-historia` | História | ENEM, Vestibulares | existente |
| `esp-geografia` | Geografia | ENEM, Vestibulares | existente |
| `esp-filosofia` | Filosofia | ENEM, Vestibulares | existente |
| `esp-sociologia` | Sociologia | ENEM, Vestibulares | existente |
| `esp-biologia` | Biologia | ENEM, Vestibulares | existente |
| `esp-fisica` | Física | ENEM, Vestibulares | existente |
| `esp-quimica` | Química | ENEM, Vestibulares | existente |
| `esp-matematica` | Matemática | ENEM, Vestibulares, Concursos | existente |
| `esp-atualidades` | Atualidades | ENEM, Vestibulares, Concursos | existente |
| `esp-redacao` | Redação | ENEM, Vestibulares, Concursos | existente |
| `esp-raciocinio_logico` | Raciocínio Lógico | Concursos | nova |
| `esp-informatica` | Informática | Concursos | nova |
| `esp-matematica_financeira` | Matemática Financeira | Concursos, ENEM | nova |
| `esp-estatistica` | Estatística | ENEM, Vestibulares, Concursos | nova |
| `esp-educacao_financeira` | Educação Financeira | ENEM, Concursos | nova |
| `esp-dir_constitucional` | Direito Constitucional | Concursos | nova |
| `esp-dir_administrativo` | Direito Administrativo | Concursos | nova |
| `esp-dir_penal` | Direito Penal | Concursos | nova |
| `esp-dir_proc_penal` | Direito Processual Penal | Concursos | nova |
| `esp-dir_civil` | Direito Civil | Concursos | nova |
| `esp-dir_proc_civil` | Direito Processual Civil | Concursos | nova |
| `esp-dir_tributario` | Direito Tributário | Concursos | nova |
| `esp-dir_trabalho` | Direito do Trabalho | Concursos | nova |
| `esp-dir_proc_trabalho` | Direito Processual do Trabalho | Concursos | nova |
| `esp-dir_eleitoral` | Direito Eleitoral | Concursos | nova |
| `esp-dir_ambiental` | Direito Ambiental | Concursos, ENEM | nova |
| `esp-dir_empresarial` | Direito Empresarial | Concursos | nova |
| `esp-dir_previdenciario` | Direito Previdenciário | Concursos | nova |
| `esp-direitos_humanos` | Direitos Humanos | ENEM, Concursos | nova |
| `esp-legislacao_especifica` | Legislação Específica | Concursos | nova |
| `esp-dir_consumidor` | Direito do Consumidor | Concursos, ENEM | nova |
| `esp-dir_internacional_publico` | Direito Internacional Público | Concursos | nova |
| `esp-adm_geral` | Administração Geral | Concursos | nova |
| `esp-adm_publica` | Administração Pública | Concursos | nova |
| `esp-etica_servico_publico` | Ética no Serviço Público | Concursos | nova |
| `esp-arquivologia` | Arquivologia | Concursos | nova |
| `esp-gestao_pessoas` | Gestão de Pessoas | Concursos | nova |
| `esp-gestao_projetos` | Gestão de Projetos | Concursos | nova |
| `esp-adm_materiais` | Administração de Materiais | Concursos | nova |
| `esp-logistica` | Logística | Concursos | nova |
| `esp-licitacoes_contratos` | Licitações e Contratos | Concursos | nova |
| `esp-gestao_processos_qualidade` | Gestão de Processos e Qualidade | Concursos | nova |
| `esp-governanca_controle` | Governança, Riscos e Controle | Concursos | nova |
| `esp-politicas_publicas` | Políticas Públicas | Concursos | nova |
| `esp-contabilidade_geral` | Contabilidade Geral | Concursos | nova |
| `esp-contabilidade_publica` | Contabilidade Pública | Concursos | nova |
| `esp-economia` | Economia | ENEM, Vestibulares, Concursos | nova |
| `esp-afo` | Administração Financeira e Orçamentária | Concursos | nova |
| `esp-auditoria` | Auditoria | Concursos | nova |
| `esp-contabilidade_custos` | Contabilidade de Custos e Gerencial | Concursos | nova |
| `esp-conhecimentos_bancarios` | Conhecimentos Bancários e SFN | Concursos | nova |
| `esp-seguranca_informacao` | Segurança da Informação | Concursos | nova |
| `esp-banco_dados` | Banco de Dados | Concursos | nova |
| `esp-redes` | Redes de Computadores | Concursos | nova |
| `esp-logica_programacao` | Lógica de Programação e Algoritmos | Concursos | nova |
| `esp-engenharia_software` | Engenharia de Software | Concursos | nova |
| `esp-sistemas_operacionais` | Sistemas Operacionais | Concursos | nova |
| `esp-arquitetura_computadores` | Arquitetura de Computadores | Concursos | nova |
| `esp-governanca_ti` | Governança de TI | Concursos | nova |
| `esp-computacao_nuvem` | Computação em Nuvem | Concursos | nova |
| `esp-ciencia_dados_ia` | Ciência de Dados e Inteligência Artificial | Concursos | nova |
| `esp-pedagogia` | Pedagogia | Concursos | nova |
| `esp-didatica` | Didática | Concursos | nova |
| `esp-legislacao_educacional` | Legislação Educacional | Concursos | nova |
| `esp-redacao_oficial` | Redação Oficial | Concursos | nova |
| `esp-psicologia_educacao` | Psicologia da Educação | Concursos | nova |
| `esp-educacao_inclusiva` | Educação Inclusiva | Concursos | nova |
| `esp-gestao_escolar` | Gestão Escolar | Concursos | nova |
| `esp-saude_publica_sus` | Saúde Pública e SUS | Concursos | nova |
