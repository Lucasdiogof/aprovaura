import 'package:flutter/widgets.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_prompt_mode.dart';
import 'package:aura/features/map_quiz/presentation/pages/map_quiz_page.dart';

Widget Function(BuildContext, String) _mapQuiz({
  required String mapId,
  required MapInteractionType interactionType,
  required String title,
  MapPromptMode promptMode = MapPromptMode.name,
  String? backgroundMapId,
}) =>
    (_, catalogNodeId) => MapQuizPage(
      mapId: mapId,
      catalogNodeId: catalogNodeId,
      interactionType: interactionType,
      title: title,
      promptMode: promptMode,
      backgroundMapId: backgroundMapId,
    );

// The dict key doubles as the catalogNodeId passed into each builder --
// see catalog_list_page.dart's call site -- so it's never duplicated as a
// second literal inside the entries below.
final Map<String, Widget Function(BuildContext, String)> mappedActivities = {
  '294b30a4-5efc-49fc-ac23-302a3ff4d180': _mapQuiz(
    mapId: 'brazil_states',
    interactionType: MapInteractionType.polygon,
    title: 'Estados do Brasil',
  ),
  'b1b8af46-010e-47dc-9be3-520ad7b987d3': _mapQuiz(
    mapId: 'europe_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Países da Europa',
  ),
  'f61b0f28-002f-4064-beea-76e7bd89f845': _mapQuiz(
    mapId: 'europe_rivers',
    interactionType: MapInteractionType.line,
    title: 'Rios da Europa',
    backgroundMapId: 'europe_countries_bg',
  ),
  '159b40c1-303d-4999-bce4-a6fb7ade0b01': _mapQuiz(
    mapId: 'south_america_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Países da América do Sul',
  ),
  '78cd83dd-f366-4f08-b362-13a1625be062': _mapQuiz(
    mapId: 'south_america_rivers',
    interactionType: MapInteractionType.line,
    title: 'Rios da América do Sul',
    backgroundMapId: 'south_america_countries_bg',
  ),
  '2d0a356f-6664-447e-9e99-4584d8e0663f': _mapQuiz(
    mapId: 'africa_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Países da África',
  ),
  '43e1463b-59ff-4dd7-b618-283a592c3f2f': _mapQuiz(
    mapId: 'africa_rivers',
    interactionType: MapInteractionType.line,
    title: 'Rios da África',
    backgroundMapId: 'africa_countries_bg',
  ),
  'a76aa97e-2694-41b8-a5f7-cedf46df41c6': _mapQuiz(
    mapId: 'asia_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Países da Ásia',
  ),
  '6bb22a03-a00d-4515-8839-261640323b81': _mapQuiz(
    mapId: 'asia_rivers',
    interactionType: MapInteractionType.line,
    title: 'Rios da Ásia',
    backgroundMapId: 'asia_countries_bg',
  ),
  '0f32f1d7-45c0-40ea-b0d8-7b6059c7bfff': _mapQuiz(
    mapId: 'europe_capitals',
    interactionType: MapInteractionType.point,
    title: 'Capitais da Europa',
    backgroundMapId: 'europe_countries_bg',
  ),
  '7a9fe166-a904-4a6a-b418-db163e1d20a1': _mapQuiz(
    mapId: 'south_america_capitals',
    interactionType: MapInteractionType.point,
    title: 'Capitais da América do Sul',
    backgroundMapId: 'south_america_countries_bg',
  ),
  '9c16fc74-a23e-4822-9c43-bf88f29e6a0c': _mapQuiz(
    mapId: 'africa_capitals',
    interactionType: MapInteractionType.point,
    title: 'Capitais da África',
    backgroundMapId: 'africa_countries_bg',
  ),
  '57e578a4-38f4-4770-ae1f-890ef3e3f6f9': _mapQuiz(
    mapId: 'asia_capitals',
    interactionType: MapInteractionType.point,
    title: 'Capitais da Ásia',
    backgroundMapId: 'asia_countries_bg',
  ),
  'c3a94a41-c598-4f80-a222-38064c3a9770': _mapQuiz(
    mapId: 'europe_cities',
    interactionType: MapInteractionType.point,
    title: 'Grandes cidades da Europa',
    backgroundMapId: 'europe_countries_bg',
  ),
  'd8bcc5de-a0b8-49a7-a017-8f4fba6b4f92': _mapQuiz(
    mapId: 'south_america_cities',
    interactionType: MapInteractionType.point,
    title: 'Grandes cidades da América do Sul',
    backgroundMapId: 'south_america_countries_bg',
  ),
  '6be2cc01-a1de-4e42-a10d-d0833c6ff83b': _mapQuiz(
    mapId: 'africa_cities',
    interactionType: MapInteractionType.point,
    title: 'Grandes cidades da África',
    backgroundMapId: 'africa_countries_bg',
  ),
  '2bfe0425-c32a-4e2f-b783-140c79cdd33c': _mapQuiz(
    mapId: 'asia_cities',
    interactionType: MapInteractionType.point,
    title: 'Grandes cidades da Ásia',
    backgroundMapId: 'asia_countries_bg',
  ),
  '8614d4f5-57de-4adb-b791-b2675d231146': _mapQuiz(
    mapId: 'north_america_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Países da América do Norte',
  ),
  '4d01bc22-f595-4fc6-a438-47dd5149eec5': _mapQuiz(
    mapId: 'north_america_rivers',
    interactionType: MapInteractionType.line,
    title: 'Rios da América do Norte',
    backgroundMapId: 'north_america_countries_bg',
  ),
  '37225bb6-1d51-478c-b34f-9a0519ce152a': _mapQuiz(
    mapId: 'north_america_capitals',
    interactionType: MapInteractionType.point,
    title: 'Capitais da América do Norte',
    backgroundMapId: 'north_america_countries_bg',
  ),
  '8cb43a48-5bb3-499f-ba84-88766dbee7c6': _mapQuiz(
    mapId: 'north_america_cities',
    interactionType: MapInteractionType.point,
    title: 'Grandes cidades da América do Norte',
    backgroundMapId: 'north_america_countries_bg',
  ),
  '54557ac9-e1c0-4528-8f85-90770585ce70': _mapQuiz(
    mapId: 'oceania_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Países da Oceania',
  ),
  '3f3122b9-8bf1-4d7c-aa38-1a018a71e83d': _mapQuiz(
    mapId: 'oceania_capitals',
    interactionType: MapInteractionType.point,
    title: 'Capitais da Oceania',
    backgroundMapId: 'oceania_countries_bg',
  ),
  '2d920dbb-3653-4c07-83c2-645e456f068b': _mapQuiz(
    mapId: 'oceania_cities',
    interactionType: MapInteractionType.point,
    title: 'Grandes cidades da Oceania',
    backgroundMapId: 'oceania_countries_bg',
  ),
  '7702b50d-364a-4236-a042-7d2799328521': _mapQuiz(
    mapId: 'world_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Países do mundo',
  ),
  '19ee546c-270d-4111-9e73-10ff9398e303': _mapQuiz(
    mapId: 'world_capitals',
    interactionType: MapInteractionType.point,
    title: 'Capitais do mundo',
    backgroundMapId: 'world_countries_bg',
  ),
  '67418a3d-3a87-4885-921d-317c75c99383': _mapQuiz(
    mapId: 'world_cities',
    interactionType: MapInteractionType.point,
    title: 'Grandes cidades do mundo',
    backgroundMapId: 'world_countries_bg',
  ),
  'a5731187-0c27-4a85-85fc-a82650ac35ac': _mapQuiz(
    mapId: 'world_rivers',
    interactionType: MapInteractionType.line,
    title: 'Grandes rios do mundo',
    backgroundMapId: 'world_countries_bg',
  ),
  '47c2eaf3-d4e4-476c-90b7-1cf6d8ddad27': _mapQuiz(
    mapId: 'europe_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Bandeiras da Europa',
    promptMode: MapPromptMode.flag,
  ),
  '8cca30ab-8897-4078-88cb-c135900e9008': _mapQuiz(
    mapId: 'south_america_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Bandeiras da América do Sul',
    promptMode: MapPromptMode.flag,
  ),
  '5b6a06bb-fa04-4671-960f-19ce67fe4808': _mapQuiz(
    mapId: 'africa_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Bandeiras da África',
    promptMode: MapPromptMode.flag,
  ),
  '57aabc63-5acd-4c54-8212-0f1f49ab44a2': _mapQuiz(
    mapId: 'asia_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Bandeiras da Ásia',
    promptMode: MapPromptMode.flag,
  ),
  'b57f2795-d8f3-43dc-a7aa-e082fc887568': _mapQuiz(
    mapId: 'world_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Bandeiras do mundo',
    promptMode: MapPromptMode.flag,
  ),
  '3f1bce0e-b7e7-4483-8384-5fe7814d8d46': _mapQuiz(
    mapId: 'north_america_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Bandeiras da América do Norte',
    promptMode: MapPromptMode.flag,
  ),
  '695fcbfa-09f7-4720-9bb0-5405cf446dc2': _mapQuiz(
    mapId: 'oceania_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Bandeiras da Oceania',
    promptMode: MapPromptMode.flag,
  ),
  'b7d3c950-9f2b-4206-9bb7-74263dacc6e7': _mapQuiz(
    mapId: 'world_straits',
    interactionType: MapInteractionType.point,
    title: 'Estreitos do mundo',
    backgroundMapId: 'world_countries_bg',
  ),
  '8bf588de-aad5-4871-b0f5-fdf1bc4083c0': _mapQuiz(
    mapId: 'world_relief',
    interactionType: MapInteractionType.point,
    title: 'Relevo do mundo',
    backgroundMapId: 'world_countries_bg',
  ),
  '1fa3c3e7-b2b1-4530-a356-4240e157644f': _mapQuiz(
    mapId: 'world_soils',
    interactionType: MapInteractionType.point,
    title: 'Solos do mundo',
    backgroundMapId: 'world_countries_bg',
  ),
  '36f310e8-f7c0-4dd2-9151-cec01f4bee5c': _mapQuiz(
    mapId: 'world_currents',
    interactionType: MapInteractionType.line,
    title: 'Correntes marítimas',
    backgroundMapId: 'world_countries_bg',
  ),
  '3e6171a4-2d01-4fe7-8aed-f86614908ea9': _mapQuiz(
    mapId: 'brazil_relief',
    interactionType: MapInteractionType.point,
    title: 'Relevo do Brasil',
    backgroundMapId: 'brazil_states_bg',
  ),
  '91b59525-7426-4918-835d-0a12afe2c688': _mapQuiz(
    mapId: 'brazil_industry',
    interactionType: MapInteractionType.point,
    title: 'Indústria do Brasil',
    backgroundMapId: 'brazil_states_bg',
  ),
  '787ccefa-e009-4971-bcd0-35b20ba3b4bd': _mapQuiz(
    mapId: 'brazil_biomes',
    interactionType: MapInteractionType.polygon,
    title: 'Biomas do Brasil',
  ),
  'dddc6035-2ce5-49d6-ae2c-e902f6d14a67': _mapQuiz(
    mapId: 'world_biomes',
    interactionType: MapInteractionType.polygon,
    title: 'Biomas do mundo',
    backgroundMapId: 'world_countries_bg',
  ),
  'd9e7a22c-03de-4849-ad6d-3420107e4805': _mapQuiz(
    mapId: 'south_america_biomes',
    interactionType: MapInteractionType.polygon,
    title: 'Biomas da América do Sul',
    backgroundMapId: 'south_america_countries_bg',
  ),
};
