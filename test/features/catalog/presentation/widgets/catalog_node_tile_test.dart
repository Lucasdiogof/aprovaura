import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/presentation/widgets/catalog_node_tile.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

void main() {
  const node = CatalogNode(id: 'n1', title: 'Funções', description: 'desc');

  Widget host(TopicProgress? progress) => BlocProvider<LocaleCubit>(
    create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
    child: MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: CatalogNodeTile(
          node: node,
          subject: Subject.matematica,
          progress: progress,
          onTap: () {},
        ),
      ),
    ),
  );

  group(CatalogNodeTile, () {
    testWidgets('an untouched topic shows no bar and no percentage', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const TopicProgress(completed: 0, total: 10)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('a started topic shows the bar and percentage', (tester) async {
      await tester.pumpWidget(
        host(const TopicProgress(completed: 3, total: 10)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('a completed topic shows the done state, not a 100% bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const TopicProgress(completed: 10, total: 10)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.text('Concluído'), findsOneWidget);
    });

    testWidgets('no progress data at all shows neither', (tester) async {
      await tester.pumpWidget(host(null));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('%'), findsNothing);
    });
  });
}
