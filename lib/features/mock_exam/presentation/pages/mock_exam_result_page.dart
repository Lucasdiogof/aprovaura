import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/error_review/presentation/pages/error_review_list_page.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_result.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_result_cubit.dart';
import 'package:aura/features/mock_exam/presentation/mock_exam_result_tier.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_setup_page.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/subject_style.dart';
import 'package:aura/features/mock_exam/presentation/widgets/mock_exam_content_width.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';
import 'package:aura/shared/widgets/section_label.dart';
import 'package:aura/shared/widgets/aura/aura_glyph.dart';
import 'package:aura/shared/widgets/stat_cell.dart';

/// A finished mock exam's result, loaded from the server by [mockExamId]
/// -- never handed over as an in-memory object, so it can be reloaded,
/// reopened, and (later) reached from a history screen. Every number here
/// is the server's; the screen only lays them out.
class MockExamResultPage extends StatelessWidget {
  const MockExamResultPage({required this.mockExamId, super.key});

  final String mockExamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MockExamResultCubit(sl<MockExamRepository>(), mockExamId: mockExamId),
      child: const _MockExamResultView(),
    );
  }
}

class _MockExamResultView extends StatelessWidget {
  const _MockExamResultView();

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = MockExamStrings(language);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(title: t.resultPageTitle, showBackButton: true),
          Expanded(
            child: BlocBuilder<MockExamResultCubit, MockExamResultState>(
              builder: (context, state) => switch (state) {
                MockExamResultLoading() => Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                ),
                MockExamResultError() => _MessageView(
                  message: t.resultLoadError,
                  actionLabel: t.retryButton,
                  onAction: context.read<MockExamResultCubit>().load,
                ),
                MockExamResultNotFound() => _MessageView(
                  message: t.resultNotFound,
                  actionLabel: t.backHomeButton,
                  onAction: () => Navigator.of(context).pop(),
                ),
                MockExamResultLoaded(:final result) => _ResultBody(
                  result: result,
                  strings: t,
                  language: language,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.result,
    required this.strings,
    required this.language,
  });

  final MockExamResult result;
  final MockExamStrings strings;
  final AppLanguage language;

  /// Subjects in the app's usual order (the server sorts alphabetically).
  List<MockExamResultLine> get _subjectsInAppOrder {
    int rank(String key) {
      final index = Subject.values.indexWhere((s) => s.name == key);
      return index < 0 ? Subject.values.length : index;
    }

    return [...result.bySubject]
      ..sort((a, b) => rank(a.key).compareTo(rank(b.key)));
  }

  _LineData _subjectLine(BuildContext context, MockExamResultLine line) {
    final style = subjectStyle(
      line.key,
      language,
      fallbackColor: context.colors.primary,
    );
    return _LineData(
      line: line,
      label: style.label,
      icon: style.icon,
      color: style.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = strings;
    final hasErrors = result.wrongCount > 0;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        mockExamHorizontalPadding(context),
        AppSpacing.lg,
        mockExamHorizontalPadding(context),
        AppSpacing.xxl,
      ),
      children: [
        _ScoreCard(result: result, strings: t),
        const SizedBox(height: AppSpacing.xxl),
        SectionLabel(t.bySubjectTitle),
        _BreakdownCard(
          lines: [
            for (final line in _subjectsInAppOrder) _subjectLine(context, line),
          ],
          strings: t,
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionLabel(t.byDifficultyTitle),
        _BreakdownCard(
          lines: [
            for (final line in result.byDifficulty)
              _LineData(
                line: line,
                label: QuestionDifficulty.fromDb(line.key).label(language),
                color: context.colors.primary,
              ),
          ],
          strings: t,
        ),
        const SizedBox(height: AppSpacing.xxl),
        // At most three actions. Review first when there is something to
        // review (blanks never are -- they were never answered).
        AppButton(
          label: hasErrors ? t.reviewErrorsButton : t.anotherExamButton,
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => hasErrors
                  ? const ErrorReviewListPage()
                  : const MockExamSetupPage(),
            ),
          ),
        ),
        if (hasErrors) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const MockExamSetupPage(),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Text(t.anotherExamButton),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.backHomeButton),
        ),
      ],
    );
  }
}

/// Score ring (accuracy) + "68 / 90 corretas" + the tier message, then
/// wrong / blank / Aura. Correct is only in the headline and the percentage
/// only in the ring -- nothing said twice. Wrong and blank are always
/// separate, and the Aura is what the server actually credited.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result, required this.strings});

  final MockExamResult result;
  final MockExamStrings strings;

  @override
  Widget build(BuildContext context) {
    final t = strings;
    final tier = MockExamResultTier.fromAccuracy(result.accuracyPercent);
    final (tierTitle, tierDescription) = switch (tier) {
      MockExamResultTier.review => (t.tierReviewTitle, t.tierReviewDescription),
      MockExamResultTier.advancing => (
        t.tierAdvancingTitle,
        t.tierAdvancingDescription,
      ),
      MockExamResultTier.good => (t.tierGoodTitle, t.tierGoodDescription),
      MockExamResultTier.excellent => (
        t.tierExcellentTitle,
        t.tierExcellentDescription,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: (result.accuracyPercent / 100).clamp(0, 1),
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      backgroundColor: context.colors.border,
                      color: context.colors.primary,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: FittedBox(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t.percent(result.accuracyPercent),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              Text(
                                t.accuracyWord,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: t.score(
                              result.correctCount,
                              result.questionCount,
                            ),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' ${t.correctSuffix}',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      tierTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tierDescription,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: context.colors.border, height: AppSpacing.xxl * 1.5),
          Row(
            children: [
              _Stat(
                icon: Icons.close_rounded,
                color: context.colors.error,
                value: '${result.wrongCount}',
                label: t.statWrong,
              ),
              _Stat(
                icon: Icons.remove_rounded,
                color: context.colors.textSecondary,
                value: '${result.blankCount}',
                label: t.statBlank,
              ),
              _Stat(
                icon: Icons.bolt_rounded,
                color: context.colors.auraViolet,
                glyph: true,
                value: '+${result.xpAwarded}',
                label: t.statAura,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            t.resultMeta(result.questionCount, result.subjectCount),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.glyph = false,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  /// Shows the Aura glyph instead of [icon] (the Aura earned).
  final bool glyph;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: StatCell(
          icon: icon,
          iconColor: color,
          iconWidget: glyph ? const AuraGlyph(size: 22) : null,
          value: value,
          label: label,
        ),
      ),
    );
  }
}

class _LineData {
  const _LineData({
    required this.line,
    required this.label,
    required this.color,
    this.icon,
  });

  final MockExamResultLine line;
  final String label;
  final Color color;
  final IconData? icon;
}

/// One grouped container per dimension, with thin dividers between rows,
/// instead of a stack of separate cards.
class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.lines, required this.strings});

  final List<_LineData> lines;
  final MockExamStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.colors.border),
            _BreakdownRow(data: lines[i], strings: strings),
          ],
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.data, required this.strings});

  final _LineData data;
  final MockExamStrings strings;

  @override
  Widget build(BuildContext context) {
    final line = data.line;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (data.icon != null) ...[
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(data.icon, size: 18, color: data.color),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      strings.score(line.correctCount, line.questionCount),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 52,
                      child: Text(
                        strings.percent(line.accuracyPercent),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: (line.accuracyPercent / 100).clamp(0, 1),
                    minHeight: 5,
                    backgroundColor: context.colors.border,
                    valueColor: AlwaysStoppedAnimation(data.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

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
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),
            AppButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}
