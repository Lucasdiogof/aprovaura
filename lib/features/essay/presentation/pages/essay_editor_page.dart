import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/essay_rules.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_state.dart';
import 'package:aura/features/essay/presentation/widgets/essay_delete_draft_sheet.dart';
import 'package:aura/features/essay/presentation/widgets/essay_prompt_sheet.dart';
import 'package:aura/features/essay/presentation/pages/essay_submission_page.dart';
import 'package:aura/features/essay/presentation/widgets/essay_save_status_line.dart';
import 'package:aura/features/essay/presentation/widgets/essay_submit_sheet.dart';
import 'package:aura/features/essay/presentation/widgets/essay_unsaved_sheet.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/content_width.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';

/// Where the essay is actually written.
///
/// The text lives in a [TextEditingController] that is created once and
/// never rebuilt -- autosave must never swap the controller, or the cursor
/// jumps to the end mid-sentence. The cubit holds only persistence state,
/// so typing rebuilds nothing but the word counter.
class EssayEditorPage extends StatelessWidget {
  const EssayEditorPage({required this.theme, super.key});

  final EssayTheme theme;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EssayEditorCubit(sl<EssayRepository>(), theme.id),
      child: _EssayEditorView(theme: theme),
    );
  }
}

class _EssayEditorView extends StatefulWidget {
  const _EssayEditorView({required this.theme});

  final EssayTheme theme;

  @override
  State<_EssayEditorView> createState() => _EssayEditorViewState();
}

class _EssayEditorViewState extends State<_EssayEditorView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _restored = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Fills the editor once, when the saved draft arrives. Assigning again
  /// later would move the cursor, so this happens exactly once.
  void _restore(String body) {
    if (_restored) return;
    _restored = true;
    _controller.text = body;
  }

  EssayStrings get _strings => EssayStrings(context.read<LocaleCubit>().state);

  Future<void> _saveDraft() async {
    final t = _strings;
    final messenger = ScaffoldMessenger.of(context);
    final saved = await context.read<EssayEditorCubit>().saveNow();
    if (!mounted) return;
    if (saved) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.draftSavedFeedback),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    // A failure already shows in the status line; a second shout would be
    // noise on a screen the person is writing in.
  }

  Future<void> _deleteDraft() async {
    final t = _strings;
    final cubit = context.read<EssayEditorCubit>();
    final confirmed = await showEssayDeleteDraftSheet(
      context,
      strings: t,
      onConfirm: cubit.deleteDraft,
    );
    if (!mounted) return;
    if (confirmed == true) {
      // Only now, with the server's confirmation in hand, is the text gone
      // from the screen.
      _controller.clear();
    } else if (confirmed == false) {
      await AppInfoBottomSheet.showError(
        context,
        description: t.deleteDraftFailed,
      );
    }
  }

  /// Sending: confirm, then flush and freeze. The confirmation comes first
  /// so nobody is asked to wait on a save they did not ask for.
  Future<void> _submit() async {
    final t = _strings;
    final cubit = context.read<EssayEditorCubit>();
    if (!await showEssaySubmitSheet(context, strings: t)) return;
    if (!mounted) return;

    final outcome = await cubit.submit();
    if (!mounted) return;

    switch (outcome) {
      case EssaySubmitOutcome.submitted:
        final attempt = cubit.submittedAttempt!;
        // Replaces the editor: this attempt is frozen, so going "back" to
        // an editor holding its text would be a lie.
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => EssaySubmissionPage(submissionId: attempt.id),
          ),
        );
      case EssaySubmitOutcome.saveFailed:
        await AppInfoBottomSheet.showError(
          context,
          description: t.submitSaveFailed,
        );
      case EssaySubmitOutcome.textTooShort:
        // The button should have caught this. If the server still says no,
        // it says why -- and the text stays where it is.
        await AppInfoBottomSheet.showError(
          context,
          description: t.submitTooShort(EssayRules.minimumWords),
        );
      case EssaySubmitOutcome.submitFailed:
        await AppInfoBottomSheet.showError(
          context,
          description: t.submitFailed,
        );
    }
  }

  /// Leaving: anything typed and not yet confirmed is flushed first. Only
  /// if that fails does the person get a say -- and the sheet never claims
  /// the text is safe when it is not.
  Future<bool> _confirmExit() async {
    final cubit = context.read<EssayEditorCubit>();
    if (!cubit.hasUnsavedChanges) return true;

    final saved = await cubit.saveNow();
    if (saved || !mounted) return saved;

    final choice = await showEssayUnsavedSheet(
      context,
      strings: _strings,
      onRetry: cubit.saveNow,
    );
    return choice == EssayUnsavedChoice.leave ||
        choice == EssayUnsavedChoice.saved;
  }

  @override
  Widget build(BuildContext context) {
    final t = EssayStrings(context.watch<LocaleCubit>().state);
    final colors = context.colors;

    return BlocBuilder<EssayEditorCubit, EssayEditorState>(
      builder: (context, state) {
        if (state is EssayEditorReady) _restore(state.initialBody);

        return PopScope(
          // Never pop straight away: an unconfirmed change gets one save
          // attempt first.
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await _confirmExit() && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              title: Text(
                widget.theme.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              // No custom leading: the default back button already goes
              // through maybePop, which is what PopScope hooks into.
              actions: [
                TextButton(
                  onPressed: () => showEssayPromptSheet(
                    context,
                    theme: widget.theme,
                    language: context.read<LocaleCubit>().state,
                  ),
                  child: Text(t.viewPromptAction),
                ),
                if (state is EssayEditorReady)
                  _Menu(
                    strings: t,
                    canDelete: state.hasSavedDraft,
                    onSave: _saveDraft,
                    onDelete: _deleteDraft,
                  ),
              ],
            ),
            body: SafeArea(
              child: switch (state) {
                EssayEditorLoading() => Center(
                  child: CircularProgressIndicator(color: colors.primary),
                ),
                EssayEditorLoadFailed() => _LoadFailedView(strings: t),
                EssayEditorReady() => _Editor(
                  controller: _controller,
                  focusNode: _focusNode,
                  strings: t,
                  status: state.status,
                  isSubmitting: state.isSubmitting,
                  onSubmit: _submit,
                ),
              },
            ),
          ),
        );
      },
    );
  }
}

/// The writing surface: status line, the field itself (which takes all the
/// room there is), and the word count.
class _Editor extends StatelessWidget {
  const _Editor({
    required this.controller,
    required this.focusNode,
    required this.strings,
    required this.status,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final EssayStrings strings;
  final EssaySaveStatus status;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Writing a full-bleed line across a tablet is miserable; the padding
    // grows instead, and on a phone this is the usual page padding.
    final horizontal = appHorizontalPadding(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              AppSpacing.sm,
              horizontal,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EssaySaveStatusLine(status: status, strings: strings),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: context.read<EssayEditorCubit>().textChanged,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: strings.editorHint,
                      filled: false,
                      // No box around the writing area: the page itself is the
                      // paper, and a border would shrink it for nothing.
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // The footer is a surface of its own, with a rule above it: a long
        // text otherwise runs straight into the counter and looks like it
        // is sliding under the button.
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              AppSpacing.sm,
              horizontal,
              AppSpacing.sm,
            ),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              // Only this block rebuilds as the person types: the counter
              // and whether there is anything to send.
              builder: (context, value, _) {
                final words = EssayRules.wordsIn(value.text);
                final shortOfMinimum = words < EssayRules.minimumWords;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      // The target only shows while it matters. Once the
                      // minimum is behind, the count goes back to being
                      // just a count.
                      shortOfMinimum
                          ? strings.wordCountToMinimum(
                              words,
                              EssayRules.minimumWords,
                            )
                          : strings.wordCount(words),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                    if (shortOfMinimum) ...[
                      const SizedBox(height: 2),
                      // Quiet on purpose: someone mid-sentence is not
                      // making a mistake, so this is not an error.
                      Text(
                        strings.minimumWordsHint(EssayRules.minimumWords),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    // Full width on its own line: "Enviar para correção"
                    // does not fit beside the counter at 360px, and this is
                    // the screen's main action anyway -- it earns the row.
                    AppButton(
                      label: strings.submitAction,
                      isLoading: isSubmitting,
                      // The same floor the server enforces, so the obvious
                      // refusal never costs a round trip -- and the sheet
                      // never opens on something that cannot be sent.
                      onPressed: shortOfMinimum ? null : onSubmit,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.strings,
    required this.canDelete,
    required this.onSave,
    required this.onDelete,
  });

  final EssayStrings strings;
  final bool canDelete;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          onTap: onSave,
          child: Text(strings.saveDraftAction),
        ),
        // Offered only when there is something on the server to throw away.
        if (canDelete)
          PopupMenuItem<void>(
            onTap: onDelete,
            child: Text(
              strings.deleteDraftAction,
              style: TextStyle(color: context.colors.error),
            ),
          ),
      ],
    );
  }
}

class _LoadFailedView extends StatelessWidget {
  const _LoadFailedView({required this.strings});

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
              strings.editorLoadFailed,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: strings.retryButton,
              onPressed: () => context.read<EssayEditorCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}
