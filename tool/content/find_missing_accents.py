"""Lists unaccented words whose accented form appears elsewhere in the
question bank (see tool/content/README.md). Usage: find_missing_accents.py <dir>"""
import json, re, sys, unicodedata, collections

S = sys.argv[1]
qs = json.load(open(f'{S}/all_pt.json', encoding='utf-8'))

def strip(w):
    return ''.join(c for c in unicodedata.normalize('NFD', w) if unicodedata.category(c) != 'Mn')

TOK = re.compile(r"[A-Za-zÀ-ÿ]+")
def fields(q):
    return [q['prompt'], *q['options'], q['explanation'] or '']

count = collections.Counter()
for q in qs:
    for f in fields(q):
        for w in TOK.findall(f):
            count[w.lower()] += 1

accented = collections.defaultdict(collections.Counter)
for w, n in count.items():
    s = strip(w)
    if s != w:
        accented[s][w] += n

pairs = {}
for w, n in count.items():
    if strip(w) == w and w in accented and len(w) > 1:
        pairs[w] = (n, dict(accented[w]))

# Where the unaccented token occurs.
where = collections.defaultdict(list)
for q in qs:
    for f in fields(q):
        for w in set(t.lower() for t in TOK.findall(f)):
            if w in pairs:
                where[w].append(q['id'])

out = sorted(pairs.items(), key=lambda kv: -kv[1][0])
json.dump({w: {'n': n, 'forms': forms, 'ids': sorted(set(where[w]))}
           for w, (n, forms) in out},
          open(f'{S}/acc_pairs.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
for w, (n, forms) in out:
    print(f'{w:18} {n:4} -> {forms}  [{len(set(where[w]))} questões]')
