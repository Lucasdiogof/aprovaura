import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// Placeholder for the editor, which is the next phase.
///
/// Deliberately not a text field: an empty box that looks like an editor
/// would invite writing that nothing can save yet. It states plainly what
/// is coming and gets out of the way.
class EssayEditorPage extends StatelessWidget {
  const EssayEditorPage({required this.theme, super.key});

  final EssayTheme theme;

  @override
  Widget build(BuildContext context) {
    final t = EssayStrings(context.watch<LocaleCubit>().state);
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          ModernAppBar(title: theme.title, showBackButton: true),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AurudoIllustration(pose: AurudoPose.studying),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      t.editorComingTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      t.editorComingDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: t.backButton,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
