-- Classifies the 20 questions from the 4 topics added on 2026-08-20
-- (questions_seed_geografia_agricultura_mundial.sql,
-- questions_seed_geografia_climas_mundo.sql,
-- questions_seed_geografia_agricultura_brasil.sql,
-- questions_seed_geografia_eua.sql) that were left at the schema default
-- 'medio' -- meaning they only ever showed up under "Todos" or "Médio",
-- never under "Fácil"/"Difícil". Targeted by catalog_node_id + order_index
-- since ids were generated at insert time and aren't known here.

-- Agricultura mundial (28c6f408-1614-4e86-b8b2-c0ddad137ff4)
update questions set difficulty = 'facil'   where catalog_node_id = '28c6f408-1614-4e86-b8b2-c0ddad137ff4' and order_index = 1; -- maior produtor de grãos
update questions set difficulty = 'facil'   where catalog_node_id = '28c6f408-1614-4e86-b8b2-c0ddad137ff4' and order_index = 2; -- 2º maior produtor de soja
update questions set difficulty = 'medio'   where catalog_node_id = '28c6f408-1614-4e86-b8b2-c0ddad137ff4' and order_index = 3; -- maior produtor de algodão
update questions set difficulty = 'dificil' where catalog_node_id = '28c6f408-1614-4e86-b8b2-c0ddad137ff4' and order_index = 4; -- ordem EUA/China no milho
update questions set difficulty = 'medio'   where catalog_node_id = '28c6f408-1614-4e86-b8b2-c0ddad137ff4' and order_index = 5; -- produtos tropicais

-- Climas do mundo (f85b69d0-019a-487c-8e82-dc5d99bbfdec)
update questions set difficulty = 'facil'   where catalog_node_id = 'f85b69d0-019a-487c-8e82-dc5d99bbfdec' and order_index = 1; -- sequência das zonas climáticas
update questions set difficulty = 'facil'   where catalog_node_id = 'f85b69d0-019a-487c-8e82-dc5d99bbfdec' and order_index = 2; -- o que define clima desértico
update questions set difficulty = 'dificil' where catalog_node_id = 'f85b69d0-019a-487c-8e82-dc5d99bbfdec' and order_index = 3; -- corrente fria -> deserto
update questions set difficulty = 'medio'   where catalog_node_id = 'f85b69d0-019a-487c-8e82-dc5d99bbfdec' and order_index = 4; -- corrente quente -> úmido
update questions set difficulty = 'dificil' where catalog_node_id = 'f85b69d0-019a-487c-8e82-dc5d99bbfdec' and order_index = 5; -- clima de montanha, -6°C/1000m

-- Agricultura do Brasil (72caea53-82f0-4f9a-ac0c-b8b834587043)
update questions set difficulty = 'dificil' where catalog_node_id = '72caea53-82f0-4f9a-ac0c-b8b834587043' and order_index = 1; -- soja começou no Sul, 1960-70
update questions set difficulty = 'medio'   where catalog_node_id = '72caea53-82f0-4f9a-ac0c-b8b834587043' and order_index = 2; -- o que é MATOPIBA
update questions set difficulty = 'facil'   where catalog_node_id = '72caea53-82f0-4f9a-ac0c-b8b834587043' and order_index = 3; -- cana-de-açúcar colonial no NE
update questions set difficulty = 'medio'   where catalog_node_id = '72caea53-82f0-4f9a-ac0c-b8b834587043' and order_index = 4; -- Oeste Paulista lidera etanol hoje
update questions set difficulty = 'facil'   where catalog_node_id = '72caea53-82f0-4f9a-ac0c-b8b834587043' and order_index = 5; -- laranja concentrada em SP

-- Estados Unidos (181684b0-7fa9-46bd-84e5-734978827037)
update questions set difficulty = 'medio'   where catalog_node_id = '181684b0-7fa9-46bd-84e5-734978827037' and order_index = 1; -- Wheat Belt
update questions set difficulty = 'medio'   where catalog_node_id = '181684b0-7fa9-46bd-84e5-734978827037' and order_index = 2; -- Corn Belt também produz soja
update questions set difficulty = 'facil'   where catalog_node_id = '181684b0-7fa9-46bd-84e5-734978827037' and order_index = 3; -- Rust Belt
update questions set difficulty = 'medio'   where catalog_node_id = '181684b0-7fa9-46bd-84e5-734978827037' and order_index = 4; -- Sun Belt
update questions set difficulty = 'dificil' where catalog_node_id = '181684b0-7fa9-46bd-84e5-734978827037' and order_index = 5; -- 3 polos metropolitanos
