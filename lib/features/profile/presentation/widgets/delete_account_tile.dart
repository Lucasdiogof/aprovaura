import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
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
///
/// It owns its own loading state because the confirmation sheet closes
/// itself before running the action -- so the row is what has to show that
/// something is happening, and what has to stop a second tap.
class DeleteAccountTile extends StatefulWidget {
  const DeleteAccountTile({super.key});

  @override
  State<DeleteAccountTile> createState() => _DeleteAccountTileState();
}

class _DeleteAccountTileState extends State<DeleteAccountTile> {
  bool _deleting = false;

  ProfileStrings get _strings =>
      ProfileStrings(context.read<LocaleCubit>().state);

  Future<void> _confirm() async {
    if (_deleting) return;
    final t = _strings;
    await AppInfoBottomSheet.showError(
      context,
      title: t.deleteAccountConfirmTitle,
      description: t.deleteAccountConfirmDescription,
      primaryActionLabel: t.deleteAccountConfirmButton,
      onPrimaryAction: _delete,
      secondaryActionLabel: t.cancelButtonLabel,
    );
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);
    final result = await context.read<AuthCubit>().deleteAccount();
    if (!mounted) return;
    switch (result) {
      case Success():
        // Account and local session are both gone: there is no authenticated
        // area left to return to.
        context.go('/login');
      case Error(:final failure):
        // Still signed in, with everything intact -- only the deletion did
        // not happen.
        setState(() => _deleting = false);
        await AppInfoBottomSheet.showError(
          context,
          description: failure.message.isNotEmpty
              ? failure.message
              : _strings.deleteAccountFailedMessage,
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
        // Tapping while it runs does nothing: the request is already on its
        // way and a second one would just fail on a deleted user.
        onPressed: _deleting ? null : _confirm,
        style: TextButton.styleFrom(
          foregroundColor: color,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: _deleting
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: color,
                ),
              )
            : Text(
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
