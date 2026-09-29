import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_achievement_badge.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_activity_completion.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_result.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_result_cubit.dart';
import 'package:aura/features/mock_exam/presentation/mock_exam_result_tier.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_review_page.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_setup_page.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/subject_style.dart';
import 'package:aura/shared/widgets/content_width.dart';
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
  const MockExamResultPage({required this.mockExamId, this.before, super.key});

  final String mockExamId;

  /// Where XP and the streak stood just before this exam was handed in,
  /// captured by the session screen. Null everywhere else this page is
  /// opened from (an exam closed on another device, and later a history
  /// screen): with nothing to diff against, the result opens in its final
  /// state and celebrates nothing.
  final AurudoRewardsSnapshot? before;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MockExamResultCubit(sl<MockExamRepository>(), mockExamId: mockExamId),
      child: _MockExamResultView(before: before),
    );
  }
}

class _MockExamResultView extends StatelessWidget {
  const _MockExamResultView({required this.before});

  final AurudoRewardsSnapshot? before;

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
                  key: ValueKey(result.mockExamId),
                  result: result,
                  strings: t,
                  language: language,
                  before: before,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The result, opened by the Aurudo Reaction System and then handed over
/// to the report.
///
/// Aurudo reacts to how it went, the score card sums it up, and the
/// breakdown by subject and by difficulty -- the reason anyone takes a
/// mock exam -- follows right under it in the same scroll. The mascot is
/// deliberately smaller here than on a quiz or a map: seven subjects to
/// read through are the point of this screen, and it never scrolls with
/// them.
class _ResultBody extends StatefulWidget {
  const _ResultBody({
    required this.result,
    required this.strings,
    required this.language,
    required this.before,
    super.key,
  });

  final MockExamResult result;
  final MockExamStrings strings;
  final AppLanguage language;
  final AurudoRewardsSnapshot? before;

  @override
  State<_ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends State<_ResultBody> {
  AurudoReaction? _reaction;
  bool _instant = false;

  /// The report waits its turn. Before the scene reaches it, the
  /// breakdowns and the actions are not in the tree at all -- not just
  /// invisible: nothing to tap, nothing to focus, nothing to reach by
  /// scrolling, and no empty space reserved where they will go.
  bool _reportVisible = false;

  MockExamResult get result => widget.result;
  MockExamStrings get strings => widget.strings;
  AppLanguage get language => widget.language;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nothing to wait for when the scene is not playing: a result being
    // reopened, or a reader who asked for less motion, gets the whole
    // screen at once.
    if (_instant || MediaQuery.disableAnimationsOf(context)) {
      _reportVisible = true;
    }
  }

  void _resolve() {
    // Nothing is granted here: finish_mock_exam() already did all of it
    // server-side, and this screen only reads. The reaction is resolved
    // from what the session screen saw before handing in versus what the
    // cubits hold now.
    //
    // The daily goal is deliberately left out on both sides: an exam's
    // answers count toward it while the exam is being taken, so the goal
    // may well have been reached twenty questions ago. Claiming it at
    // hand-in would celebrate the wrong moment.
    final reaction = resolveFromSnapshots(
      before: widget.before,
      after: widget.before == null
          ? null
          : AurudoRewardsSnapshot.fromCubits(context),
      correctCount: result.correctCount,
      totalAnswered: result.questionCount,
    );
    final alreadySeen = markReactionSeen(result.mockExamId);
    setState(() {
      _reaction = reaction;
      // Opened again, or reached without having just been handed in: the
      // scene does not replay.
      _instant = alreadySeen || widget.before == null;
      if (_instant) _reportVisible = true;
    });
  }

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

  /// The headline: the exam's own tier copy, which is already written in
  /// the sober voice this screen needs -- unless the hand-in also earned
  /// something, which takes the line instead. Perfect always wins.
  (String, String) _headlineFor(AurudoReaction reaction) {
    final t = strings;
    final isPerfect =
        result.questionCount > 0 && result.correctCount == result.questionCount;
    if (isPerfect) return (t.tierPerfectTitle, t.tierPerfectDescription);
    final tier = MockExamResultTier.fromAccuracy(result.accuracyPercent);
    final (title, description) = switch (tier) {
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
    return (t.reactionHeadline(reaction.type, title), description);
  }

  @override
  Widget build(BuildContext context) {
    final t = strings;
    final hasErrors = result.wrongCount > 0;
    final reaction = _reaction;
    final (headlineTitle, headlineDescription) = reaction == null
        ? ('', '')
        : _headlineFor(reaction);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        appHorizontalPadding(context),
        AppSpacing.lg,
        appHorizontalPadding(context),
        AppSpacing.xxl,
      ),
      children: [
        if (reaction != null)
          AurudoReactionStage(
            reaction: reaction,
            instant: _instant,
            // Smaller than on a quiz or a map on purpose: this screen has
            // a report to get to.
            mascotSize: 120,
            headline: _Headline(
              title: headlineTitle,
              description: headlineDescription,
            ),
            content: _ScoreCard(result: result, strings: t),
            stats: reaction.secondary.isEmpty
                ? null
                : _SecondaryBadgesRow(
                    achievements: reaction.secondary,
                    strings: t,
                  ),
            onSequenceCompleted: () {
              if (mounted && !_reportVisible) {
                setState(() => _reportVisible = true);
              }
            },
          )
        else
          _ScoreCard(result: result, strings: t),
        // Appended only when the scene gets to it: before that the report
        // is not in the tree, so there is no reserved gap, nothing to tap
        // and nothing to scroll to. It arrives under what is already on
        // screen, so nothing above it moves.
        if (_reportVisible)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: _instant
                ? Duration.zero
                : const Duration(milliseconds: 220),
            builder: (context, value, child) =>
                Opacity(opacity: value, child: child),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                SectionLabel(t.bySubjectTitle),
                _BreakdownCard(
                  lines: [
                    for (final line in _subjectsInAppOrder)
                      _subjectLine(context, line),
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
                        label: QuestionDifficulty.fromDb(
                          line.key,
                        ).label(language),
                        color: context.colors.primary,
                      ),
                  ],
                  strings: t,
                ),
                const SizedBox(height: AppSpacing.xxl),
                // At most three actions. Review first when there is something to
                // review (blanks never are -- they were never answered). This
                // exam's own wrong questions, not the cross-topic "Revisar erros"
                // (that one re-quizzes; this one only shows what happened).
                AppButton(
                  label: hasErrors
                      ? t.reviewMockExamButton
                      : t.anotherExamButton,
                  onPressed: () => hasErrors
                      ? Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => MockExamReviewPage(
                              mockExamId: result.mockExamId,
                            ),
                          ),
                        )
                      : Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const MockExamSetupPage(),
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
            ),
          ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// What handing this exam in earned, beyond the score. Perfect stays the
/// main reaction, so these are always badges beside it.
///
/// The daily goal is never here: an exam's answers count toward it while
/// the exam is being taken, so hand-in is the wrong moment to claim it.
class _SecondaryBadgesRow extends StatelessWidget {
  const _SecondaryBadgesRow({
    required this.achievements,
    required this.strings,
  });

  final List<AurudoSecondaryAchievement> achievements;
  final MockExamStrings strings;

  String _labelFor(AurudoSecondaryAchievement achievement) =>
      switch (achievement.type) {
        AurudoSecondaryAchievementType.levelUp => strings.levelUpBadge(
          achievement.value ?? 0,
        ),
        AurudoSecondaryAchievementType.streakMilestone =>
          strings.streakMilestoneBadge(achievement.value ?? 0),
        AurudoSecondaryAchievementType.dailyGoalComplete => '',
      };

  @override
  Widget build(BuildContext context) {
    final badges = [
      for (final achievement in achievements)
        if (achievement.type !=
            AurudoSecondaryAchievementType.dailyGoalComplete)
          AurudoAchievementBadge(
            achievement: achievement,
            label: _labelFor(achievement),
          ),
    ];
    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: badges,
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
              // Blanks can't happen any more (the exam only moves on after
              // an answer); only an exam from before that rule shows them.
              if (result.blankCount > 0)
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
