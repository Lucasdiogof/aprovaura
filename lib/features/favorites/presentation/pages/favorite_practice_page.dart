import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/favorites/l10n/favorites_strings.dart';
import 'package:aura/features/favorites/presentation/widgets/favorites_state_views.dart';
import 'package:aura/features/questions/data/preloaded_question_repository.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/presentation/widgets/multiple_choice_view.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// Runs favorited questions through the same quiz engine as everywhere
/// else. Progress is tracked normally (trackProgress stays on), so
/// answering a "Precisa revisar" favorite correctly clears it from Revisar
/// erros and counts toward the topic's mastery exactly like answering it
/// anywhere else -- same upsert, no duplicate row. Rewards stay off, as
/// before: favorites are revisits of already-seen questions, and awarding
/// XP here would let the same bookmarked deck be farmed repeatedly.
class FavoritePracticePage extends StatelessWidget {
  const FavoritePracticePage({
    required this.catalogNodeId,
    required this.title,
    required this.questions,
    super.key,
    this.contextLabel,
  });

  final String catalogNodeId;
  final String title;
  final List<Question> questions;
  final String? contextLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(title: title, showBackButton: true),
          Expanded(
            child: MultipleChoiceView(
              catalogNodeId: catalogNodeId,
              repository: PreloadedQuestionRepository(questions),
              awardsRewards: false,
              contextLabel: contextLabel,
              onEmpty: (context) {
                final t = FavoritesStrings(context.watch<LocaleCubit>().state);
                return FavoritesEmptyView(
                  title: t.sectionEmptyTitle,
                  description: t.sectionEmptyDescription,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
