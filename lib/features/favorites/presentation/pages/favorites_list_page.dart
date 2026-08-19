import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/router/app_route_observer.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/favorites/l10n/favorites_strings.dart';
import 'package:aura/features/favorites/presentation/cubit/favorites_list_cubit.dart';
import 'package:aura/features/favorites/presentation/cubit/favorites_list_state.dart';
import 'package:aura/features/favorites/presentation/pages/favorite_practice_page.dart';
import 'package:aura/features/favorites/presentation/widgets/favorite_topic_card.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

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
                builder: (context, state) => switch (state) {
                  FavoritesListLoading() => Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                  FavoritesListError(:final message) => _ErrorView(
                    strings: t,
                    message: message,
                  ),
                  FavoritesListLoaded(topics: final topics)
                      when topics.isEmpty =>
                    _EmptyView(strings: t),
                  FavoritesListLoaded(:final topics) => ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: topics.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return FavoriteTopicCard(
                        topic: topic,
                        language: language,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => FavoritePracticePage(
                              catalogNodeId: topic.catalogNodeId,
                              title: topic.title,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.strings});

  final FavoritesStrings strings;

  @override
  Widget build(BuildContext context) {
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
              strings.emptyTitle,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.emptyDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.strings, required this.message});

  final FavoritesStrings strings;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: strings.retryButton,
              onPressed: () => context.read<FavoritesListCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}
