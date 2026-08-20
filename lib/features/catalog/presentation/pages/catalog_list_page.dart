import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/router/app_route_observer.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/catalog/l10n/catalog_strings.dart';
import 'package:aura/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:aura/features/catalog/presentation/cubit/catalog_state.dart';
import 'package:aura/features/catalog/presentation/mapped_activities.dart';
import 'package:aura/features/catalog/presentation/widgets/catalog_node_tile.dart';
import 'package:aura/features/catalog/presentation/widgets/difficulty_selector.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/presentation/widgets/multiple_choice_view.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class CatalogListPage extends StatefulWidget {
  const CatalogListPage({
    required this.subject,
    required this.title,
    this.parentId,
    this.subtitle,
    this.difficulty,
    super.key,
  });

  final Subject subject;
  final String title;
  final String? subtitle;
  final String? parentId;
  final QuestionDifficulty? difficulty;

  @override
  State<CatalogListPage> createState() => _CatalogListPageState();
}

class _CatalogListPageState extends State<CatalogListPage> with RouteAware {
  late final _cubit = CatalogCubit(
    sl<CatalogRepository>(),
    sl<ProgressRepository>(),
    subject: widget.subject.name,
    parentId: widget.parentId,
    difficulty: widget.difficulty,
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

  // Called when a route pushed on top of this one (a finished activity, a
  // sub-topic list) is popped back to this one — refreshes the progress
  // bars without a CatalogLoading flash.
  @override
  void didPopNext() => _cubit.refresh();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(
              title: widget.title,
              subtitle: widget.subtitle,
              showBackButton: true,
            ),
            if (widget.parentId == null)
              BlocBuilder<CatalogCubit, CatalogState>(
                builder: (context, _) => Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: DifficultySelector(
                    selected: context.read<CatalogCubit>().difficulty,
                    accentColor: widget.subject.accentColor,
                    onChanged: (value) =>
                        context.read<CatalogCubit>().setDifficulty(value),
                  ),
                ),
              ),
            Expanded(
              child: BlocBuilder<CatalogCubit, CatalogState>(
                builder: (context, state) => switch (state) {
                  CatalogLoading() => Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                  CatalogError(:final message) => _ErrorView(message: message),
                  CatalogLoaded(nodes: final nodes) when nodes.isEmpty =>
                    widget.parentId == null
                        ? (context.read<CatalogCubit>().difficulty == null
                              ? const _ComingSoonView()
                              : const _DifficultyEmptyView())
                        : MultipleChoiceView(
                            catalogNodeId: widget.parentId!,
                            difficulty: context.read<CatalogCubit>().difficulty,
                            onEmpty: (_) => const _ComingSoonView(),
                          ),
                  CatalogLoaded(:final nodes, :final progressByNodeId) =>
                    ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: nodes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final node = nodes[index];
                        final activityBuilder = mappedActivities[node.id];
                        return CatalogNodeTile(
                          node: node,
                          accentColor: widget.subject.accentColor,
                          progress: progressByNodeId[node.id],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: activityBuilder != null
                                  ? (context) =>
                                        activityBuilder(context, node.id)
                                  : (_) => CatalogListPage(
                                      subject: widget.subject,
                                      title: node.title,
                                      subtitle: node.description,
                                      parentId: node.id,
                                      difficulty: context
                                          .read<CatalogCubit>()
                                          .difficulty,
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

class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView();

  @override
  Widget build(BuildContext context) {
    final t = CatalogStrings(context.watch<LocaleCubit>().state);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 40,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              t.comingSoonTitle,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.comingSoonDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyEmptyView extends StatelessWidget {
  const _DifficultyEmptyView();

  @override
  Widget build(BuildContext context) {
    final t = CatalogStrings(context.watch<LocaleCubit>().state);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 40,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              t.difficultyEmptyDescription,
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
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = CatalogStrings(context.watch<LocaleCubit>().state);
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
              label: t.retryButton,
              onPressed: () => context.read<CatalogCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}
