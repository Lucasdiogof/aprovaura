-- Apple: a loja não tem o ponto de preço R$ 190,00; o anual na App Store é R$ 189,90 (decisão do dono, 25/11/2026).
-- Ajuste ESPECÍFICO da plataforma Apple: Google Play e Mercado Pago continuam em R$ 190,00.
-- Só referência de catálogo/portal: o valor financeiro real vem da transação Apple (tx.price).
update payment_catalog
   set price_cents = 18990
 where provider = 'apple' and plan = 'annual' and environment = 'production' and price_cents = 19000;
