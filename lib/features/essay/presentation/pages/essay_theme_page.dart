import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/cubit/essay_theme_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_theme_state.dart';
import 'package:aura/features/essay/presentation/pages/essay_editor_page.dart';
import 'package:aura/features/essay/presentation/widgets/essay_origin_badge.dart';
import 'package:aura/features/essay/presentation/widgets/essay_supporting_text_view.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// The proposal itself: prompt and motivating texts, laid out to be read.
///
/// The user's standing comes from the list ([summary]) instead of a second
/// query -- the list already fetched it, and re-asking would only add a
/// spinner to a screen that is meant to be opened and read.
class EssayThemePage extends StatelessWidget {
  const EssayThemePage({required this.summary, super.key});

  final EssayThemeSummary summary;

  String _ctaLabel(EssayStrings strings) {
    if (summary.hasDraft) return strings.continueButton;
    if (summary.hasBeenTried) return strings.newAttemptButton;
    return strings.startButton;
  }

  @override
  Widget build(BuildContext context) {
    final t = EssayStrings(context.watch<LocaleCubit>().state);
    return BlocProvider(
      create: (_) => EssayThemeCubit(sl<EssayRepository>(), summary.id),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(title: t.subjectLabel, showBackButton: true),
            Expanded(
              child: BlocBuilder<EssayThemeCubit, EssayThemeState>(
                builder: (context, state) => switch (state) {
                  EssayThemeLoading() => Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                  EssayThemeError() => _ErrorView(strings: t),
                  EssayThemeLoaded(:final theme) => _ThemeView(
                    theme: theme,
                    summary: summary,
                    strings: t,
                    ctaLabel: _ctaLabel(t),
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

class _ThemeView extends StatelessWidget {
  const _ThemeView({
    required this.theme,
    required this.summary,
    required this.strings,
    required this.ctaLabel,
  });

  final EssayTheme theme;
  final EssayThemeSummary summary;
  final EssayStrings strings;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      children: [
        EssayOriginBadge(origin: theme.origin, strings: strings),
        const SizedBox(height: AppSpacing.md),
        Text(
          theme.title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: colors.textPrimary,
          ),
        ),
        if (theme.description case final description?) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: TextStyle(color: colors.textSecondary, height: 1.45),
          ),
        ],
        if (summary.hasBeenTried) ...[
          const SizedBox(height: AppSpacing.lg),
          _AttemptSummary(summary: summary, strings: strings),
        ],
        const SizedBox(height: AppSpacing.xl),
        _SectionHeading(label: strings.proposalHeading),
        const SizedBox(height: AppSpacing.sm),
        Text(
          theme.prompt,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: colors.textPrimary,
          ),
        ),
        if (theme.supportingTexts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          _SectionHeading(label: strings.supportingTextsHeading),
          for (final text in theme.supportingTexts) ...[
            const SizedBox(height: AppSpacing.md),
            EssaySupportingTextView(text: text),
          ],
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: ctaLabel,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => EssayEditorPage(theme: theme),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: context.colors.textSecondary,
      ),
    );
  }
}

/// Last score and attempt count, kept deliberately small -- the full
/// history is its own screen, in a later phase.
class _AttemptSummary extends StatelessWidget {
  const _AttemptSummary({required this.summary, required this.strings});

  final EssayThemeSummary summary;
  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        if (summary.lastScore case final score?) ...[
          _Stat(label: strings.lastScoreLabel, value: '$score'),
          const SizedBox(width: AppSpacing.xl),
        ],
        _Stat(
          label: strings.attemptsLabel,
          value: '${summary.attemptCount}',
          muted: true,
          color: colors.textSecondary,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.muted = false,
    this.color,
  });

  final String label;
  final String value;
  final bool muted;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: muted ? 16 : 20,
            fontWeight: FontWeight.w800,
            color: color ?? colors.primary,
          ),
        ),
      ],
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
            Text(
              strings.themeErrorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: strings.retryButton,
              onPressed: () => context.read<EssayThemeCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}
