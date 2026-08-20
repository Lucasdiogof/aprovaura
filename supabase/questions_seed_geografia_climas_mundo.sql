-- New leaf under Geografia > Mundo: climate zones are latitude bands, not
-- discrete map-clickable regions, so this is multiple-choice questions
-- instead -- see project_aura_atlas_pdf_content_pipeline memory.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
values (
  'f85b69d0-019a-487c-8e82-dc5d99bbfdec',
  'geografia',
  (select id from catalog_nodes where subject = 'geografia' and parent_id is null and title = 'Mundo'),
  'Climas do mundo',
  'Zonas climáticas, correntes marítimas e formação dos desertos',
  '🌦️',
  19
);

insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('f85b69d0-019a-487c-8e82-dc5d99bbfdec', 'Partindo da linha do Equador em direção aos polos, qual é a sequência correta das zonas climáticas?',
  array['Polar, Temperado, Tropical, Equatorial', 'Tropical, Equatorial, Temperado, Subpolar', 'Equatorial, Tropical, Subtropical, Temperado, Subpolar, Polar', 'Subtropical, Equatorial, Polar, Temperado'], 2,
  'A partir do Equador, o clima esfria progressivamente até os polos, passando por essas seis faixas.', 1),
('f85b69d0-019a-487c-8e82-dc5d99bbfdec', 'O que caracteriza principalmente um clima desértico?',
  array['Amplitude térmica sempre pequena', 'Temperaturas sempre baixas', 'Ausência quase total de umidade', 'Chuvas constantes e regulares'], 2,
  'Desertos se definem pela escassez extrema de chuva, e não necessariamente pela temperatura.', 2),
('f85b69d0-019a-487c-8e82-dc5d99bbfdec', 'A presença de uma corrente marítima fria na costa oeste de um continente costuma favorecer a formação de qual tipo de clima na região costeira?',
  array['Equatorial úmido', 'Tropical úmido', 'Subpolar', 'Desértico'], 3,
  'Correntes frias, como a de Humboldt e a da Califórnia, resfriam o ar e dificultam a formação de chuva, favorecendo desertos costeiros.', 3),
('f85b69d0-019a-487c-8e82-dc5d99bbfdec', 'Uma corrente marítima quente, como a do Golfo, costuma ter qual efeito sobre o clima das regiões costeiras próximas?',
  array['Aumenta a umidade e ameniza a temperatura', 'Torna o clima mais seco e frio', 'Não influencia o clima local', 'Provoca formação de desertos'], 0,
  'Correntes quentes aquecem e umedecem o ar, tornando o clima costeiro mais úmido e ameno.', 4),
('f85b69d0-019a-487c-8e82-dc5d99bbfdec', 'Por que a temperatura tende a cair mesmo em regiões de baixa latitude quando a altitude aumenta muito, como no topo de uma montanha?',
  array['Porque montanhas altas ficam sempre nos polos', 'Porque o ar fica mais úmido com a altitude', 'Porque a altitude não afeta a temperatura', 'Porque a temperatura cai em média cerca de 6°C a cada 1.000 metros de altitude'], 3,
  'É o chamado clima de montanha: a temperatura cai com a altitude, independentemente da latitude.', 5);
