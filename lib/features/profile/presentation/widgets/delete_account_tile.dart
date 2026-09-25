import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';

/// "Excluir minha conta" as plain red text at the end of the Profile, with
/// its confirmation and the wait that follows.
///
/// The work behind it was already built and deployed (the `delete-account`
/// Edge Function, reached through `AuthCubit.deleteAccount`); this only
/// puts it somewhere findable. Nothing here decides anything: the server
/// takes the user id from the caller's own JWT, never from the app.
class DeleteAccountTile extends StatelessWidget {
  const DeleteAccountTile({super.key});

  ProfileStrings _strings(BuildContext context) =>
      ProfileStrings(context.read<LocaleCubit>().state);

  Future<void> _confirm(BuildContext context) async {
    final t = _strings(context);
    await AppInfoBottomSheet.showError(
      context,
      title: t.deleteAccountConfirmTitle,
      description: t.deleteAccountConfirmDescription,
      primaryActionLabel: t.deleteAccountConfirmButton,
      onPrimaryAction: () => _delete(context),
      secondaryActionLabel: t.cancelButtonLabel,
    );
  }

  Future<void> _delete(BuildContext context) async {
    // The confirmation sheet is already closing itself by the time this
    // runs, so the blocking overlay -- not a row-level spinner -- is what
    // has to show that something is happening now and refuse a second tap.
    final t = _strings(context);
    final authCubit = context.read<AuthCubit>();
    final loading = context.read<AppBlockingLoadingCubit>();
    final result = await loading.run(
      authCubit.deleteAccount,
      message: t.deletingAccountMessage,
    );
    if (!context.mounted) return;
    switch (result) {
      case Success():
        // Account and local session are both gone: there is no authenticated
        // area left to return to.
        context.go('/login');
      case Error(:final failure):
        // Still signed in, with everything intact -- only the deletion did
        // not happen.
        await AppInfoBottomSheet.showError(
          context,
          description: failure.message.isNotEmpty
              ? failure.message
              : t.deleteAccountFailedMessage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ProfileStrings(context.watch<LocaleCubit>().state);
    final color = context.colors.error;
    // Plain centered red text, not a card: it closes the page quietly
    // instead of competing with the rows above. What it does is spelled
    // out by the confirmation, which always comes first.
    return Center(
      child: TextButton(
        onPressed: () => _confirm(context),
        style: TextButton.styleFrom(
          foregroundColor: color,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: Text(
          t.deleteAccountRowLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
