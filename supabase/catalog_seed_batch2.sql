-- Partial content seed for História, Português, Biologia, Física e Química,
-- following the same discipline as catalog_seed.sql (Geografia/Matemática):
-- full top-level list per subject, then 1-2 branches fleshed out to real
-- leaf activities to prove the recursive catalog at variable depth. Every
-- other subject/theme stays at whatever level was seeded, no deeper.
--
-- Run catalog_schema.sql first (only once — already done if you ran
-- catalog_seed.sql before). Safe to re-run: wipes and reinserts these 5
-- subjects' rows each time. Does not touch geografia/matematica rows.

delete from catalog_nodes
where subject in ('historia', 'portugues', 'biologia', 'fisica', 'quimica');

-- ===================== HISTÓRIA =====================
do $$
declare
  v_brasil uuid;
  v_era_vargas uuid;
  v_estado_novo uuid;
begin
  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('historia', null, 'História do Brasil', 'Colônia, Império, República e Brasil contemporâneo', '🇧🇷', 1)
  returning id into v_brasil;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index) values
    ('historia', null, 'Antiguidade', 'Egito, Grécia, Roma e civilizações antigas', '🏺', 2),
    ('historia', null, 'Idade Média', 'Feudalismo, Igreja, Cruzadas e transformações medievais', '🏰', 3),
    ('historia', null, 'Idade Moderna', 'Renascimento, absolutismo, reformas e expansão marítima', '👑', 4),
    ('historia', null, 'Idade Contemporânea', 'Revoluções, guerras, imperialismo e mundo atual', '🏭', 5),
    ('historia', null, 'História da América', 'Povos originários, colonização e independências', '🌎', 6),
    ('historia', null, 'História da África', 'Civilizações africanas, colonialismo e independências', '🌍', 7),
    ('historia', null, 'Grandes temas históricos', 'Escravidão, democracia, revoluções e direitos humanos', '🧠', 8);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('historia', v_brasil, 'Povos indígenas', '🏹', 1),
    ('historia', v_brasil, 'Brasil Colonial', '🧭', 2),
    ('historia', v_brasil, 'Independência do Brasil', '📜', 3),
    ('historia', v_brasil, 'Brasil Império', '👑', 4),
    ('historia', v_brasil, 'República Velha', '🏛️', 5);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('historia', v_brasil, 'Era Vargas', '🎖️', 6)
  returning id into v_era_vargas;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('historia', v_brasil, 'República de 1946', '🏛️', 7),
    ('historia', v_brasil, 'Ditadura Militar', '🪖', 8),
    ('historia', v_brasil, 'Nova República', '🗳️', 9);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('historia', v_era_vargas, 'Revolução de 1930', '⚔️', 1),
    ('historia', v_era_vargas, 'Governo Provisório (1930–1934)', '📋', 2),
    ('historia', v_era_vargas, 'Governo Constitucional (1934–1937)', '📋', 3);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('historia', v_era_vargas, 'Estado Novo (1937–1945)', '🎖️', 4)
  returning id into v_estado_novo;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('historia', v_estado_novo, 'Constituição de 1937', '📜', 1),
    ('historia', v_estado_novo, 'Trabalhismo', '👷', 2),
    ('historia', v_estado_novo, 'DIP — Departamento de Imprensa e Propaganda', '📢', 3),
    ('historia', v_estado_novo, 'Intentona Comunista', '⚔️', 4),
    ('historia', v_estado_novo, 'Integralismo', '⚔️', 5),
    ('historia', v_estado_novo, 'Brasil na Segunda Guerra Mundial', '🪖', 6),
    ('historia', v_estado_novo, 'Fim do Estado Novo', '🏁', 7);
end $$;

-- ===================== PORTUGUÊS =====================
do $$
declare
  v_interpretacao uuid;
  v_concordancia_regencia uuid;
  v_crase uuid;
begin
  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('portugues', null, 'Interpretação de texto', 'Compreensão, inferência e análise textual', '📖', 1)
  returning id into v_interpretacao;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index) values
    ('portugues', null, 'Gramática', 'Classes de palavras, formação e estrutura', '🔤', 2),
    ('portugues', null, 'Sintaxe', 'Orações, períodos e relações sintáticas', '🧩', 3),
    ('portugues', null, 'Ortografia e acentuação', 'Escrita, acentos e regras ortográficas', '✍️', 4);

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('portugues', null, 'Concordância e regência', 'Concordância, regência e crase', '🔗', 5)
  returning id into v_concordancia_regencia;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index) values
    ('portugues', null, 'Semântica', 'Sentidos, figuras de linguagem e ambiguidades', '💬', 6),
    ('portugues', null, 'Redação', 'Estrutura, argumentação e coesão', '📝', 7),
    ('portugues', null, 'Literatura', 'Escolas literárias, autores e obras', '📚', 8);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('portugues', v_interpretacao, 'Compreensão textual', '📖', 1),
    ('portugues', v_interpretacao, 'Tema e assunto', '📖', 2),
    ('portugues', v_interpretacao, 'Ideia principal', '📖', 3),
    ('portugues', v_interpretacao, 'Informações explícitas', '📖', 4),
    ('portugues', v_interpretacao, 'Informações implícitas', '📖', 5),
    ('portugues', v_interpretacao, 'Inferência', '📖', 6),
    ('portugues', v_interpretacao, 'Intenção do autor', '📖', 7),
    ('portugues', v_interpretacao, 'Argumentação', '📖', 8),
    ('portugues', v_interpretacao, 'Fato × opinião', '📖', 9),
    ('portugues', v_interpretacao, 'Coesão e coerência textual', '📖', 10);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('portugues', v_concordancia_regencia, 'Concordância verbal', '🔗', 1),
    ('portugues', v_concordancia_regencia, 'Concordância nominal', '🔗', 2),
    ('portugues', v_concordancia_regencia, 'Regência verbal', '🔗', 3),
    ('portugues', v_concordancia_regencia, 'Regência nominal', '🔗', 4);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('portugues', v_concordancia_regencia, 'Crase', 'à', 5)
  returning id into v_crase;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('portugues', v_crase, 'Casos obrigatórios', 'à', 1),
    ('portugues', v_crase, 'Casos proibidos', 'à', 2),
    ('portugues', v_crase, 'Casos facultativos', 'à', 3),
    ('portugues', v_crase, 'Locuções', 'à', 4);
end $$;

-- ===================== BIOLOGIA =====================
do $$
declare
  v_citologia uuid;
  v_membrana uuid;
  v_organelas uuid;
  v_genetica uuid;
  v_genetica_conceitos uuid;
  v_genetica_leis uuid;
  v_ecologia uuid;
  v_ecologia_cadeias uuid;
  v_ecologia_relacoes uuid;
  v_ecologia_impactos uuid;
  v_corpo_humano uuid;
  v_cardiovascular uuid;
  v_nervoso uuid;
begin
  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('biologia', null, 'Citologia', 'Células, organelas, membranas e divisão celular', '🔬', 1)
  returning id into v_citologia;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('biologia', null, 'Genética e Biotecnologia', 'DNA, hereditariedade, Mendel e engenharia genética', '🧬', 2)
  returning id into v_genetica;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('biologia', null, 'Ecologia', 'Ecossistemas, cadeias alimentares e ciclos naturais', '🌱', 3)
  returning id into v_ecologia;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('biologia', null, 'Corpo Humano e Fisiologia', 'Sistemas, órgãos e funcionamento do organismo', '🫀', 4)
  returning id into v_corpo_humano;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index) values
    ('biologia', null, 'Botânica', 'Tecidos, órgãos, reprodução e fisiologia vegetal', '🌿', 5),
    ('biologia', null, 'Zoologia', 'Invertebrados, vertebrados e evolução animal', '🐾', 6),
    ('biologia', null, 'Microbiologia e Saúde', 'Vírus, bactérias, protozoários, fungos e doenças', '🦠', 7),
    ('biologia', null, 'Evolução', 'Seleção natural, especiação e origem da vida', '🌎', 8);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('biologia', v_citologia, 'Membrana plasmática', '🧫', 1)
  returning id into v_membrana;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('biologia', v_citologia, 'Organelas', '🔬', 2)
  returning id into v_organelas;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_citologia, 'Ciclo celular, mitose e meiose', '🔬', 3);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_membrana, 'Difusão', '🧫', 1),
    ('biologia', v_membrana, 'Osmose', '🧫', 2),
    ('biologia', v_membrana, 'Transporte ativo', '🧫', 3),
    ('biologia', v_membrana, 'Endocitose', '🧫', 4),
    ('biologia', v_membrana, 'Exocitose', '🧫', 5);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_organelas, 'Núcleo', '🔬', 1),
    ('biologia', v_organelas, 'Ribossomos', '🔬', 2),
    ('biologia', v_organelas, 'Mitocôndrias', '🔬', 3),
    ('biologia', v_organelas, 'Lisossomos', '🔬', 4),
    ('biologia', v_organelas, 'Complexo golgiense', '🔬', 5),
    ('biologia', v_organelas, 'Retículo endoplasmático', '🔬', 6),
    ('biologia', v_organelas, 'Centríolos', '🔬', 7),
    ('biologia', v_organelas, 'Cloroplastos', '🔬', 8);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('biologia', v_genetica, 'Conceitos fundamentais', '🧬', 1)
  returning id into v_genetica_conceitos;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('biologia', v_genetica, 'Leis de Mendel e padrões de herança', '🧬', 2)
  returning id into v_genetica_leis;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_genetica_conceitos, 'Gene', '🧬', 1),
    ('biologia', v_genetica_conceitos, 'Alelo', '🧬', 2),
    ('biologia', v_genetica_conceitos, 'Genótipo', '🧬', 3),
    ('biologia', v_genetica_conceitos, 'Fenótipo', '🧬', 4),
    ('biologia', v_genetica_conceitos, 'Homozigoto', '🧬', 5),
    ('biologia', v_genetica_conceitos, 'Heterozigoto', '🧬', 6);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_genetica_leis, 'Primeira Lei de Mendel', '🧬', 1),
    ('biologia', v_genetica_leis, 'Segunda Lei de Mendel', '🧬', 2),
    ('biologia', v_genetica_leis, 'Dominância completa', '🧬', 3),
    ('biologia', v_genetica_leis, 'Dominância incompleta', '🧬', 4),
    ('biologia', v_genetica_leis, 'Codominância', '🧬', 5),
    ('biologia', v_genetica_leis, 'Herança ligada ao sexo', '🧬', 6),
    ('biologia', v_genetica_leis, 'Heredogramas', '🧬', 7);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('biologia', v_ecologia, 'Cadeias e teias alimentares', '🌱', 1)
  returning id into v_ecologia_cadeias;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('biologia', v_ecologia, 'Relações ecológicas', '🤝', 2)
  returning id into v_ecologia_relacoes;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('biologia', v_ecologia, 'Impactos ambientais', '🌍', 3)
  returning id into v_ecologia_impactos;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_ecologia_cadeias, 'Cadeias alimentares', '🌱', 1),
    ('biologia', v_ecologia_cadeias, 'Teias alimentares', '🌱', 2),
    ('biologia', v_ecologia_cadeias, 'Níveis tróficos', '🌱', 3),
    ('biologia', v_ecologia_cadeias, 'Pirâmides ecológicas', '🌱', 4);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_ecologia_relacoes, 'Mutualismo', '🤝', 1),
    ('biologia', v_ecologia_relacoes, 'Protocooperação', '🤝', 2),
    ('biologia', v_ecologia_relacoes, 'Comensalismo', '🤝', 3),
    ('biologia', v_ecologia_relacoes, 'Predatismo', '🤝', 4),
    ('biologia', v_ecologia_relacoes, 'Parasitismo', '🤝', 5),
    ('biologia', v_ecologia_relacoes, 'Competição', '🤝', 6),
    ('biologia', v_ecologia_relacoes, 'Amensalismo', '🤝', 7);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_ecologia_impactos, 'Aquecimento global', '🌍', 1),
    ('biologia', v_ecologia_impactos, 'Desmatamento', '🌍', 2),
    ('biologia', v_ecologia_impactos, 'Poluição', '🌍', 3),
    ('biologia', v_ecologia_impactos, 'Chuva ácida', '🌍', 4),
    ('biologia', v_ecologia_impactos, 'Espécies invasoras', '🌍', 5);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('biologia', v_corpo_humano, 'Sistema cardiovascular', '❤️', 1)
  returning id into v_cardiovascular;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('biologia', v_corpo_humano, 'Sistema nervoso', '🧠', 2)
  returning id into v_nervoso;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_corpo_humano, 'Sistema digestório', '🍽️', 3),
    ('biologia', v_corpo_humano, 'Sistema endócrino', '🧪', 4),
    ('biologia', v_corpo_humano, 'Sistema imunológico', '🛡️', 5);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_cardiovascular, 'Coração', '❤️', 1),
    ('biologia', v_cardiovascular, 'Válvulas', '❤️', 2),
    ('biologia', v_cardiovascular, 'Artérias', '❤️', 3),
    ('biologia', v_cardiovascular, 'Veias', '❤️', 4),
    ('biologia', v_cardiovascular, 'Capilares', '❤️', 5),
    ('biologia', v_cardiovascular, 'Circulação pulmonar', '❤️', 6),
    ('biologia', v_cardiovascular, 'Circulação sistêmica', '❤️', 7);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('biologia', v_nervoso, 'Neurônio', '🧠', 1),
    ('biologia', v_nervoso, 'Sistema nervoso central', '🧠', 2),
    ('biologia', v_nervoso, 'Sistema nervoso periférico', '🧠', 3),
    ('biologia', v_nervoso, 'Sinapses', '🧠', 4),
    ('biologia', v_nervoso, 'Arco reflexo', '🧠', 5);
end $$;

-- ===================== FÍSICA =====================
do $$
declare
  v_mecanica uuid;
  v_cinematica uuid;
  v_dinamica uuid;
  v_optica uuid;
  v_espelhos uuid;
  v_lentes uuid;
begin
  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('fisica', null, 'Mecânica', 'Movimento, forças, energia e gravitação', '🏎️', 1)
  returning id into v_mecanica;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index) values
    ('fisica', null, 'Termologia e Termodinâmica', 'Temperatura, calor, gases e máquinas térmicas', '🌡️', 2),
    ('fisica', null, 'Ondulatória', 'Ondas, som, frequência e fenômenos ondulatórios', '🌊', 3);

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('fisica', null, 'Óptica', 'Espelhos, lentes, reflexão e refração', '🔭', 4)
  returning id into v_optica;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index) values
    ('fisica', null, 'Eletricidade', 'Cargas, circuitos, corrente e potência', '⚡', 5),
    ('fisica', null, 'Magnetismo e Eletromagnetismo', 'Campos magnéticos, indução e ondas eletromagnéticas', '🧲', 6),
    ('fisica', null, 'Fluidos', 'Pressão, hidrostática e empuxo', '💧', 7),
    ('fisica', null, 'Física Moderna', 'Relatividade, quântica, radioatividade e física nuclear', '⚛️', 8);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('fisica', v_mecanica, 'Cinemática', '🏃', 1)
  returning id into v_cinematica;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('fisica', v_mecanica, 'Dinâmica', '🧱', 2)
  returning id into v_dinamica;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('fisica', v_mecanica, 'Trabalho e energia', '🔋', 3),
    ('fisica', v_mecanica, 'Gravitação', '🌍', 4);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('fisica', v_cinematica, 'Movimento uniforme', '🏃', 1),
    ('fisica', v_cinematica, 'Aceleração', '🏃', 2),
    ('fisica', v_cinematica, 'Movimento uniformemente variado', '🏃', 3),
    ('fisica', v_cinematica, 'Queda livre', '🏃', 4),
    ('fisica', v_cinematica, 'Lançamento horizontal', '🏃', 5),
    ('fisica', v_cinematica, 'Lançamento oblíquo', '🏃', 6);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('fisica', v_dinamica, 'Primeira Lei de Newton', '🧱', 1),
    ('fisica', v_dinamica, 'Segunda Lei de Newton', '🧱', 2),
    ('fisica', v_dinamica, 'Terceira Lei de Newton', '🧱', 3),
    ('fisica', v_dinamica, 'Força peso', '🧱', 4),
    ('fisica', v_dinamica, 'Força normal', '🧱', 5),
    ('fisica', v_dinamica, 'Atrito', '🧱', 6),
    ('fisica', v_dinamica, 'Plano inclinado', '🧱', 7);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('fisica', v_optica, 'Espelhos esféricos', '🪞', 1)
  returning id into v_espelhos;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('fisica', v_optica, 'Lentes', '👓', 2)
  returning id into v_lentes;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('fisica', v_espelhos, 'Espelho côncavo', '🪞', 1),
    ('fisica', v_espelhos, 'Espelho convexo', '🪞', 2),
    ('fisica', v_espelhos, 'Foco e centro de curvatura', '🪞', 3),
    ('fisica', v_espelhos, 'Raios notáveis', '🪞', 4),
    ('fisica', v_espelhos, 'Formação de imagens', '🪞', 5);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('fisica', v_lentes, 'Lentes convergentes', '👓', 1),
    ('fisica', v_lentes, 'Lentes divergentes', '👓', 2),
    ('fisica', v_lentes, 'Miopia', '👓', 3),
    ('fisica', v_lentes, 'Hipermetropia', '👓', 4),
    ('fisica', v_lentes, 'Presbiopia', '👓', 5);
end $$;

-- ===================== QUÍMICA =====================
do $$
declare
  v_fundamentos uuid;
  v_estrutura_atomica uuid;
  v_modelos_atomicos uuid;
  v_tabela_periodica uuid;
  v_organica uuid;
  v_funcoes_organicas uuid;
begin
  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('quimica', null, 'Fundamentos da Química', 'Matéria, átomos, elementos e tabela periódica', '⚛️', 1)
  returning id into v_fundamentos;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index) values
    ('quimica', null, 'Ligações e Estrutura', 'Ligações químicas, geometria e forças intermoleculares', '🔗', 2),
    ('quimica', null, 'Estequiometria', 'Mol, massas, reações e cálculos químicos', '🧮', 3),
    ('quimica', null, 'Soluções', 'Concentração, diluição, misturas e solubilidade', '🧪', 4),
    ('quimica', null, 'Físico-Química', 'Termoquímica, cinética, equilíbrio, pH e eletroquímica', '🔥', 5),
    ('quimica', null, 'Química Inorgânica', 'Ácidos, bases, sais, óxidos e reações inorgânicas', '🧱', 6);

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index)
  values ('quimica', null, 'Química Orgânica', 'Carbono, funções orgânicas, reações e isomeria', '🧬', 7)
  returning id into v_organica;

  insert into catalog_nodes (subject, parent_id, title, description, icon, order_index) values
    ('quimica', null, 'Química Ambiental e Cotidiano', 'Poluição, combustíveis, água, materiais e aplicações', '🌱', 8);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('quimica', v_fundamentos, 'Estrutura atômica', '⚛️', 1)
  returning id into v_estrutura_atomica;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('quimica', v_fundamentos, 'Modelos atômicos', '⚛️', 2)
  returning id into v_modelos_atomicos;
  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('quimica', v_fundamentos, 'Tabela periódica', '🧭', 3)
  returning id into v_tabela_periodica;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('quimica', v_estrutura_atomica, 'Prótons', '⚛️', 1),
    ('quimica', v_estrutura_atomica, 'Nêutrons', '⚛️', 2),
    ('quimica', v_estrutura_atomica, 'Elétrons', '⚛️', 3),
    ('quimica', v_estrutura_atomica, 'Íons (cátion e ânion)', '⚛️', 4),
    ('quimica', v_estrutura_atomica, 'Isótopos', '⚛️', 5);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('quimica', v_modelos_atomicos, 'Dalton', '⚛️', 1),
    ('quimica', v_modelos_atomicos, 'Thomson', '⚛️', 2),
    ('quimica', v_modelos_atomicos, 'Rutherford', '⚛️', 3),
    ('quimica', v_modelos_atomicos, 'Bohr', '⚛️', 4);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('quimica', v_tabela_periodica, 'Períodos', '🧭', 1),
    ('quimica', v_tabela_periodica, 'Famílias', '🧭', 2),
    ('quimica', v_tabela_periodica, 'Metais, ametais e semimetais', '🧭', 3),
    ('quimica', v_tabela_periodica, 'Gases nobres', '🧭', 4),
    ('quimica', v_tabela_periodica, 'Metais alcalinos', '🧭', 5),
    ('quimica', v_tabela_periodica, 'Halogênios', '🧭', 6),
    ('quimica', v_tabela_periodica, 'Propriedades periódicas', '🧭', 7);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('quimica', v_organica, 'Cadeias carbônicas', '⛓️', 1);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index)
  values ('quimica', v_organica, 'Funções orgânicas', '🧪', 2)
  returning id into v_funcoes_organicas;

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('quimica', v_organica, 'Nomenclatura', '🏷️', 3),
    ('quimica', v_organica, 'Isomeria', '🪞', 4),
    ('quimica', v_organica, 'Reações orgânicas', '🔥', 5),
    ('quimica', v_organica, 'Polímeros', '🧴', 6);

  insert into catalog_nodes (subject, parent_id, title, icon, order_index) values
    ('quimica', v_funcoes_organicas, 'Hidrocarbonetos', '🧪', 1),
    ('quimica', v_funcoes_organicas, 'Álcool', '🧪', 2),
    ('quimica', v_funcoes_organicas, 'Fenol', '🧪', 3),
    ('quimica', v_funcoes_organicas, 'Éter', '🧪', 4),
    ('quimica', v_funcoes_organicas, 'Aldeído', '🧪', 5),
    ('quimica', v_funcoes_organicas, 'Cetona', '🧪', 6),
    ('quimica', v_funcoes_organicas, 'Ácido carboxílico', '🧪', 7),
    ('quimica', v_funcoes_organicas, 'Éster', '🧪', 8),
    ('quimica', v_funcoes_organicas, 'Amina', '🧪', 9),
    ('quimica', v_funcoes_organicas, 'Amida', '🧪', 10);
end $$;
