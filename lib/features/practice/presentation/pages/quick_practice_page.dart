import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/practice/l10n/practice_strings.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/presentation/widgets/multiple_choice_view.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// A deck of questions the user has never answered, one per subject per
/// round. It is the ordinary quiz engine pointed at a different repository,
/// so answering here counts toward the originating topic's progress and a
/// wrong answer shows up under "revisar erros" like any other.
class QuickPracticePage extends StatelessWidget {
  const QuickPracticePage({super.key});

  /// The deck is not tied to a catalog node -- the quick-practice repository
  /// ignores this, and the engine only needs something to pass along.
  static const _noCatalogNode = '';

  @override
  Widget build(BuildContext context) {
    final t = PracticeStrings(context.watch<LocaleCubit>().state);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(title: t.quickPracticeTitle, showBackButton: true),
          Expanded(
            child: MultipleChoiceView(
              catalogNodeId: _noCatalogNode,
              repository: sl<QuestionRepository>(
                instanceName: 'quickPracticeQuestions',
              ),
              onEmpty: (context) => _NothingLeftView(strings: t),
              onSessionFinished: (sheetContext, cubit) {
                AppInfoBottomSheet.showInfo(
                  sheetContext,
                  title: t.quickPracticeMoreTitle,
                  description: t.quickPracticeMoreDescription,
                  primaryActionLabel: t.quickPracticeMoreConfirm,
                  // Reloading deals a fresh deck: the questions just
                  // answered now have progress rows, so the RPC skips them.
                  onPrimaryAction: cubit.load,
                  secondaryActionLabel: t.quickPracticeMoreDismiss,
                  onSecondaryAction: () => Navigator.of(context).maybePop(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Every question in the bank has been answered at least once. Rare, but
/// it is the natural end of the feature rather than an error.
class _NothingLeftView extends StatelessWidget {
  const _NothingLeftView({required this.strings});

  final PracticeStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.done_all_rounded, size: 40, color: colors.success),
            const SizedBox(height: 16),
            Text(
              strings.quickPracticeEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.quickPracticeEmptyDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: strings.quickPracticeMoreDismiss,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
