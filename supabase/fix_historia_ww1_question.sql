-- The wrong options for this question included events from 1929 and 1933,
-- both clearly after the 1914-1918 range stated in the question itself --
-- answerable by elimination without any real historical knowledge. Replaced
-- with genuine long-term causes from the same era, so telling them apart
-- from the immediate trigger actually requires understanding the material.
update questions
set options = array[
    'O assassinato do arquiduque Francisco Ferdinando, da Áustria-Hungria, em Sarajevo',
    'A crise dos Bálcãs de 1912-1913',
    'A corrida armamentista naval entre Alemanha e Inglaterra',
    'O sistema de alianças militares firmado nas décadas anteriores'
  ],
  explanation = 'O assassinato do herdeiro do trono austro-húngaro em Sarajevo, em junho de 1914, foi o estopim imediato. As demais alternativas são causas estruturais de longo prazo que tensionaram a Europa antes da guerra, mas não o gatilho direto.'
where catalog_node_id = '9d1627ca-eade-4dcf-83dc-a1acfcd096c8'
  and order_index = 5;
