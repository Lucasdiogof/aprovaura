import 'package:flutter/widgets.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/presentation/pages/map_quiz_page.dart';

const _brazilStatesNodeId = '294b30a4-5efc-49fc-ac23-302a3ff4d180';
const _europeCountriesNodeId = 'b1b8af46-010e-47dc-9be3-520ad7b987d3';
const _europeRiversNodeId = 'f61b0f28-002f-4064-beea-76e7bd89f845';

final Map<String, WidgetBuilder> mappedActivities = {
  _brazilStatesNodeId: (_) => const MapQuizPage(
    mapId: 'brazil_states',
    interactionType: MapInteractionType.polygon,
    title: 'Estados do Brasil',
  ),
  _europeCountriesNodeId: (_) => const MapQuizPage(
    mapId: 'europe_countries',
    interactionType: MapInteractionType.polygon,
    title: 'Países da Europa',
  ),
  _europeRiversNodeId: (_) => const MapQuizPage(
    mapId: 'europe_rivers',
    interactionType: MapInteractionType.line,
    title: 'Rios da Europa',
  ),
};
