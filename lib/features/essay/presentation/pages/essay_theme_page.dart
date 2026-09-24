import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/cubit/essay_theme_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_theme_state.dart';
import 'package:aura/features/essay/presentation/pages/essay_editor_page.dart';
import 'package:aura/features/essay/presentation/widgets/essay_attempt_row.dart';
import 'package:aura/features/essay/presentation/widgets/essay_origin_badge.dart';
import 'package:aura/features/essay/presentation/widgets/essay_supporting_text_view.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/content_width.dart';
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
    // A draft that came after an attempt is a new one being written, and
    // saying so keeps it clear that the old attempt is untouched.
    if (summary.hasDraft) {
      return summary.hasBeenTried
          ? strings.continueNewAttemptButton
          : strings.continueButton;
    }
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
                  EssayThemeLoaded(:final theme, :final attempts) => _ThemeView(
                    theme: theme,
                    summary: summary,
                    attempts: attempts,
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
    required this.attempts,
    required this.strings,
    required this.ctaLabel,
  });

  final EssayTheme theme;
  final EssayThemeSummary summary;
  final List<EssayAttempt> attempts;
  final EssayStrings strings;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        appHorizontalPadding(context),
        AppSpacing.md,
        appHorizontalPadding(context),
        AppSpacing.xxl,
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: EssayOriginBadge(origin: theme.origin, strings: strings),
        ),
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
        // History after the proposal, not in the middle of it: reading the
        // theme and reviewing past attempts are different errands.
        if (attempts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          _SectionHeading(label: strings.attemptsHeading),
          for (final attempt in attempts) ...[
            const SizedBox(height: AppSpacing.sm),
            EssayAttemptRow(attempt: attempt, strings: strings),
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
