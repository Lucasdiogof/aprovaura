import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/catalog/l10n/catalog_strings.dart';
import 'package:aura/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:aura/features/catalog/presentation/cubit/catalog_state.dart';
import 'package:aura/features/catalog/presentation/mapped_activities.dart';
import 'package:aura/features/catalog/presentation/widgets/catalog_node_tile.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class CatalogListPage extends StatelessWidget {
  const CatalogListPage({
    required this.subject,
    required this.title,
    this.parentId,
    this.subtitle,
    super.key,
  });

  final Subject subject;
  final String title;
  final String? subtitle;
  final String? parentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CatalogCubit(
        sl<CatalogRepository>(),
        subject: subject.name,
        parentId: parentId,
      ),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(
              title: title,
              subtitle: subtitle,
              showBackButton: true,
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
                    const _ComingSoonView(),
                  CatalogLoaded(:final nodes) => ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: nodes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final node = nodes[index];
                      final activityBuilder = mappedActivities[node.id];
                      return CatalogNodeTile(
                        node: node,
                        accentColor: subject.accentColor,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder:
                                activityBuilder ??
                                (_) => CatalogListPage(
                                  subject: subject,
                                  title: node.title,
                                  subtitle: node.description,
                                  parentId: node.id,
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
