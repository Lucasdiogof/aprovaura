import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/profile/presentation/cubit/username_check_state.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';

/// On the right of a username field: the Aura loader while the database is
/// asked, a green check once the name is free. Taken or failed show as the
/// field's error message instead.
class UsernameStatusIndicator extends StatelessWidget {
  const UsernameStatusIndicator({
    required this.check,
    required this.value,
    required this.availableLabel,
    super.key,
  });

  final UsernameCheckState check;

  /// What is in the field now; a status about an older value shows nothing.
  final String value;
  final String availableLabel;

  @override
  Widget build(BuildContext context) {
    if (!check.isAbout(value)) return const SizedBox.shrink();
    return switch (check.status) {
      UsernameCheck.checking => const Center(
        child: SizedBox.square(
          dimension: 18,
          child: FittedBox(child: AppAuraLoader.small()),
        ),
      ),
      UsernameCheck.available => Icon(
        Icons.check_circle_rounded,
        size: 20,
        color: context.colors.success,
        semanticLabel: availableLabel,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
