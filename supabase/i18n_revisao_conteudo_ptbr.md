# Conteúdo pt-BR para revisão (i18n)

Registro da demanda de i18n: problemas encontrados no **conteúdo original em português** durante a tradução.
Nada aqui foi corrigido automaticamente. A regra da demanda é não mexer no pt-BR em silêncio, e a correção fica a critério do dono do conteúdo.

## Questões sem acentuação

Estas questões foram cadastradas sem nenhum acento ("Goias", "e" no lugar de "é", "nao", "populacao"). As traduções en/es estão corretas;
o problema é só do original em português, que é o que aparece para quem usa o app em pt-BR.

Critério: enunciado + alternativas + explicação com mais de 100 caracteres e nenhum caractere acentuado. Levantado em 2026-09-25, em todas as matérias.

| Matéria | Tópico | Questões |
|---|---|---|
| fisica | Eletricidade | 3 |
| fisica | Fluidos | 1 |
| fisica | Mecânica > Cinemática > Lançamento horizontal | 1 |
| fisica | Mecânica > Cinemática > Lançamento oblíquo | 1 |
| fisica | Mecânica > Cinemática > Movimento uniforme | 1 |
| fisica | Mecânica > Cinemática > Movimento uniformemente variado | 1 |
| fisica | Mecânica > Cinemática > Queda livre | 1 |
| fisica | Mecânica > Dinâmica > Atrito | 1 |
| fisica | Mecânica > Dinâmica > Plano inclinado | 1 |
| fisica | Mecânica > Dinâmica > Segunda Lei de Newton | 1 |
| fisica | Mecânica > Gravitação | 2 |
| fisica | Mecânica > Trabalho e energia | 2 |
| fisica | Ondulatória | 1 |
| fisica | Termologia e Termodinâmica | 2 |
| fisica | Óptica > Espelhos esféricos > Espelho côncavo | 1 |
| fisica | Óptica > Espelhos esféricos > Foco e centro de curvatura | 1 |
| fisica | Óptica > Lentes > Lentes convergentes | 1 |
| geografia | Brasil > Energia do Brasil | 12 |
| geografia | Brasil > Estados > Goiás > Clima | 5 |
| geografia | Brasil > Estados > Goiás > Divisões regionais | 5 |
| geografia | Brasil > Estados > Goiás > Economia | 5 |
| geografia | Brasil > Estados > Goiás > Municípios | 5 |
| geografia | Brasil > Estados > Goiás > Principais cidades | 5 |
| geografia | Brasil > Estados > Goiás > Região Metropolitana de Goiânia | 5 |
| geografia | Brasil > Estados > Goiás > Relevo | 5 |
| geografia | Brasil > Estados > Goiás > Rios > Rio Araguaia | 2 |
| geografia | Brasil > Estados > Goiás > Rios > Rio Corumbá | 3 |
| geografia | Brasil > Estados > Goiás > Rios > Rio Meia Ponte | 4 |
| geografia | Brasil > Estados > Goiás > Rios > Rio Paranaíba | 4 |
| geografia | Brasil > Estados > Goiás > Rios > Rio Vermelho | 3 |
| geografia | Brasil > Estados > Goiás > Rios > Rio das Almas | 3 |
| geografia | Brasil > Estados > Goiás > Vegetação | 5 |
| geografia | Brasil > Indústria do Brasil | 12 |
| geografia | Brasil > População do Brasil | 11 |
| geografia | Brasil > Questão ambiental do Brasil | 12 |
| geografia | Brasil > Urbanização do Brasil | 12 |
| geografia | Mundo > Geopolítica e globalização | 12 |
| matematica | Análise combinatória | 1 |
| matematica | Estatística | 1 |
| matematica | Probabilidade | 1 |

Total: 155 questões.

## Nomes nos mapas (lib/assets/maps/*.geojson)

Levantado na FASE 14, em 2026-09-25. As traduções en/es (em `lib/features/map_quiz/l10n/map_region_names.dart`) usam a forma correta. Os `.geojson` ficaram intocados.

| Arquivo | sigla | nome atual | Problema |
|---|---|---|---|
| `*_capitals` | SWZ | Mebabane | Erro de grafia: a capital de Essuatíni é **Mbabane**. |
| `*_capitals` | KAZ | Nur-Sultã | A cidade voltou a se chamar **Astana** em 2022. |
| `*_capitals` | TZA | Dar es Salaam | A capital oficial da Tanzânia é **Dodoma**; Dar es Salaam é a maior cidade. |
| `*_capitals` | ZAF | Cidade do Cabo | A África do Sul tem três capitais; a executiva é **Pretória**, e Cidade do Cabo é a legislativa. Hoje o quiz aceita só Cidade do Cabo. |
| `world_soils` | — | Chernozion (Terra Negra) | O termo usual é **Chernozem** (ou Tchernozem). |
| `*_capitals` | — | Moscovo, Amesterdão, Teerão, Bagdade, Copenhaga, Helsínquia, Mónaco | Grafia de Portugal. Em pt-BR: Moscou, Amsterdã, Teerã, Bagdá, Copenhague, Helsinque, Mônaco. A camada `world_cities` já usa "Moscou", então o mesmo lugar aparece com duas grafias. |
