import sys, json
sys.path.insert(0, 'tool/qa')
from qa_lib import *
user, width, locale, theme = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
outdir = sys.argv[5]
depth = int(sys.argv[6]) if len(sys.argv) > 6 else 2
s = Session(width, locale, theme == 'dark')
login(s, user)
tag = f"{user}-{width}-{locale}-{theme}"
res = []
for tab in (['Início'], ['Praticar'], ['Perfil']):
    res += crawl(s, outdir, tag, depth=depth, base=tab)
bad = [r for r in res if r[1]]
print(json.dumps({"tag": tag, "telas": len(res), "com_issue": len(bad), "issues": [(r[0], r[1][:2]) for r in bad]}, ensure_ascii=False))
s.close()
