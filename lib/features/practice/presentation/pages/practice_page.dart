import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/error_review/presentation/pages/error_review_list_page.dart';
import 'package:aura/features/favorites/presentation/pages/favorites_list_page.dart';
import 'package:aura/features/practice/domain/entities/practice_option.dart';
import 'package:aura/features/practice/l10n/practice_strings.dart';
import 'package:aura/features/practice/presentation/widgets/practice_option_card.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  void _openOption(BuildContext context, PracticeOption option) {
    switch (option) {
      case PracticeOption.reviewMistakes:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ErrorReviewListPage()),
        );
      case PracticeOption.favorites:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const FavoritesListPage()),
        );
      // No functional destination yet for the others — callbacks are wired
      // per option so navigation can be added later without touching this
      // page's layout.
      case PracticeOption.quickPractice:
      case PracticeOption.chooseSubject:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = PracticeStrings(language);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.pageTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.pageSubtitle,
                style: TextStyle(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: PracticeOption.values.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = PracticeOption.values[index];
                    return PracticeOptionCard(
                      option: option,
                      language: language,
                      onTap: () => _openOption(context, option),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
