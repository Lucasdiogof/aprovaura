import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_state.dart';

/// "Salvando... / Salvo / Não foi possível salvar", in small type above the
/// writing area. Deliberately not a snackbar: autosave fires constantly,
/// and a toast per save would be unbearable while writing.
class EssaySaveStatusLine extends StatelessWidget {
  const EssaySaveStatusLine({
    required this.status,
    required this.strings,
    super.key,
  });

  /// Fixed height so the writing area never shifts when the label changes.
  static const height = 18.0;

  final EssaySaveStatus status;
  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (status == EssaySaveStatus.idle) {
      return const SizedBox(height: height);
    }

    final label = switch (status) {
      EssaySaveStatus.saving => strings.savingStatus,
      EssaySaveStatus.saved => strings.savedStatus,
      EssaySaveStatus.failed => strings.saveFailedStatus,
      EssaySaveStatus.idle => '',
    };
    final color = switch (status) {
      EssaySaveStatus.saved => colors.success,
      EssaySaveStatus.failed => colors.error,
      _ => colors.textSecondary,
    };

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (status == EssaySaveStatus.failed) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.read<EssayEditorCubit>().retrySave(),
              child: Text(
                strings.retrySaveAction,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
