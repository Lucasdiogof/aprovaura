import 'package:flutter/widgets.dart';
import 'package:aura/features/map_quiz/presentation/pages/map_quiz_page.dart';

const _brazilStatesNodeId = '294b30a4-5efc-49fc-ac23-302a3ff4d180';

final Map<String, WidgetBuilder> mappedActivities = {
  _brazilStatesNodeId: (_) => const MapQuizPage(),
};
