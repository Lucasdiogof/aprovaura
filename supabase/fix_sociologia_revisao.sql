-- Sociologia: 2 correções aceitas da revisão externa (2026-09-30)
--
-- Nenhum gabarito errado. Entram a base legal das cotas no ensino federal
-- (Lei 12.711/2012, atualizada pela 14.723/2023) e a ressalva de que o
-- enquadramento jurídico do trabalho por plataforma não é pacífico.
--
-- Recusadas 12: quase todas trocavam a alternativa certa por uma versão cheia
-- de ressalvas ("em muitos contextos", "varia conforme autor e período")
-- bem mais longa que os distratores, o que entrega a resposta, e trocavam
-- distratores plausíveis por outros absurdos.
--
-- Só o texto muda: a ORDEM das alternativas é preservada, para o gabarito
-- não se mexer e as traduções seguirem alinhadas por posição. Cada
-- update grava o valor final inteiro, então rodar de novo não muda nada.

-- cotas: a base legal no ensino federal
update questions set explanation = 'Ações afirmativas buscam reduzir desigualdades históricas, ampliando o acesso de grupos discriminados. No ensino federal, a base é a Lei de Cotas (Lei 12.711/2012), atualizada pela Lei 14.723/2023.'
 where id = '57464758-cf9a-543c-9d8d-bbb7fdd86644';
update question_translations set explanation = 'Affirmative actions seek to reduce historical inequalities by widening access for groups that face discrimination. In Brazil''s federal education system, the legal basis is the Quota Law (Law 12,711/2012), updated by Law 14,723/2023.'
 where question_id = '57464758-cf9a-543c-9d8d-bbb7fdd86644' and locale = 'en';
update question_translations set explanation = 'Las acciones afirmativas buscan reducir desigualdades históricas, ampliando el acceso de grupos discriminados. En la enseñanza federal brasileña, la base es la Ley de Cuotas (Ley 12.711/2012), actualizada por la Ley 14.723/2023.'
 where question_id = '57464758-cf9a-543c-9d8d-bbb7fdd86644' and locale = 'es';

-- uberização: o enquadramento jurídico do vínculo não é pacífico
update questions set explanation = 'Na uberização, a plataforma controla preços e a distribuição de tarefas por algoritmos, e o trabalhador assume custos e riscos. O enquadramento jurídico desse vínculo varia conforme a legislação e as decisões judiciais.'
 where id = '5c5c2a48-da77-5b2b-977c-cfdc6c5d5f08';
update question_translations set explanation = 'In Uberization, the platform controls prices and task distribution through algorithms, while the worker bears costs and risks. The legal classification of this relationship varies with legislation and court rulings.'
 where question_id = '5c5c2a48-da77-5b2b-977c-cfdc6c5d5f08' and locale = 'en';
update question_translations set explanation = 'En la uberización, la plataforma controla precios y el reparto de tareas mediante algoritmos, y el trabajador asume costos y riesgos. El encuadre jurídico de ese vínculo varía según la legislación y las decisiones judiciales.'
 where question_id = '5c5c2a48-da77-5b2b-977c-cfdc6c5d5f08' and locale = 'es';
