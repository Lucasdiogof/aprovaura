"""Usage: gen_new_questions.py SCRATCH SUBJECT IN.txt OUT.sql

IN.txt blocks:
=== <topic path exactly as in leaves.json> c=<correct index 0..3> [d=facil|medio|dificil] [id=<uuid>]
  (id= pins the uuid of a question whose published pt prompt was reworded;
   without it the id is the uuid5 of the prompt)
P: pt prompt
- option (x4)
E: pt explanation
--- en
P: / - x4 (or "- @" to copy the pt option) / E:
--- es
P: / - x4 / E:
"""
import json, sys, uuid

S, subject, src, out = sys.argv[1:5]
leaves = json.load(open(f'{S}/leaves.json', encoding='utf-8'))['leaves']
by_path = {l['path']: l for l in leaves if l['subject'] == subject}
NS = uuid.UUID('6f1c1b8e-8a52-4a0e-9d4e-2b9f7f1d0a11')

qs, cur, lang = [], None, None
for n, raw in enumerate(open(src, encoding='utf-8'), 1):
    line = raw.rstrip('\n')
    if not line.strip():
        continue
    if line.startswith('=== '):
        rest = line[4:]
        pin = None
        if ' id=' in rest:
            rest, pin = rest.rsplit(' id=', 1)
            pin = str(uuid.UUID(pin))
        d = 'dificil'
        if ' d=' in rest:
            rest, d = rest.rsplit(' d=', 1)
            assert d in ('facil', 'medio', 'dificil'), (n, d)
        head, c = rest.rsplit(' c=', 1)
        assert head in by_path, (n, head)
        cur = {'node': by_path[head]['id'], 'c': int(c), 'd': d, 'pin': pin, 'pt': {'O': []}}
        qs.append(cur); lang = 'pt'
    elif line.startswith('--- '):
        lang = line[4:].strip(); assert lang in ('en', 'es'), n
        cur[lang] = {'O': []}
    elif line.startswith('P: '):
        cur[lang]['P'] = line[3:].strip()
    elif line.startswith('- '):
        o = line[2:].strip()
        if o == '@':
            o = cur['pt']['O'][len(cur[lang]['O'])]
        cur[lang]['O'].append(o)
    elif line.startswith('E: '):
        cur[lang]['E'] = line[3:].strip()
    else:
        raise SystemExit(f'{src}:{n}: bad line {line!r}')

seen = set()
for i, q in enumerate(qs):
    assert 0 <= q['c'] <= 3, (i, 'c')
    for l in ('pt', 'en', 'es'):
        b = q.get(l)
        assert b and b.get('P') and b.get('E'), (i, l, 'missing P/E')
        assert len(b['O']) == 4 and all(b['O']), (i, l, 'needs 4 options')
        assert len(set(b['O'])) == 4, (i, l, 'duplicate option')
    q['id'] = q['pin'] or str(uuid.uuid5(NS, q['pt']['P']))
    assert q['id'] not in seen, (i, 'duplicate prompt'); seen.add(q['id'])

def s(x): return "'" + x.replace("'", "''") + "'"
def arr(o): return 'array[' + ', '.join(s(x) for x in o) + ']'
qrows, trows = [], []
for k, q in enumerate(qs):
    p = q['pt']
    qrows.append(f"  ({s(q['id'])}, {s(q['node'])},\n   {s(p['P'])},\n   {arr(p['O'])}, {q['c']},\n   {s(p['E'])}, {100 + k}, {s(q['d'])})")
    for l in ('en', 'es'):
        b = q[l]
        trows.append(f"  ({s(q['id'])}, {s(l)},\n   {s(b['P'])},\n   {arr(b['O'])},\n   {s(b['E'])})")
from collections import Counter
QJ = (',' + chr(10)).join(qrows)
TJ = (',' + chr(10)).join(trows)
sql = f'''-- New questions for {subject}: {len(qs)} questions, each already
-- with its en/es translation ({len(trows)} translation rows).
--
-- ids are deterministic (uuid5 of the pt-BR prompt, or the id= pinned in the
-- source when a published prompt was reworded), so running this twice
-- inserts nothing new: questions use on conflict do nothing, translations
-- on conflict do update. The translation join refuses any row whose option
-- count differs from the original (correct_index is positional).

insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty)
select v.id::uuid, v.node::uuid, v.prompt, v.options, v.correct_index, v.explanation, v.order_index, v.difficulty
from (values
{QJ}
) as v(id, node, prompt, options, correct_index, explanation, order_index, difficulty)
join catalog_nodes c on c.id = v.node::uuid
on conflict (id) do nothing;

insert into question_translations (question_id, locale, prompt, options, explanation)
select v.id::uuid, v.locale, v.prompt, v.options, v.explanation
from (values
{TJ}
) as v(id, locale, prompt, options, explanation)
join questions q
  on q.id = v.id::uuid
 and cardinality(q.options) = cardinality(v.options)
on conflict (question_id, locale) do update
  set prompt = excluded.prompt,
      options = excluded.options,
      explanation = excluded.explanation;
'''
open(out, 'w', encoding='utf-8', newline='\n').write(sql)
print(len(qs), 'questions; correct_index spread', dict(Counter(q['c'] for q in qs)),
      'levels', dict(Counter(q['d'] for q in qs)))
print('topics', dict(Counter(next(p for p, l in by_path.items() if l['id'] == q['node']) for q in qs)))
