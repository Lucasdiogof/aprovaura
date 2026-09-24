import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/cubit/essay_themes_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_themes_state.dart';
import 'package:aura/features/essay/presentation/pages/essay_theme_page.dart';
import 'package:aura/features/essay/presentation/widgets/essay_theme_card.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// The list of writing prompts. Themes come from the database -- nothing
/// here is hardcoded, and the order is the server's, so the list never
/// reshuffles between openings.
class EssayThemesPage extends StatelessWidget {
  const EssayThemesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = EssayStrings(context.watch<LocaleCubit>().state);
    return BlocProvider(
      create: (_) => EssayThemesCubit(sl<EssayRepository>()),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(title: t.subjectLabel, showBackButton: true),
            Expanded(
              child: BlocBuilder<EssayThemesCubit, EssayThemesState>(
                builder: (context, state) => switch (state) {
                  EssayThemesLoading() => Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                  EssayThemesError() => _ErrorView(strings: t),
                  EssayThemesLoaded(:final themes) when themes.isEmpty =>
                    _EmptyView(strings: t),
                  EssayThemesLoaded(:final themes) => _ThemeList(
                    themes: themes,
                    strings: t,
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

class _ThemeList extends StatelessWidget {
  const _ThemeList({required this.themes, required this.strings});

  final List<EssayThemeSummary> themes;
  final EssayStrings strings;

  Future<void> _open(BuildContext context, EssayThemeSummary summary) async {
    final cubit = context.read<EssayThemesCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EssayThemePage(summary: summary)),
    );
    // A draft may have appeared while the theme was open.
    await cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      itemCount: themes.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              strings.themesSubtitle,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          );
        }
        final summary = themes[index - 1];
        return EssayThemeCard(
          summary: summary,
          strings: strings,
          onTap: () => _open(context, summary),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.strings});

  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AurudoIllustration(pose: AurudoPose.neutral),
            const SizedBox(height: AppSpacing.lg),
            Text(
              strings.emptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.strings});

  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AurudoIllustration(pose: AurudoPose.frustrated, size: 120),
            const SizedBox(height: AppSpacing.lg),
            Text(
              strings.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: strings.retryButton,
              onPressed: () => context.read<EssayThemesCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}
