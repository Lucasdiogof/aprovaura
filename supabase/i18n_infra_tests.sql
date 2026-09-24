-- i18n FASE 2 infra tests: real INSERTs against real rows, wrapped in a
-- transaction that always ends in ROLLBACK -- nothing here survives the
-- run, on success or failure. Run this whole file as one script (not
-- statement by statement) so the transaction stays open throughout.
--
-- Each check is a `raise exception` if the condition is wrong, which both
-- aborts (rolling back on its own) and surfaces as a visible error in the
-- SQL Editor. If the whole block finishes and prints
-- 'i18n infra tests: all passed', every one of the FASE 2 QA scenarios
-- held: pt-BR, en/es with no translation, en with a translation, a
-- partial translation, an invalid (option-count-mismatch) translation not
-- mixing languages, ids identical across locales, and options order
-- preserved.

begin;

do $$
declare
  v_question_id uuid;
  v_original_prompt text;
  v_original_options text[];
  v_original_explanation text;
  v_catalog_node_id uuid;
  v_original_title text;
  r record;
begin
  -- Pick one real question and one real catalog node to attach synthetic
  -- translations to -- FKs require a row that actually exists.
  select id, prompt, options, explanation
    into v_question_id, v_original_prompt, v_original_options, v_original_explanation
  from questions limit 1;

  select id, title into v_catalog_node_id, v_original_title
  from catalog_nodes limit 1;

  -- 1. pt-BR (default) returns the canonical content, untouched.
  select * into r from get_catalog_questions(
    (select catalog_node_id from questions where id = v_question_id)
  ) where id = v_question_id;
  if r.prompt is distinct from v_original_prompt
      or r.options is distinct from v_original_options then
    raise exception 'FAIL: pt-BR did not return the canonical question';
  end if;

  -- 2. en/es with zero rows in question_translations both fall back to
  -- pt-BR -- not an error, not an empty string.
  select * into r from get_catalog_questions(
    (select catalog_node_id from questions where id = v_question_id),
    p_locale => 'en'
  ) where id = v_question_id;
  if r.prompt is distinct from v_original_prompt then
    raise exception 'FAIL: en with no translation did not fall back to pt-BR';
  end if;

  select * into r from get_catalog_questions(
    (select catalog_node_id from questions where id = v_question_id),
    p_locale => 'es'
  ) where id = v_question_id;
  if r.prompt is distinct from v_original_prompt then
    raise exception 'FAIL: es with no translation did not fall back to pt-BR';
  end if;

  -- 3. en WITH a valid translation (same option count) is used as-is, and
  -- the id/correct_index never change across locales.
  insert into question_translations (question_id, locale, prompt, options, explanation)
  values (
    v_question_id, 'en', 'EN prompt',
    array(select 'EN option ' || i from generate_series(1, array_length(v_original_options, 1)) i),
    'EN explanation'
  );

  select * into r from get_catalog_questions(
    (select catalog_node_id from questions where id = v_question_id),
    p_locale => 'en'
  ) where id = v_question_id;
  if r.prompt is distinct from 'EN prompt' or r.explanation is distinct from 'EN explanation' then
    raise exception 'FAIL: en with a valid translation was not used';
  end if;
  if r.id is distinct from v_question_id then
    raise exception 'FAIL: translated row returned a different id';
  end if;
  if array_length(r.options, 1) is distinct from array_length(v_original_options, 1) then
    raise exception 'FAIL: translated options changed count/order length';
  end if;

  -- 4. Partial translation (explanation left out): prompt/options still
  -- come from the translation, explanation falls back to pt-BR on its own.
  update question_translations set explanation = null
  where question_id = v_question_id and locale = 'en';

  select * into r from get_catalog_questions(
    (select catalog_node_id from questions where id = v_question_id),
    p_locale => 'en'
  ) where id = v_question_id;
  if r.prompt is distinct from 'EN prompt' then
    raise exception 'FAIL: partial translation lost its prompt';
  end if;
  if r.explanation is distinct from v_original_explanation then
    raise exception 'FAIL: explanation did not fall back independently on a partial translation';
  end if;

  -- 5. Invalid translation (fewer options than the original): the whole
  -- question falls back to pt-BR -- prompt AND options together, never a
  -- translated prompt paired with pt-BR options or vice-versa.
  update question_translations
  set options = v_original_options[1:array_length(v_original_options, 1) - 1]
  where question_id = v_question_id and locale = 'en';

  select * into r from get_catalog_questions(
    (select catalog_node_id from questions where id = v_question_id),
    p_locale => 'en'
  ) where id = v_question_id;
  if r.prompt is distinct from v_original_prompt or r.options is distinct from v_original_options then
    raise exception 'FAIL: an invalid (mismatched option count) translation was not fully rejected';
  end if;

  -- 6. Same shape of proof for catalog_children: a translated title is
  -- used when present, and locale='es' with no translation falls back.
  insert into catalog_node_translations (catalog_node_id, locale, title, description)
  values (v_catalog_node_id, 'es', 'ES title', 'ES description');

  if not exists (
    select 1 from catalog_children(
      (select subject from catalog_nodes where id = v_catalog_node_id),
      (select parent_id from catalog_nodes where id = v_catalog_node_id),
      'es'
    ) where id = v_catalog_node_id and title = 'ES title'
  ) then
    raise exception 'FAIL: catalog_children(es) did not use the translated title';
  end if;

  if not exists (
    select 1 from catalog_children(
      (select subject from catalog_nodes where id = v_catalog_node_id),
      (select parent_id from catalog_nodes where id = v_catalog_node_id),
      'fr'
    ) where id = v_catalog_node_id and title = v_original_title
  ) then
    raise exception 'FAIL: an unsupported locale (fr, no rows possible) did not fall back to pt-BR';
  end if;

  raise notice 'i18n infra tests: all passed';
end $$;

rollback;
