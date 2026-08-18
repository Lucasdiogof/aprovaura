-- Fisica — questoes DIFICEIS novas (raciocinio de varios passos).
-- difficulty='dificil'; order_index >= 11 para nao colidir com as existentes (1..8).
-- Alternativa correta em posicoes variadas (nao apenas A).

insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index, difficulty) values

-- Cinematica: Movimento uniforme
('8298e55f-972f-4aef-9447-bff9347da0b7',
 'Dois trens trafegam em sentidos opostos, um a 90 km/h e outro a 72 km/h, partindo simultaneamente de estacoes separadas por 810 km. Apos quanto tempo eles se cruzam?',
 array['4 h', '5 h', '6 h', '10 h'], 1,
 'Em aproximacao, as velocidades se somam: 90 + 72 = 162 km/h. t = 810 / 162 = 5 h.', 11, 'dificil'),

-- Cinematica: Queda livre
('95ca3ad3-5c40-4ccc-b0d0-0c54e2105207',
 'Um corpo abandonado em queda livre percorre 25 m durante o ultimo segundo antes de atingir o solo (g = 10 m/s2). De que altura ele caiu?',
 array['25 m', '30 m', '45 m', '20 m'], 2,
 'A distancia no ultimo segundo e 5(2t-1) = 25, logo 2t-1 = 5 e t = 3 s. Altura = 5 t2 = 5 x 9 = 45 m.', 11, 'dificil'),

-- Cinematica: MUV
('d8f64aef-8abc-45da-9e5d-501798c0d345',
 'Um carro a 20 m/s freia com desaceleracao constante e para apos percorrer 40 m. Qual e o modulo da desaceleracao?',
 array['2 m/s2', '5 m/s2', '8 m/s2', '10 m/s2'], 1,
 'Por Torricelli: 0 = 20^2 - 2a(40), entao 400 = 80a e a = 5 m/s2.', 11, 'dificil'),

-- Cinematica: Lancamento horizontal
('b6821cec-74b2-4da2-8026-8d821f82f15d',
 'Um objeto e lancado horizontalmente a 15 m/s do alto de uma plataforma de 20 m de altura (g = 10 m/s2). Qual e o alcance horizontal ate atingir o solo?',
 array['15 m', '20 m', '30 m', '45 m'], 2,
 'Tempo de queda: t = raiz(2h/g) = raiz(4) = 2 s. Alcance = v.t = 15 x 2 = 30 m.', 11, 'dificil'),

-- Cinematica: Lancamento obliquo
('92e52c60-4571-450a-99cc-e6e840caa2f8',
 'Um projetil e lancado a 20 m/s formando 30 graus com a horizontal (g = 10 m/s2, sen30 = 0,5). Qual e a altura maxima atingida?',
 array['2,5 m', '5 m', '10 m', '20 m'], 1,
 'Componente vertical: vy = 20 x 0,5 = 10 m/s. Altura maxima = vy^2 / (2g) = 100 / 20 = 5 m.', 11, 'dificil'),

-- Dinamica: Segunda Lei (sistema de blocos)
('9df1808d-9ac5-4809-8bdb-63e12480aa97',
 'Um bloco de 2 kg sobre uma mesa horizontal sem atrito e ligado por um fio, que passa por uma polia, a um bloco de 3 kg pendurado (g = 10 m/s2). Qual e a aceleracao do sistema?',
 array['5 m/s2', '6 m/s2', '10 m/s2', '15 m/s2'], 1,
 'A forca motriz e o peso do bloco pendurado: a = (m2.g)/(m1+m2) = 30/5 = 6 m/s2.', 11, 'dificil'),

-- Dinamica: Plano inclinado com atrito
('7e0cc321-55aa-4635-b067-8ab32d376084',
 'Um bloco desce um plano inclinado de 37 graus (sen37 = 0,6; cos37 = 0,8) com coeficiente de atrito cinetico 0,25 (g = 10 m/s2). Qual e a aceleracao do bloco?',
 array['2 m/s2', '3 m/s2', '4 m/s2', '6 m/s2'], 2,
 'a = g(sen - mu.cos) = 10(0,6 - 0,25 x 0,8) = 10(0,6 - 0,2) = 4 m/s2.', 11, 'dificil'),

-- Dinamica: Atrito
('fea10bb2-7f2f-40f8-baaf-e398343701aa',
 'Um bloco de 10 kg sobre superficie horizontal recebe uma forca horizontal de 40 N. O coeficiente de atrito cinetico e 0,3 (g = 10 m/s2). Qual e a aceleracao do bloco?',
 array['1 m/s2', '2 m/s2', '3 m/s2', '4 m/s2'], 0,
 'Normal = 100 N; atrito = 0,3 x 100 = 30 N; resultante = 40 - 30 = 10 N; a = 10/10 = 1 m/s2.', 11, 'dificil'),

-- Trabalho e energia: conservacao (rampa lisa)
('f394659b-6de0-4d60-a1bf-4935db2b35b5',
 'Um carrinho parte do repouso e desce uma rampa lisa a partir de uma altura de 3,2 m (g = 10 m/s2). Qual e sua velocidade ao chegar na base?',
 array['4 m/s', '6,4 m/s', '8 m/s', '16 m/s'], 2,
 'Conservacao de energia: v = raiz(2gh) = raiz(2 x 10 x 3,2) = raiz(64) = 8 m/s.', 11, 'dificil'),

-- Trabalho e energia: atrito dissipativo
('f394659b-6de0-4d60-a1bf-4935db2b35b5',
 'Um bloco de 2 kg lancado a 10 m/s sobre uma superficie horizontal para completamente apos deslizar 10 m (g = 10 m/s2). Qual e o coeficiente de atrito cinetico?',
 array['0,1', '0,25', '0,5', '1,0'], 2,
 'A energia cinetica e dissipada pelo atrito: (m.v^2)/2 = mu.m.g.d. Logo 100 = mu x 200, e mu = 0,5.', 12, 'dificil'),

-- Gravitacao: gravidade superficial
('e5d65d25-c4b5-40b9-8c2a-641f4c56e0bb',
 'Um planeta tem o dobro da massa da Terra e o mesmo raio. Comparada a gravidade na superficie da Terra, a gravidade na superficie desse planeta e:',
 array['a metade', 'igual', 'o dobro', 'o quadruplo'], 2,
 'g = G.M/R^2. Dobrando a massa com o mesmo raio, a gravidade superficial dobra.', 11, 'dificil'),

-- Gravitacao: Kepler
('e5d65d25-c4b5-40b9-8c2a-641f4c56e0bb',
 'Se o raio da orbita de um satelite ao redor da Terra for multiplicado por 4, seu periodo de revolucao passa a ser (Terceira Lei de Kepler):',
 array['2 vezes maior', '4 vezes maior', '8 vezes maior', '16 vezes maior'], 2,
 'Por Kepler, T^2 e proporcional a R^3. Com R x 4, T^2 x 64, entao T x 8.', 12, 'dificil'),

-- Eletricidade: resistores em paralelo
('89939da9-3bec-40f4-826d-514c063a9351',
 'Tres resistores identicos de 6 ohms sao associados em paralelo. Qual e a resistencia equivalente da associacao?',
 array['2 ohms', '6 ohms', '9 ohms', '18 ohms'], 0,
 'Para resistores iguais em paralelo, Req = R/n = 6/3 = 2 ohms.', 11, 'dificil'),

-- Eletricidade: consumo em kWh
('89939da9-3bec-40f4-826d-514c063a9351',
 'Um chuveiro de 4400 W e usado em media 0,5 hora por dia durante 30 dias. Qual e o consumo aproximado de energia no periodo?',
 array['6,6 kWh', '66 kWh', '132 kWh', '220 kWh'], 1,
 'Consumo = potencia x tempo = 4,4 kW x 0,5 h x 30 = 66 kWh.', 12, 'dificil'),

-- Eletricidade: serie
('89939da9-3bec-40f4-826d-514c063a9351',
 'Dois resistores de 10 ohms e 20 ohms sao ligados em serie a uma fonte de 30 V. Qual e a corrente que percorre o circuito?',
 array['0,5 A', '1 A', '1,5 A', '2 A'], 1,
 'Em serie, Req = 10 + 20 = 30 ohms. i = U/Req = 30/30 = 1 A.', 13, 'dificil'),

-- Termologia: calorimetria
('c11d5ba1-65e8-487a-96e0-38e15a64af15',
 'Que quantidade de calor e necessaria para aquecer 200 g de agua de 20 C ate 70 C? (calor especifico da agua = 1 cal/g.C)',
 array['2000 cal', '5000 cal', '10000 cal', '14000 cal'], 2,
 'Q = m.c.deltaT = 200 x 1 x 50 = 10000 cal.', 11, 'dificil'),

-- Termologia: rendimento de maquina termica
('c11d5ba1-65e8-487a-96e0-38e15a64af15',
 'Uma maquina termica recebe 800 J da fonte quente e rejeita 600 J para a fonte fria em cada ciclo. Qual e o seu rendimento?',
 array['20%', '25%', '33%', '75%'], 1,
 'Rendimento = 1 - Qfria/Qquente = 1 - 600/800 = 0,25, ou seja, 25%.', 12, 'dificil'),

-- Ondulatoria
('8f3b95a7-93f3-4d62-b383-d9b66d005f08',
 'Em uma corda, dois pontos consecutivos que oscilam em concordancia de fase estao separados por 0,4 m, e o periodo da onda e 0,1 s. Qual e a velocidade de propagacao?',
 array['0,04 m/s', '2 m/s', '4 m/s', '40 m/s'], 2,
 'A distancia entre pontos consecutivos em concordancia de fase e um comprimento de onda (0,4 m). v = lambda/T = 0,4/0,1 = 4 m/s.', 11, 'dificil'),

-- Fluidos: empuxo
('bf4b630c-1de1-4cdd-9cbf-f31c70007234',
 'Um cubo macico de 10 cm de aresta e totalmente imerso em agua (densidade 1000 kg/m3; g = 10 m/s2). Qual e o empuxo sobre o cubo?',
 array['0,1 N', '1 N', '10 N', '100 N'], 2,
 'Volume = (0,1)^3 = 0,001 m3. Empuxo = densidade x V x g = 1000 x 0,001 x 10 = 10 N.', 11, 'dificil'),

-- Optica: equacao de Gauss (espelho concavo)
('3d47f86a-ebcd-4a53-8742-71245315dc79',
 'Um objeto e colocado a 30 cm de um espelho concavo de distancia focal 10 cm. A que distancia do espelho se forma a imagem? (1/f = 1/p + 1/p'')',
 array['7,5 cm', '10 cm', '15 cm', '30 cm'], 2,
 '1/10 = 1/30 + 1/p''. Logo 1/p'' = 1/10 - 1/30 = 2/30, e p'' = 15 cm.', 11, 'dificil'),

-- Optica: espelho, objeto no centro de curvatura
('2e7f9326-dd6b-4cf9-820b-df10c38fef0c',
 'Um espelho concavo tem raio de curvatura de 40 cm. Um objeto colocado a 40 cm do espelho (sobre o centro de curvatura) forma uma imagem que e:',
 array['real, invertida e de mesmo tamanho', 'virtual e maior', 'real e menor', 'impropria, no infinito'], 0,
 'A distancia focal e R/2 = 20 cm. Com o objeto no centro de curvatura (2f), a imagem se forma tambem sobre C: real, invertida e do mesmo tamanho.', 11, 'dificil'),

-- Optica: aumento em lente convergente
('b124402a-4ae1-486c-abee-1db66cc184a6',
 'Um objeto e colocado a 40 cm de uma lente convergente de distancia focal 20 cm. A imagem formada e:',
 array['virtual e maior', 'real, de mesmo tamanho e invertida', 'real e 2 vezes maior', 'virtual e menor'], 1,
 '1/20 = 1/40 + 1/p'' leva a p'' = 40 cm. O aumento e -p''/p = -1, ou seja, imagem real, invertida e do mesmo tamanho do objeto.', 11, 'dificil');
