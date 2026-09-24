import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/error_review/presentation/pages/error_review_list_page.dart';
import 'package:aura/features/favorites/presentation/pages/favorites_list_page.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_cubit.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_state.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_session_page.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_setup_page.dart';
import 'package:aura/features/mock_exam/presentation/widgets/mock_exam_active_sheet.dart';
import 'package:aura/features/practice/domain/entities/practice_option.dart';
import 'package:aura/features/practice/l10n/practice_strings.dart';
import 'package:aura/features/practice/presentation/pages/quick_practice_page.dart';
import 'package:aura/features/practice/presentation/widgets/practice_option_card.dart';

/// The ways into practice that don't start from a subject: a quick mixed
/// deck, the pending mistakes, the saved questions, and a mock exam. They
/// live on Home, where they are the first thing offered after the
/// daily-goal card.
class PracticeOptionsList extends StatelessWidget {
  const PracticeOptionsList({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _open(
    BuildContext context,
    PracticeOption option,
    ActiveMockExam? activeMockExam,
  ) {
    final page = switch (option) {
      PracticeOption.quickPractice => const QuickPracticePage(),
      PracticeOption.reviewMistakes => const ErrorReviewListPage(),
      PracticeOption.favorites => const FavoritesListPage(),
      // With one in progress the card reads "Continuar simulado" and goes
      // straight back into it; otherwise it opens the setup screen.
      PracticeOption.mockExam =>
        activeMockExam == null
            ? const MockExamSetupPage()
            : MockExamSessionPage(mockExamId: activeMockExam.id),
    };
    _push(context, page);
  }

  /// "Montar outro" while one is in progress: never discards on its own --
  /// the user picks continue or discard in the sheet first.
  Future<void> _buildAnother(
    BuildContext context,
    ActiveMockExam active,
    AppLanguage language,
  ) async {
    final choice = await showMockExamActiveSheet(
      context,
      active: active,
      language: language,
      onDiscard: (id) async {
        final result = await sl<MockExamRepository>().abandonMockExam(id);
        return switch (result) {
          Success() => null,
          Error(:final failure) =>
            failure is MockExamFailure
                ? failure
                : MockExamFailure(MockExamFailureKind.unexpected),
        };
      },
    );
    if (!context.mounted) return;
    switch (choice) {
      case MockExamActiveChoice.continueExam:
        _push(context, MockExamSessionPage(mockExamId: active.id));
      case MockExamActiveChoice.discarded:
        // Refresh right away so the card is back to "Montar simulado" even
        // before the setup screen is popped.
        unawaited(context.read<HomeSummaryCubit>().refresh());
        _push(context, const MockExamSetupPage());
      case null:
        break;
    }
  }

  // Only reviewMistakes/favorites/mockExam get a live subtitle --
  // quickPractice's description doesn't depend on any number.
  String? _subtitleFor(
    PracticeOption option,
    PracticeStrings strings,
    MockExamStrings mockExamStrings,
    HomeSummaryState summaryState,
  ) {
    if (summaryState is! HomeSummaryLoaded) return null;
    return switch (option) {
      PracticeOption.reviewMistakes =>
        summaryState.pendingErrorsCount == null
            ? null
            : strings.pendingReviewCount(summaryState.pendingErrorsCount!),
      PracticeOption.favorites =>
        summaryState.favoritesCount == null
            ? null
            : strings.savedFavoritesCount(summaryState.favoritesCount!),
      PracticeOption.mockExam => switch (summaryState.activeMockExam) {
        final active? => mockExamStrings.answeredProgress(
          active.answeredCount,
          active.questionCount,
        ),
        null => null,
      },
      PracticeOption.quickPractice => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final strings = PracticeStrings(language);
    final mockExamStrings = MockExamStrings(language);
    final summaryState = context.watch<HomeSummaryCubit>().state;
    final activeMockExam = summaryState is HomeSummaryLoaded
        ? summaryState.activeMockExam
        : null;
    return Column(
      children: [
        for (final option in PracticeOption.values) ...[
          PracticeOptionCard(
            option: option,
            language: language,
            titleOverride:
                option == PracticeOption.mockExam && activeMockExam != null
                ? mockExamStrings.continueTitle
                : null,
            subtitleOverride: _subtitleFor(
              option,
              strings,
              mockExamStrings,
              summaryState,
            ),
            onTap: () => _open(context, option, activeMockExam),
          ),
          if (option == PracticeOption.mockExam && activeMockExam != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    _buildAnother(context, activeMockExam, language),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(mockExamStrings.buildAnotherButton),
              ),
            ),
          if (option != PracticeOption.values.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
