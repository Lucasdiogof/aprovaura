import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/atualidades/domain/entities/dossier_area.dart';
import 'package:aura/features/atualidades/domain/repositories/atualidades_repository.dart';
import 'package:aura/features/atualidades/l10n/atualidades_strings.dart';
import 'package:aura/features/atualidades/presentation/cubit/dossier_list_cubit.dart';
import 'package:aura/features/atualidades/presentation/cubit/dossier_list_state.dart';
import 'package:aura/features/atualidades/presentation/dossier_freshness.dart';
import 'package:aura/features/atualidades/presentation/pages/dossier_detail_page.dart';
import 'package:aura/features/catalog/l10n/catalog_strings.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class DossierListPage extends StatelessWidget {
  const DossierListPage({required this.area, super.key});

  final DossierArea area;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    return BlocProvider(
      create: (_) => DossierListCubit(sl<AtualidadesRepository>(), area),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(title: area.label(language), showBackButton: true),
            Expanded(
              child: BlocBuilder<DossierListCubit, DossierListState>(
                builder: (context, state) => switch (state) {
                  DossierListLoading() => Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                  DossierListError(:final message) => _ErrorView(
                    message: message,
                  ),
                  DossierListLoaded(dossiers: final dossiers)
                      when dossiers.isEmpty =>
                    const _ComingSoonView(),
                  DossierListLoaded(:final dossiers) => ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    itemCount: dossiers.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final dossier = dossiers[index];
                      final t = AtualidadesStrings(language);
                      final freshness = dossierFreshnessLabel(dossier, t);
                      return Material(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  DossierDetailPage(dossier: dossier),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: context.colors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dossier.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: context.colors.textPrimary,
                                        ),
                                      ),
                                      if (dossier.readMinutes != null ||
                                          freshness != null) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        Wrap(
                                          spacing: AppSpacing.sm,
                                          runSpacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            if (dossier.readMinutes != null)
                                              Text(
                                                t.readMinutesLabel(
                                                  dossier.readMinutes!,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: context
                                                      .colors
                                                      .textSecondary,
                                                ),
                                              ),
                                            if (freshness != null)
                                              _FreshnessBadge(label: freshness),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: context.colors.textSecondary,
                                ),
                              ],
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

class _FreshnessBadge extends StatelessWidget {
  const _FreshnessBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.colors.primary,
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
              onPressed: () => context.read<DossierListCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}
