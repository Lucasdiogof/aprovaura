-- Partial content seed for Geografia and Matemática, taken directly from the
-- structure discussed with the user (2026-08-13). This is intentionally NOT
-- exhaustive: only a couple of branches per subject are filled all the way
-- down to real leaf activities, to prove the recursive catalog works at
-- variable depth. Every other subject stays empty for now.
--
-- Run catalog_schema.sql first. Safe to re-run: it wipes and reinserts both
-- subjects' rows each time.

delete from catalog_nodes where subject in ('geografia', 'matematica');

do $$
declare
  v_brasil uuid;
  v_brasil_hidrografia uuid;
  v_brasil_estados uuid;
  v_goias uuid;
  v_goias_rios uuid;
begin
  -- ===================== GEOGRAFIA: regiões (nível 1) =====================
  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('geografia', null, 'Brasil', 'Estados, cidades, rios, relevo, biomas e muito mais', '🇧🇷', 1)
  returning id into v_brasil;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index) values
    ('geografia', null, 'América do Sul', 'Países, capitais, cidades, relevo e hidrografia', '🌎', 2),
    ('geografia', null, 'América do Norte', 'Países, estados, capitais, relevo e hidrografia', '🌎', 3),
    ('geografia', null, 'Europa', 'Países, capitais, cidades, rios e relevo', '🌍', 4),
    ('geografia', null, 'África', 'Países, capitais, cidades, rios e relevo', '🌍', 5),
    ('geografia', null, 'Ásia', 'Países, capitais, cidades, rios e relevo', '🌏', 6),
    ('geografia', null, 'Oceania', 'Países, capitais, ilhas e relevo', '🌏', 7),
    ('geografia', null, 'Mundo', 'Continentes, oceanos, países e grandes formações', '🌐', 8);

  -- ===================== BRASIL: temas (nível 2) =====================
  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('geografia', v_brasil, 'Território', '🗺️', 1)
  ;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('geografia', v_brasil, 'Hidrografia', '💧', 2)
  returning id into v_brasil_hidrografia;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('geografia', v_brasil, 'Relevo', '⛰️', 3),
    ('geografia', v_brasil, 'Biomas e vegetação', '🌳', 4),
    ('geografia', v_brasil, 'Clima', '🌦️', 5),
    ('geografia', v_brasil, 'Cidades', '🏙️', 6),
    ('geografia', v_brasil, 'Geografia humana', '👥', 7),
    ('geografia', v_brasil, 'Geografia econômica', '🏭', 8);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('geografia', v_brasil, 'Estados', '🇧🇷', 9)
  returning id into v_brasil_estados;

  -- ============= BRASIL > HIDROGRAFIA: atividades (nível 3, folhas) =============
  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('geografia', v_brasil_hidrografia, 'Principais rios do Brasil', '💧', 1),
    ('geografia', v_brasil_hidrografia, 'Bacias hidrográficas brasileiras', '🌊', 2),
    ('geografia', v_brasil_hidrografia, 'Rio Amazonas e seus principais afluentes', '💧', 3),
    ('geografia', v_brasil_hidrografia, 'Rio Paraná e seus principais afluentes', '💧', 4),
    ('geografia', v_brasil_hidrografia, 'Rio São Francisco e seus principais afluentes', '💧', 5),
    ('geografia', v_brasil_hidrografia, 'Rios da Região Norte', '💧', 6),
    ('geografia', v_brasil_hidrografia, 'Rios da Região Nordeste', '💧', 7),
    ('geografia', v_brasil_hidrografia, 'Rios da Região Centro-Oeste', '💧', 8),
    ('geografia', v_brasil_hidrografia, 'Rios da Região Sudeste', '💧', 9),
    ('geografia', v_brasil_hidrografia, 'Rios da Região Sul', '💧', 10),
    ('geografia', v_brasil_hidrografia, 'Principais hidrelétricas brasileiras', '⚡', 11);

  -- ============= BRASIL > ESTADOS: um estado completo (Goiás) como prova =============
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('geografia', v_brasil_estados, 'Goiás', '🌾', 1)
  returning id into v_goias;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('geografia', v_goias, 'Municípios', '🗺️', 1),
    ('geografia', v_goias, 'Principais cidades', '📍', 2);
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('geografia', v_goias, 'Rios', '💧', 3)
  returning id into v_goias_rios;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('geografia', v_goias, 'Relevo', '⛰️', 4),
    ('geografia', v_goias, 'Vegetação', '🌿', 5),
    ('geografia', v_goias, 'Clima', '🌦️', 6),
    ('geografia', v_goias, 'Divisões regionais', '🛣️', 7),
    ('geografia', v_goias, 'Região Metropolitana de Goiânia', '🏙️', 8),
    ('geografia', v_goias, 'Economia', '📊', 9);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('geografia', v_goias_rios, 'Rio Araguaia', '💧', 1),
    ('geografia', v_goias_rios, 'Rio Paranaíba', '💧', 2),
    ('geografia', v_goias_rios, 'Rio Meia Ponte', '💧', 3),
    ('geografia', v_goias_rios, 'Rio Corumbá', '💧', 4),
    ('geografia', v_goias_rios, 'Rio das Almas', '💧', 5),
    ('geografia', v_goias_rios, 'Rio Vermelho', '💧', 6);
end $$;

-- ===================== outras regiões: temas (nível 2), sem folhas ainda =====================
do $$
declare
  v_america_sul uuid;
  v_europa uuid;
  v_africa uuid;
  v_asia uuid;
  v_mundo uuid;
begin
  select id into v_america_sul from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'América do Sul';
  select id into v_europa from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Europa';
  select id into v_africa from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'África';
  select id into v_asia from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Ásia';
  select id into v_mundo from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Mundo';

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('geografia', v_america_sul, 'Países', '🗺️', 1),
    ('geografia', v_america_sul, 'Bandeiras', '🏳️', 2),
    ('geografia', v_america_sul, 'Capitais', '📍', 3),
    ('geografia', v_america_sul, 'Cidades', '🏙️', 4),
    ('geografia', v_america_sul, 'Rios', '💧', 5),
    ('geografia', v_america_sul, 'Relevo', '⛰️', 6),
    ('geografia', v_america_sul, 'Biomas', '🌿', 7),
    ('geografia', v_america_sul, 'Divisões administrativas', '🗺️', 8),
    ('geografia', v_america_sul, 'Pontos turísticos', '⭐', 9),

    ('geografia', v_europa, 'Países', '🗺️', 1),
    ('geografia', v_europa, 'Bandeiras', '🏳️', 2),
    ('geografia', v_europa, 'Capitais', '📍', 3),
    ('geografia', v_europa, 'Cidades', '🏙️', 4),
    ('geografia', v_europa, 'Rios', '💧', 5),
    ('geografia', v_europa, 'Lagos e mares', '🌊', 6),
    ('geografia', v_europa, 'Montanhas e cordilheiras', '⛰️', 7),
    ('geografia', v_europa, 'Regiões', '🗺️', 8),
    ('geografia', v_europa, 'Geografia histórica', '📜', 9),
    ('geografia', v_europa, 'Pontos turísticos', '⭐', 10),

    ('geografia', v_africa, 'Países', '🗺️', 1),
    ('geografia', v_africa, 'Bandeiras', '🏳️', 2),
    ('geografia', v_africa, 'Capitais', '📍', 3),
    ('geografia', v_africa, 'Cidades', '🏙️', 4),
    ('geografia', v_africa, 'Rios', '💧', 5),
    ('geografia', v_africa, 'Lagos', '🌊', 6),
    ('geografia', v_africa, 'Desertos', '🏜️', 7),
    ('geografia', v_africa, 'Relevo', '⛰️', 8),
    ('geografia', v_africa, 'Regiões africanas', '🗺️', 9),

    ('geografia', v_asia, 'Países', '🗺️', 1),
    ('geografia', v_asia, 'Bandeiras', '🏳️', 2),
    ('geografia', v_asia, 'Capitais', '📍', 3),
    ('geografia', v_asia, 'Cidades', '🏙️', 4),
    ('geografia', v_asia, 'Rios', '💧', 5),
    ('geografia', v_asia, 'Mares', '🌊', 6),
    ('geografia', v_asia, 'Cordilheiras', '⛰️', 7),
    ('geografia', v_asia, 'Desertos', '🏜️', 8),
    ('geografia', v_asia, 'Oriente Médio', '🗺️', 9),
    ('geografia', v_asia, 'Sudeste Asiático', '🗺️', 10),
    ('geografia', v_asia, 'Sul da Ásia', '🗺️', 11),
    ('geografia', v_asia, 'Ásia Central', '🗺️', 12),

    ('geografia', v_mundo, 'Continentes', '🌎', 1),
    ('geografia', v_mundo, 'Oceanos', '🌊', 2),
    ('geografia', v_mundo, 'Países do mundo', '🗺️', 3),
    ('geografia', v_mundo, 'Bandeiras do mundo', '🏳️', 4),
    ('geografia', v_mundo, 'Capitais do mundo', '📍', 5),
    ('geografia', v_mundo, 'Grandes cidades', '🏙️', 6),
    ('geografia', v_mundo, 'Grandes rios', '💧', 7),
    ('geografia', v_mundo, 'Mares', '🌊', 8),
    ('geografia', v_mundo, 'Grandes cordilheiras', '🏔️', 9),
    ('geografia', v_mundo, 'Desertos', '🏜️', 10),
    ('geografia', v_mundo, 'Ilhas', '🏝️', 11),
    ('geografia', v_mundo, 'Vulcões', '🌋', 12),
    ('geografia', v_mundo, 'Linhas imaginárias', '🧭', 13);
end $$;

-- ===================== MATEMÁTICA =====================
do $$
declare
  v_fundamentos uuid;
  v_divisibilidade uuid;
  v_algebra uuid;
  v_equacoes uuid;
  v_geometria uuid;
begin
  -- Áreas (nível 1) — Geometria agrupa as 4 subáreas de geometria, como o
  -- usuário decidiu explicitamente para não estourar a tela principal.
  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('matematica', null, 'Fundamentos', 'Operações, frações, potências e números', '🔢', 1)
  returning id into v_fundamentos;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('matematica', null, 'Razão, proporção e porcentagem', 'Proporção, regra de três e porcentagens', '📊', 2);

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('matematica', null, 'Álgebra', 'Equações, sistemas, inequações e polinômios', '✖️', 3)
  returning id into v_algebra;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('matematica', null, 'Funções', 'Função afim, quadrática, exponencial e gráficos', '📈', 4);

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('matematica', null, 'Geometria', 'Áreas, perímetros, sólidos e trigonometria', '📐', 5)
  returning id into v_geometria;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index) values
    ('matematica', null, 'Sequências e progressões', 'Progressão aritmética e geométrica', '🔢', 6),
    ('matematica', null, 'Probabilidade', 'Espaço amostral, eventos e probabilidade condicional', '🎲', 7),
    ('matematica', null, 'Análise combinatória', 'Permutação, arranjo e combinação', '🧮', 8),
    ('matematica', null, 'Estatística', 'Gráficos, média, mediana, moda e desvio padrão', '📊', 9),
    ('matematica', null, 'Matemática financeira', 'Juros, descontos e porcentagens', '💰', 10),
    ('matematica', null, 'Conjuntos', 'Pertinência, união, interseção e diagramas de Venn', '🧩', 11),
    ('matematica', null, 'Raciocínio lógico', 'Sequências, proposições e problemas de lógica', '🧠', 12),
    ('matematica', null, 'Conteúdos avançados', 'Matrizes, determinantes e números complexos', '🎓', 13);

  -- Geometria > subáreas (nível 2)
  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('matematica', v_geometria, 'Geometria plana', '📐', 1),
    ('matematica', v_geometria, 'Geometria espacial', '🧊', 2),
    ('matematica', v_geometria, 'Geometria analítica', '📍', 3),
    ('matematica', v_geometria, 'Trigonometria', '📐', 4);

  -- Fundamentos > temas (nível 2) — só a ramificação de Divisibilidade vai
  -- até atividade real, o resto fica como prova de estrutura por enquanto.
  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('matematica', v_fundamentos, 'Números (naturais, inteiros, racionais, irracionais, reais)', '🔢', 1),
    ('matematica', v_fundamentos, 'Operações básicas e ordem das operações', '➕', 2),
    ('matematica', v_fundamentos, 'Frações', '➗', 3),
    ('matematica', v_fundamentos, 'Números decimais', '🔢', 4),
    ('matematica', v_fundamentos, 'Potenciação e radiciação', '🔢', 5);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('matematica', v_fundamentos, 'Divisibilidade', '🔢', 6)
  returning id into v_divisibilidade;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('matematica', v_divisibilidade, 'Critérios de divisibilidade', '🔢', 1),
    ('matematica', v_divisibilidade, 'Números primos', '🔢', 2),
    ('matematica', v_divisibilidade, 'Fatoração', '🔢', 3),
    ('matematica', v_divisibilidade, 'MMC e MDC', '🔢', 4);

  -- Álgebra > temas (nível 2)
  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('matematica', v_algebra, 'Expressões algébricas', '✖️', 1),
    ('matematica', v_algebra, 'Produtos notáveis', '✖️', 2),
    ('matematica', v_algebra, 'Fatoração', '✖️', 3);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('matematica', v_algebra, 'Equações', '✖️', 4)
  returning id into v_equacoes;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('matematica', v_algebra, 'Sistemas de equações', '✖️', 5),
    ('matematica', v_algebra, 'Inequações', '✖️', 6),
    ('matematica', v_algebra, 'Polinômios', '✖️', 7);

  -- Álgebra > Equações > atividades (nível 3, folhas)
  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('matematica', v_equacoes, 'Equação do 1º grau', '✖️', 1),
    ('matematica', v_equacoes, 'Equação do 2º grau', '✖️', 2),
    ('matematica', v_equacoes, 'Equações fracionárias', '✖️', 3),
    ('matematica', v_equacoes, 'Equações irracionais', '✖️', 4),
    ('matematica', v_equacoes, 'Equações exponenciais', '✖️', 5);
end $$;
