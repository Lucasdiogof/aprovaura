-- Map-quiz leaves (Estados do Brasil, Rios da Europa, etc.) have no rows
-- in `questions`, so catalog_node_progress never had anything to sum for
-- them -- their cards show no progress bar at all today, unlike
-- question-based topics which show "0%" until answered. This mirrors
-- user_question_progress/register_question_answered for map regions
-- instead of questions.
--
-- region_id is the geojson feature's "sigla" (e.g. 'sp', 'gibraltar').
-- catalog_node_id is required (not derived from mapId) because the same
-- map backs more than one activity -- e.g. europe_countries.geojson backs
-- both "Países da Europa" and "Bandeiras da Europa", and finding a
-- country in one doesn't count toward the other.
create table if not exists user_region_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  catalog_node_id uuid not null references catalog_nodes (id) on delete cascade,
  region_id text not null,
  found_at timestamptz not null default now(),
  unique (user_id, catalog_node_id, region_id)
);

create index if not exists user_region_progress_user_idx
  on user_region_progress (user_id);

alter table user_region_progress enable row level security;

-- No insert/update policy on purpose, same as user_question_progress --
-- writes only happen through register_region_found() below.
create policy "users can read their own region progress"
  on user_region_progress for select
  using (auth.uid() = user_id);

-- Called on every correct tap. A region only counts once per user per
-- activity no matter how many times the quiz is retried.
create or replace function register_region_found(
  p_catalog_node_id uuid,
  p_region_id text
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  insert into user_region_progress (user_id, catalog_node_id, region_id, found_at)
  values (v_user_id, p_catalog_node_id, p_region_id, now())
  on conflict (user_id, catalog_node_id, region_id) do nothing;
end;
$$;

-- Total tappable regions for map-quiz leaves. Can't be derived in
-- Postgres like `questions` totals are -- the regions live in bundled
-- .geojson assets, not the database -- so it's seeded once below from
-- each geojson's feature count. Null for question-based leaves.
alter table catalog_nodes
  add column if not exists region_count integer;

update catalog_nodes set region_count = 27 where id = '294b30a4-5efc-49fc-ac23-302a3ff4d180'; -- Estados do Brasil
update catalog_nodes set region_count = 45 where id = 'b1b8af46-010e-47dc-9be3-520ad7b987d3'; -- Países da Europa
update catalog_nodes set region_count = 15 where id = 'f61b0f28-002f-4064-beea-76e7bd89f845'; -- Rios da Europa
update catalog_nodes set region_count = 12 where id = '159b40c1-303d-4999-bce4-a6fb7ade0b01'; -- Países da América do Sul
update catalog_nodes set region_count = 7  where id = '78cd83dd-f366-4f08-b362-13a1625be062'; -- Rios da América do Sul
update catalog_nodes set region_count = 52 where id = '2d0a356f-6664-447e-9e99-4584d8e0663f'; -- Países da África
update catalog_nodes set region_count = 7  where id = '43e1463b-59ff-4dd7-b618-283a592c3f2f'; -- Rios da África
update catalog_nodes set region_count = 48 where id = 'a76aa97e-2694-41b8-a5f7-cedf46df41c6'; -- Países da Ásia
update catalog_nodes set region_count = 12 where id = '6bb22a03-a00d-4515-8839-261640323b81'; -- Rios da Ásia
update catalog_nodes set region_count = 45 where id = '0f32f1d7-45c0-40ea-b0d8-7b6059c7bfff'; -- Capitais da Europa
update catalog_nodes set region_count = 12 where id = '7a9fe166-a904-4a6a-b418-db163e1d20a1'; -- Capitais da América do Sul
update catalog_nodes set region_count = 51 where id = '9c16fc74-a23e-4822-9c43-bf88f29e6a0c'; -- Capitais da África
update catalog_nodes set region_count = 47 where id = '57e578a4-38f4-4770-ae1f-890ef3e3f6f9'; -- Capitais da Ásia
update catalog_nodes set region_count = 15 where id = 'c3a94a41-c598-4f80-a222-38064c3a9770'; -- Grandes cidades da Europa
update catalog_nodes set region_count = 12 where id = 'd8bcc5de-a0b8-49a7-a017-8f4fba6b4f92'; -- Grandes cidades da América do Sul
update catalog_nodes set region_count = 15 where id = '6be2cc01-a1de-4e42-a10d-d0833c6ff83b'; -- Grandes cidades da África
update catalog_nodes set region_count = 15 where id = '2bfe0425-c32a-4e2f-b783-140c79cdd33c'; -- Grandes cidades da Ásia
update catalog_nodes set region_count = 23 where id = '8614d4f5-57de-4adb-b791-b2675d231146'; -- Países da América do Norte
update catalog_nodes set region_count = 6  where id = '4d01bc22-f595-4fc6-a438-47dd5149eec5'; -- Rios da América do Norte
update catalog_nodes set region_count = 23 where id = '37225bb6-1d51-478c-b34f-9a0519ce152a'; -- Capitais da América do Norte
update catalog_nodes set region_count = 15 where id = '8cb43a48-5bb3-499f-ba84-88766dbee7c6'; -- Grandes cidades da América do Norte
update catalog_nodes set region_count = 14 where id = '54557ac9-e1c0-4528-8f85-90770585ce70'; -- Países da Oceania
update catalog_nodes set region_count = 13 where id = '3f3122b9-8bf1-4d7c-aa38-1a018a71e83d'; -- Capitais da Oceania
update catalog_nodes set region_count = 10 where id = '2d920dbb-3653-4c07-83c2-645e456f068b'; -- Grandes cidades da Oceania
update catalog_nodes set region_count = 194 where id = '7702b50d-364a-4236-a042-7d2799328521'; -- Países do mundo
update catalog_nodes set region_count = 191 where id = '19ee546c-270d-4111-9e73-10ff9398e303'; -- Capitais do mundo
update catalog_nodes set region_count = 30 where id = '67418a3d-3a87-4885-921d-317c75c99383'; -- Grandes cidades do mundo
update catalog_nodes set region_count = 12 where id = 'a5731187-0c27-4a85-85fc-a82650ac35ac'; -- Grandes rios do mundo
update catalog_nodes set region_count = 45 where id = '47c2eaf3-d4e4-476c-90b7-1cf6d8ddad27'; -- Bandeiras da Europa
update catalog_nodes set region_count = 12 where id = '8cca30ab-8897-4078-88cb-c135900e9008'; -- Bandeiras da América do Sul
update catalog_nodes set region_count = 52 where id = '5b6a06bb-fa04-4671-960f-19ce67fe4808'; -- Bandeiras da África
update catalog_nodes set region_count = 48 where id = '57aabc63-5acd-4c54-8212-0f1f49ab44a2'; -- Bandeiras da Ásia
update catalog_nodes set region_count = 194 where id = 'b57f2795-d8f3-43dc-a7aa-e082fc887568'; -- Bandeiras do mundo
update catalog_nodes set region_count = 23 where id = '3f1bce0e-b7e7-4483-8384-5fe7814d8d46'; -- Bandeiras da América do Norte
update catalog_nodes set region_count = 14 where id = '695fcbfa-09f7-4720-9bb0-5405cf446dc2'; -- Bandeiras da Oceania
update catalog_nodes set region_count = 34 where id = 'b7d3c950-9f2b-4206-9bb7-74263dacc6e7'; -- Estreitos do mundo

-- catalog_node_progress now rolls up both sources: question-based totals
-- (unchanged) plus map-quiz totals (region_count / user_region_progress).
-- p_difficulty still narrows question totals by q.difficulty and map-quiz
-- totals by manual_difficulty, same rule as catalog_children_with_difficulty
-- uses to decide what's visible under a given filter -- a map-quiz leaf
-- with no manual_difficulty simply doesn't count toward any specific
-- filter, only "Todos" (p_difficulty null), which is the existing behavior.
create or replace function catalog_node_progress(
  p_node_ids uuid[],
  p_difficulty text default null
)
returns table (node_id uuid, total integer, completed integer)
language sql
stable
as $$
  with recursive descendants as (
    select n.id, n.id as branch_root
    from catalog_nodes n
    where n.id = any(p_node_ids)
    union all
    select c.id, d.branch_root
    from catalog_nodes c
    join descendants d on c.parent_id = d.id
  ),
  question_totals as (
    select d.branch_root as node_id,
           count(q.id)::int as total,
           count(up.question_id)::int as completed
    from descendants d
    join questions q on q.catalog_node_id = d.id
    left join user_question_progress up
      on up.question_id = q.id and up.user_id = auth.uid()
    where p_difficulty is null or q.difficulty = p_difficulty
    group by d.branch_root
  ),
  region_totals as (
    select d.branch_root as node_id,
           sum(cn.region_count)::int as total,
           count(rp.region_id)::int as completed
    from descendants d
    join catalog_nodes cn on cn.id = d.id and cn.region_count is not null
    left join user_region_progress rp
      on rp.catalog_node_id = cn.id and rp.user_id = auth.uid()
    where p_difficulty is null or cn.manual_difficulty = p_difficulty
    group by d.branch_root
  )
  select
    coalesce(q.node_id, r.node_id) as node_id,
    coalesce(q.total, 0) + coalesce(r.total, 0) as total,
    coalesce(q.completed, 0) + coalesce(r.completed, 0) as completed
  from question_totals q
  full outer join region_totals r on q.node_id = r.node_id;
$$;
