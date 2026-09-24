import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/router/app_route_observer.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/favorites/domain/entities/favorite_topic.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/favorites/l10n/favorites_strings.dart';
import 'package:aura/features/favorites/presentation/cubit/favorite_questions_cubit.dart';
import 'package:aura/features/favorites/presentation/cubit/favorite_questions_state.dart';
import 'package:aura/features/favorites/presentation/pages/favorite_practice_page.dart';
import 'package:aura/features/favorites/presentation/widgets/favorite_question_tile.dart';
import 'package:aura/features/favorites/presentation/widgets/favorites_state_views.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// Bottom level of Favorites: every favorited question in one topic, with
/// its difficulty and whether the user has answered it right, wrong, or not
/// at all. Tapping one opens just that question in the regular quiz
/// engine; "Praticar todas" opens the whole list in the same order.
class FavoriteTopicPage extends StatefulWidget {
  const FavoriteTopicPage({
    required this.topic,
    required this.subjectLabel,
    required this.accentColor,
    super.key,
  });

  final FavoriteTopic topic;
  final String subjectLabel;
  final Color accentColor;

  @override
  State<FavoriteTopicPage> createState() => _FavoriteTopicPageState();
}

class _FavoriteTopicPageState extends State<FavoriteTopicPage> with RouteAware {
  late final _cubit = FavoriteQuestionsCubit(
    sl<FavoritesRepository>(),
    catalogNodeId: widget.topic.catalogNodeId,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) appRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _cubit.close();
    super.dispose();
  }

  // Coming back from practice: statuses may have changed (a wrong one
  // answered right) and questions may have been unfavorited.
  @override
  void didPopNext() => _cubit.refresh();

  String get _contextLabel => [
    widget.subjectLabel,
    ?widget.topic.parentTitle,
    widget.topic.title,
  ].join(' · ');

  void _practice(List<Question> questions) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FavoritePracticePage(
          catalogNodeId: widget.topic.catalogNodeId,
          title: widget.topic.title,
          contextLabel: _contextLabel,
          questions: questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = FavoritesStrings(language);
    final subtitle = widget.topic.parentTitle == null
        ? widget.subjectLabel
        : '${widget.subjectLabel} · ${widget.topic.parentTitle}';

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(
              title: widget.topic.title,
              subtitle: subtitle,
              showBackButton: true,
            ),
            Expanded(
              child:
                  BlocBuilder<FavoriteQuestionsCubit, FavoriteQuestionsState>(
                    builder: (context, state) {
                      switch (state) {
                        case FavoriteQuestionsLoading():
                          return Center(
                            child: CircularProgressIndicator(
                              color: widget.accentColor,
                            ),
                          );
                        case FavoriteQuestionsError(:final message):
                          return FavoritesErrorView(
                            message: message,
                            retryLabel: t.retryButton,
                            onRetry: _cubit.load,
                          );
                        case FavoriteQuestionsLoaded(:final questions)
                            when questions.isEmpty:
                          return FavoritesEmptyView(
                            title: t.sectionEmptyTitle,
                            description: t.sectionEmptyDescription,
                          );
                        case FavoriteQuestionsLoaded(:final questions):
                          return ListView(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            children: [
                              Text(
                                t.favoritedQuestions(questions.length),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: widget.accentColor,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppButton(
                                label: t.practiceAllButton,
                                onPressed: () => _practice([
                                  for (final favorite in questions)
                                    favorite.question,
                                ]),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              for (final favorite in questions) ...[
                                FavoriteQuestionTile(
                                  favorite: favorite,
                                  language: language,
                                  onTap: () => _practice([favorite.question]),
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                            ],
                          );
                      }
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
