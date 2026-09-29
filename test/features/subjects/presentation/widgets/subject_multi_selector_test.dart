import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_multi_selector.dart';

void main() {
  testWidgets('"Quais matérias você mais quer estudar?" offers every '
      'subject, Redação included, and it can be picked', (tester) async {
    Subject? toggled;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SubjectMultiSelector(
              language: AppLanguage.portuguese,
              selected: const {},
              onToggle: (s) => toggled = s,
            ),
          ),
        ),
      ),
    );

    for (final subject in Subject.values) {
      expect(find.text(subject.label(AppLanguage.portuguese)), findsOneWidget);
    }
    await tester.ensureVisible(find.text('Redação'));
    await tester.tap(find.text('Redação'));
    expect(toggled, Subject.redacao);
  });
}
