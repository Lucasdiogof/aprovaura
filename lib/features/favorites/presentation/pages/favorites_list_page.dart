import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/router/app_route_observer.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/favorites/domain/entities/favorite_subject.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/favorites/l10n/favorites_strings.dart';
import 'package:aura/features/favorites/presentation/cubit/favorites_list_cubit.dart';
import 'package:aura/features/favorites/presentation/cubit/favorites_list_state.dart';
import 'package:aura/features/subjects/presentation/subject_style.dart';
import 'package:aura/features/favorites/presentation/pages/favorite_subject_page.dart';
import 'package:aura/features/favorites/presentation/widgets/favorite_nav_card.dart';
import 'package:aura/features/favorites/presentation/widgets/favorites_state_views.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// Top level of Favorites: one row per subject that still has at least
/// one favorited question. Subject → topic → questions.
class FavoritesListPage extends StatefulWidget {
  const FavoritesListPage({super.key});

  @override
  State<FavoritesListPage> createState() => _FavoritesListPageState();
}

class _FavoritesListPageState extends State<FavoritesListPage> with RouteAware {
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
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(title: t.pageTitle, showBackButton: true),
            Expanded(
              child: BlocBuilder<FavoritesListCubit, FavoritesListState>(
                builder: (context, state) {
                  switch (state) {
                    case FavoritesListLoading():
                      return Center(
                        child: CircularProgressIndicator(
                          color: context.colors.primary,
                        ),
                      );
                    case FavoritesListError(:final message):
                      return FavoritesErrorView(
                        message: message,
                        retryLabel: t.retryButton,
                        onRetry: _cubit.load,
                      );
                    case FavoritesListLoaded(:final topics):
                      final subjects = FavoriteSubject.group(topics);
                      if (subjects.isEmpty) {
                        return FavoritesEmptyView(
                          title: t.emptyTitle,
                          description: t.emptyDescription,
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        itemCount: subjects.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final group = subjects[index];
                          final style = subjectStyle(
                            group.subject,
                            language,
                            fallbackColor: context.colors.primary,
                          );
                          return FavoriteNavCard(
                            icon: style.icon,
                            accentColor: style.color,
                            title: style.label,
                            countLabel: t.favoritedQuestions(
                              group.questionCount,
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => FavoriteSubjectPage(
                                  subjectKey: group.subject,
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
