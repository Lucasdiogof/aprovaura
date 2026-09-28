"""Regenerates lib/features/map_quiz/l10n/map_region_names.dart from
tool/content/map_region_names.txt (see tool/content/README.md)."""
import json, glob, sys

tr = open(sys.argv[1], encoding='utf-8').read().splitlines()
base, over, mode = {}, {}, None
for l in tr:
    if l.startswith('## '):
        mode = 'over' if 'overrides' in l else 'base'
        continue
    pt, en, es = l.split('|')
    assert en and es
    d = over if mode == 'over' else base
    assert pt not in d, pt
    d[pt] = (en, es)

names = set()
for f in glob.glob('lib/assets/maps/*.geojson'):
    for ft in json.load(open(f, encoding='utf-8'))['features']:
        names.add(ft['properties']['nome'])
print('missing', sorted(names - set(base)), 'extra', sorted(set(base) - names))

BS = chr(92)
def q(s):
    return "'" + s.replace(BS, BS + BS).replace("'", BS + "'").replace('$', BS + '$') + "'"

HEADER = """import 'package:aura/core/l10n/app_language.dart';

/// Display name of a map region in the app's language.
///
/// The .geojson assets under lib/assets/maps/ stay untouched: they carry only
/// the pt-BR `nome` (plus `sigla`, the id every answer is matched by), so a
/// translation can never change which region counts as correct. Lookup is by
/// that pt-BR name, falling back to it when there's no entry.
///
/// A handful of pt-BR names mean different places in different layers
/// ("Amazonas" is both the river and the state); [_overrides] resolves those
/// by layer kind, i.e. the last segment of the mapId (`world_rivers` ->
/// `rivers`). test/features/map_quiz/map_region_names_test.dart fails if any
/// name in any .geojson is missing here.
String localizedRegionName(
  String ptName,
  AppLanguage language, {
  required String mapId,
}) {
  if (language == AppLanguage.portuguese) return ptName;
  final kind = mapId.substring(mapId.lastIndexOf('_') + 1);
  final entry = _overrides['$kind:$ptName'] ?? regionNameTranslations[ptName];
  if (entry == null) return ptName;
  return language == AppLanguage.english ? entry.$1 : entry.$2;
}

const Map<String, (String, String)> _overrides = {"""
lines = [HEADER]
for k, (en, es) in over.items():
    lines.append(f"  {q(k)}: ({q(en)}, {q(es)}),")
lines.append("};\n\n/// pt-BR name -> (en, es). Public for the coverage test.\n"
             "const Map<String, (String, String)> regionNameTranslations = {")
for k, (en, es) in base.items():
    lines.append(f"  {q(k)}: ({q(en)}, {q(es)}),")
lines.append("};\n")
open('lib/features/map_quiz/l10n/map_region_names.dart', 'w', encoding='utf-8',
     newline='\n').write('\n'.join(lines))
print(len(base), len(over))
