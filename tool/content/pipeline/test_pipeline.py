"""Testes do pipeline: python -m unittest discover -s tool/content/pipeline"""
import copy, os, sys, unittest
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qc
from dedupe import Index, jaccard, shingles

EXPL = ("A alternativa B está correta porque a razão é a proporção direta entre as grandezas e os dados do enunciado. "
        "A) erra por inverter a proporção; C) confunde a unidade; D) ignora o dado do enunciado. Assim, revise o conceito e o cálculo.") * 1
BASE = dict(id="T-1", materia="matematica_financeira", topico="matematica_financeira.juros_simples", categorias=["concurso"],
            dificuldade="medio", origem="autoral", idioma="pt-BR", gabarito=1, explicacao=EXPL,
            enunciado="Um capital de R$ 1.000,00 é aplicado a juros simples de 2% ao mês durante 5 meses. Qual é o montante final?",
            alternativas=["R$ 1.050,00", "R$ 1.100,00", "R$ 1.102,04", "R$ 1.200,00"], data_referencia="2026-11-27")
VERIF = dict(tipo="python", codigo="valores=[1050,1100,1102.04,1200]\ncorreta=1000*(1+0.02*5)")

def q(**kw):
    d = copy.deepcopy(BASE); d.update(kw); return d

class Estrutura(unittest.TestCase):
    def test_valida(self): self.assertEqual(qc.estrutura(q())[0], [])
    def test_alternativas_duplicadas(self): self.assertIn("alternativas_duplicadas", qc.estrutura(q(alternativas=["a b", "A  B", "c", "d"]))[0])
    def test_sinal_distingue(self): self.assertNotIn("alternativas_duplicadas", qc.estrutura(q(alternativas=["-4,00%", "4,00%", "0%", "2%"]))[0])
    def test_gabarito_fora(self): self.assertIn("gabarito_fora_do_intervalo", qc.estrutura(q(gabarito=4))[0])
    def test_explicacao_curta(self): self.assertIn("explicacao_curta", qc.estrutura(q(explicacao="curta"))[0])
    def test_html(self): self.assertTrue(any("padrao_proibido" in e for e in qc.estrutura(q(enunciado=BASE["enunciado"] + " <script>x</script>"))[0]))
    def test_todas_anteriores(self): self.assertTrue(any("padrao_proibido" in e for e in qc.estrutura(q(alternativas=["a", "b", "c", "Todas as anteriores"]))[0]))
    def test_imagem(self): self.assertTrue(any("padrao_proibido" in e for e in qc.estrutura(q(enunciado="Na figura abaixo há um triângulo retângulo com catetos 3 e 4. Qual a hipotenusa?"))[0]))
    def test_banca(self): self.assertIn("cita_banca_ou_instituicao", qc.estrutura(q(enunciado=BASE["enunciado"] + " (FGV 2020)"))[0])
    def test_categoria_fora(self): self.assertTrue(any("categoria_fora_da_materia" in e for e in qc.estrutura(q(categorias=["enem", "concurso"], materia="raciocinio_logico", topico="raciocinio_logico.negacao"))[0]))
    def test_topico_desconhecido(self): self.assertTrue(any("topico_desconhecido" in e for e in qc.estrutura(q(topico="matematica_financeira.xyz"))[0]))
    def test_oficial_bloqueada(self): self.assertIn("oficial_autorizada_exige_documentacao_manual", qc.estrutura(q(origem="oficial_autorizada"))[0])
    def test_juridica_sem_referencia(self):
        j = q(materia="dir_penal", topico="dir_penal.penas", categorias=["concurso"])
        self.assertIn("sem_referencia_normativa", qc.estrutura(j)[0])
        j["referencias"] = [{"fonte": "planalto-cp", "citacao": "art. 59, CP"}]
        self.assertEqual(qc.estrutura(j)[0], [])
        j["referencias"] = [{"fonte": "inventada", "citacao": "art. 1º"}]
        self.assertTrue(any("referencia_fonte_desconhecida" in e for e in qc.estrutura(j)[0]))
        j["referencias"] = [{"fonte": "planalto-cp", "citacao": "o código diz"}]
        self.assertIn("citacao_sem_dispositivo", qc.estrutura(j)[0])
    def test_mutavel_sem_data(self):
        j = q(materia="economia", topico="economia.oferta_demanda", categorias=["concurso"]); j.pop("data_referencia"); self.assertIn("sem_data_referencia", qc.estrutura(j)[0])
    def test_expiracao(self): self.assertEqual(qc.expira_em(q(materia="economia")), "2027-11-27"); self.assertIsNone(qc.expira_em(q()))

class Vies(unittest.TestCase):
    def test_mais_longa(self):
        self.assertTrue(qc.gabarito_mais_longa(q(alternativas=["a", "b muito mais longo", "c", "d"], gabarito=1)))
        self.assertFalse(qc.gabarito_mais_longa(q(alternativas=["aaaa", "bbbb", "cccc", "dddd"], gabarito=1)))

class Calculo(unittest.TestCase):
    def test_ok(self): self.assertEqual(qc.verificar_calculo(q(verificacao=VERIF)), ([], []))
    def test_gabarito_errado(self): self.assertTrue(qc.verificar_calculo(q(verificacao=VERIF, gabarito=0))[0][0].startswith("verificacao_diverge"))
    def test_duas_corretas(self):
        v = dict(tipo="python", codigo="valores=[1100,1100,1,2]\ncorreta=1100")
        self.assertTrue(qc.verificar_calculo(q(verificacao=v))[0][0].startswith("verificacao_diverge"))
    def test_codigo_proibido(self): self.assertEqual(qc.verificar_calculo(q(verificacao=dict(tipo="python", codigo="import os\nvalores=[1]\ncorreta=1")))[0], ["verificacao_codigo_proibido"])
    def test_sympy_exato(self):
        v = dict(tipo="python", codigo="from sympy import sqrt, Rational\nvalores=[sqrt(2), 2, Rational(3,2), 1]\ncorreta=sqrt(8)/2")
        self.assertEqual(qc.verificar_calculo(q(verificacao=v, gabarito=0)), ([], []))
    def test_timeout(self):
        v = dict(tipo="python", codigo="while True: pass\nvalores=[1]\ncorreta=1")
        self.assertEqual(qc.verificar_calculo(q(verificacao=v), timeout=2)[0], ["verificacao_timeout"])

class Dedupe(unittest.TestCase):
    def test_identica_e_similar(self):
        ix = Index(); ix.add("a", "Um capital de R$ 1.000,00 é aplicado a juros simples de 2% ao mês durante 5 meses. Qual é o montante final?", ["x", "y", "z", "w"])
        self.assertEqual(ix.query("UM capital de R$ 1.000,00 é aplicado a juros simples de 2% ao mês durante 5 meses. Qual é o montante final")[2], "enunciado_identico")
        self.assertEqual(ix.query("Um capital de R$ 1.000,00 é aplicado a juros simples de 2% ao mês durante 6 meses. Qual é o montante final obtido?")[0], "a")
        self.assertIsNone(ix.query("Qual é a capital do Brasil e qual é a sua principal função política no país?")[0])
    def test_jaccard(self): self.assertEqual(jaccard(shingles("a b c d"), shingles("a b c d")), 1.0)


class Sandbox(unittest.TestCase):
    """Código hostil (que escapa do regex _DENY) precisa falhar DENTRO do contêiner."""
    def _v(self, corpo): return qc.verificar_calculo(q(verificacao=dict(tipo="python", codigo=corpo + "\nvalores=[1,2,3,4]\ncorreta=1")), timeout=20)[0]
    def test_sem_rede(self):
        e = self._v("__builtins__['__imp'+'ort__']('socket').create_connection(('1.1.1.1',53),3)")
        self.assertTrue(e and ("OSError" in e[0] or "Network" in e[0] or "unreachable" in e[0] or "gaierror" in e[0]), e)
    def test_disco_somente_leitura(self):
        e = self._v("__builtins__['op'+'en']('/x.txt','w').write('a')")
        self.assertTrue(e and "Read-only" in e[0], e)
    def test_nao_enxerga_host(self):
        e = self._v("o=__builtins__['__imp'+'ort__']('os'); assert not o.path.exists('/Users') and not o.path.exists('/c')")
        self.assertFalse([x for x in e if x.startswith('verificacao_erro')], e)  # asserts internos passaram
    def test_loop_infinito_morre(self):
        self.assertEqual(self._v("while True: pass"), ["verificacao_timeout"])


if __name__ == "__main__": unittest.main()
