-- Artes: conserta o gabarito de 12 questões
--
-- Mesmo defeito encontrado em Educação Física: o índice do gabarito
-- seguia a distribuição de 30 por letra, mas a alternativa correta não
-- foi movida para a posição indicada. Em todas as 12, a explicação já
-- gravada descreve a alternativa certa, não a que estava marcada.
--
-- A correção troca as duas alternativas de lugar, nos três idiomas, para
-- que o gabarito continue com 30 questões por letra.
--
-- Precisa ser UPDATE: as questões entram com `on conflict do nothing`.
-- Idempotente: rodar de novo escreve o mesmo valor.

update questions set options = array['Técnicas exclusivamente manuais e artesanais', 'Materiais tradicionais como mármore e bronze', 'Inteligência artificial na geração de imagens e obras', 'Técnicas restritas ao século XV']
 where id = '518f5535-9a1a-51d6-9bc6-c36fdba2d5dc';
update question_translations set options = array['Exclusively manual, handmade techniques', 'Traditional materials such as marble and bronze', 'Artificial intelligence in generating images and works', 'Techniques restricted to the 15th century']
 where question_id = '518f5535-9a1a-51d6-9bc6-c36fdba2d5dc' and locale = 'en';
update question_translations set options = array['Técnicas exclusivamente manuales y artesanales', 'Materiales tradicionales como el mármol y el bronce', 'Inteligencia artificial en la generación de imágenes y obras', 'Técnicas restringidas al siglo XV']
 where question_id = '518f5535-9a1a-51d6-9bc6-c36fdba2d5dc' and locale = 'es';

update questions set options = array['Usar metáforas e letras para criticar a censura e o regime autoritário', 'Ser produzida exclusivamente fora do Brasil', 'Ser um gênero puramente instrumental sem letras', 'Evitar qualquer crítica ao governo']
 where id = '68c9837a-734a-57d1-a9dd-5681b08689f2';
update question_translations set options = array['Using metaphors and lyrics to criticize censorship and the authoritarian regime', 'Being produced exclusively outside Brazil', 'Being a purely instrumental genre with no lyrics', 'Avoiding any criticism of the government']
 where question_id = '68c9837a-734a-57d1-a9dd-5681b08689f2' and locale = 'en';
update question_translations set options = array['Usar metáforas y letras para criticar la censura y el régimen autoritario', 'Ser producida exclusivamente fuera de Brasil', 'Ser un género puramente instrumental sin letras', 'Evitar cualquier crítica al gobierno']
 where question_id = '68c9837a-734a-57d1-a9dd-5681b08689f2' and locale = 'es';

update questions set options = array['A circulação mais ampla de produtos culturais, mas também riscos de homogeneização cultural', 'A eliminação de qualquer intercâmbio cultural', 'A garantia automática de valorização das culturas locais', 'O fim total da produção cultural local']
 where id = 'b6a99dc2-6c63-5969-9db3-d53293bd541d';
update question_translations set options = array['Wider circulation of cultural products, but also risks of cultural homogenization', 'The elimination of any cultural exchange', 'The automatic guarantee of valuing local cultures', 'The total end of local cultural production']
 where question_id = 'b6a99dc2-6c63-5969-9db3-d53293bd541d' and locale = 'en';
update question_translations set options = array['Una circulación más amplia de productos culturales, pero también riesgos de homogeneización cultural', 'La eliminación de cualquier intercambio cultural', 'La garantía automática de valoración de las culturas locales', 'El fin total de la producción cultural local']
 where question_id = 'b6a99dc2-6c63-5969-9db3-d53293bd541d' and locale = 'es';

update questions set options = array['Não existe nenhuma tensão entre elas', 'Grandes produções globais podem coexistir e, por vezes, competir com expressões culturais locais', 'Elas nunca se relacionam de forma alguma', 'A indústria cultural sempre fortalece automaticamente as culturas locais']
 where id = '19b393ad-60bc-5fba-8564-e100cedcc213';
update question_translations set options = array['There is no tension between them at all', 'Large global productions can coexist and sometimes compete with local cultural expressions', 'They never relate to each other in any way', 'The cultural industry always automatically strengthens local cultures']
 where question_id = '19b393ad-60bc-5fba-8564-e100cedcc213' and locale = 'en';
update question_translations set options = array['No existe ninguna tensión entre ellas', 'Las grandes producciones globales pueden coexistir y, a veces, competir con expresiones culturales locales', 'Nunca se relacionan de ninguna forma', 'La industria cultural siempre fortalece automáticamente las culturas locales']
 where question_id = '19b393ad-60bc-5fba-8564-e100cedcc213' and locale = 'es';

update questions set options = array['A produção e distribuição em massa de bens culturais, como filmes, música e programas de TV', 'Exclusivamente obras de arte únicas em museus', 'Um conceito exclusivo da música clássica europeia', 'Apenas a produção artesanal individual']
 where id = '185bc13c-e66b-5b50-9917-95c0f0dc022c';
update question_translations set options = array['The mass production and distribution of cultural goods, such as films, music and TV shows', 'Exclusively unique works of art in museums', 'A concept exclusive to European classical music', 'Only individual craft production']
 where question_id = '185bc13c-e66b-5b50-9917-95c0f0dc022c' and locale = 'en';
update question_translations set options = array['La producción y distribución masiva de bienes culturales, como películas, música y programas de televisión', 'Exclusivamente obras de arte únicas en museos', 'Un concepto exclusivo de la música clásica europea', 'Solo la producción artesanal individual']
 where question_id = '185bc13c-e66b-5b50-9917-95c0f0dc022c' and locale = 'es';

update questions set options = array['Uma pintura rupestre pré-histórica', 'Uma série de streaming produzida para um grande público', 'Um manuscrito medieval original', 'Uma escultura única exposta em um museu']
 where id = 'b1628002-2771-5d45-b36a-35ca20092045';
update question_translations set options = array['A prehistoric cave painting', 'A streaming series produced for a large audience', 'An original medieval manuscript', 'A unique sculpture displayed in a museum']
 where question_id = 'b1628002-2771-5d45-b36a-35ca20092045' and locale = 'en';
update question_translations set options = array['Una pintura rupestre prehistórica', 'Una serie de streaming producida para un gran público', 'Un manuscrito medieval original', 'Una escultura única expuesta en un museo']
 where question_id = 'b1628002-2771-5d45-b36a-35ca20092045' and locale = 'es';

update questions set options = array['O processo de selecionar e organizar os planos filmados para construir a narrativa', 'A criação do roteiro original', 'A escolha das roupas dos personagens', 'A escolha do elenco antes das filmagens']
 where id = '190265ff-7a2b-5031-98c7-edeb73338c10';
update question_translations set options = array['The process of selecting and arranging filmed shots to build the narrative', 'Creating the original script', 'Choosing the characters'' clothes', 'Choosing the cast before filming']
 where question_id = '190265ff-7a2b-5031-98c7-edeb73338c10' and locale = 'en';
update question_translations set options = array['El proceso de seleccionar y organizar los planos filmados para construir la narrativa', 'La creación del guion original', 'La elección de la ropa de los personajes', 'La elección del elenco antes de las filmaciones']
 where question_id = '190265ff-7a2b-5031-98c7-edeb73338c10' and locale = 'es';

update questions set options = array['O conjunto de objetos físicos produzidos por uma sociedade, que refletem seus valores e práticas', 'Apenas leis e normas jurídicas', 'Exclusivamente obras digitais', 'Apenas ideias e crenças, sem qualquer objeto físico']
 where id = '2e1a14b9-a973-5d41-b294-b9e52c8a2cc9';
update question_translations set options = array['The set of physical objects produced by a society, reflecting its values and practices', 'Only laws and legal norms', 'Exclusively digital works', 'Only ideas and beliefs, with no physical object']
 where question_id = '2e1a14b9-a973-5d41-b294-b9e52c8a2cc9' and locale = 'en';
update question_translations set options = array['El conjunto de objetos físicos producidos por una sociedad, que reflejan sus valores y prácticas', 'Solo leyes y normas jurídicas', 'Exclusivamente obras digitales', 'Solo ideas y creencias, sin ningún objeto físico']
 where question_id = '2e1a14b9-a973-5d41-b294-b9e52c8a2cc9' and locale = 'es';

update questions set options = array['Proibir a realização dessas festas', 'Valorizar e apoiar a continuidade dessas manifestações culturais', 'Restringir a festa a um público pagante', 'Transformar as festas em propriedade exclusiva do Estado']
 where id = '0c8f2b93-45ee-5498-aa16-17b9628eb76c';
update question_translations set options = array['Prohibit these festivals from taking place', 'Value and support the continuity of these cultural manifestations', 'Restrict the festival to a paying audience', 'Turn the festivals into exclusive state property']
 where question_id = '0c8f2b93-45ee-5498-aa16-17b9628eb76c' and locale = 'en';
update question_translations set options = array['Prohibir la realización de esas fiestas', 'Valorar y apoyar la continuidad de esas manifestaciones culturales', 'Restringir la fiesta a un público pagante', 'Transformar las fiestas en propiedad exclusiva del Estado']
 where question_id = '0c8f2b93-45ee-5498-aa16-17b9628eb76c' and locale = 'es';

update questions set options = array['Detalhismo fotográfico extremo', 'Ausência total de cor', 'Simplificação de formas e cores fortes, com temas ligados à identidade nacional', 'Uso exclusivo de tons sépia']
 where id = '10295998-9c7b-58da-9267-88a57cdf06a6';
update question_translations set options = array['Extreme photographic detail', 'Total absence of color', 'Simplification of forms and strong colors, with themes linked to national identity', 'Exclusive use of sepia tones']
 where question_id = '10295998-9c7b-58da-9267-88a57cdf06a6' and locale = 'en';
update question_translations set options = array['Detallismo fotográfico extremo', 'Ausencia total de color', 'Simplificación de formas y colores fuertes, con temas ligados a la identidad nacional', 'Uso exclusivo de tonos sepia']
 where question_id = '10295998-9c7b-58da-9267-88a57cdf06a6' and locale = 'es';

update questions set options = array['Ocultar completamente a superfície da tela', 'Criar um efeito totalmente liso e sem textura', 'Capturar a sensação de luz e movimento em vez de detalhes precisos', 'Imitar exatamente uma fotografia']
 where id = 'bbfaf69b-4010-503a-bad6-cacc04690f08';
update question_translations set options = array['To completely hide the surface of the canvas', 'To create a completely smooth, textureless effect', 'To capture the sensation of light and movement rather than precise detail', 'To imitate a photograph exactly']
 where question_id = 'bbfaf69b-4010-503a-bad6-cacc04690f08' and locale = 'en';
update question_translations set options = array['Ocultar completamente la superficie del lienzo', 'Crear un efecto totalmente liso y sin textura', 'Capturar la sensación de luz y movimiento en lugar de detalles precisos', 'Imitar exactamente una fotografía']
 where question_id = 'bbfaf69b-4010-503a-bad6-cacc04690f08' and locale = 'es';

update questions set options = array['Tradições europeias medievais', 'Músicas eletrônicas contemporâneas', 'Manifestações culturais afro-brasileiras, especialmente no Rio de Janeiro', 'Óperas italianas clássicas']
 where id = 'cf277bf4-e9cd-585e-bd39-d70167bd96a4';
update question_translations set options = array['Medieval European traditions', 'Contemporary electronic music', 'Afro-Brazilian cultural manifestations, especially in Rio de Janeiro', 'Classical Italian operas']
 where question_id = 'cf277bf4-e9cd-585e-bd39-d70167bd96a4' and locale = 'en';
update question_translations set options = array['Tradiciones europeas medievales', 'Músicas electrónicas contemporáneas', 'Manifestaciones culturales afrobrasileñas, especialmente en Río de Janeiro', 'Óperas italianas clásicas']
 where question_id = 'cf277bf4-e9cd-585e-bd39-d70167bd96a4' and locale = 'es';

