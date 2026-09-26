-- Fix: questions in geografia/fisica whose prompt/options/explanation were
-- seeded with zero accented characters at all (pt-BR is the canonical
-- text in `questions`, not a translation).
--
-- A curated word-level dictionary (unaccented -> accented), applied with
-- whole-word boundaries so it never touches a substring inside a
-- longer/unrelated word, applied once lowercase and once with the first
-- letter capitalized (covers sentence-start and capitalized proper nouns
-- without flattening their case).
--
-- Every entry here was checked against the actual flagged rows first, to
-- rule out verb/noun homographs that are legitimately unaccented in some
-- forms (e.g. "pratica"/"critica" as verbs) -- none of those are
-- included. "pais"->"país", "esta"->"está", "marco"->"março" and
-- "media"->"média" were each individually confirmed against every one of
-- their occurrences in this content (never the ambiguous
-- parents/this/milestone/midia reading). "franca"/"Franca" is genuinely
-- ambiguous even case-sensitively ("Zona Franca de Manaus" vs. "Franca"
-- the country) and is fixed separately below, by row id, instead of
-- through this dictionary.
create or replace function _fix_pt_accents(input text) returns text
language plpgsql as $$
declare
  mapping text[][] := array[
    array['area', 'área'], array['areas', 'áreas'],
    array['regiao', 'região'], array['regioes', 'regiões'],
    array['populacao', 'população'], array['producao', 'produção'],
    array['industria', 'indústria'], array['industrias', 'indústrias'],
    array['goiania', 'goiânia'], array['goias', 'goiás'],
    array['parana', 'paraná'], array['petroleo', 'petróleo'],
    array['paranaiba', 'paranaíba'], array['municipios', 'municípios'],
    array['municipio', 'município'], array['agua', 'água'],
    array['aguas', 'águas'], array['carvao', 'carvão'],
    array['corumba', 'corumbá'], array['territorio', 'território'],
    array['amazonia', 'amazônia'], array['estao', 'estão'],
    array['mineracao', 'mineração'], array['anapolis', 'anápolis'],
    array['catalao', 'catalão'], array['migracao', 'migração'],
    array['migracoes', 'migrações'], array['ausencia', 'ausência'],
    array['acucar', 'açúcar'], array['hidreletricas', 'hidrelétricas'],
    array['hidreletrica', 'hidrelétrica'], array['servicos', 'serviços'],
    array['nivel', 'nível'], array['extracao', 'extração'],
    array['conurbacao', 'conurbação'], array['reune', 'reúne'],
    array['energetica', 'energética'], array['apos', 'após'],
    array['seculo', 'século'], array['distancia', 'distância'],
    array['eletrica', 'elétrica'], array['relacao', 'relação'],
    array['russia', 'rússia'], array['industrializacao', 'industrialização'],
    array['verao', 'verão'], array['demografica', 'demográfica'],
    array['reducao', 'redução'], array['india', 'índia'],
    array['conservacao', 'conservação'], array['america', 'américa'],
    array['niobio', 'nióbio'], array['influencia', 'influência'],
    array['estacao', 'estação'], array['estacoes', 'estações'],
    array['importacoes', 'importações'], array['concentracao', 'concentração'],
    array['agricola', 'agrícola'], array['agronegocio', 'agronegócio'],
    array['graos', 'grãos'], array['avanco', 'avanço'],
    array['urbanizacao', 'urbanização'], array['agropecuaria', 'agropecuária'],
    array['superficie', 'superfície'], array['economico', 'econômico'],
    array['historico', 'histórico'], array['historica', 'histórica'],
    array['unica', 'única'], array['unico', 'único'],
    array['exodo', 'êxodo'], array['geracao', 'geração'],
    array['atlantica', 'atlântica'], array['metropoles', 'metrópoles'],
    array['materia', 'matéria'], array['emissoes', 'emissões'],
    array['aceleracao', 'aceleração'], array['niquelandia', 'niquelândia'],
    array['jatai', 'jataí'], array['expansao', 'expansão'],
    array['renovavel', 'renovável'], array['renovaveis', 'renováveis'],
    array['forca', 'força'], array['uniao', 'união'],
    array['transicao', 'transição'], array['planicie', 'planície'],
    array['proibicao', 'proibição'], array['sertao', 'sertão'],
    array['educacao', 'educação'], array['cinetico', 'cinético'],
    array['cinetica', 'cinética'], array['patrimonio', 'patrimônio'],
    array['pirenopolis', 'pirenópolis'], array['poluicao', 'poluição'],
    array['integracao', 'integração'], array['pecuaria', 'pecuária'],
    array['japao', 'japão'], array['combustiveis', 'combustíveis'],
    array['brasilia', 'brasília'], array['lancado', 'lançado'],
    array['formacao', 'formação'], array['criacao', 'criação'],
    array['proxima', 'próxima'], array['importancia', 'importância'],
    array['varias', 'várias'], array['comercio', 'comércio'],
    array['potencias', 'potências'], array['reservatorios', 'reservatórios'],
    array['substituicao', 'substituição'], array['depressao', 'depressão'],
    array['organizacao', 'organização'], array['instituicoes', 'instituições'],
    array['economicas', 'econômicas'], array['desconcentracao', 'desconcentração'],
    array['dispersao', 'dispersão'], array['automobilistica', 'automobilística'],
    array['estatizacao', 'estatização'], array['agraria', 'agrária'],
    array['ameacados', 'ameaçados'], array['pressao', 'pressão'],
    array['elevacao', 'elevação'], array['mesorregioes', 'mesorregiões'],
    array['tres', 'três'], array['orbita', 'órbita'],
    array['satelite', 'satélite'], array['revolucao', 'revolução'],
    array['aproximacao', 'aproximação'], array['desaceleracao', 'desaceleração'],
    array['modulo', 'módulo'], array['concordancia', 'concordância'],
    array['concavo', 'côncavo'], array['macico', 'maciço'],
    array['maxima', 'máxima'], array['quadruplo', 'quádruplo'],
    array['projetil', 'projétil'], array['necessaria', 'necessária'],
    array['especifico', 'específico'], array['maquina', 'máquina'],
    array['termica', 'térmica'], array['propagacao', 'propagação'],
    array['ultimo', 'último'], array['resistencia', 'resistência'],
    array['identicos', 'idênticos'], array['periodo', 'período'],
    array['italia', 'itália'], array['nao', 'não'],
    array['sao', 'são'], array['pais', 'país'],
    array['esta', 'está'], array['marco', 'março'],
    array['media', 'média']
  ];
  m text[];
  result text := input;
begin
  if result is null then
    return null;
  end if;
  foreach m slice 1 in array mapping loop
    result := regexp_replace(result, '\m' || m[1] || '\M', m[2], 'g');
    result := regexp_replace(
      result,
      '\m' || upper(substr(m[1], 1, 1)) || substr(m[1], 2) || '\M',
      upper(substr(m[2], 1, 1)) || substr(m[2], 2),
      'g'
    );
  end loop;
  return result;
end;
$$;

update questions q
set
  prompt = _fix_pt_accents(q.prompt),
  explanation = _fix_pt_accents(q.explanation),
  options = (
    select array_agg(_fix_pt_accents(el) order by ord)
    from unnest(q.options) with ordinality as t(el, ord)
  )
from catalog_nodes cn
where cn.id = q.catalog_node_id
  and cn.subject in ('geografia', 'fisica');

-- "Franca"/"franca" is ambiguous even by case ("Zona Franca de Manaus" is
-- correctly unaccented; the same capitalized spelling means the country
-- "França" everywhere else it appears in this content) -- fixed by row id
-- instead of the dictionary above, only where it means the country.
update questions
set
  explanation = replace(explanation, 'Franca', 'França'),
  options = (
    select array_agg(replace(el, 'Franca', 'França') order by ord)
    from unnest(options) with ordinality as t(el, ord)
  )
where id in (
  'a6000292-2d52-4b88-98a8-2b5d1bc5bdb6',
  '89d6e89d-8c00-4642-a5a1-ef3092c2b7c3',
  'e5b08bdf-d264-47a6-af9a-4a89341e2820',
  'e0c39f2e-ce23-4372-86a9-3ee5fdd809f6'
);

drop function _fix_pt_accents(text);
