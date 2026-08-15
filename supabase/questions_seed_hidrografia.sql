-- Principais rios do Brasil (19ff93e1-6e9b-4f31-a0d1-0c1501339130)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('19ff93e1-6e9b-4f31-a0d1-0c1501339130', 'Qual é o maior rio do Brasil em volume de água?',
  array['Rio Amazonas', 'Rio Paraná', 'Rio São Francisco', 'Rio Tocantins'], 0,
  'O Rio Amazonas é o maior rio do mundo em volume de água (vazão).', 1),
('19ff93e1-6e9b-4f31-a0d1-0c1501339130', 'Qual é o segundo maior rio brasileiro em extensão, um dos principais da bacia Platina?',
  array['Rio Paraná', 'Rio Tocantins', 'Rio Xingu', 'Rio Madeira'], 0,
  'O Rio Paraná é um dos grandes rios sul-americanos, essencial para a geração de energia elétrica.', 2),
('19ff93e1-6e9b-4f31-a0d1-0c1501339130', 'Qual rio corta o semiárido nordestino e é conhecido como "Rio da Integração Nacional"?',
  array['Rio São Francisco', 'Rio Parnaíba', 'Rio Jaguaribe', 'Rio Doce'], 0,
  'O São Francisco nasce em Minas Gerais e atravessa o sertão nordestino, sendo vital para a região.', 3),
('19ff93e1-6e9b-4f31-a0d1-0c1501339130', 'Em qual oceano deságua a maior parte dos grandes rios brasileiros?',
  array['Oceano Atlântico', 'Oceano Pacífico', 'Oceano Índico', 'Oceano Ártico'], 0,
  'A maioria dos rios brasileiros corre em direção ao litoral atlântico.', 4),
('19ff93e1-6e9b-4f31-a0d1-0c1501339130', 'Qual é considerado o maior afluente do Rio Amazonas em extensão?',
  array['Rio Madeira', 'Rio Negro', 'Rio Tapajós', 'Rio Xingu'], 0,
  'O Rio Madeira tem cerca de 3.315 km e banha Rondônia e Amazonas antes de encontrar o Amazonas.', 5);

-- Bacias hidrográficas brasileiras (d5cb9910-b35e-4b55-a2fd-f0a975e28c2a)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('d5cb9910-b35e-4b55-a2fd-f0a975e28c2a', 'Quantas grandes regiões hidrográficas o Brasil possui, segundo a divisão oficial da ANA?',
  array['12', '8', '5', '20'], 0,
  'A Divisão Hidrográfica Nacional, de 2003, organiza o país em 12 regiões hidrográficas.', 1),
('d5cb9910-b35e-4b55-a2fd-f0a975e28c2a', 'Qual é a maior bacia hidrográfica do Brasil e do mundo em extensão?',
  array['Bacia Amazônica', 'Bacia do Paraná', 'Bacia do São Francisco', 'Bacia do Tocantins-Araguaia'], 0,
  'A Bacia Amazônica cobre cerca de metade do território brasileiro.', 2),
('d5cb9910-b35e-4b55-a2fd-f0a975e28c2a', 'A Bacia do Paraná (Platina) é compartilhada pelo Brasil com quais outros países?',
  array['Argentina, Paraguai e Uruguai', 'Peru, Bolívia e Chile', 'Colômbia e Venezuela', 'Apenas com a Argentina'], 0,
  'A bacia Platina é uma das maiores do continente e reúne vários países sul-americanos.', 3),
('d5cb9910-b35e-4b55-a2fd-f0a975e28c2a', 'Qual bacia hidrográfica brasileira banha o semiárido nordestino e é fundamental para o abastecimento da região?',
  array['Bacia do São Francisco', 'Bacia do Paraguai', 'Bacia do Uruguai', 'Bacia do Atlântico Sul'], 0,
  'O Rio São Francisco é a principal fonte de água doce para boa parte do sertão.', 4),
('d5cb9910-b35e-4b55-a2fd-f0a975e28c2a', 'Qual é considerada a maior bacia hidrográfica localizada inteiramente em território brasileiro?',
  array['Bacia do Tocantins-Araguaia', 'Bacia Amazônica', 'Bacia do Paraná', 'Bacia do Paraguai'], 0,
  'Diferente da Amazônica e da Platina, que se estendem por outros países, a bacia Tocantins-Araguaia está toda dentro do Brasil.', 5);

-- Rio Amazonas e seus principais afluentes (fa2a77cc-acc8-4010-91b0-d3f600d7dab1)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('fa2a77cc-acc8-4010-91b0-d3f600d7dab1', 'Qual famoso fenômeno ocorre no encontro do Rio Negro com o Rio Solimões, perto de Manaus?',
  array['Encontro das Águas', 'Pororoca', 'Enchente Cíclica', 'Maré Negra'], 0,
  'As águas escuras do Negro e as barrentas do Solimões correm lado a lado por quilômetros sem se misturar totalmente.', 1),
('fa2a77cc-acc8-4010-91b0-d3f600d7dab1', 'O Rio Amazonas, no Brasil, é formado principalmente pela junção de quais dois rios?',
  array['Rio Solimões e Rio Negro', 'Rio Madeira e Rio Tapajós', 'Rio Xingu e Rio Tocantins', 'Rio Purus e Rio Juruá'], 0,
  'O rio passa a se chamar Amazonas a partir desse encontro, próximo a Manaus.', 2),
('fa2a77cc-acc8-4010-91b0-d3f600d7dab1', 'Qual é o maior afluente do Rio Amazonas em extensão?',
  array['Rio Madeira', 'Rio Negro', 'Rio Purus', 'Rio Juruá'], 0,
  'O Rio Madeira tem cerca de 3.315 km, banhando Rondônia e o Amazonas.', 3),
('fa2a77cc-acc8-4010-91b0-d3f600d7dab1', 'O Rio Negro recebe esse nome por causa de qual característica de suas águas?',
  array['A coloração escura, por matéria orgânica em decomposição', 'A poluição industrial', 'O sedimento vulcânico', 'A presença de minérios de ferro'], 0,
  'São as chamadas "águas pretas", típicas de rios que atravessam áreas de vegetação densa.', 4),
('fa2a77cc-acc8-4010-91b0-d3f600d7dab1', 'Qual afluente do Amazonas banha o estado do Pará e é conhecido pela usina de Belo Monte?',
  array['Rio Xingu', 'Rio Madeira', 'Rio Negro', 'Rio Tapajós'], 0,
  'A Usina de Belo Monte, uma das maiores do Brasil, está no Rio Xingu.', 5);

-- Rio Paraná e seus principais afluentes (32c25d44-9f51-4d08-9767-d15a6cb09f8b)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('32c25d44-9f51-4d08-9767-d15a6cb09f8b', 'O Rio Paraná nasce do encontro de quais dois rios, ambos originados em Minas Gerais?',
  array['Rio Grande e Rio Paranaíba', 'Rio Tietê e Rio Iguaçu', 'Rio Doce e Rio Grande', 'Rio Paraguai e Rio Uruguai'], 0,
  'O encontro ocorre na divisa entre São Paulo, Minas Gerais e Mato Grosso do Sul.', 1),
('32c25d44-9f51-4d08-9767-d15a6cb09f8b', 'Qual afluente do Rio Paraná é famoso por formar as Cataratas do Iguaçu?',
  array['Rio Iguaçu', 'Rio Tietê', 'Rio Paranapanema', 'Rio Ivinhema'], 0,
  'O Rio Iguaçu deságua no Paraná logo após formar uma das maiores quedas d’água do mundo.', 2),
('32c25d44-9f51-4d08-9767-d15a6cb09f8b', 'A Usina de Itaipu, no Rio Paraná, é uma parceria do Brasil com qual país?',
  array['Paraguai', 'Argentina', 'Uruguai', 'Bolívia'], 0,
  'Itaipu Binacional é administrada em conjunto por Brasil e Paraguai.', 3),
('32c25d44-9f51-4d08-9767-d15a6cb09f8b', 'O Rio Tietê, importante rio paulista, é afluente de qual grande rio?',
  array['Rio Paraná', 'Rio São Francisco', 'Rio Amazonas', 'Rio Doce'], 0,
  'O Tietê nasce perto do litoral de São Paulo e corre para o interior até encontrar o Paraná.', 4),
('32c25d44-9f51-4d08-9767-d15a6cb09f8b', 'Ao sair do Brasil, o Rio Paraná deságua, junto com o Rio Uruguai, em qual grande estuário?',
  array['Rio da Prata', 'Golfo de Darién', 'Delta do Orinoco', 'Baía de Guanabara'], 0,
  'O estuário do Rio da Prata fica entre Argentina e Uruguai.', 5);

-- Rio São Francisco e seus principais afluentes (f8a0db60-38ed-4512-89a3-addf95defa11)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('f8a0db60-38ed-4512-89a3-addf95defa11', 'O Rio São Francisco nasce em qual estado brasileiro?',
  array['Minas Gerais', 'Bahia', 'Pernambuco', 'Goiás'], 0,
  'Nasce na Serra da Canastra, em Minas Gerais.', 1),
('f8a0db60-38ed-4512-89a3-addf95defa11', 'Por que o Rio São Francisco é chamado de "Rio da Integração Nacional"?',
  array['Por atravessar e abastecer várias regiões e estados do semiárido nordestino', 'Por ser o único rio navegável do país', 'Por nascer em dois países diferentes', 'Por dividir o Brasil ao meio'], 0,
  'Ele conecta o Sudeste ao Nordeste, levando água a uma região marcada pela seca.', 2),
('f8a0db60-38ed-4512-89a3-addf95defa11', 'O Rio São Francisco deságua no Oceano Atlântico na divisa entre quais dois estados?',
  array['Alagoas e Sergipe', 'Bahia e Sergipe', 'Pernambuco e Alagoas', 'Sergipe e Pernambuco'], 0,
  'A foz do "Velho Chico" fica exatamente nessa divisa.', 3),
('f8a0db60-38ed-4512-89a3-addf95defa11', 'Hidrelétricas como Sobradinho e Xingó, construídas no Rio São Francisco, têm qual função principal?',
  array['Geração de energia elétrica', 'Irrigação exclusiva', 'Controle de enchentes apenas', 'Produção de água potável'], 0,
  'Essas usinas são importantes fontes de energia para o Nordeste.', 4),
('f8a0db60-38ed-4512-89a3-addf95defa11', 'Qual foi o principal objetivo do projeto de transposição do Rio São Francisco?',
  array['Levar água para áreas do semiárido nordestino com escassez hídrica', 'Aumentar a navegação internacional', 'Gerar mais energia elétrica', 'Reduzir o volume do rio'], 0,
  'O projeto desvia parte da água do rio para bacias que sofrem com a seca.', 5);

-- Rios da Região Norte (3d3fa6fe-b7fb-4e32-8fb7-bba2482fa0ab)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('3d3fa6fe-b7fb-4e32-8fb7-bba2482fa0ab', 'Qual é o principal rio da região Norte do Brasil?',
  array['Rio Amazonas', 'Rio Tocantins', 'Rio Negro', 'Rio Madeira'], 0,
  'O Amazonas é o eixo hidrográfico central de toda a região Norte.', 1),
('3d3fa6fe-b7fb-4e32-8fb7-bba2482fa0ab', 'Além do Amazonas, qual rio banha o Pará e abriga a usina hidrelétrica de Tucuruí?',
  array['Rio Tocantins', 'Rio Negro', 'Rio Madeira', 'Rio Purus'], 0,
  'Tucuruí é uma das maiores hidrelétricas inteiramente brasileiras.', 2),
('3d3fa6fe-b7fb-4e32-8fb7-bba2482fa0ab', 'O Rio Negro, um dos maiores afluentes do Amazonas, é conhecido pela coloração de suas águas, chamadas de?',
  array['Águas pretas', 'Águas brancas', 'Águas claras', 'Águas azuis'], 0,
  'A cor escura vem da matéria orgânica em decomposição na vegetação ao redor.', 3),
('3d3fa6fe-b7fb-4e32-8fb7-bba2482fa0ab', 'Qual estado da região Norte é banhado pelo Rio Madeira, importante via de navegação e energia?',
  array['Rondônia', 'Roraima', 'Acre', 'Amapá'], 0,
  'O Madeira atravessa Rondônia antes de encontrar o Amazonas.', 4),
('3d3fa6fe-b7fb-4e32-8fb7-bba2482fa0ab', 'Os rios da região Norte são especialmente importantes para qual meio de transporte, dada a densidade da floresta?',
  array['Transporte fluvial (hidroviário)', 'Transporte ferroviário', 'Transporte rodoviário', 'Transporte por dutos'], 0,
  'Em muitas áreas da Amazônia, os rios são a principal via de deslocamento.', 5);

-- Rios da Região Nordeste (2095a633-a9fa-4276-8a1b-2706f22380b7)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('2095a633-a9fa-4276-8a1b-2706f22380b7', 'Qual é o principal rio perene (que não seca) da região Nordeste?',
  array['Rio São Francisco', 'Rio Jaguaribe', 'Rio Parnaíba', 'Rio Paraguaçu'], 0,
  'Diferente de muitos rios do sertão, o São Francisco corre o ano todo.', 1),
('2095a633-a9fa-4276-8a1b-2706f22380b7', 'Muitos rios do sertão nordestino são classificados como intermitentes ou temporários porque?',
  array['Secam durante parte do ano devido à irregularidade das chuvas', 'Correm apenas no inverno europeu', 'São represados o ano todo', 'Nascem no litoral'], 0,
  'A irregularidade pluviométrica do clima semiárido é a principal causa.', 2),
('2095a633-a9fa-4276-8a1b-2706f22380b7', 'Qual é considerado o maior rio inteiramente localizado no estado do Ceará?',
  array['Rio Jaguaribe', 'Rio São Francisco', 'Rio Parnaíba', 'Rio Poti'], 0,
  'O Jaguaribe tem cerca de 633 km e é conhecido como um dos maiores rios temporários do mundo.', 3),
('2095a633-a9fa-4276-8a1b-2706f22380b7', 'O Rio São Francisco sustenta importantes polos agrícolas irrigados no Nordeste, como o de?',
  array['Petrolina (PE) e Juazeiro (BA)', 'Recife e Salvador', 'Fortaleza e Natal', 'São Luís e Teresina'], 0,
  'A região é hoje um dos maiores polos de fruticultura irrigada do Brasil.', 4),
('2095a633-a9fa-4276-8a1b-2706f22380b7', 'A escassez de rios perenes no interior do Nordeste está diretamente relacionada a qual característica climática?',
  array['Clima semiárido, com chuvas baixas e irregulares', 'Clima equatorial, com chuvas constantes', 'Clima subtropical, com geadas frequentes', 'Clima polar'], 0,
  'O clima semiárido é o principal responsável pela intermitência de muitos rios da região.', 5);

-- Rios da Região Centro-Oeste (d8d82add-d42c-4609-9e28-8160f20bf1a3)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('d8d82add-d42c-4609-9e28-8160f20bf1a3', 'Qual grande planície alagável do Centro-Oeste é formada pelo transbordamento sazonal de rios como o Paraguai?',
  array['Pantanal', 'Planície Amazônica', 'Depressão do Araguaia', 'Chapada dos Guimarães'], 0,
  'O Pantanal é a maior planície alagável do mundo.', 1),
('d8d82add-d42c-4609-9e28-8160f20bf1a3', 'O Rio Paraguai, importante para o Centro-Oeste, nasce em qual estado?',
  array['Mato Grosso', 'Mato Grosso do Sul', 'Goiás', 'Tocantins'], 0,
  'Suas nascentes ficam na região da Chapada dos Parecis, em Mato Grosso.', 2),
('d8d82add-d42c-4609-9e28-8160f20bf1a3', 'Por que o Centro-Oeste é chamado de "berço das águas" do Brasil?',
  array['Porque nele nascem rios que alimentam três das principais bacias hidrográficas do país', 'Porque concentra toda a água doce do Brasil', 'Porque não possui nenhum rio perene', 'Porque só existem lagos na região'], 0,
  'Rios que nascem no Centro-Oeste alimentam as bacias Amazônica, Platina e Tocantins-Araguaia.', 3),
('d8d82add-d42c-4609-9e28-8160f20bf1a3', 'O Rio Araguaia forma, junto com o Rio Javaés, qual famosa ilha, considerada a maior ilha fluvial do mundo?',
  array['Ilha do Bananal', 'Ilha de Marajó', 'Ilha do Combu', 'Ilha Grande'], 0,
  'A Ilha do Bananal, no Tocantins, tem cerca de 20 mil km² e é Reserva da Biosfera da UNESCO.', 4),
('d8d82add-d42c-4609-9e28-8160f20bf1a3', 'O Pantanal está localizado principalmente em quais estados brasileiros?',
  array['Mato Grosso e Mato Grosso do Sul', 'Goiás e Tocantins', 'Rondônia e Acre', 'Minas Gerais e Bahia'], 0,
  'O bioma se estende por esses dois estados, além de porções da Bolívia e do Paraguai.', 5);

-- Rios da Região Sudeste (8065021b-5ec4-4470-bc6b-a743898a5955)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('8065021b-5ec4-4470-bc6b-a743898a5955', 'Qual rio corta a cidade de São Paulo e é afluente do Rio Paraná?',
  array['Rio Tietê', 'Rio Doce', 'Rio Paraíba do Sul', 'Rio Grande'], 0,
  'O Tietê nasce perto do litoral paulista e corre para o interior do estado.', 1),
('8065021b-5ec4-4470-bc6b-a743898a5955', 'O Rio Paraíba do Sul banha quais estados do Sudeste?',
  array['São Paulo, Rio de Janeiro e Minas Gerais', 'Espírito Santo e Bahia', 'Apenas o Rio de Janeiro', 'Minas Gerais e Goiás'], 0,
  'É um dos rios mais importantes do eixo Rio–São Paulo.', 2),
('8065021b-5ec4-4470-bc6b-a743898a5955', 'O Rio Doce, atingido pelo rompimento de barragem em Mariana (2015), banha principalmente quais estados?',
  array['Minas Gerais e Espírito Santo', 'São Paulo e Rio de Janeiro', 'Bahia e Minas Gerais', 'Rio de Janeiro e Espírito Santo'], 0,
  'O desastre de Mariana afetou gravemente a bacia do Rio Doce até sua foz no Espírito Santo.', 3),
('8065021b-5ec4-4470-bc6b-a743898a5955', 'O Rio Tietê foi historicamente importante para São Paulo principalmente por servir de via de penetração para qual grupo?',
  array['Os bandeirantes, rumo ao interior do país', 'Os imigrantes europeus, ao chegar ao litoral', 'A frota naval portuguesa', 'Os exploradores espanhóis'], 0,
  'O rio foi um caminho natural para o interior durante o período colonial.', 4),
('8065021b-5ec4-4470-bc6b-a743898a5955', 'O Rio Grande, um dos formadores do Rio Paraná, nasce em qual serra, em Minas Gerais?',
  array['Serra da Mantiqueira', 'Serra do Mar', 'Serra da Canastra', 'Serra do Espinhaço'], 0,
  'Suas nascentes ficam na Serra da Mantiqueira, no sul de Minas Gerais.', 5);

-- Rios da Região Sul (39e51a80-1df3-4d6d-9652-a25f10b2424f)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('39e51a80-1df3-4d6d-9652-a25f10b2424f', 'Qual rio marca boa parte da fronteira entre o Brasil e a Argentina, na região Sul?',
  array['Rio Uruguai', 'Rio Jacuí', 'Rio Itajaí', 'Rio Iguaçu'], 0,
  'O Rio Uruguai nasce em Santa Catarina e serve de fronteira em grande parte de seu curso.', 1),
('39e51a80-1df3-4d6d-9652-a25f10b2424f', 'O Rio Iguaçu, famoso pelas cataratas, é afluente de qual grande rio?',
  array['Rio Paraná', 'Rio Uruguai', 'Rio Jacuí', 'Rio Ivaí'], 0,
  'O Iguaçu deságua no Paraná logo depois das quedas d’água.', 2),
('39e51a80-1df3-4d6d-9652-a25f10b2424f', 'O Rio Jacuí é um dos principais rios de qual estado?',
  array['Rio Grande do Sul', 'Santa Catarina', 'Paraná', 'Nenhum dos anteriores'], 0,
  'O Jacuí é o principal rio formador do Guaíba, em Porto Alegre.', 3),
('39e51a80-1df3-4d6d-9652-a25f10b2424f', 'O relevo em planaltos com bordas abruptas na região Sul favorece principalmente qual uso dos rios?',
  array['Geração de energia hidrelétrica', 'Navegação de grandes navios', 'Irrigação apenas', 'Nenhum uso relevante'], 0,
  'Os desníveis do terreno criam quedas d’água ideais para usinas hidrelétricas.', 4),
('39e51a80-1df3-4d6d-9652-a25f10b2424f', 'O Guaíba, que banha Porto Alegre, é formado principalmente pelo encontro de quais rios?',
  array['Jacuí, dos Sinos, Caí e Gravataí', 'Tietê, Pinheiros e Tamanduateí', 'Paraná, Iguaçu e Uruguai', 'Doce, Paraíba do Sul e Grande'], 0,
  'O Jacuí é o principal contribuinte, seguido por Sinos, Caí e Gravataí.', 5);

-- Principais hidrelétricas brasileiras (291853ce-ec62-4e00-baad-3bc93128bebe)
insert into questions (catalog_node_id, prompt, options, correct_index, explanation, order_index) values
('291853ce-ec62-4e00-baad-3bc93128bebe', 'Qual é uma das maiores usinas hidrelétricas do mundo, localizada no Rio Paraná?',
  array['Itaipu Binacional', 'Belo Monte', 'Tucuruí', 'Sobradinho'], 0,
  'Itaipu foi, por muitos anos, a maior hidrelétrica do mundo em geração de energia.', 1),
('291853ce-ec62-4e00-baad-3bc93128bebe', 'A Usina de Itaipu foi construída em parceria entre o Brasil e qual país?',
  array['Paraguai', 'Argentina', 'Uruguai', 'Bolívia'], 0,
  'A usina é administrada conjuntamente pelos dois países.', 2),
('291853ce-ec62-4e00-baad-3bc93128bebe', 'A Usina de Belo Monte, uma das maiores do Brasil, está localizada em qual rio, no Pará?',
  array['Rio Xingu', 'Rio Tocantins', 'Rio Madeira', 'Rio Tapajós'], 0,
  'Belo Monte é uma das hidrelétricas mais discutidas do país por seus impactos ambientais.', 3),
('291853ce-ec62-4e00-baad-3bc93128bebe', 'A hidrelétrica de Tucuruí, uma das maiores inteiramente brasileiras, está em qual rio?',
  array['Rio Tocantins', 'Rio Araguaia', 'Rio Xingu', 'Rio Negro'], 0,
  'Tucuruí, no Pará, foi a primeira grande hidrelétrica construída na Amazônia.', 4),
('291853ce-ec62-4e00-baad-3bc93128bebe', 'Qual é a principal fonte de geração de energia elétrica no Brasil?',
  array['Energia hidrelétrica', 'Energia nuclear', 'Energia a carvão', 'Energia eólica'], 0,
  'Apesar do crescimento da energia eólica e solar, as hidrelétricas ainda dominam a matriz elétrica brasileira.', 5);
