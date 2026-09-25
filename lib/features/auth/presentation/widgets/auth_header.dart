import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/shared/widgets/app_logo.dart';

/// Header of the auth screens. Login gets the full horizontal logo — it is
/// the app's front door, so the brand leads. Sign-up gets the monogram plus
/// a page title instead: there the task, not the brand, is what the person
/// came for, and the wordmark next to "Criar sua conta" would read as two
/// competing headlines.
class AuthHeader extends StatelessWidget {
  const AuthHeader.brand({required this.subtitle, super.key}) : title = null;

  const AuthHeader.page({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String? title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final title = this.title;
    return Column(
      children: [
        if (title == null)
          const AppLogo.wordmark(maxWidth: 196)
        else ...[
          const AppLogo.mark(size: 44),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
        SizedBox(height: title == null ? 14 : 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
