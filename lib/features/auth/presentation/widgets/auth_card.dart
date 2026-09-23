import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

/// The surface the auth forms sit on. It lifts the form off the background
/// wash and gives the fields and the CTA a single block to belong to,
/// instead of floating loose on the page.
class AuthCard extends StatelessWidget {
  const AuthCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          // A single wide, very light shadow. Anything stronger starts
          // looking like a pop-up rather than part of the page.
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
