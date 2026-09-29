"""Usage: gen_subject_catalog.py SUBJECT IN.txt OUT.sql LEAVES_DIR

Builds the catalog tree of a NEW subject (areas and their topics, already
with en/es) and the leaves.json that gen_new_questions.py reads, so the
questions can be written before the catalog is in the database.

IN.txt:
== <area pt> | <description pt> | <emoji>
en: <area en> | <description en>
es: <area es> | <description es>
-- <topic pt>
en: <topic en>
es: <topic es>
(more "--" topics, then the next "==" area)

ids are uuid5 of "<subject> > <path>", so running the SQL twice changes
nothing (nodes: do nothing; translations: update).
"""
import json
import os
import sys
import uuid

subject, src, out, leaves_dir = sys.argv[1:5]
NS = uuid.UUID('3b6d2a52-3f0e-4c8e-9a51-7c1b6e2f9d40')

areas, cur, last = [], None, None
for n, raw in enumerate(open(src, encoding='utf-8'), 1):
    line = raw.strip()
    if not line:
        continue
    if line.startswith('== '):
        title, desc, icon = [x.strip() for x in line[3:].split('|')]
        cur = {'pt': (title, desc), 'icon': icon, 'topics': []}
        areas.append(cur)
        last = cur
    elif line.startswith('-- '):
        topic = {'pt': (line[3:].strip(), None)}
        cur['topics'].append(topic)
        last = topic
    elif line[:3] in ('en:', 'es:'):
        parts = [x.strip() for x in line[3:].split('|')]
        last[line[:2]] = (parts[0], parts[1] if len(parts) > 1 else None)
    else:
        raise SystemExit(f'{src}:{n}: bad line {line!r}')

nodes, leaves = [], []
for i, a in enumerate(areas):
    assert a.get('en') and a.get('es') and a['pt'][1], (a['pt'], 'area needs en/es/description')
    a_path = a['pt'][0]
    a_id = str(uuid.uuid5(NS, f'{subject} > {a_path}'))
    nodes.append((a_id, None, a, a['icon'], i))
    assert a['topics'], (a_path, 'area without topics')
    for j, t in enumerate(a['topics']):
        assert t.get('en') and t.get('es'), (t['pt'], 'topic needs en/es')
        path = f"{a_path} > {t['pt'][0]}"
        t_id = str(uuid.uuid5(NS, f'{subject} > {path}'))
        nodes.append((t_id, a_id, t, a['icon'], j))
        leaves.append({'id': t_id, 'subject': subject, 'path': path})


def s(x):
    return 'null' if x is None else "'" + x.replace("'", "''") + "'"


node_rows = ',\n'.join(
    f"  ({s(i)}, {s(p)}, {s(n['pt'][0])}, {s(n['pt'][1])}, {s(icon)}, {o})"
    for i, p, n, icon, o in nodes)
tr_rows = ',\n'.join(
    f"  ({s(i)}, {s(l)}, {s(n[l][0])}, {s(n[l][1])})"
    for i, _, n, _, _ in nodes for l in ('en', 'es'))

sql = f'''-- Catalog of the new subject "{subject}": {len(areas)} areas, {len(leaves)} topics,
-- each with its en/es translation. Idempotent (uuid5 ids).
-- Areas first (a topic references its area), in one statement: a VALUES
-- list is inserted in order, and the parent always comes before its child.

insert into catalog_nodes (id, subject, parent_id, title, description, icon, order_index)
select v.id::uuid, {s(subject)}, v.parent::uuid, v.title, v.description, v.icon, v.ord
from (values
{node_rows}
) as v(id, parent, title, description, icon, ord)
order by v.parent nulls first
on conflict (id) do nothing;

insert into catalog_node_translations (catalog_node_id, locale, title, description)
select v.id::uuid, v.locale, v.title, v.description
from (values
{tr_rows}
) as v(id, locale, title, description)
join catalog_nodes c on c.id = v.id::uuid
on conflict (catalog_node_id, locale) do update
  set title = excluded.title, description = excluded.description;
'''
open(out, 'w', encoding='utf-8', newline='\n').write(sql)
os.makedirs(leaves_dir, exist_ok=True)
json.dump({'leaves': leaves}, open(os.path.join(leaves_dir, 'leaves.json'), 'w', encoding='utf-8'),
          ensure_ascii=False, indent=1)
print(len(areas), 'areas,', len(leaves), 'topics')
