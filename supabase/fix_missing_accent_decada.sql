-- Fix: one word ("decada" -> "década") missed by the word list in
-- fix_missing_accents_geografia_fisica.sql, found by re-running its
-- verification query after that fix ran.
update questions
set prompt = regexp_replace(prompt, '\mdecada\M', 'década', 'g')
where id = 'd8b2d2c4-8b1d-4487-9553-6b6b9400c473';
