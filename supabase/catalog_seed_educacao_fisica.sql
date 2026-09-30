-- Catalog of the new subject "educacao_fisica": 8 areas, 20 topics,
-- each with its en/es translation. Idempotent (uuid5 ids).
-- Areas first (a topic references its area), in one statement: a VALUES
-- list is inserted in order, and the parent always comes before its child.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
select v.id::uuid, 'educacao_fisica', v.parent::uuid, v.title, v.description, v.icon, v.ord
from (values
  ('483d9ae4-c2d7-50c0-a8a2-58da1eb6620b', null, 'Esportes coletivos', 'Futebol, voleibol, basquetebol e a lógica dos jogos de equipe', '⚽', 0),
  ('e5e2d32f-81bf-5c55-9f26-2544439c9328', '483d9ae4-c2d7-50c0-a8a2-58da1eb6620b', 'Futebol e futsal', null, '⚽', 0),
  ('56b18e30-7553-5533-a586-0126cae0fa3a', '483d9ae4-c2d7-50c0-a8a2-58da1eb6620b', 'Voleibol', null, '⚽', 1),
  ('513e1850-b4eb-55c4-a81d-026f8d56be6b', '483d9ae4-c2d7-50c0-a8a2-58da1eb6620b', 'Basquetebol e handebol', null, '⚽', 2),
  ('6e32ed0e-9289-59d2-8518-8bf6e22aebb5', null, 'Esportes individuais', 'Atletismo, natação e ginástica: desempenho e técnica', '🏃', 1),
  ('6bbca0cd-1ecd-5415-ab11-bf0c4160f272', '6e32ed0e-9289-59d2-8518-8bf6e22aebb5', 'Atletismo', null, '🏃', 0),
  ('d082e092-89d7-5436-b0fc-b90d9c512ead', '6e32ed0e-9289-59d2-8518-8bf6e22aebb5', 'Natação e esportes aquáticos', null, '🏃', 1),
  ('8bc5ea64-12b9-5227-a543-cbe81d030050', '6e32ed0e-9289-59d2-8518-8bf6e22aebb5', 'Ginástica', null, '🏃', 2),
  ('173ccd22-b118-5bbd-8901-f6529a4a4f16', null, 'Corpo, movimento e saúde', 'Capacidades físicas, sistemas do corpo e vida ativa', '❤️', 2),
  ('585e92a3-ca7d-5d22-8f77-221de40033eb', '173ccd22-b118-5bbd-8901-f6529a4a4f16', 'Capacidades físicas', null, '❤️', 0),
  ('de64f0c8-9c09-5216-a98f-a233bf02f5a4', '173ccd22-b118-5bbd-8901-f6529a4a4f16', 'Sistema cardiorrespiratório e exercício', null, '❤️', 1),
  ('2bd28a7c-96e5-5449-a63d-2df7368e4940', '173ccd22-b118-5bbd-8901-f6529a4a4f16', 'Alimentação, hidratação e atividade física', null, '❤️', 2),
  ('9cf4e215-da5c-55f7-bdb4-3817dc87e1b8', null, 'Lutas e artes marciais', 'Da capoeira às lutas de origem oriental', '🥋', 3),
  ('51599c64-3e9e-5d31-8c50-90af2cecf480', '9cf4e215-da5c-55f7-bdb4-3817dc87e1b8', 'Capoeira e lutas brasileiras', null, '🥋', 0),
  ('68775cef-c907-5080-9566-6958e76f653c', '9cf4e215-da5c-55f7-bdb4-3817dc87e1b8', 'Lutas de origem oriental', null, '🥋', 1),
  ('e73d915e-ec79-5e58-9f83-26b00b0189d9', null, 'Danças e atividades rítmicas', 'Danças brasileiras, urbanas e a expressão pelo movimento', '💃', 4),
  ('bbcfb4e7-19b4-52a8-aa4a-a1a6ec320e6e', 'e73d915e-ec79-5e58-9f83-26b00b0189d9', 'Danças brasileiras', null, '💃', 0),
  ('6870efdc-6ddd-5702-b5b4-e2091f894328', 'e73d915e-ec79-5e58-9f83-26b00b0189d9', 'Danças urbanas e contemporâneas', null, '💃', 1),
  ('03425a5f-f35b-585d-bccc-caae995b37c3', null, 'Jogos e brincadeiras populares', 'O jogo como patrimônio cultural', '🎲', 5),
  ('7a36d2c6-0e67-5445-94fe-e68e326a39bf', '03425a5f-f35b-585d-bccc-caae995b37c3', 'Jogos e brincadeiras do Brasil', null, '🎲', 0),
  ('8649a340-3c41-5d35-8d2f-16a505356e5c', '03425a5f-f35b-585d-bccc-caae995b37c3', 'Jogos indígenas e de matriz africana', null, '🎲', 1),
  ('ccd98201-d65f-5dc4-b29d-1342ecdfe3fb', null, 'Esporte, sociedade e mídia', 'Megaeventos, mídia esportiva e inclusão', '📺', 6),
  ('7793361e-68c2-5a99-a3d6-e1beedfb2f06', 'ccd98201-d65f-5dc4-b29d-1342ecdfe3fb', 'Esporte e mídia', null, '📺', 0),
  ('7a596603-b642-55ab-b82c-5eaaae062314', 'ccd98201-d65f-5dc4-b29d-1342ecdfe3fb', 'Megaeventos esportivos', null, '📺', 1),
  ('04613235-1c91-5a85-a1bd-b2d1da81184b', 'ccd98201-d65f-5dc4-b29d-1342ecdfe3fb', 'Esporte paralímpico e inclusão', null, '📺', 2),
  ('4cd96964-f8e3-523e-acb8-8e87da50117b', null, 'Educação Física, lazer e políticas', 'História da área, lazer e direito ao esporte', '🏛️', 7),
  ('84c6ad0f-4967-5205-8b3b-73bf0c4f9f96', '4cd96964-f8e3-523e-acb8-8e87da50117b', 'História da Educação Física no Brasil', null, '🏛️', 0),
  ('e3adc2ef-634f-59c6-9e71-ec8dd3a34517', '4cd96964-f8e3-523e-acb8-8e87da50117b', 'Lazer, políticas públicas e direito ao esporte', null, '🏛️', 1)
) as v(id, parent, title, description, icon, ord)
order by v.parent nulls first
on conflict (id) do nothing;

insert into catalog_node_translations (catalog_node_id, locale, title, description)
select v.id::uuid, v.locale, v.title, v.description
from (values
  ('483d9ae4-c2d7-50c0-a8a2-58da1eb6620b', 'en', 'Team sports', 'Football, volleyball, basketball and the logic of team games'),
  ('483d9ae4-c2d7-50c0-a8a2-58da1eb6620b', 'es', 'Deportes colectivos', 'Fútbol, voleibol, baloncesto y la lógica de los juegos de equipo'),
  ('e5e2d32f-81bf-5c55-9f26-2544439c9328', 'en', 'Football and futsal', null),
  ('e5e2d32f-81bf-5c55-9f26-2544439c9328', 'es', 'Fútbol y futsal', null),
  ('56b18e30-7553-5533-a586-0126cae0fa3a', 'en', 'Volleyball', null),
  ('56b18e30-7553-5533-a586-0126cae0fa3a', 'es', 'Voleibol', null),
  ('513e1850-b4eb-55c4-a81d-026f8d56be6b', 'en', 'Basketball and handball', null),
  ('513e1850-b4eb-55c4-a81d-026f8d56be6b', 'es', 'Baloncesto y balonmano', null),
  ('6e32ed0e-9289-59d2-8518-8bf6e22aebb5', 'en', 'Individual sports', 'Athletics, swimming and gymnastics: performance and technique'),
  ('6e32ed0e-9289-59d2-8518-8bf6e22aebb5', 'es', 'Deportes individuales', 'Atletismo, natación y gimnasia: rendimiento y técnica'),
  ('6bbca0cd-1ecd-5415-ab11-bf0c4160f272', 'en', 'Athletics', null),
  ('6bbca0cd-1ecd-5415-ab11-bf0c4160f272', 'es', 'Atletismo', null),
  ('d082e092-89d7-5436-b0fc-b90d9c512ead', 'en', 'Swimming and water sports', null),
  ('d082e092-89d7-5436-b0fc-b90d9c512ead', 'es', 'Natación y deportes acuáticos', null),
  ('8bc5ea64-12b9-5227-a543-cbe81d030050', 'en', 'Gymnastics', null),
  ('8bc5ea64-12b9-5227-a543-cbe81d030050', 'es', 'Gimnasia', null),
  ('173ccd22-b118-5bbd-8901-f6529a4a4f16', 'en', 'Body, movement and health', 'Physical capacities, body systems and active living'),
  ('173ccd22-b118-5bbd-8901-f6529a4a4f16', 'es', 'Cuerpo, movimiento y salud', 'Capacidades físicas, sistemas del cuerpo y vida activa'),
  ('585e92a3-ca7d-5d22-8f77-221de40033eb', 'en', 'Physical capacities', null),
  ('585e92a3-ca7d-5d22-8f77-221de40033eb', 'es', 'Capacidades físicas', null),
  ('de64f0c8-9c09-5216-a98f-a233bf02f5a4', 'en', 'Cardiorespiratory system and exercise', null),
  ('de64f0c8-9c09-5216-a98f-a233bf02f5a4', 'es', 'Sistema cardiorrespiratorio y ejercicio', null),
  ('2bd28a7c-96e5-5449-a63d-2df7368e4940', 'en', 'Nutrition, hydration and physical activity', null),
  ('2bd28a7c-96e5-5449-a63d-2df7368e4940', 'es', 'Alimentación, hidratación y actividad física', null),
  ('9cf4e215-da5c-55f7-bdb4-3817dc87e1b8', 'en', 'Fighting and martial arts', 'From capoeira to martial arts of Eastern origin'),
  ('9cf4e215-da5c-55f7-bdb4-3817dc87e1b8', 'es', 'Luchas y artes marciales', 'De la capoeira a las luchas de origen oriental'),
  ('51599c64-3e9e-5d31-8c50-90af2cecf480', 'en', 'Capoeira and Brazilian fighting styles', null),
  ('51599c64-3e9e-5d31-8c50-90af2cecf480', 'es', 'Capoeira y luchas brasileñas', null),
  ('68775cef-c907-5080-9566-6958e76f653c', 'en', 'Martial arts of Eastern origin', null),
  ('68775cef-c907-5080-9566-6958e76f653c', 'es', 'Luchas de origen oriental', null),
  ('e73d915e-ec79-5e58-9f83-26b00b0189d9', 'en', 'Dance and rhythmic activities', 'Brazilian dances, urban dances and expression through movement'),
  ('e73d915e-ec79-5e58-9f83-26b00b0189d9', 'es', 'Danzas y actividades rítmicas', 'Danzas brasileñas, urbanas y la expresión por el movimiento'),
  ('bbcfb4e7-19b4-52a8-aa4a-a1a6ec320e6e', 'en', 'Brazilian dances', null),
  ('bbcfb4e7-19b4-52a8-aa4a-a1a6ec320e6e', 'es', 'Danzas brasileñas', null),
  ('6870efdc-6ddd-5702-b5b4-e2091f894328', 'en', 'Urban and contemporary dance', null),
  ('6870efdc-6ddd-5702-b5b4-e2091f894328', 'es', 'Danzas urbanas y contemporáneas', null),
  ('03425a5f-f35b-585d-bccc-caae995b37c3', 'en', 'Games and traditional play', 'Play as cultural heritage'),
  ('03425a5f-f35b-585d-bccc-caae995b37c3', 'es', 'Juegos y juegos tradicionales', 'El juego como patrimonio cultural'),
  ('7a36d2c6-0e67-5445-94fe-e68e326a39bf', 'en', 'Brazilian games and traditional play', null),
  ('7a36d2c6-0e67-5445-94fe-e68e326a39bf', 'es', 'Juegos y juegos tradicionales de Brasil', null),
  ('8649a340-3c41-5d35-8d2f-16a505356e5c', 'en', 'Indigenous and African-rooted games', null),
  ('8649a340-3c41-5d35-8d2f-16a505356e5c', 'es', 'Juegos indígenas y de matriz africana', null),
  ('ccd98201-d65f-5dc4-b29d-1342ecdfe3fb', 'en', 'Sport, society and media', 'Mega-events, sports media and inclusion'),
  ('ccd98201-d65f-5dc4-b29d-1342ecdfe3fb', 'es', 'Deporte, sociedad y medios', 'Megaeventos, medios deportivos e inclusión'),
  ('7793361e-68c2-5a99-a3d6-e1beedfb2f06', 'en', 'Sport and media', null),
  ('7793361e-68c2-5a99-a3d6-e1beedfb2f06', 'es', 'Deporte y medios', null),
  ('7a596603-b642-55ab-b82c-5eaaae062314', 'en', 'Sporting mega-events', null),
  ('7a596603-b642-55ab-b82c-5eaaae062314', 'es', 'Megaeventos deportivos', null),
  ('04613235-1c91-5a85-a1bd-b2d1da81184b', 'en', 'Paralympic sport and inclusion', null),
  ('04613235-1c91-5a85-a1bd-b2d1da81184b', 'es', 'Deporte paralímpico e inclusión', null),
  ('4cd96964-f8e3-523e-acb8-8e87da50117b', 'en', 'Physical Education, leisure and policy', 'History of the field, leisure and the right to sport'),
  ('4cd96964-f8e3-523e-acb8-8e87da50117b', 'es', 'Educación Física, ocio y políticas', 'Historia del área, ocio y derecho al deporte'),
  ('84c6ad0f-4967-5205-8b3b-73bf0c4f9f96', 'en', 'History of Physical Education in Brazil', null),
  ('84c6ad0f-4967-5205-8b3b-73bf0c4f9f96', 'es', 'Historia de la Educación Física en Brasil', null),
  ('e3adc2ef-634f-59c6-9e71-ec8dd3a34517', 'en', 'Leisure, public policy and the right to sport', null),
  ('e3adc2ef-634f-59c6-9e71-ec8dd3a34517', 'es', 'Ocio, políticas públicas y derecho al deporte', null)
) as v(id, locale, title, description)
join catalog_nodes c on c.id = v.id::uuid
on conflict (catalog_node_id, locale) do update
  set title = excluded.title, description = excluded.description;
