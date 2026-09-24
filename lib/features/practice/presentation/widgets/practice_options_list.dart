import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/error_review/presentation/pages/error_review_list_page.dart';
import 'package:aura/features/favorites/presentation/pages/favorites_list_page.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_cubit.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_state.dart';
import 'package:aura/features/practice/domain/entities/practice_option.dart';
import 'package:aura/features/practice/l10n/practice_strings.dart';
import 'package:aura/features/practice/presentation/pages/quick_practice_page.dart';
import 'package:aura/features/practice/presentation/widgets/practice_option_card.dart';

/// The three ways into practice that don't start from a subject: a quick
/// mixed deck, the pending mistakes, and the saved questions. They live on
/// Home, where they are the first thing offered after the daily-goal card.
class PracticeOptionsList extends StatelessWidget {
  const PracticeOptionsList({super.key});

  void _open(BuildContext context, PracticeOption option) {
    final page = switch (option) {
      PracticeOption.quickPractice => const QuickPracticePage(),
      PracticeOption.reviewMistakes => const ErrorReviewListPage(),
      PracticeOption.favorites => const FavoritesListPage(),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  // Only reviewMistakes/favorites get a live count -- quickPractice's
  // description doesn't depend on any number.
  String? _subtitleFor(
    PracticeOption option,
    PracticeStrings strings,
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
      PracticeOption.quickPractice => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final strings = PracticeStrings(language);
    final summaryState = context.watch<HomeSummaryCubit>().state;
    return Column(
      children: [
        for (final option in PracticeOption.values) ...[
          PracticeOptionCard(
            option: option,
            language: language,
            subtitleOverride: _subtitleFor(option, strings, summaryState),
            onTap: () => _open(context, option),
          ),
          if (option != PracticeOption.values.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
