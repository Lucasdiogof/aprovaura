# Fontes, licenças e política de uso

Gerado por `tool/content/gen_matrix.py` + `verify_sources.py`. Fonte da verdade: `tool/content/curriculum/sources.json`; verificação HTTP em `tool/content/state/sources_check.json`.

## Regras permanentes

1. **Não copiamos** bancos/plataformas comerciais (Qconcursos, Gran, Estratégia, TEC e similares), não fazemos scraping que viole termos e não republicamos provas protegidas.
2. Documentos oficiais servem para **matriz e estilo**; as questões são **autorais originais** (sem paráfrase disfarçada, sem atribuir a banca/instituição real).
3. Questão oficial só entra com autorização/licença/domínio público **documentados** (origem `oficial_autorizada` + URL + licença + data).
4. Legislação e atos oficiais não são objeto de proteção autoral (Lei 9.610/98, art. 8º, IV). Texto de lei só vale com **artigo + data de vigência verificada**.
5. 'a confirmar' em licença = não confirmado; a fonte só alimenta a matriz, sem reprodução.

## Registro (47 fontes)

| ID | Fonte | URL | Uso | Licença documentada | HTTP | Consulta |
|---|---|---|---|---|---|---|
| `inep-matriz-enem` | INEP — Matriz de Referência do ENEM | https://www.gov.br/inep/pt-br/areas-de-atuacao/avaliacao-e-exames-educacionais/enem | matriz | a confirmar (conteúdo gov.br; usar apenas estrutura de competências/objetos de conhecimento) | 200 | 2026-11-27 |
| `bncc` | MEC — Base Nacional Comum Curricular | http://basenacionalcomum.mec.gov.br/ | matriz | a confirmar (documento oficial do MEC; usar como referência curricular) | 403 — bloqueio anti-bot: abrir manualmente | 2026-11-27 |
| `ibge` | IBGE — Dados e indicadores | https://www.ibge.gov.br/ | referencia | a confirmar (dados estatísticos públicos; citar fonte e data) | 403 — bloqueio anti-bot: abrir manualmente | 2026-11-27 |
| `bcb` | Banco Central do Brasil | https://www.bcb.gov.br/ | referencia | a confirmar (indicadores públicos; citar fonte e data de referência) | 200 | 2026-11-27 |
| `tesouro-transparente` | Tesouro Nacional — Tesouro Transparente | https://www.tesourotransparente.gov.br/ | referencia | a confirmar (dados abertos; citar fonte e data) | 200 | 2026-11-27 |
| `stn-mcasp` | STN — Manual de Contabilidade Aplicada ao Setor Público (MCASP) | https://www.tesourotransparente.gov.br/publicacoes/manual-de-contabilidade-aplicada-ao-setor-publico-mcasp | referencia | a confirmar; usar como referência, questões autorais | 200 | 2026-11-27 |
| `cfc-nbc-tsp` | CFC — NBC TSP (normas do setor público) | https://cfc.org.br/ | referencia | a confirmar; não reproduzir texto | 200 | 2026-11-27 |
| `cpc-pronunciamentos` | CPC — Pronunciamentos Contábeis | https://www.cpc.org.br/ | referencia | a confirmar; uso como referência, sem reproduzir | 200 | 2026-11-27 |
| `cgu-publicacoes` | CGU — publicações e referenciais | https://www.gov.br/cgu/pt-br | referencia | a confirmar | 200 | 2026-11-27 |
| `tcu-orientacoes` | TCU — orientações e publicações | https://portal.tcu.gov.br/ | referencia | a confirmar | 200 | 2026-11-27 |
| `conarq` | CONARQ / Arquivo Nacional | https://www.gov.br/conarq/pt-br | referencia | a confirmar | 200 | 2026-11-27 |
| `manual-redacao-presidencia` | Presidência da República — Manual de Redação | https://www.gov.br/planalto/pt-br/acesso-a-informacao/manual-de-redacao | referencia | a confirmar; questões autorais sobre o padrão, sem reproduzir o manual | 404 — URL a corrigir | 2026-11-27 |
| `planalto-cf88` | Constituição Federal de 1988 (compilada) | https://www.planalto.gov.br/ccivil_03/constituicao/constituicaocompilado.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-cp` | Código Penal (Decreto-Lei 2.848/1940) | https://www.planalto.gov.br/ccivil_03/decreto-lei/del2848compilado.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-cpp` | Código de Processo Penal (Decreto-Lei 3.689/1941) | https://www.planalto.gov.br/ccivil_03/decreto-lei/del3689compilado.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-cc` | Código Civil (Lei 10.406/2002) | https://www.planalto.gov.br/ccivil_03/leis/2002/l10406compilada.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-cpc` | Código de Processo Civil (Lei 13.105/2015) | https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2015/lei/l13105.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-ctn` | Código Tributário Nacional (Lei 5.172/1966) | https://www.planalto.gov.br/ccivil_03/leis/l5172compilado.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-clt` | CLT (Decreto-Lei 5.452/1943) | https://www.planalto.gov.br/ccivil_03/decreto-lei/del5452.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-codigo-eleitoral` | Código Eleitoral (Lei 4.737/1965) | https://www.planalto.gov.br/ccivil_03/leis/l4737compilado.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lei14133` | Lei de Licitações e Contratos (Lei 14.133/2021) | https://www.planalto.gov.br/ccivil_03/_ato2019-2022/2021/lei/L14133.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lei8112` | Estatuto dos Servidores Federais (Lei 8.112/1990) | https://www.planalto.gov.br/ccivil_03/leis/l8112cons.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lei9784` | Processo Administrativo Federal (Lei 9.784/1999) | https://www.planalto.gov.br/ccivil_03/leis/l9784.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lei8429` | Improbidade Administrativa (Lei 8.429/1992) | https://www.planalto.gov.br/ccivil_03/leis/l8429.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lrf` | Lei de Responsabilidade Fiscal (LC 101/2000) | https://www.planalto.gov.br/ccivil_03/leis/lcp/lcp101.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lei4320` | Normas de Direito Financeiro (Lei 4.320/1964) | https://www.planalto.gov.br/ccivil_03/leis/l4320.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lei6938` | Política Nacional do Meio Ambiente (Lei 6.938/1981) | https://www.planalto.gov.br/ccivil_03/leis/l6938.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lei8213` | Benefícios da Previdência Social (Lei 8.213/1991) | https://www.planalto.gov.br/ccivil_03/leis/l8213cons.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lei4595` | Sistema Financeiro Nacional (Lei 4.595/1964) | https://www.planalto.gov.br/ccivil_03/leis/l4595.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lgpd` | LGPD (Lei 13.709/2018) | https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-cdc` | Código de Defesa do Consumidor (Lei 8.078/1990) | https://www.planalto.gov.br/ccivil_03/leis/l8078compilado.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-ldb` | LDB (Lei 9.394/1996) | https://www.planalto.gov.br/ccivil_03/leis/l9394.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-eca` | ECA (Lei 8.069/1990) | https://www.planalto.gov.br/ccivil_03/leis/l8069.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-pne` | Plano Nacional de Educação (Lei 13.005/2014) | https://www.planalto.gov.br/ccivil_03/_ato2011-2014/2014/lei/l13005.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lbi` | Lei Brasileira de Inclusão (Lei 13.146/2015) | https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2015/lei/l13146.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lei8080` | Lei Orgânica da Saúde (Lei 8.080/1990) | https://www.planalto.gov.br/ccivil_03/leis/l8080.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-lei8159` | Política Nacional de Arquivos (Lei 8.159/1991) | https://www.planalto.gov.br/ccivil_03/leis/l8159.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `planalto-decreto1171` | Código de Ética do Servidor (Decreto 1.171/1994) | https://www.planalto.gov.br/ccivil_03/decreto/d1171.htm | texto_oficial | Domínio público (Lei 9.610/98 art. 8º, IV) | 200 | 2026-11-27 |
| `stf-jurisprudencia` | STF — súmulas e jurisprudência | https://portal.stf.jus.br/jurisprudencia/sumulas.asp | texto_oficial | Decisões judiciais: não protegidas (Lei 9.610/98 art. 8º, IV); citar número e data; conferir se vigente/cancelada | 200 | 2026-11-27 |
| `stj-jurisprudencia` | STJ — súmulas | https://www.stj.jus.br/sites/portalp/Jurisprudencia/Sumulas | texto_oficial | Decisões judiciais: não protegidas (art. 8º, IV); conferir vigência | 404 — URL a corrigir | 2026-11-27 |
| `tst-jurisprudencia` | TST — súmulas e orientações | https://www.tst.jus.br/sumulas | texto_oficial | Decisões judiciais: não protegidas (art. 8º, IV); conferir vigência | 200 | 2026-11-27 |
| `tse-legislacao` | TSE — legislação e resoluções eleitorais | https://www.tse.jus.br/legislacao | texto_oficial | Atos oficiais: não protegidos (art. 8º, IV); resoluções mudam a cada eleição — registrar data | 200 | 2026-11-27 |
| `onu-oea-tratados` | ONU / OEA — textos de tratados de direitos humanos | https://www.un.org/en/about-us/universal-declaration-of-human-rights | texto_oficial | a confirmar por tratado; não traduzir de forma que altere o conteúdo avaliado | 200 | 2026-11-27 |
| `nist-publicacoes` | NIST — publicações (CSRC) | https://csrc.nist.gov/publications | referencia | Publicações do NIST em geral de domínio público nos EUA (a confirmar por documento) | 200 | 2026-11-27 |
| `rfc-editor` | RFC Editor — RFCs | https://www.rfc-editor.org/ | referencia | Termos do IETF Trust (a confirmar por RFC); usar como referência, questões autorais | 200 | 2026-11-27 |
| `bancas-programas` | Conteúdos programáticos de bancas (CEBRASPE, FGV, FCC, VUNESP, CESGRANRIO etc.) | https://www.cebraspe.org.br/concursos | matriz | Editais: só estrutura de temas para a matriz; PROVAS e questões das bancas NÃO são copiadas nem parafraseadas; nenhuma questão é atribuída à banca | 200 | 2026-11-27 |
| `vestibulares-programas` | Programas/lista de leituras de vestibulares próprios (Fuvest, Unicamp, Unesp, UERJ, UFRGS, UFG) | https://www.fuvest.br | matriz | Programas publicados: só estrutura de temas; provas anteriores com direitos reservados NÃO são republicadas | 200 | 2026-11-27 |

Fontes com HTTP diferente de 200 **não foram validadas**; nenhum conteúdo delas foi usado ainda. O 200 comprova só que a URL responde, não a licença.
