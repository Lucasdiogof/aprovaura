-- i18n: en/es translations of the 5 Redação themes (5 x 2 = 10 rows).
-- Only writes essay_theme_translations; essay_themes (the pt-BR original)
-- is never touched, and grading keeps reading the pt-BR theme
-- (see i18n_essay_rpcs.sql).
--
-- The prompt keeps saying the essay must be written in formal Portuguese:
-- that is the exam being practised, and the grader expects Portuguese.
--
-- supporting_texts: every theme's original is [] today, so the translation
-- copies the original value (the column is NOT NULL). If a theme ever gains
-- supporting texts, this row goes stale; i18n_essay_checkup.sql flags it
-- ("supporting_texts length mismatch").
--
-- Idempotent (on conflict do update).

insert into essay_theme_translations (essay_theme_id, locale, title, description, prompt, supporting_texts)
select t.id, v.locale, v.title, v.description, v.prompt, t.supporting_texts
from (values
  ('238beac9-ebba-414d-b488-93daf8260a92', 'en',
   'The limits of privacy in the age of data',
   'How far does the right not to be tracked go?',
   'Based on the motivating texts and on the knowledge you have built throughout your education, write an argumentative essay in formal written Portuguese on the theme "The limits of privacy in the age of data", presenting an intervention proposal that respects human rights.'),
  ('238beac9-ebba-414d-b488-93daf8260a92', 'es',
   'Los límites de la privacidad en la era de los datos',
   'Hasta dónde llega el derecho a no ser rastreado.',
   'A partir de la lectura de los textos motivadores y con base en los conocimientos construidos a lo largo de tu formación, redacta un texto expositivo-argumentativo en registro escrito formal de la lengua portuguesa sobre el tema "Los límites de la privacidad en la era de los datos", presentando una propuesta de intervención que respete los derechos humanos.'),
  ('798cb3e6-7b27-47ba-ba5c-d6553ee80b91', 'en',
   'App-based work and protection for delivery workers',
   'Autonomy was promised; protection never came with it.',
   'Based on the motivating texts and on the knowledge you have built throughout your education, write an argumentative essay in formal written Portuguese on the theme "App-based work and protection for delivery workers", presenting an intervention proposal that respects human rights.'),
  ('798cb3e6-7b27-47ba-ba5c-d6553ee80b91', 'es',
   'El trabajo por aplicación y la protección de quienes hacen entregas',
   'Autonomía prometida, protección que no llegó con ella.',
   'A partir de la lectura de los textos motivadores y con base en los conocimientos construidos a lo largo de tu formación, redacta un texto expositivo-argumentativo en registro escrito formal de la lengua portuguesa sobre el tema "El trabajo por aplicación y la protección de quienes hacen entregas", presentando una propuesta de intervención que respete los derechos humanos.'),
  ('52ef1f96-a28c-4324-9e91-036b5f54dbd2', 'en',
   'Disinformation and the right to know',
   'When the lie spreads faster than the correction.',
   'Based on the motivating texts and on the knowledge you have built throughout your education, write an argumentative essay in formal written Portuguese on the theme "Disinformation and the right to know", presenting an intervention proposal that respects human rights.'),
  ('52ef1f96-a28c-4324-9e91-036b5f54dbd2', 'es',
   'La desinformación y el derecho a saber',
   'Cuando la mentira circula más rápido que la corrección.',
   'A partir de la lectura de los textos motivadores y con base en los conocimientos construidos a lo largo de tu formación, redacta un texto expositivo-argumentativo en registro escrito formal de la lengua portuguesa sobre el tema "La desinformación y el derecho a saber", presentando una propuesta de intervención que respete los derechos humanos.'),
  ('b60308a6-1241-444b-8f33-c36542f2182d', 'en',
   'Students'' mental health in the year of university entrance exams',
   'The pressure that shapes you and the pressure that makes you ill.',
   'Based on the motivating texts and on the knowledge you have built throughout your education, write an argumentative essay in formal written Portuguese on the theme "Students'' mental health in the year of university entrance exams", presenting an intervention proposal that respects human rights.'),
  ('b60308a6-1241-444b-8f33-c36542f2182d', 'es',
   'La salud mental de los estudiantes en el año del examen de ingreso a la universidad',
   'La exigencia que forma y la exigencia que enferma.',
   'A partir de la lectura de los textos motivadores y con base en los conocimientos construidos a lo largo de tu formación, redacta un texto expositivo-argumentativo en registro escrito formal de la lengua portuguesa sobre el tema "La salud mental de los estudiantes en el año del examen de ingreso a la universidad", presentando una propuesta de intervención que respete los derechos humanos.'),
  ('46bf00dd-5131-48f5-94b9-b2c4297178d9', 'en',
   'Water: scarcity, waste and inequality in Brazil',
   'The same country that has plenty of water has people with none at all.',
   'Based on the motivating texts and on the knowledge you have built throughout your education, write an argumentative essay in formal written Portuguese on the theme "Water: scarcity, waste and inequality in Brazil", presenting an intervention proposal that respects human rights.'),
  ('46bf00dd-5131-48f5-94b9-b2c4297178d9', 'es',
   'Agua: escasez, desperdicio y desigualdad en Brasil',
   'El mismo país que tiene mucha agua tiene a quien no tiene nada.',
   'A partir de la lectura de los textos motivadores y con base en los conocimientos construidos a lo largo de tu formación, redacta un texto expositivo-argumentativo en registro escrito formal de la lengua portuguesa sobre el tema "Agua: escasez, desperdicio y desigualdad en Brasil", presentando una propuesta de intervención que respete los derechos humanos.')
) as v(id, locale, title, description, prompt)
join essay_themes t on t.id = v.id::uuid
on conflict (essay_theme_id, locale) do update
  set title = excluded.title,
      description = excluded.description,
      prompt = excluded.prompt,
      supporting_texts = excluded.supporting_texts;
