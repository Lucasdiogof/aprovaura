import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/router/app_route_observer.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/favorites/l10n/favorites_strings.dart';
import 'package:aura/features/favorites/presentation/cubit/favorites_list_cubit.dart';
import 'package:aura/features/favorites/presentation/cubit/favorites_list_state.dart';
import 'package:aura/features/favorites/presentation/favorite_subject_style.dart';
import 'package:aura/features/favorites/presentation/pages/favorite_topic_page.dart';
import 'package:aura/features/favorites/presentation/widgets/favorite_nav_card.dart';
import 'package:aura/features/favorites/presentation/widgets/favorites_state_views.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// Middle level of Favorites: the topics inside one subject that still
/// have favorited questions. Reuses the same list_favorite_topics() load
/// as the landing page and filters client-side, so both screens always
/// agree on the counts.
class FavoriteSubjectPage extends StatefulWidget {
  const FavoriteSubjectPage({required this.subjectKey, super.key});

  final String subjectKey;

  @override
  State<FavoriteSubjectPage> createState() => _FavoriteSubjectPageState();
}

class _FavoriteSubjectPageState extends State<FavoriteSubjectPage>
    with RouteAware {
  late final _cubit = FavoritesListCubit(sl<FavoritesRepository>());

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

  @override
  void didPopNext() => _cubit.refresh();

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = FavoritesStrings(language);
    final style = favoriteSubjectStyle(
      widget.subjectKey,
      language,
      fallbackColor: context.colors.primary,
    );

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(
              title: style.label,
              subtitle: t.pageTitle,
              showBackButton: true,
            ),
            Expanded(
              child: BlocBuilder<FavoritesListCubit, FavoritesListState>(
                builder: (context, state) {
                  switch (state) {
                    case FavoritesListLoading():
                      return Center(
                        child: CircularProgressIndicator(color: style.color),
                      );
                    case FavoritesListError(:final message):
                      return FavoritesErrorView(
                        message: message,
                        retryLabel: t.retryButton,
                        onRetry: _cubit.load,
                      );
                    case FavoritesListLoaded(:final topics):
                      final subjectTopics = [
                        for (final topic in topics)
                          if (topic.subject == widget.subjectKey &&
                              topic.favoriteCount > 0)
                            topic,
                      ];
                      if (subjectTopics.isEmpty) {
                        return FavoritesEmptyView(
                          title: t.sectionEmptyTitle,
                          description: t.sectionEmptyDescription,
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        itemCount: subjectTopics.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final topic = subjectTopics[index];
                          return FavoriteNavCard(
                            icon: Icons.bookmark_rounded,
                            accentColor: style.color,
                            // The parent node is the region/area the topic
                            // sits under ("África" above "Lagos").
                            contextLabel: topic.parentTitle,
                            title: topic.title,
                            countLabel: t.favoritedQuestions(
                              topic.favoriteCount,
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => FavoriteTopicPage(
                                  topic: topic,
                                  subjectLabel: style.label,
                                  accentColor: style.color,
                                ),
                              ),
                            ),
                          );
                        },
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
