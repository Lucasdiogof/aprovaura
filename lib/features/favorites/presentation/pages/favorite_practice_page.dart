import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/favorites/l10n/favorites_strings.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/presentation/widgets/multiple_choice_view.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class FavoritePracticePage extends StatelessWidget {
  const FavoritePracticePage({
    required this.catalogNodeId,
    required this.title,
    super.key,
  });

  final String catalogNodeId;
  final String title;

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
              repository: sl<QuestionRepository>(
                instanceName: 'favoriteQuestions',
              ),
              awardsRewards: false,
              onEmpty: (_) => const _AllUnfavoritedView(),
            ),
          ),
        ],
      ),
    );
  }
}

// Reachable if the user unfavorites every question in this topic from
// another tab/session between opening this page and it loading.
class _AllUnfavoritedView extends StatelessWidget {
  const _AllUnfavoritedView();

  @override
  Widget build(BuildContext context) {
    final t = FavoritesStrings(context.watch<LocaleCubit>().state);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 40,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              t.emptyTitle,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
