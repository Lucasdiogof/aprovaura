import 'package:flutter/widgets.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/presentation/pages/map_quiz_page.dart';

Widget Function(BuildContext) _mapQuiz({
  required String mapId,
  required MapInteractionType interactionType,
  required String title,
}) =>
    (_) => MapQuizPage(
      mapId: mapId,
      interactionType: interactionType,
      title: title,
    );

final Map<String, WidgetBuilder> mappedActivities = {
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
  ),
};
