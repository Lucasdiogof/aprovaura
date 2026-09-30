-- Capitaliza a inicial das alternativas em prosa (2026-09-30)
--
-- Varias alternativas comecavam em minuscula ("a pesca industrial"),
-- o que destoa do resto do app. Ficam intactos os casos em que a
-- minuscula e correta: formula, variavel isolada, unidade, sigla de
-- segunda letra maiuscula (pH) e nomenclatura quimica.
--
-- Ingles e Espanhol ficaram de fora por inteiro: ali a alternativa
-- costuma ser a lacuna da frase, e maiuscula no meio dela seria erro.
--
-- Idempotente: rodar de novo escreve o mesmo valor.

update questions set options = array['Não mudou', 'Caiu 4%', 'Subiu 4%', 'Caiu 2%']
 where id = 'be3bbced-3173-5202-865b-03f5889a3c9e';
update question_translations set options = array['Did not change', 'Fell 4%', 'Rose 4%', 'Fell 2%']
 where question_id = 'be3bbced-3173-5202-865b-03f5889a3c9e' and locale = 'en';
update question_translations set options = array['No cambió', 'Bajó un 4 %', 'Subió un 4 %', 'Bajó un 2 %']
 where question_id = 'be3bbced-3173-5202-865b-03f5889a3c9e' and locale = 'es';

update questions set options = array['Pronome relativo', 'Conjunção integrante', 'Advérbio', 'Preposição']
 where id = '07150010-f793-5e51-a879-59ca73a56e67';
update question_translations set options = array['A relative pronoun', 'A complementizer (conjunção integrante)', 'An adverb', 'A preposition']
 where question_id = '07150010-f793-5e51-a879-59ca73a56e67' and locale = 'en';
update question_translations set options = array['Pronombre relativo', 'Conjunción completiva (conjunção integrante)', 'Adverbio', 'Preposición']
 where question_id = '07150010-f793-5e51-a879-59ca73a56e67' and locale = 'es';

update questions set options = array['Indeterminado', 'Oculto', 'Simples ("funcionários")', 'Inexistente']
 where id = '522037db-69b5-59d8-ba93-df39aa887d28';
update question_translations set options = array['Indeterminate', 'Implied (oculto)', 'Simple ("funcionários")', 'Nonexistent']
 where question_id = '522037db-69b5-59d8-ba93-df39aa887d28' and locale = 'en';
update question_translations set options = array['Indeterminado', 'Tácito (oculto)', 'Simple ("funcionários")', 'Inexistente']
 where question_id = '522037db-69b5-59d8-ba93-df39aa887d28' and locale = 'es';

update questions set options = array['Oculto', 'Indeterminado', 'Simples', 'Inexistente (oração sem sujeito)']
 where id = 'e6b2ea2c-4ded-54ba-aa8b-83e335e68d50';
update question_translations set options = array['Implied (oculto)', 'Indeterminate', 'Simple', 'Nonexistent (a subjectless clause)']
 where question_id = 'e6b2ea2c-4ded-54ba-aa8b-83e335e68d50' and locale = 'en';
update question_translations set options = array['Tácito (oculto)', 'Indeterminado', 'Simple', 'Inexistente (oración sin sujeto)']
 where question_id = 'e6b2ea2c-4ded-54ba-aa8b-83e335e68d50' and locale = 'es';

update questions set options = array['Idéia, heróico, vôo', 'Ideia, herói, vôo', 'Ideia, heroico, voo', 'Idéia, heroico, voo']
 where id = '9fe949dc-fd41-5588-81aa-23e693ae14fc';
update question_translations set options = array['Idéia, heróico, vôo', 'Ideia, herói, vôo', 'Ideia, heroico, voo', 'Idéia, heroico, voo']
 where question_id = '9fe949dc-fd41-5588-81aa-23e693ae14fc' and locale = 'en';
update question_translations set options = array['Idéia, heróico, vôo', 'Ideia, herói, vôo', 'Ideia, heroico, voo', 'Idéia, heroico, voo']
 where question_id = '9fe949dc-fd41-5588-81aa-23e693ae14fc' and locale = 'es';

update questions set options = array['Metáfora', 'Eufemismo', 'Metonímia', 'Catacrese']
 where id = '4ef9cc68-3121-5da8-af27-18192701a9e6';
update question_translations set options = array['Metaphor', 'Euphemism', 'Metonymy', 'Catachresis']
 where question_id = '4ef9cc68-3121-5da8-af27-18192701a9e6' and locale = 'en';
update question_translations set options = array['Metáfora', 'Eufemismo', 'Metonimia', 'Catacresis']
 where question_id = '4ef9cc68-3121-5da8-af27-18192701a9e6' and locale = 'es';

update questions set options = array['O domínio da norma-padrão da língua escrita', 'A compreensão da proposta e a aplicação de conceitos de várias áreas', 'O uso de mecanismos de coesão', 'A elaboração de proposta de intervenção que respeite os direitos humanos']
 where id = 'd69cb890-40f1-501f-afa5-284bd41125db';
update question_translations set options = array['Command of standard written Portuguese', 'Understanding of the prompt and use of concepts from different fields', 'The use of cohesive devices', 'An intervention proposal that respects human rights']
 where question_id = 'd69cb890-40f1-501f-afa5-284bd41125db' and locale = 'en';
update question_translations set options = array['El dominio de la norma culta del portugués escrito', 'La comprensión de la propuesta y el uso de conceptos de varias áreas', 'El uso de mecanismos de cohesión', 'La elaboración de una propuesta de intervención que respete los derechos humanos']
 where question_id = 'd69cb890-40f1-501f-afa5-284bd41125db' and locale = 'es';

update questions set options = array['As telas eliminaram o hábito da leitura', 'O hábito de ler diminuiu, mas o suporte continuou o mesmo', 'A leitura em papel é superior à leitura digital', 'O hábito de ler continua; mudou o meio em que se lê']
 where id = 'ab1bfe60-1b7e-5116-bc15-54b6ffccf83d';
update question_translations set options = array['Screens have eliminated the reading habit', 'The reading habit has declined, but the medium stayed the same', 'Reading on paper is better than reading on screens', 'The reading habit continues; what changed is the medium people read on']
 where question_id = 'ab1bfe60-1b7e-5116-bc15-54b6ffccf83d' and locale = 'en';
update question_translations set options = array['Las pantallas eliminaron el hábito de la lectura', 'El hábito de leer disminuyó, pero el soporte siguió siendo el mismo', 'La lectura en papel es superior a la lectura digital', 'El hábito de leer continúa; cambió el medio en el que se lee']
 where question_id = 'ab1bfe60-1b7e-5116-bc15-54b6ffccf83d' and locale = 'es';

update questions set options = array['A pesca industrial', 'A culinária de frutos do mar', 'Os efeitos do descarte de plástico na cadeia alimentar', 'A reciclagem de garrafas']
 where id = 'b68415f2-f35e-52d1-b261-3ef761721091';
update question_translations set options = array['Industrial fishing', 'Seafood cooking', 'The effects of plastic waste on the food chain', 'Bottle recycling']
 where question_id = 'b68415f2-f35e-52d1-b261-3ef761721091' and locale = 'en';
update question_translations set options = array['La pesca industrial', 'La cocina de mariscos', 'Los efectos del desecho de plástico en la cadena alimentaria', 'El reciclaje de botellas']
 where question_id = 'b68415f2-f35e-52d1-b261-3ef761721091' and locale = 'es';

update questions set options = array['Pedro tinha um guarda-chuva, mas não o abriu', 'Não estava chovendo quando Pedro saiu', 'Pedro comprou o guarda-chuva no caminho', 'O guarda-chuva pertencia a outra pessoa']
 where id = '08cb7802-9566-5550-9d62-56deda7d5bb3';
update question_translations set options = array['Pedro had an umbrella but did not open it', 'It was not raining when Pedro left', 'Pedro bought the umbrella on the way', 'The umbrella belonged to someone else']
 where question_id = '08cb7802-9566-5550-9d62-56deda7d5bb3' and locale = 'en';
update question_translations set options = array['Pedro tenía un paraguas, pero no lo abrió', 'No llovía cuando Pedro salió', 'Pedro compró el paraguas en el camino', 'El paraguas pertenecía a otra persona']
 where question_id = '08cb7802-9566-5550-9d62-56deda7d5bb3' and locale = 'es';

update questions set options = array['Informar dados científicos sobre energia solar', 'Narrar a experiência de um consumidor', 'Descrever o funcionamento de um painel', 'Persuadir o leitor a comprar o produto']
 where id = '0d2fccbc-2141-5c37-8a53-867b67037fe6';
update question_translations set options = array['Report scientific data on solar energy', 'Narrate a consumer''s experience', 'Describe how a panel works', 'Persuade the reader to buy the product']
 where question_id = '0d2fccbc-2141-5c37-8a53-867b67037fe6' and locale = 'en';
update question_translations set options = array['Informar datos científicos sobre la energía solar', 'Narrar la experiencia de un consumidor', 'Describir el funcionamiento de un panel', 'Persuadir al lector de comprar el producto']
 where question_id = '0d2fccbc-2141-5c37-8a53-867b67037fe6' and locale = 'es';

update questions set options = array['Exemplificação com uma experiência pessoal', 'Comparação entre dois países', 'Argumento de autoridade', 'Apelo emocional ao leitor']
 where id = '7e966574-fdbc-5139-ae32-893e90d86d92';
update question_translations set options = array['An example from personal experience', 'A comparison between two countries', 'An argument from authority', 'An emotional appeal to the reader']
 where question_id = '7e966574-fdbc-5139-ae32-893e90d86d92' and locale = 'en';
update question_translations set options = array['Un ejemplo de experiencia personal', 'Una comparación entre dos países', 'Un argumento de autoridad', 'Un llamado emocional al lector']
 where question_id = '7e966574-fdbc-5139-ae32-893e90d86d92' and locale = 'es';

update questions set options = array['Conclusão', 'Oposição (adversidade)', 'Explicação', 'Causa']
 where id = '7fde73b2-752e-5876-a352-52da57e4bf1e';
update question_translations set options = array['Conclusion', 'Contrast (opposition)', 'Explanation', 'Cause']
 where question_id = '7fde73b2-752e-5876-a352-52da57e4bf1e' and locale = 'en';
update question_translations set options = array['Conclusión', 'Oposición (adversidad)', 'Explicación', 'Causa']
 where question_id = '7fde73b2-752e-5876-a352-52da57e4bf1e' and locale = 'es';

update questions set options = array['Condenar à morte os cidadãos acusados de traição', 'Exilar temporariamente, por votação dos cidadãos, quem fosse considerado ameaça à democracia', 'Confiscar as terras da aristocracia', 'Impedir que estrangeiros participassem da assembleia']
 where id = '7947ef16-626a-5843-b991-57f9c287e6f9';
update question_translations set options = array['Sentencing citizens accused of treason to death', 'Temporarily exiling, by a vote of the citizens, anyone considered a threat to democracy', 'Confiscating the aristocracy''s land', 'Barring foreigners from the assembly']
 where question_id = '7947ef16-626a-5843-b991-57f9c287e6f9' and locale = 'en';
update question_translations set options = array['Condenar a muerte a los ciudadanos acusados de traición', 'Desterrar temporalmente, por votación de los ciudadanos, a quien se considerara una amenaza para la democracia', 'Confiscar las tierras de la aristocracia', 'Impedir que los extranjeros participaran en la asamblea']
 where question_id = '7947ef16-626a-5843-b991-57f9c287e6f9' and locale = 'es';

update questions set options = array['Paz de Vestfália', 'Concordata de Worms (1122)', 'Bula Unam Sanctam', 'Tratado de Verdun']
 where id = 'b1db9185-f0f3-5abd-b483-4769868c4880';
update question_translations set options = array['The Peace of Westphalia', 'The Concordat of Worms (1122)', 'The bull Unam Sanctam', 'The Treaty of Verdun']
 where question_id = 'b1db9185-f0f3-5abd-b483-4769868c4880' and locale = 'en';
update question_translations set options = array['La Paz de Westfalia', 'El Concordato de Worms (1122)', 'La bula Unam Sanctam', 'El Tratado de Verdún']
 where question_id = 'b1db9185-f0f3-5abd-b483-4769868c4880' and locale = 'es';

update questions set options = array['Do sistema de Estados soberanos na Europa', 'Da unificação italiana', 'Do início da Reforma Protestante', 'Da criação do Sacro Império']
 where id = '1112fdf5-f4c1-5875-a710-b6e69ae9487f';
update question_translations set options = array['The system of sovereign states in Europe', 'Italian unification', 'The start of the Protestant Reformation', 'The creation of the Holy Roman Empire']
 where question_id = '1112fdf5-f4c1-5875-a710-b6e69ae9487f' and locale = 'en';
update question_translations set options = array['Del sistema de Estados soberanos en Europa', 'De la unificación italiana', 'Del inicio de la Reforma protestante', 'De la creación del Sacro Imperio']
 where question_id = '1112fdf5-f4c1-5875-a710-b6e69ae9487f' and locale = 'es';

update questions set options = array['A OTAN', 'A ONU', 'O Pacto de Varsóvia', 'O Comecon']
 where id = '4b1b4018-615b-5649-995c-96b6191b982d';
update question_translations set options = array['NATO', 'The UN', 'The Warsaw Pact', 'Comecon']
 where question_id = '4b1b4018-615b-5649-995c-96b6191b982d' and locale = 'en';
update question_translations set options = array['La OTAN', 'La ONU', 'El Pacto de Varsovia', 'El Comecon']
 where question_id = '4b1b4018-615b-5649-995c-96b6191b982d' and locale = 'es';

update questions set options = array['A soberania popular e o sufrágio universal', 'A independência das colônias americanas', 'A restauração das dinastias depostas durante as guerras napoleônicas', 'A unificação imediata da Alemanha']
 where id = '9f3e9ad2-1d2d-515d-ab6e-fa4e5f3bc550';
update question_translations set options = array['Popular sovereignty and universal suffrage', 'The independence of the American colonies', 'The restoration of the dynasties deposed during the Napoleonic Wars', 'The immediate unification of Germany']
 where question_id = '9f3e9ad2-1d2d-515d-ab6e-fa4e5f3bc550' and locale = 'en';
update question_translations set options = array['La soberanía popular y el sufragio universal', 'La independencia de las colonias americanas', 'La restauración de las dinastías depuestas durante las guerras napoleónicas', 'La unificación inmediata de Alemania']
 where question_id = '9f3e9ad2-1d2d-515d-ab6e-fa4e5f3bc550' and locale = 'es';

update questions set options = array['Foi conduzida pela elite criolla, que manteve a escravidão', 'Foi concedida pacificamente pela Espanha', 'Deu origem a uma monarquia governada pela dinastia de Bragança', 'Resultou de uma revolta de escravizados, que aboliu a escravidão e criou um país governado por ex-escravizados']
 where id = 'add91609-47ba-5640-b64a-4d36c32d4968';
update question_translations set options = array['It was led by the Creole elite, who kept slavery', 'It was granted peacefully by Spain', 'It created a monarchy ruled by the House of Braganza', 'It resulted from a revolt of enslaved people, which abolished slavery and created a country governed by formerly enslaved people']
 where question_id = 'add91609-47ba-5640-b64a-4d36c32d4968' and locale = 'en';
update question_translations set options = array['Fue conducida por la élite criolla, que mantuvo la esclavitud', 'Fue concedida pacíficamente por España', 'Dio origen a una monarquía gobernada por la dinastía de Braganza', 'Resultó de una rebelión de esclavizados, que abolió la esclavitud y creó un país gobernado por antiguos esclavizados']
 where question_id = 'add91609-47ba-5640-b64a-4d36c32d4968' and locale = 'es';

update questions set options = array['Marcou a conversão do Mali ao cristianismo', 'Levou à fundação da cidade de Grande Zimbábue', 'A quantidade de ouro que ele distribuiu no caminho chegou a derrubar o valor do metal no Cairo', 'Deu início ao tráfico atlântico de escravizados']
 where id = '56df408d-d2ca-5939-ad59-9ac921a91999';
update question_translations set options = array['It marked Mali''s conversion to Christianity', 'It led to the founding of Great Zimbabwe', 'The amount of gold he gave away along the way lowered the value of the metal in Cairo', 'It started the Atlantic slave trade']
 where question_id = '56df408d-d2ca-5939-ad59-9ac921a91999' and locale = 'en';
update question_translations set options = array['Marcó la conversión de Malí al cristianismo', 'Llevó a la fundación de la ciudad del Gran Zimbabue', 'La cantidad de oro que repartió en el camino llegó a hacer caer el valor del metal en El Cairo', 'Dio inicio a la trata atlántica de esclavos']
 where question_id = '56df408d-d2ca-5939-ad59-9ac921a91999' and locale = 'es';

update questions set options = array['A entrega das aldeias ao controle dos jesuítas', 'A abolição imediata de todo trabalho indígena', 'A demarcação de terras indígenas pela Coroa', 'A obrigatoriedade da língua portuguesa e a proibição da língua geral nas aldeias']
 where id = 'd8728fc0-a3d2-58fa-86d7-78c3ef0fd2bd';
update question_translations set options = array['That the villages be handed over to Jesuit control', 'The immediate abolition of all Indigenous labor', 'The demarcation of Indigenous lands by the Crown', 'The mandatory use of Portuguese and a ban on the língua geral in the villages']
 where question_id = 'd8728fc0-a3d2-58fa-86d7-78c3ef0fd2bd' and locale = 'en';
update question_translations set options = array['La entrega de las aldeas al control de los jesuitas', 'La abolición inmediata de todo trabajo indígena', 'La demarcación de tierras indígenas por la Corona', 'La obligatoriedad de la lengua portuguesa y la prohibición de la lengua general en las aldeas']
 where question_id = 'd8728fc0-a3d2-58fa-86d7-78c3ef0fd2bd' and locale = 'es';

update questions set options = array['A terra pertenceria a quem de fato a ocupasse', 'Continuaria valendo a linha do Tratado de Tordesilhas', 'O papa arbitraria as disputas de fronteira', 'As terras indígenas seriam declaradas neutras']
 where id = '409dcfe0-8ee6-519e-8c48-a6b7e7fcd2c2';
update question_translations set options = array['Land would belong to whoever actually occupied it', 'The Treaty of Tordesillas line would remain in force', 'The Pope would settle border disputes', 'Indigenous lands would be declared neutral']
 where question_id = '409dcfe0-8ee6-519e-8c48-a6b7e7fcd2c2' and locale = 'en';
update question_translations set options = array['La tierra pertenecería a quien efectivamente la ocupara', 'Seguiría vigente la línea del Tratado de Tordesillas', 'El papa arbitraría las disputas fronterizas', 'Las tierras indígenas serían declaradas neutrales']
 where question_id = '409dcfe0-8ee6-519e-8c48-a6b7e7fcd2c2' and locale = 'es';

update questions set options = array['À coroação de D. Pedro I como imperador', 'Ao retorno de D. João VI a Portugal', 'À decisão de D. Pedro de permanecer no Brasil, contrariando as Cortes de Lisboa', 'Ao reconhecimento da independência por Portugal']
 where id = 'a093ad44-d1a4-5114-a098-0bd29673d1c4';
update question_translations set options = array['The coronation of Pedro I as emperor', 'João VI''s return to Portugal', 'Prince Pedro''s decision to stay in Brazil, defying the Cortes of Lisbon', 'Portugal''s recognition of independence']
 where question_id = 'a093ad44-d1a4-5114-a098-0bd29673d1c4' and locale = 'en';
update question_translations set options = array['A la coronación de Pedro I como emperador', 'Al regreso de Juan VI a Portugal', 'A la decisión del príncipe Pedro de permanecer en Brasil, desafiando a las Cortes de Lisboa', 'Al reconocimiento de la independencia por Portugal']
 where question_id = 'a093ad44-d1a4-5114-a098-0bd29673d1c4' and locale = 'es';

update questions set options = array['Distribuiu terras gratuitamente aos imigrantes europeus', 'Determinou que as terras devolutas só poderiam ser adquiridas por compra, dificultando o acesso dos pobres e dos futuros libertos', 'Aboliu o latifúndio e criou pequenas propriedades', 'Proibiu a venda de terras a estrangeiros']
 where id = '1a9b7a27-fe56-5489-8a02-5fb081732280';
update question_translations set options = array['It gave land free of charge to European immigrants', 'It determined that public (unclaimed) land could only be acquired by purchase, making access difficult for the poor and for those who would later be freed', 'It abolished large estates and created small farms', 'It banned the sale of land to foreigners']
 where question_id = '1a9b7a27-fe56-5489-8a02-5fb081732280' and locale = 'en';
update question_translations set options = array['Repartió tierras gratuitamente a los inmigrantes europeos', 'Determinó que las tierras baldías solo podían adquirirse mediante compra, lo que dificultaba el acceso de los pobres y de los futuros libertos', 'Abolió el latifundio y creó pequeñas propiedades', 'Prohibió la venta de tierras a extranjeros']
 where question_id = '1a9b7a27-fe56-5489-8a02-5fb081732280' and locale = 'es';

update questions set options = array['Um apoio mútuo: o governo federal favorecia as oligarquias estaduais, que em troca elegiam bancadas fiéis ao presidente', 'A eleição dos governadores pelo Congresso Nacional', 'Uma lei que obrigava a alternância entre São Paulo e Minas na Presidência', 'A intervenção federal permanente nos estados']
 where id = 'e2b82773-4616-5ce0-babb-519027f01ac5';
update question_translations set options = array['Mutual support: the federal government favored the state oligarchies, which in return elected delegations loyal to the president', 'The election of governors by the National Congress', 'A law requiring São Paulo and Minas Gerais to alternate in the presidency', 'Permanent federal intervention in the states']
 where question_id = 'e2b82773-4616-5ce0-babb-519027f01ac5' and locale = 'en';
update question_translations set options = array['Un apoyo mutuo: el gobierno federal favorecía a las oligarquías estatales, que a cambio elegían bancadas fieles al presidente', 'La elección de los gobernadores por el Congreso Nacional', 'Una ley que obligaba a la alternancia entre São Paulo y Minas en la Presidencia', 'La intervención federal permanente en los estados']
 where question_id = 'e2b82773-4616-5ce0-babb-519027f01ac5' and locale = 'es';

update questions set options = array['A reforma agrária e a nacionalização de empresas estrangeiras', 'Energia, transportes e indústria de base, com forte entrada de capital estrangeiro', 'A criação da Petrobras e o monopólio estatal do petróleo', 'O controle da inflação por meio de cortes de gastos']
 where id = '99276aa2-334d-5d65-b032-3c972172ef77';
update question_translations set options = array['Land reform and the nationalization of foreign companies', 'Energy, transportation and basic industry, with a large inflow of foreign capital', 'The creation of Petrobras and the state oil monopoly', 'Fighting inflation through spending cuts']
 where question_id = '99276aa2-334d-5d65-b032-3c972172ef77' and locale = 'en';
update question_translations set options = array['La reforma agraria y la nacionalización de empresas extranjeras', 'La energía, el transporte y la industria de base, con fuerte entrada de capital extranjero', 'La creación de Petrobras y el monopolio estatal del petróleo', 'El control de la inflación mediante recortes de gastos']
 where question_id = '99276aa2-334d-5d65-b032-3c972172ef77' and locale = 'es';

update questions set options = array['A criação do bipartidarismo (ARENA e MDB)', 'O restabelecimento das eleições diretas para presidente', 'A suspensão do habeas corpus nos casos de crimes políticos', 'A anistia aos exilados políticos']
 where id = 'a52dddea-3d92-566f-8be1-cd47cd0ee303';
update question_translations set options = array['The creation of the two-party system (ARENA and MDB)', 'The return of direct presidential elections', 'The suspension of habeas corpus in cases of political crimes', 'An amnesty for political exiles']
 where question_id = 'a52dddea-3d92-566f-8be1-cd47cd0ee303' and locale = 'en';
update question_translations set options = array['La creación del bipartidismo (ARENA y MDB)', 'El restablecimiento de las elecciones directas para presidente', 'La suspensión del habeas corpus en los casos de delitos políticos', 'La amnistía a los exiliados políticos']
 where question_id = 'a52dddea-3d92-566f-8be1-cd47cd0ee303' and locale = 'es';

update questions set options = array['Ampliar direitos sociais e individuais após o fim da ditadura', 'Instituir o parlamentarismo', 'Restabelecer a eleição indireta para presidente', 'Reduzir o papel do Estado na saúde e na educação']
 where id = '72281f63-4c5c-5ff5-b8e6-3bbd3c8fa2b9';
update question_translations set options = array['Expanded social and individual rights after the end of the dictatorship', 'Established a parliamentary system', 'Restored indirect presidential elections', 'Reduced the state''s role in health and education']
 where question_id = '72281f63-4c5c-5ff5-b8e6-3bbd3c8fa2b9' and locale = 'en';
update question_translations set options = array['Ampliar los derechos sociales e individuales tras el fin de la dictadura', 'Instituir el parlamentarismo', 'Restablecer la elección indirecta del presidente', 'Reducir el papel del Estado en la salud y la educación']
 where question_id = '72281f63-4c5c-5ff5-b8e6-3bbd3c8fa2b9' and locale = 'es';

update questions set options = array['A Revolta da Vacina', 'O assassinato de João Pessoa, candidato a vice-presidente na chapa de Getúlio Vargas', 'A morte de Washington Luís', 'A crise do Encilhamento']
 where id = '819d7d9d-e9ec-5940-bd49-a205a4e612c5';
update question_translations set options = array['The Vaccine Revolt', 'The assassination of João Pessoa, the vice-presidential candidate on Getúlio Vargas''s ticket', 'The death of Washington Luís', 'The Encilhamento financial crisis']
 where question_id = '819d7d9d-e9ec-5940-bd49-a205a4e612c5' and locale = 'en';
update question_translations set options = array['La Revuelta de la Vacuna', 'El asesinato de João Pessoa, candidato a vicepresidente en la fórmula de Getúlio Vargas', 'La muerte de Washington Luís', 'La crisis del Encilhamento']
 where question_id = '819d7d9d-e9ec-5940-bd49-a205a4e612c5' and locale = 'es';

update questions set options = array['Gaúcho que exigia a volta de Washington Luís à Presidência', 'Comunista liderado pela Aliança Nacional Libertadora', 'Integralista contra a Constituição de 1934', 'Paulista que exigia uma Assembleia Constituinte e o fim do Governo Provisório de Vargas']
 where id = '4f4daa34-f914-5418-96a8-bb8e9f329555';
update question_translations set options = array['From Rio Grande do Sul demanding Washington Luís''s return to the presidency', 'Led by communists of the National Liberation Alliance', 'Of Integralists against the 1934 Constitution', 'From São Paulo demanding a Constituent Assembly and an end to Vargas''s Provisional Government']
 where question_id = '4f4daa34-f914-5418-96a8-bb8e9f329555' and locale = 'en';
update question_translations set options = array['Gaúcho que exigía el regreso de Washington Luís a la Presidencia', 'Comunista liderado por la Alianza Nacional Libertadora', 'Integralista contra la Constitución de 1934', 'Paulista que exigía una Asamblea Constituyente y el fin del Gobierno Provisional de Vargas']
 where question_id = '4f4daa34-f914-5418-96a8-bb8e9f329555' and locale = 'es';

update questions set options = array['O voto censitário e o voto aberto', 'O sistema parlamentarista de governo', 'O voto secreto e o voto feminino, além de prever a criação da Justiça do Trabalho', 'O Poder Moderador']
 where id = 'd3f569ea-d733-5d25-bdc0-cc0a8c483d0e';
update question_translations set options = array['Income-based voting and open ballots', 'A parliamentary system of government', 'The secret ballot and women''s suffrage, and it provided for a Labor Court system', 'The Moderating Power']
 where question_id = 'd3f569ea-d733-5d25-bdc0-cc0a8c483d0e' and locale = 'en';
update question_translations set options = array['El voto censitario y el voto abierto', 'El sistema parlamentario de gobierno', 'El voto secreto y el voto femenino, además de prever la creación de la Justicia del Trabajo', 'El Poder Moderador']
 where question_id = 'd3f569ea-d733-5d25-bdc0-cc0a8c483d0e' and locale = 'es';

update questions set options = array['Foi redigida por imigrantes poloneses', 'Foi aprovada em plebiscito popular', 'Restabeleceu o federalismo da República Velha', 'Foi inspirada na Constituição autoritária da Polônia de 1935']
 where id = '35dcfadd-c0b2-5285-b1b3-ca55ed9782cd';
update question_translations set options = array['It was drafted by Polish immigrants', 'It was approved in a popular referendum', 'It restored the federalism of the Old Republic', 'It was inspired by Poland''s authoritarian Constitution of 1935']
 where question_id = '35dcfadd-c0b2-5285-b1b3-ca55ed9782cd' and locale = 'en';
update question_translations set options = array['Fue redactada por inmigrantes polacos', 'Fue aprobada en un plebiscito popular', 'Restableció el federalismo de la República Vieja', 'Se inspiró en la Constitución autoritaria de Polonia de 1935']
 where question_id = '35dcfadd-c0b2-5285-b1b3-ca55ed9782cd' and locale = 'es';

update questions set options = array['Os sindicatos dependiam do reconhecimento do Ministério do Trabalho e eram sustentados pelo imposto sindical', 'Os sindicatos eram proibidos e substituídos por conselhos de fábrica', 'As greves eram incentivadas pelo governo como forma de pressão', 'Os sindicatos eram subordinados à Igreja Católica']
 where id = '77788a8f-9b4a-5e3f-bdad-9f2342c2dfa9';
update question_translations set options = array['Unions depended on recognition by the Ministry of Labor and were funded by the mandatory union tax', 'Unions were banned and replaced by factory councils', 'The government encouraged strikes as a means of pressure', 'Unions were subordinated to the Catholic Church']
 where question_id = '77788a8f-9b4a-5e3f-bdad-9f2342c2dfa9' and locale = 'en';
update question_translations set options = array['Los sindicatos dependían del reconocimiento del Ministerio de Trabajo y se sostenían con el impuesto sindical', 'Los sindicatos estaban prohibidos y fueron sustituidos por consejos de fábrica', 'El gobierno incentivaba las huelgas como forma de presión', 'Los sindicatos estaban subordinados a la Iglesia católica']
 where question_id = '77788a8f-9b4a-5e3f-bdad-9f2342c2dfa9' and locale = 'es';

update questions set options = array['Censurar a imprensa e as artes e produzir a propaganda do regime, como o programa "A Hora do Brasil"', 'Organizar e financiar os sindicatos', 'Administrar a Companhia Siderúrgica Nacional', 'Fiscalizar as eleições estaduais']
 where id = '1d518a42-9c1a-5f48-907e-c0d2b3bdeda3';
update question_translations set options = array['Censoring the press and the arts and producing the regime''s propaganda, such as the radio program "A Hora do Brasil"', 'Organizing and funding trade unions', 'Running the National Steel Company (CSN)', 'Overseeing state elections']
 where question_id = '1d518a42-9c1a-5f48-907e-c0d2b3bdeda3' and locale = 'en';
update question_translations set options = array['Censurar la prensa y las artes y producir la propaganda del régimen, como el programa "A Hora do Brasil"', 'Organizar y financiar los sindicatos', 'Administrar la Compañía Siderúrgica Nacional', 'Fiscalizar las elecciones estatales']
 where question_id = '1d518a42-9c1a-5f48-907e-c0d2b3bdeda3' and locale = 'es';

update question_translations set options = array['The Brazilian Integralist Action (AIB)', 'The National Democratic Union (UDN)', 'The Social Democratic Party (PSD)', 'The National Liberation Alliance (ANL), with Luís Carlos Prestes']
 where question_id = '8ffe29e3-415f-5853-a914-4ef89a025d35' and locale = 'en';
update question_translations set options = array['La Acción Integralista Brasileña (AIB)', 'La Unión Democrática Nacional (UDN)', 'El Partido Social Democrático (PSD)', 'La Alianza Nacional Libertadora (ANL), con Luís Carlos Prestes']
 where question_id = '8ffe29e3-415f-5853-a914-4ef89a025d35' and locale = 'es';

update questions set options = array['Defender a revolução proletária e a reforma agrária radical', 'Pregar o liberalismo econômico e o federalismo', 'Um ideário nacionalista, autoritário e anticomunista, inspirado no fascismo, com o lema "Deus, Pátria e Família"', 'Apoiar a restauração da monarquia']
 where id = '19623bdc-8211-5c84-84d3-29723eed44d6';
update question_translations set options = array['Advocating proletarian revolution and radical land reform', 'Preaching economic liberalism and federalism', 'A nationalist, authoritarian and anti-communist ideology, inspired by fascism, with the motto "God, Fatherland and Family"', 'Supporting the restoration of the monarchy']
 where question_id = '19623bdc-8211-5c84-84d3-29723eed44d6' and locale = 'en';
update question_translations set options = array['Defender la revolución proletaria y la reforma agraria radical', 'Predicar el liberalismo económico y el federalismo', 'Un ideario nacionalista, autoritario y anticomunista, inspirado en el fascismo, con el lema "Dios, Patria y Familia"', 'Apoyar la restauración de la monarquía']
 where question_id = '19623bdc-8211-5c84-84d3-29723eed44d6' and locale = 'es';

update questions set options = array['A vitória do Integralismo nas eleições de 1945', 'A contradição de o Brasil lutar contra regimes autoritários na Segunda Guerra enquanto vivia uma ditadura', 'A Revolução Constitucionalista de São Paulo', 'A renúncia de Vargas para assumir um cargo na ONU']
 where id = 'b9704caa-d2fe-5b95-843b-445f06378091';
update question_translations set options = array['The victory of Integralism in the 1945 elections', 'The contradiction of Brazil fighting authoritarian regimes in World War II while living under a dictatorship', 'The Constitutionalist Revolution in São Paulo', 'Vargas''s resignation to take up a post at the UN']
 where question_id = 'b9704caa-d2fe-5b95-843b-445f06378091' and locale = 'en';
update question_translations set options = array['La victoria del Integralismo en las elecciones de 1945', 'La contradicción de que Brasil combatiera regímenes autoritarios en la Segunda Guerra Mundial mientras vivía una dictadura', 'La Revolución Constitucionalista de São Paulo', 'La renuncia de Vargas para asumir un cargo en la ONU']
 where question_id = 'b9704caa-d2fe-5b95-843b-445f06378091' and locale = 'es';

update questions set options = array['Que atrai o ímã, criando um polo sul na face voltada para ele', 'Nula, porque o ímã não toca a espira', 'Que se opõe à aproximação, criando um polo norte na face voltada para o ímã', 'Contínua, que permanece mesmo com o ímã parado']
 where id = '4e6945f2-e6ad-5c4f-a154-2a6164caee66';
update question_translations set options = array['Attracts the magnet, creating a south pole on the face turned toward it', 'Is zero, because the magnet does not touch the loop', 'Opposes the approach, creating a north pole on the face turned toward the magnet', 'Is continuous and remains even when the magnet stops']
 where question_id = '4e6945f2-e6ad-5c4f-a154-2a6164caee66' and locale = 'en';
update question_translations set options = array['Que atrae al imán, creando un polo sur en la cara orientada hacia él', 'Nula, porque el imán no toca la espira', 'Que se opone al acercamiento, creando un polo norte en la cara orientada hacia el imán', 'Continua, que permanece incluso con el imán quieto']
 where question_id = '4e6945f2-e6ad-5c4f-a154-2a6164caee66' and locale = 'es';

update questions set options = array['Zero', '4 × 10⁻³ N', '4 × 10⁻⁶ N', '1 × 10⁻² N']
 where id = 'bb068afe-44f1-5d11-9327-2bfcd56eb829';
update question_translations set options = array['Zero', '4 × 10⁻³ N', '4 × 10⁻⁶ N', '1 × 10⁻² N']
 where question_id = 'bb068afe-44f1-5d11-9327-2bfcd56eb829' and locale = 'en';
update question_translations set options = array['Cero', '4 × 10⁻³ N', '4 × 10⁻⁶ N', '1 × 10⁻² N']
 where question_id = 'bb068afe-44f1-5d11-9327-2bfcd56eb829' and locale = 'es';

update questions set options = array['Aumenta a energia cinética dos elétrons emitidos', 'Faz os elétrons serem emitidos após algum tempo', 'Não provoca emissão de elétrons', 'Diminui a função trabalho do metal']
 where id = '94a5a983-6cea-5b31-be3a-4b23a9b4f98a';
update question_translations set options = array['Increases the kinetic energy of the emitted electrons', 'Makes electrons come out after some time', 'Causes no emission of electrons', 'Lowers the metal''s work function']
 where question_id = '94a5a983-6cea-5b31-be3a-4b23a9b4f98a' and locale = 'en';
update question_translations set options = array['Aumenta la energía cinética de los electrones emitidos', 'Hace que los electrones se emitan después de un tiempo', 'No provoca emisión de electrones', 'Disminuye la función de trabajo del metal']
 where question_id = '94a5a983-6cea-5b31-be3a-4b23a9b4f98a' and locale = 'es';

update questions set options = array['Uma força para frente passa a agir sobre os passageiros', 'A gravidade aumenta durante a frenagem', 'Os passageiros tendem a manter o estado de movimento que tinham, por inércia', 'O atrito com o piso empurra os passageiros para frente']
 where id = '883c4484-d50b-5f0b-bfc9-6bba996c4dd6';
update question_translations set options = array['A forward force starts acting on the passengers', 'Gravity increases during braking', 'The passengers tend to keep the state of motion they had, due to inertia', 'Friction with the floor pushes the passengers forward']
 where question_id = '883c4484-d50b-5f0b-bfc9-6bba996c4dd6' and locale = 'en';
update question_translations set options = array['Una fuerza hacia adelante comienza a actuar sobre los pasajeros', 'La gravedad aumenta durante el frenado', 'Los pasajeros tienden a mantener el estado de movimiento que tenían, por inercia', 'El rozamiento con el piso empuja a los pasajeros hacia adelante']
 where question_id = '883c4484-d50b-5f0b-bfc9-6bba996c4dd6' and locale = 'es';

update questions set options = array['A força do cavalo é um pouco maior que a da carroça', 'As forças do par ação-reação agem em corpos diferentes; o que acelera o conjunto é o atrito do chão sobre as patas do cavalo', 'Ação e reação se anulam, e o conjunto se move por inércia', 'A reação só surge depois que a carroça já está em movimento']
 where id = '368838dc-0690-55b6-b79f-c58e891e29b1';
update question_translations set options = array['The horse''s force is slightly greater than the cart''s', 'The action-reaction forces act on different bodies; what accelerates the pair is the friction of the ground on the horse''s hooves', 'Action and reaction cancel out, and the pair moves by inertia', 'The reaction only appears after the cart is already moving']
 where question_id = '368838dc-0690-55b6-b79f-c58e891e29b1' and locale = 'en';
update question_translations set options = array['La fuerza del caballo es un poco mayor que la de la carreta', 'Las fuerzas del par acción-reacción actúan sobre cuerpos distintos; lo que acelera al conjunto es el rozamiento del suelo sobre las patas del caballo', 'Acción y reacción se anulan, y el conjunto se mueve por inercia', 'La reacción solo aparece cuando la carreta ya está en movimiento']
 where question_id = '368838dc-0690-55b6-b79f-c58e891e29b1' and locale = 'es';

update questions set options = array['Reais e invertidas', 'Virtuais e maiores que o objeto', 'Reais e do mesmo tamanho do objeto', 'Virtuais, direitas e menores, o que amplia o campo visual']
 where id = '3ef04855-8eec-5381-9209-4021c9929643';
update question_translations set options = array['Real and inverted', 'Virtual and larger than the object', 'Real and the same size as the object', 'Virtual, upright and smaller, which widens the field of view']
 where question_id = '3ef04855-8eec-5381-9209-4021c9929643' and locale = 'en';
update question_translations set options = array['Reales e invertidas', 'Virtuales y mayores que el objeto', 'Reales y del mismo tamaño que el objeto', 'Virtuales, derechas y menores, lo que amplía el campo visual']
 where question_id = '3ef04855-8eec-5381-9209-4021c9929643' and locale = 'es';

update questions set options = array['Real, a 40 cm do espelho', 'Imprópria (formada no infinito)', 'Virtual, a 20 cm do espelho', 'Real e do mesmo tamanho, a 20 cm do espelho']
 where id = '92f35e22-ee5d-54d9-974c-b658aeae3345';
update question_translations set options = array['Real, 40 cm from the mirror', 'At infinity (no image forms at a finite distance)', 'Virtual, 20 cm from the mirror', 'Real and the same size, 20 cm from the mirror']
 where question_id = '92f35e22-ee5d-54d9-974c-b658aeae3345' and locale = 'en';
update question_translations set options = array['Real, a 40 cm del espejo', 'Impropia (formada en el infinito)', 'Virtual, a 20 cm del espejo', 'Real y del mismo tamaño, a 20 cm del espejo']
 where question_id = '92f35e22-ee5d-54d9-974c-b658aeae3345' and locale = 'es';

update questions set options = array['Paralelo ao eixo principal', 'Sobre si mesmo', 'Passando pelo foco', 'Simétrico em relação ao eixo principal']
 where id = 'f3182876-df2a-5fff-a8b6-5c9703020a74';
update question_translations set options = array['Parallel to the principal axis', 'Back along its own path', 'Through the focal point', 'Symmetrically about the principal axis']
 where question_id = 'f3182876-df2a-5fff-a8b6-5c9703020a74' and locale = 'en';
update question_translations set options = array['Paralelo al eje principal', 'Sobre sí mismo', 'Pasando por el foco', 'Simétrico respecto al eje principal']
 where question_id = 'f3182876-df2a-5fff-a8b6-5c9703020a74' and locale = 'es';

update questions set options = array['(base × altura) / 2', 'Base × altura', 'Base + altura', '2 × base × altura']
 where id = 'e491e7ac-bbc0-49eb-a6a5-3b8b6db732dc';
update question_translations set options = array['(base × height) / 2', 'Base × height', 'Base + height', '2 × base × height']
 where question_id = 'e491e7ac-bbc0-49eb-a6a5-3b8b6db732dc' and locale = 'en';
update question_translations set options = array['(base × altura) / 2', 'Base × altura', 'Base + altura', '2 × base × altura']
 where question_id = 'e491e7ac-bbc0-49eb-a6a5-3b8b6db732dc' and locale = 'es';

update questions set options = array['Comprimento × largura × altura', 'Comprimento + largura + altura', '2 × (comprimento × largura)', 'comprimento²']
 where id = '772ef0be-b676-4efc-8777-a09d5743339e';
update question_translations set options = array['Length × width × height', 'Length + width + height', '2 × (length × width)', 'length²']
 where question_id = '772ef0be-b676-4efc-8777-a09d5743339e' and locale = 'en';
update question_translations set options = array['Largo × ancho × alto', 'Largo + ancho + alto', '2 × (largo × ancho)', 'largo²']
 where question_id = '772ef0be-b676-4efc-8777-a09d5743339e' and locale = 'es';

update questions set options = array['Real, invertida, a 10 cm da lente', 'Virtual, do mesmo tamanho, a 20 cm da lente', 'Imprópria', 'Virtual, direita, a 10 cm da lente e com metade do tamanho do objeto']
 where id = '609ba28d-28f3-5281-b8a2-966f5eb06dd9';
update question_translations set options = array['Real, inverted, 10 cm from the lens', 'Virtual, the same size, 20 cm from the lens', 'At infinity', 'Virtual, upright, 10 cm from the lens and half the size of the object']
 where question_id = '609ba28d-28f3-5281-b8a2-966f5eb06dd9' and locale = 'en';
update question_translations set options = array['Real, invertida, a 10 cm de la lente', 'Virtual, del mismo tamaño, a 20 cm de la lente', 'Impropia', 'Virtual, derecha, a 10 cm de la lente y con la mitad del tamaño del objeto']
 where question_id = '609ba28d-28f3-5281-b8a2-966f5eb06dd9' and locale = 'es';

update questions set options = array['Perda da capacidade de acomodação do cristalino com a idade', 'Alongamento do globo ocular', 'Curvatura irregular da córnea', 'Opacificação do cristalino']
 where id = 'dcfaa5f8-44ba-56f4-9a5f-34f3c855d2c1';
update question_translations set options = array['The lens losing its ability to accommodate with age', 'Elongation of the eyeball', 'Irregular curvature of the cornea', 'Clouding of the lens']
 where question_id = 'dcfaa5f8-44ba-56f4-9a5f-34f3c855d2c1' and locale = 'en';
update question_translations set options = array['La pérdida de la capacidad de acomodación del cristalino con la edad', 'El alargamiento del globo ocular', 'La curvatura irregular de la córnea', 'La opacificación del cristalino']
 where question_id = 'dcfaa5f8-44ba-56f4-9a5f-34f3c855d2c1' and locale = 'es';

update questions set options = array['Gás carbônico (CO₂), apenas', 'Clorofluorcarbonetos (CFCs)', 'Óxidos de enxofre e de nitrogênio, que formam H₂SO₄ e HNO₃ na atmosfera', 'Metano (CH₄)']
 where id = '3885b88b-a71e-53fb-94d6-14df63d08812';
update question_translations set options = array['Carbon dioxide (CO₂) alone', 'Chlorofluorocarbons (CFCs)', 'Sulfur and nitrogen oxides, which form H₂SO₄ and HNO₃ in the atmosphere', 'Methane (CH₄)']
 where question_id = '3885b88b-a71e-53fb-94d6-14df63d08812' and locale = 'en';
update question_translations set options = array['Dióxido de carbono (CO₂), únicamente', 'Clorofluorocarbonos (CFC)', 'Óxidos de azufre y de nitrógeno, que forman H₂SO₄ y HNO₃ en la atmósfera', 'Metano (CH₄)']
 where question_id = '3885b88b-a71e-53fb-94d6-14df63d08812' and locale = 'es';

update questions set options = array['Os elétrons têm carga positiva', 'A carga positiva e quase toda a massa do átomo se concentram num núcleo muito pequeno', 'O átomo é maciço e indivisível', 'Os elétrons giram em órbitas de energia quantizada']
 where id = 'd1efe2d1-9537-5613-968e-0821103849f6';
update question_translations set options = array['Electrons have a positive charge', 'The positive charge and nearly all of the atom''s mass are concentrated in a very small nucleus', 'The atom is solid and indivisible', 'Electrons move in orbits of quantized energy']
 where question_id = 'd1efe2d1-9537-5613-968e-0821103849f6' and locale = 'en';
update question_translations set options = array['Los electrones tienen carga positiva', 'La carga positiva y casi toda la masa del átomo se concentran en un núcleo muy pequeño', 'El átomo es macizo e indivisible', 'Los electrones giran en órbitas de energía cuantizada']
 where question_id = 'd1efe2d1-9537-5613-968e-0821103849f6' and locale = 'es';

update questions set options = array['Um elétron passa de um nível de maior energia para um de menor energia, liberando um fóton de energia bem definida', 'Um elétron absorve energia e sobe de nível', 'O núcleo se desintegra', 'Um elétron colide com o núcleo']
 where id = '0cf90330-9cdf-5c82-a281-314e6dbbd844';
update question_translations set options = array['An electron moves from a higher-energy level to a lower-energy level, releasing a photon of well-defined energy', 'An electron absorbs energy and moves up a level', 'The nucleus disintegrates', 'An electron collides with the nucleus']
 where question_id = '0cf90330-9cdf-5c82-a281-314e6dbbd844' and locale = 'en';
update question_translations set options = array['Un electrón pasa de un nivel de mayor energía a uno de menor energía, liberando un fotón de energía bien definida', 'Un electrón absorbe energía y sube de nivel', 'El núcleo se desintegra', 'Un electrón choca con el núcleo']
 where question_id = '0cf90330-9cdf-5c82-a281-314e6dbbd844' and locale = 'es';

update questions set options = array['Grupo 17 (halogênios), 4º período', 'Grupo 15, 4º período', 'Grupo 7, 5º período', 'Grupo 17 (halogênios), 5º período']
 where id = '8ac673f1-8b23-5c62-a8d9-1c504ceedfae';
update question_translations set options = array['Group 17 (halogens), period 4', 'Group 15, period 4', 'Group 7, period 5', 'Group 17 (halogens), period 5']
 where question_id = '8ac673f1-8b23-5c62-a8d9-1c504ceedfae' and locale = 'en';
update question_translations set options = array['Grupo 17 (halógenos), 4.º período', 'Grupo 15, 4.º período', 'Grupo 7, 5.º período', 'Grupo 17 (halógenos), 5.º período']
 where question_id = '8ac673f1-8b23-5c62-a8d9-1c504ceedfae' and locale = 'es';

update questions set options = array['Óxido do metal e gás oxigênio', 'Hidróxido do metal e gás hidrogênio', 'Um sal e água', 'Hidreto do metal e gás oxigênio']
 where id = '39d823f6-ded7-54a6-bd73-8049546d04e7';
update question_translations set options = array['The metal oxide and oxygen gas', 'The metal hydroxide and hydrogen gas', 'A salt and water', 'The metal hydride and oxygen gas']
 where question_id = '39d823f6-ded7-54a6-bd73-8049546d04e7' and locale = 'en';
update question_translations set options = array['Óxido del metal y oxígeno gaseoso', 'Hidróxido del metal e hidrógeno gaseoso', 'Una sal y agua', 'Hidruro del metal y oxígeno gaseoso']
 where question_id = '39d823f6-ded7-54a6-bd73-8049546d04e7' and locale = 'es';

update questions set options = array['Aberta, insaturada, heterogênea e normal', 'Fechada, saturada e homogênea', 'Aberta, saturada, heterogênea e ramificada', 'Aberta, insaturada, homogênea e normal']
 where id = '286733f6-663c-525e-b2df-3f118fe35e8a';
update question_translations set options = array['Open, unsaturated, heterogeneous and unbranched', 'Closed, saturated and homogeneous', 'Open, saturated, heterogeneous and branched', 'Open, unsaturated, homogeneous and unbranched']
 where question_id = '286733f6-663c-525e-b2df-3f118fe35e8a' and locale = 'en';
update question_translations set options = array['Abierta, insaturada, heterogénea y normal', 'Cerrada, saturada y homogénea', 'Abierta, saturada, heterogénea y ramificada', 'Abierta, insaturada, homogénea y normal']
 where question_id = '286733f6-663c-525e-b2df-3f118fe35e8a' and locale = 'es';

update questions set options = array['Pentano', '3-metilbutano', '2-metilbutano', '2-metilpropano']
 where id = '7b378b4f-1bfd-5b0a-b677-43c4c6009312';
update question_translations set options = array['Pentane', '3-methylbutane', '2-methylbutane', '2-methylpropane']
 where question_id = '7b378b4f-1bfd-5b0a-b677-43c4c6009312' and locale = 'en';
update question_translations set options = array['Pentano', '3-metilbutano', '2-metilbutano', '2-metilpropano']
 where question_id = '7b378b4f-1bfd-5b0a-b677-43c4c6009312' and locale = 'es';

update questions set options = array['but-1-eno', 'Propeno', '2-metilpropeno', 'but-2-eno']
 where id = 'd9773b1e-4487-51e2-9100-de7905ba4858';
update question_translations set options = array['but-1-ene', 'Propene', '2-methylpropene', 'but-2-ene']
 where question_id = 'd9773b1e-4487-51e2-9100-de7905ba4858' and locale = 'en';
update question_translations set options = array['but-1-eno', 'Propeno', '2-metilpropeno', 'but-2-eno']
 where question_id = 'd9773b1e-4487-51e2-9100-de7905ba4858' and locale = 'es';

update questions set options = array['1-bromopropano', '2-bromopropano', '1,2-dibromopropano', 'Bromopropeno']
 where id = '223ed992-bc0f-5717-a97a-55a745d759fe';
update question_translations set options = array['1-bromopropane', '2-bromopropane', '1,2-dibromopropane', 'Bromopropene']
 where question_id = '223ed992-bc0f-5717-a97a-55a745d759fe' and locale = 'en';
update question_translations set options = array['1-bromopropano', '2-bromopropano', '1,2-dibromopropano', 'Bromopropeno']
 where question_id = '223ed992-bc0f-5717-a97a-55a745d759fe' and locale = 'es';

update questions set options = array['Um alcano', 'Um alceno', 'Um cicloalcano', 'Um alcino ou um alcadieno']
 where id = '36da46eb-3e71-5b3d-9f9e-6aad5c17c011';
update question_translations set options = array['An alkane', 'An alkene', 'A cycloalkane', 'An alkyne or a diene']
 where question_id = '36da46eb-3e71-5b3d-9f9e-6aad5c17c011' and locale = 'en';
update question_translations set options = array['Un alcano', 'Un alqueno', 'Un cicloalcano', 'Un alquino o un alcadieno']
 where question_id = '36da46eb-3e71-5b3d-9f9e-6aad5c17c011' and locale = 'es';

update questions set options = array['Propanal', 'Propanona (uma cetona)', 'Ácido propanoico', 'Nada, pois não sofre oxidação']
 where id = '39cc00c3-bddf-5fd0-b770-e446542cb35d';
update question_translations set options = array['Propanal', 'Propanone (a ketone)', 'Propanoic acid', 'Nothing, since it does not oxidize']
 where question_id = '39cc00c3-bddf-5fd0-b770-e446542cb35d' and locale = 'en';
update question_translations set options = array['Propanal', 'Propanona (una cetona)', 'Ácido propanoico', 'Nada, porque no se oxida']
 where question_id = '39cc00c3-bddf-5fd0-b770-e446542cb35d' and locale = 'es';

update questions set options = array['Tem mais hidrogênios ionizáveis', 'Os átomos de cloro atraem elétrons e estabilizam o ânion carboxilato (efeito indutivo)', 'Forma ligações de hidrogênio mais fortes com a água', 'Tem maior massa molar']
 where id = '389445f8-fd2d-5aba-8e1c-97dddb800587';
update question_translations set options = array['It has more ionizable hydrogens', 'The chlorine atoms withdraw electrons and stabilize the carboxylate anion (inductive effect)', 'It forms stronger hydrogen bonds with water', 'It has a higher molar mass']
 where question_id = '389445f8-fd2d-5aba-8e1c-97dddb800587' and locale = 'en';
update question_translations set options = array['Tiene más hidrógenos ionizables', 'Los átomos de cloro atraen electrones y estabilizan el anión carboxilato (efecto inductivo)', 'Forma enlaces de hidrógeno más fuertes con el agua', 'Tiene mayor masa molar']
 where question_id = '389445f8-fd2d-5aba-8e1c-97dddb800587' and locale = 'es';

update questions set options = array['Etanoato de etila e água', 'Etanoato de metila e água', 'Éter dietílico e água', 'Ácido etanoico e etano']
 where id = 'ae5fcb42-5195-5ee3-8f42-d6a3b39b275c';
update question_translations set options = array['Ethyl ethanoate and water', 'Methyl ethanoate and water', 'Diethyl ether and water', 'Ethanoic acid and ethane']
 where question_id = 'ae5fcb42-5195-5ee3-8f42-d6a3b39b275c' and locale = 'en';
update question_translations set options = array['Etanoato de etilo y agua', 'Etanoato de metilo y agua', 'Éter dietílico y agua', 'Ácido etanoico y etano']
 where question_id = 'ae5fcb42-5195-5ee3-8f42-d6a3b39b275c' and locale = 'es';

update questions set options = array['À presença de um grupo hidroxila (–OH)', 'À liberação de íons H⁺ em água', 'Ao par de elétrons não ligante do nitrogênio, que pode receber um próton (H⁺)', 'À ligação dupla C=O']
 where id = '596502cf-b5dd-52c1-89c2-bebd0d595be1';
update question_translations set options = array['The presence of a hydroxyl group (–OH)', 'The release of H⁺ ions in water', 'The nitrogen''s lone pair of electrons, which can accept a proton (H⁺)', 'the C=O double bond']
 where question_id = '596502cf-b5dd-52c1-89c2-bebd0d595be1' and locale = 'en';
update question_translations set options = array['A la presencia de un grupo hidroxilo (–OH)', 'A la liberación de iones H⁺ en agua', 'Al par de electrones no enlazante del nitrógeno, que puede aceptar un protón (H⁺)', 'al doble enlace C=O']
 where question_id = '596502cf-b5dd-52c1-89c2-bebd0d595be1' and locale = 'es';

update questions set options = array['Real, invertida e de mesmo tamanho', 'Virtual e maior', 'Real e menor', 'Imprópria, no infinito']
 where id = '074881be-6bc3-4d78-85d3-9207d8fa2790';

update questions set options = array['Virtual e maior', 'Real, de mesmo tamanho e invertida', 'Real e 2 vezes maior', 'Virtual e menor']
 where id = 'a6deb288-88cd-4496-8c11-aa404d642e31';

update questions set options = array['Base × altura', 'Base + altura', '2 × (base + altura)', 'base² + altura²']
 where id = '86ad48ea-bc1a-4d1b-9689-e846b0fa03b6';
update question_translations set options = array['Base × height', 'Base + height', '2 × (base + height)', 'base² + height²']
 where question_id = '86ad48ea-bc1a-4d1b-9689-e846b0fa03b6' and locale = 'en';
update question_translations set options = array['Base × altura', 'Base + altura', '2 × (base + altura)', 'base² + altura²']
 where question_id = '86ad48ea-bc1a-4d1b-9689-e846b0fa03b6' and locale = 'es';

update question_translations set options = array['Slope', 'Y-intercept', 'Point of origin', 'Length']
 where question_id = 'b36d48ca-4c25-48e3-bc5a-f3deda5b046d' and locale = 'en';

update questions set options = array['A metade', 'Igual', 'O dobro', 'O quádruplo']
 where id = '979f8a12-f147-4078-ab07-278141d1bc03';

