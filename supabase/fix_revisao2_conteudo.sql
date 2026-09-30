-- Segunda rodada da revisão externa (2026-09-30): 16 correções de conteúdo
--
-- Todas aceitas. Ajustes meus por cima do revisor: em Geografia 192 e na
-- questão do Governo Provisório a alternativa certa tinha virado a mais longa
-- de longe (com ressalvas que entregavam a resposta), e em Geografia 263 os
-- distratores eram absurdos (marés, geleiras, vulcões); os três foram
-- reescritos. Na soja saiu a frase que falava com o revisor, não com o aluno.
--
-- As 1.828 reordenações de alternativas foram recusadas: o app embaralha as
-- alternativas na hora de mostrar, então a posição no banco não chega ao
-- aluno. Pelo mesmo motivo, cada questão mantém o correct_index que já tinha:
-- as alternativas novas foram arrumadas para a certa cair nele, e quando a
-- lista não mudou, só a ordem, ficou a ordem do banco. As três línguas usam
-- a mesma ordem. Cada update grava o valor final inteiro, então rodar de novo
-- não muda nada. Só Inglês tem fonte (tool/content/materias/ingles_q*.txt),
-- já atualizada; as outras matérias vivem só no banco.

-- fisica: acentos no enunciado e g = G·M/R² na explicação
update questions set prompt = 'Um planeta tem o dobro da massa da Terra e o mesmo raio. Comparada à gravidade na superfície da Terra, a gravidade na superfície desse planeta é:', options = array['A metade', 'Igual', 'O dobro', 'O quádruplo'], explanation = 'g = G·M/R². Dobrando a massa e mantendo o mesmo raio, a gravidade superficial dobra.'
 where id = '979f8a12-f147-4078-ab07-278141d1bc03' and correct_index = 2;
update question_translations set prompt = 'A planet has twice Earth''s mass and the same radius. Compared with gravity at Earth''s surface, gravity at the surface of this planet is:', options = array['Half as large', 'The same', 'Twice as large', 'Four times as large'], explanation = 'g = G·M/R². Doubling the mass while keeping the same radius doubles surface gravity.'
 where question_id = '979f8a12-f147-4078-ab07-278141d1bc03' and locale = 'en';
update question_translations set prompt = 'Un planeta tiene el doble de la masa de la Tierra y el mismo radio. Comparada con la gravedad en la superficie terrestre, la gravedad en la superficie de ese planeta es:', options = array['La mitad', 'Igual', 'El doble', 'El cuádruple'], explanation = 'g = G·M/R². Al duplicar la masa y mantener el mismo radio, la gravedad superficial se duplica.'
 where question_id = '979f8a12-f147-4078-ab07-278141d1bc03' and locale = 'es';

-- geografia: Cidade de Goiás: o que a UNESCO inscreveu (2001) foi o centro histórico
update questions set prompt = 'A primeira capital de Goiás, cujo centro histórico é reconhecido como Patrimônio Mundial pela UNESCO, é:', options = array['Cidade de Goiás (Goiás Velho)', 'Pirenópolis', 'Anápolis', 'Catalão'], explanation = 'A Cidade de Goiás, também conhecida como Goiás Velho, foi a primeira capital do estado. Seu centro histórico foi inscrito pela UNESCO na Lista do Patrimônio Mundial em 2001.'
 where id = '5feb182a-3192-485c-81a1-d90efe97033e' and correct_index = 0;
update question_translations set prompt = 'The first capital of Goiás, whose historic center is recognized as a UNESCO World Heritage Site, is:', options = array['City of Goiás (Goiás Velho)', 'Pirenópolis', 'Anápolis', 'Catalão'], explanation = 'The City of Goiás, also known as Goiás Velho, was the state''s first capital. Its historic center was inscribed on the UNESCO World Heritage List in 2001.'
 where question_id = '5feb182a-3192-485c-81a1-d90efe97033e' and locale = 'en';
update question_translations set prompt = 'La primera capital de Goiás, cuyo centro histórico es reconocido como Patrimonio Mundial por la UNESCO, es:', options = array['Ciudad de Goiás (Goiás Velho)', 'Pirenópolis', 'Anápolis', 'Catalão'], explanation = 'La Ciudad de Goiás, también conocida como Goiás Velho, fue la primera capital del estado. Su centro histórico fue inscrito en la Lista del Patrimonio Mundial de la UNESCO en 2001.'
 where question_id = '5feb182a-3192-485c-81a1-d90efe97033e' and locale = 'es';

-- geografia: duplicava a questão de Principais hidrelétricas; passa a ser sobre a matriz elétrica
update questions set prompt = 'Uma característica marcante da matriz elétrica brasileira é:', options = array['A alta participação de fontes renováveis', 'A predominância de termelétricas a carvão', 'A liderança da energia nuclear', 'A dependência de eletricidade importada'], explanation = 'A geração elétrica brasileira apresenta participação elevada de fontes renováveis. A hidreletricidade tem papel histórico central, enquanto eólica e solar ganharam participação nas últimas décadas.'
 where id = 'be922be1-cee1-4bf8-a973-d45c96b811fb' and correct_index = 0;
update question_translations set prompt = 'A notable feature of Brazil''s electricity mix is:', options = array['A high share of renewable sources', 'A predominance of coal-fired power plants', 'Nuclear power as the leading source', 'Dependence on imported electricity'], explanation = 'Brazil''s electricity generation has a high share of renewables. Hydropower has historically played a central role, while wind and solar have gained share in recent decades.'
 where question_id = 'be922be1-cee1-4bf8-a973-d45c96b811fb' and locale = 'en';
update question_translations set prompt = 'Una característica destacada de la matriz eléctrica brasileña es:', options = array['La alta participación de fuentes renovables', 'El predominio de las termoeléctricas a carbón', 'El liderazgo de la energía nuclear', 'La dependencia de electricidad importada'], explanation = 'La generación eléctrica brasileña presenta una alta participación de fuentes renovables. La hidroelectricidad ha tenido un papel histórico central, mientras la eólica y la solar han ganado participación en las últimas décadas.'
 where question_id = 'be922be1-cee1-4bf8-a973-d45c96b811fb' and locale = 'es';

-- geografia: "segundo maior rio brasileiro" é duvidoso; passa a identificar o Paraná por Itaipu
update questions set prompt = 'Qual grande rio da Bacia do Prata percorre o Centro-Sul da América do Sul e abriga a Usina de Itaipu em um trecho de seu curso?', options = array['Rio Paraná', 'Rio Tocantins', 'Rio Xingu', 'Rio Madeira'], explanation = 'O Rio Paraná integra a Bacia do Prata e, na fronteira entre Brasil e Paraguai, abriga a Usina Hidrelétrica de Itaipu.'
 where id = '0a8c87c0-bd24-42e6-a72e-51b42c0ac4d4' and correct_index = 0;
update question_translations set prompt = 'Which major river of the Río de la Plata Basin crosses south-central South America and contains the Itaipu Hydroelectric Plant along part of its course?', options = array['Paraná River', 'Tocantins River', 'Xingu River', 'Madeira River'], explanation = 'The Paraná River is part of the Río de la Plata Basin and, on the Brazil-Paraguay border, contains the Itaipu Hydroelectric Plant.'
 where question_id = '0a8c87c0-bd24-42e6-a72e-51b42c0ac4d4' and locale = 'en';
update question_translations set prompt = '¿Qué gran río de la Cuenca del Plata recorre el centro-sur de Sudamérica y alberga la Central Hidroeléctrica de Itaipú en un tramo de su curso?', options = array['Río Paraná', 'Río Tocantins', 'Río Xingu', 'Río Madeira'], explanation = 'El río Paraná integra la Cuenca del Plata y, en la frontera entre Brasil y Paraguay, alberga la Central Hidroeléctrica de Itaipú.'
 where question_id = '0a8c87c0-bd24-42e6-a72e-51b42c0ac4d4' and locale = 'es';

-- geografia: terceira questão sobre o Madeira; passa a ser sobre o Tapajós
update questions set prompt = 'Qual rio amazônico de águas claras passa pela região de Santarém (PA) e deságua no Rio Amazonas?', options = array['Rio Tapajós', 'Rio Negro', 'Rio Madeira', 'Rio Juruá'], explanation = 'O Tapajós é um importante afluente de águas claras do Amazonas e encontra o rio principal nas proximidades de Santarém, no Pará.'
 where id = '5bbae9c4-a9b7-40d8-a54c-d06b3cec4bce' and correct_index = 0;
update question_translations set prompt = 'Which clear-water Amazonian river passes through the Santarém region in Pará and flows into the Amazon River?', options = array['Tapajós River', 'Negro River', 'Madeira River', 'Juruá River'], explanation = 'The Tapajós is an important clear-water tributary of the Amazon and meets the main river near Santarém, Pará.'
 where question_id = '5bbae9c4-a9b7-40d8-a54c-d06b3cec4bce' and locale = 'en';
update question_translations set prompt = '¿Qué río amazónico de aguas claras pasa por la región de Santarém, en Pará, y desemboca en el río Amazonas?', options = array['Río Tapajós', 'Río Negro', 'Río Madeira', 'Río Juruá'], explanation = 'El Tapajós es un importante afluente de aguas claras del Amazonas y se encuentra con el río principal cerca de Santarém, en Pará.'
 where question_id = '5bbae9c4-a9b7-40d8-a54c-d06b3cec4bce' and locale = 'es';

-- geografia: Itaipu: pergunta a fronteira em vez de repetir a parceria
update questions set prompt = 'Em qual trecho de fronteira internacional se localiza a Usina Hidrelétrica de Itaipu?', options = array['Entre Brasil e Paraguai', 'Entre Brasil e Argentina', 'Entre Brasil e Uruguai', 'Entre Paraguai e Bolívia'], explanation = 'Itaipu foi construída no Rio Paraná e é administrada conjuntamente por Brasil e Paraguai.'
 where id = 'd9e26fb8-a3b4-4e3e-b720-681e6f5638bb' and correct_index = 0;
update question_translations set prompt = 'On which international border is the Itaipu Hydroelectric Plant located?', options = array['Between Brazil and Paraguay', 'Between Brazil and Argentina', 'Between Brazil and Uruguay', 'Between Paraguay and Bolivia'], explanation = 'Itaipu was built on the Paraná River and is jointly administered by Brazil and Paraguay.'
 where question_id = 'd9e26fb8-a3b4-4e3e-b720-681e6f5638bb' and locale = 'en';
update question_translations set prompt = '¿En qué frontera internacional se encuentra la Central Hidroeléctrica de Itaipú?', options = array['Entre Brasil y Paraguay', 'Entre Brasil y Argentina', 'Entre Brasil y Uruguay', 'Entre Paraguay y Bolivia'], explanation = 'Itaipú fue construida sobre el río Paraná y es administrada conjuntamente por Brasil y Paraguay.'
 where question_id = 'd9e26fb8-a3b4-4e3e-b720-681e6f5638bb' and locale = 'es';

-- geografia: "segundo maior bioma" some do enunciado; distratores absurdos trocados
update questions set prompt = 'A principal pressão ambiental sobre o Cerrado brasileiro hoje é:', options = array['A expansão da agropecuária e o desmatamento', 'A extração seletiva de madeira de lei', 'A pesca predatória nos rios', 'O crescimento das cidades litorâneas'], explanation = 'A conversão da vegetação nativa em lavouras e pastagens é uma das principais causas de perda de habitat no Cerrado.'
 where id = 'd7b8c550-5827-40c2-a105-e17a804b7fb3' and correct_index = 0;
update question_translations set prompt = 'The main environmental pressure on Brazil''s Cerrado today is:', options = array['Agricultural expansion and deforestation', 'Selective logging of hardwoods', 'Overfishing in the rivers', 'The growth of coastal cities'], explanation = 'Converting native vegetation into cropland and pasture is one of the main causes of habitat loss in the Cerrado.'
 where question_id = 'd7b8c550-5827-40c2-a105-e17a804b7fb3' and locale = 'en';
update question_translations set prompt = 'La principal presión ambiental sobre el Cerrado brasileño hoy es:', options = array['La expansión agropecuaria y la deforestación', 'La extracción selectiva de maderas nobles', 'La pesca depredadora en los ríos', 'El crecimiento de las ciudades costeras'], explanation = 'La conversión de la vegetación nativa en cultivos y pastizales es una de las principales causas de pérdida de hábitat en el Cerrado.'
 where question_id = 'd7b8c550-5827-40c2-a105-e17a804b7fb3' and locale = 'es';

-- geografia: duplicava a questão de População; passa a ser o conceito de urbanização
update questions set prompt = 'O aumento da proporção de pessoas que vivem em cidades, em relação à população total, caracteriza o processo de:', options = array['Urbanização', 'Êxodo urbano', 'Transumância', 'Nomadismo'], explanation = 'Urbanização é o aumento relativo da população urbana. No Brasil, esse processo se intensificou especialmente ao longo do século XX.'
 where id = '9c03caeb-3841-46ac-a0d4-50d17acf0111' and correct_index = 0;
update question_translations set prompt = 'An increase in the proportion of people living in cities relative to the total population characterizes the process of:', options = array['Urbanization', 'Urban exodus', 'Transhumance', 'Nomadism'], explanation = 'Urbanization is the relative increase in the urban population. In Brazil, this process intensified especially during the twentieth century.'
 where question_id = '9c03caeb-3841-46ac-a0d4-50d17acf0111' and locale = 'en';
update question_translations set prompt = 'El aumento de la proporción de personas que viven en ciudades respecto de la población total caracteriza el proceso de:', options = array['Urbanización', 'Éxodo urbano', 'Trashumancia', 'Nomadismo'], explanation = 'La urbanización es el aumento relativo de la población urbana. En Brasil, este proceso se intensificó especialmente a lo largo del siglo XX.'
 where question_id = '9c03caeb-3841-46ac-a0d4-50d17acf0111' and locale = 'es';

-- geografia: soja: ranking datado na safra 2025/26
update questions set prompt = 'Segundo as estimativas internacionais para a safra 2025/26, qual país aparece como o maior produtor mundial de soja?', options = array['Argentina', 'China', 'Brasil', 'Estados Unidos'], explanation = 'Nas estimativas do USDA para 2025/26, o Brasil permanece à frente dos Estados Unidos na produção mundial de soja.'
 where id = '885de2c7-bd27-49f8-970b-bf5eff2b9a06' and correct_index = 2;
update question_translations set prompt = 'According to international estimates for the 2025/26 crop year, which country appears as the world''s largest soybean producer?', options = array['Argentina', 'United States', 'Brazil', 'China'], explanation = 'In USDA estimates for 2025/26, Brazil remains ahead of the United States in global soybean production.'
 where question_id = '885de2c7-bd27-49f8-970b-bf5eff2b9a06' and locale = 'en';
update question_translations set prompt = 'Según las estimaciones internacionales para la campaña 2025/26, ¿qué país aparece como el mayor productor mundial de soja?', options = array['Argentina', 'China', 'Brasil', 'Estados Unidos'], explanation = 'En las estimaciones del USDA para 2025/26, Brasil se mantiene por delante de Estados Unidos en la producción mundial de soja.'
 where question_id = '885de2c7-bd27-49f8-970b-bf5eff2b9a06' and locale = 'es';

-- historia: "decretos-lei" é termo do Estado Novo, não do Governo Provisório
update questions set prompt = 'Durante o Governo Provisório, Vargas governou principalmente por meio de:', options = array['Decretos, acumulando os poderes Executivo e Legislativo', 'Um Congresso Nacional eleito e atuante', 'Um parlamento bicameral tradicional', 'Assembleias estaduais autônomas'], explanation = 'No Governo Provisório (1930–1934), Vargas governou de forma centralizada e legislou por decretos, enquanto o Congresso Nacional permaneceu dissolvido.'
 where id = '1c842470-82aa-4a6d-b82a-f84a4dd4bed6' and correct_index = 0;
update question_translations set prompt = 'During Brazil''s Provisional Government, Vargas governed mainly through:', options = array['Decrees, holding both executive and legislative power', 'An elected and active National Congress', 'A traditional bicameral parliament', 'Autonomous state assemblies'], explanation = 'During the Provisional Government (1930–1934), Vargas ruled in a centralized manner and legislated by decree while the National Congress remained dissolved.'
 where question_id = '1c842470-82aa-4a6d-b82a-f84a4dd4bed6' and locale = 'en';
update question_translations set prompt = 'Durante el Gobierno Provisional de Brasil, Vargas gobernó principalmente mediante:', options = array['Decretos, acumulando los poderes Ejecutivo y Legislativo', 'Un Congreso Nacional elegido y activo', 'Un parlamento bicameral tradicional', 'Asambleas estatales autónomas'], explanation = 'Durante el Gobierno Provisional (1930–1934), Vargas gobernó de forma centralizada y legisló por decretos mientras el Congreso Nacional permanecía disuelto.'
 where question_id = '1c842470-82aa-4a6d-b82a-f84a4dd4bed6' and locale = 'es';

-- ingles: Nova Zelândia: data exata do reconhecimento legal do inglês
update questions set prompt = 'Na Nova Zelândia, além do inglês, qual língua indígena tem status oficial?', options = array['Francês', 'Espanhol', 'Havaiano', 'Māori'], explanation = 'O te reo Māori é uma língua indígena oficial da Nova Zelândia. A Língua de Sinais da Nova Zelândia também é oficial; desde 7 de agosto de 2026, o inglês passou a ter reconhecimento legal expresso como língua oficial.'
 where id = '1dab01c8-2fa7-596b-965c-5736786c5644' and correct_index = 3;
update question_translations set prompt = 'In New Zealand, besides English, which Indigenous language has official status?', options = array['French', 'Spanish', 'Hawaiian', 'Māori'], explanation = 'Te reo Māori is an Indigenous official language of New Zealand. New Zealand Sign Language is also official; since August 7, 2026, English has had explicit statutory recognition as an official language as well.'
 where question_id = '1dab01c8-2fa7-596b-965c-5736786c5644' and locale = 'en';
update question_translations set prompt = 'En Nueva Zelanda, además del inglés, ¿qué lengua indígena tiene estatus oficial?', options = array['Francés', 'Español', 'Hawaiano', 'Māori'], explanation = 'El te reo Māori es una lengua indígena oficial de Nueva Zelanda. La lengua de señas de Nueva Zelanda también es oficial; desde el 7 de agosto de 2026, el inglés cuenta además con reconocimiento legal expreso como lengua oficial.'
 where question_id = '1dab01c8-2fa7-596b-965c-5736786c5644' and locale = 'es';

-- matematica: explicação mostra a substituição
update questions set prompt = 'Em uma função f(x) = 2x + 1, qual é o valor de f(3)?', options = array['7', '6', '5', '9'], explanation = 'Substituindo x = 3 em f(x) = 2x + 1: f(3) = 2 · 3 + 1 = 6 + 1 = 7.'
 where id = 'fec962e2-8821-4d6f-a043-2cdf4ff54457' and correct_index = 0;
update question_translations set prompt = 'For f(x) = 2x + 1, what is f(3)?', options = array['7', '6', '5', '9'], explanation = 'Substituting x = 3 into f(x) = 2x + 1: f(3) = 2 · 3 + 1 = 6 + 1 = 7.'
 where question_id = 'fec962e2-8821-4d6f-a043-2cdf4ff54457' and locale = 'en';
update question_translations set prompt = 'Para f(x) = 2x + 1, ¿cuál es el valor de f(3)?', options = array['7', '6', '5', '9'], explanation = 'Sustituyendo x = 3 en f(x) = 2x + 1: f(3) = 2 · 3 + 1 = 6 + 1 = 7.'
 where question_id = 'fec962e2-8821-4d6f-a043-2cdf4ff54457' and locale = 'es';

-- matematica: explicação mostra a equação
update questions set prompt = 'Em uma função f(x) = 3x, se f(x) = 15, qual é o valor de x?', options = array['5', '3', '45', '18'], explanation = 'Como f(x) = 3x e f(x) = 15, temos 3x = 15. Dividindo os dois lados por 3, obtemos x = 5.'
 where id = '0b22bb0a-bf5f-4e64-928a-b79603867892' and correct_index = 0;
update question_translations set prompt = 'For f(x) = 3x, if f(x) = 15, what is x?', options = array['5', '3', '45', '18'], explanation = 'Since f(x) = 3x and f(x) = 15, we have 3x = 15. Dividing both sides by 3 gives x = 5.'
 where question_id = '0b22bb0a-bf5f-4e64-928a-b79603867892' and locale = 'en';
update question_translations set prompt = 'Para f(x) = 3x, si f(x) = 15, ¿cuál es el valor de x?', options = array['5', '3', '45', '18'], explanation = 'Como f(x) = 3x y f(x) = 15, tenemos 3x = 15. Al dividir ambos lados entre 3, obtenemos x = 5.'
 where question_id = '0b22bb0a-bf5f-4e64-928a-b79603867892' and locale = 'es';

-- matematica: explicação mostra a potência
update questions set prompt = 'Qual é o resultado de 2³ (dois elevado ao cubo)?', options = array['8', '6', '9', '4'], explanation = 'Elevar 2 ao cubo significa multiplicar três fatores iguais a 2: 2³ = 2 · 2 · 2 = 8.'
 where id = '583aa689-59af-4b7b-965d-904bdbf501bb' and correct_index = 0;
update question_translations set prompt = 'What is 2³ (two cubed)?', options = array['8', '6', '9', '4'], explanation = 'Cubing 2 means multiplying three factors equal to 2: 2³ = 2 · 2 · 2 = 8.'
 where question_id = '583aa689-59af-4b7b-965d-904bdbf501bb' and locale = 'en';
update question_translations set prompt = '¿Cuál es el resultado de 2³ (dos al cubo)?', options = array['8', '6', '9', '4'], explanation = 'Elevar 2 al cubo significa multiplicar tres factores iguales a 2: 2³ = 2 · 2 · 2 = 8.'
 where question_id = '583aa689-59af-4b7b-965d-904bdbf501bb' and locale = 'es';

-- matematica: explicação mostra a regra da sequência
update questions set prompt = 'Na sequência 3, 6, 12, 24, ..., em que cada termo dobra o anterior, qual é o próximo número?', options = array['48', '36', '30', '42'], explanation = 'Cada termo é o dobro do anterior. Assim, depois de 24 vem 24 · 2 = 48.'
 where id = '7ac8f3e6-1de2-457a-88e6-202f85940adb' and correct_index = 0;
update question_translations set prompt = 'In the sequence 3, 6, 12, 24, ..., where each term doubles the previous one, what is the next number?', options = array['48', '36', '30', '42'], explanation = 'Each term is twice the previous one. Therefore, after 24 comes 24 · 2 = 48.'
 where question_id = '7ac8f3e6-1de2-457a-88e6-202f85940adb' and locale = 'en';
update question_translations set prompt = 'En la secuencia 3, 6, 12, 24, ..., en la que cada término duplica al anterior, ¿cuál es el siguiente número?', options = array['48', '36', '30', '42'], explanation = 'Cada término es el doble del anterior. Por tanto, después de 24 viene 24 · 2 = 48.'
 where question_id = '7ac8f3e6-1de2-457a-88e6-202f85940adb' and locale = 'es';

-- matematica: explicação mostra o desconto
update questions set prompt = 'Um produto custava R$ 50 e teve desconto de 20%. Qual é o novo preço?', options = array['R$ 40', 'R$ 45', 'R$ 30', 'R$ 35'], explanation = 'Um desconto de 20% significa pagar 80% do preço original: 50 · 0,80 = 40. Portanto, o novo preço é R$ 40.'
 where id = 'c7c9cc4d-e867-477d-934d-bc87d609bfbc' and correct_index = 0;
update question_translations set prompt = 'A product cost R$ 50 and received a 20% discount. What is the new price?', options = array['R$ 40', 'R$ 45', 'R$ 30', 'R$ 35'], explanation = 'A 20% discount means paying 80% of the original price: 50 · 0.80 = 40. Therefore, the new price is R$ 40.'
 where question_id = 'c7c9cc4d-e867-477d-934d-bc87d609bfbc' and locale = 'en';
update question_translations set prompt = 'Un producto costaba R$ 50 y recibió un descuento del 20%. ¿Cuál es el nuevo precio?', options = array['R$ 40', 'R$ 45', 'R$ 30', 'R$ 35'], explanation = 'Un descuento del 20% significa pagar el 80% del precio original: 50 · 0,80 = 40. Por tanto, el nuevo precio es R$ 40.'
 where question_id = 'c7c9cc4d-e867-477d-934d-bc87d609bfbc' and locale = 'es';
