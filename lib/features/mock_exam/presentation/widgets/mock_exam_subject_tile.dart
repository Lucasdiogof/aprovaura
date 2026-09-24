import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_setup_state.dart';
import 'package:aura/features/subjects/presentation/subject_style.dart';

/// One subject on "Montar simulado": a compact row that toggles selection,
/// expanding in place into level chips + the question stepper. All limits
/// come from [state] (real availability and the 180 cap); this widget only
/// renders them and forwards taps.
class MockExamSubjectTile extends StatelessWidget {
  const MockExamSubjectTile({
    required this.subject,
    required this.state,
    required this.language,
    required this.onToggle,
    required this.onDifficultyChanged,
    required this.onIncrease,
    required this.onDecrease,
    super.key,
  });

  final String subject;
  final MockExamSetupState state;
  final AppLanguage language;
  final VoidCallback onToggle;
  final ValueChanged<MockExamDifficulty> onDifficultyChanged;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    final t = MockExamStrings(language);
    final style = subjectStyle(
      subject,
      language,
      fallbackColor: context.colors.primary,
    );
    final entry = state.selections[subject];
    final isSelected = entry != null;
    final canToggle = state.canSelect(subject) && !state.isSubmitting;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isSelected
              ? style.color.withValues(alpha: 0.6)
              : context.colors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            checked: isSelected,
            enabled: canToggle,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: canToggle ? onToggle : null,
              child: Opacity(
                opacity: canToggle ? 1 : 0.45,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(style.icon, color: style.color, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          style.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                      _CheckMark(isSelected: isSelected, color: style.color),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !isSelected
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(t.difficultyLabel),
                        const SizedBox(height: AppSpacing.xs + 2),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final difficulty in MockExamDifficulty.values)
                              _DifficultyChip(
                                label: difficulty.label(language),
                                isSelected: entry.difficulty == difficulty,
                                isEnabled:
                                    !state.isSubmitting &&
                                    state.available(subject, difficulty) > 0,
                                color: style.color,
                                onTap: () => onDifficultyChanged(difficulty),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel(t.quantityLabel),
                                  const SizedBox(height: 2),
                                  Text(
                                    t.availableCount(
                                      state.available(
                                        subject,
                                        entry.difficulty,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StepButton(
                              icon: Icons.remove_rounded,
                              tooltip: t.decreaseTooltip,
                              onPressed:
                                  state.canDecrease(subject) &&
                                      !state.isSubmitting
                                  ? onDecrease
                                  : null,
                            ),
                            SizedBox(
                              width: 44,
                              child: Text(
                                '${entry.questionCount}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                            _StepButton(
                              icon: Icons.add_rounded,
                              tooltip: t.increaseTooltip,
                              onPressed:
                                  state.canIncrease(subject) &&
                                      !state.isSubmitting
                                  ? onIncrease
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.isSelected, required this.color});

  final bool isSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : context.colors.textHint,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: context.colors.textSecondary,
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.label,
    required this.isSelected,
    required this.isEnabled,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isEnabled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = !isEnabled
        ? context.colors.textHint
        : isSelected
        ? color
        : context.colors.textPrimary;
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      child: Material(
        color: isSelected
            ? color.withValues(alpha: 0.16)
            : context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: isEnabled && !isSelected ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: isSelected
                    ? color
                    : context.colors.border.withValues(
                        alpha: isEnabled ? 1 : 0.5,
                      ),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: foreground,
                decoration: isEnabled ? null : TextDecoration.lineThrough,
                decorationColor: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: onPressed,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: isEnabled
                    ? context.colors.border
                    : context.colors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isEnabled
                  ? context.colors.textPrimary
                  : context.colors.textHint,
            ),
          ),
        ),
      ),
    );
  }
}
