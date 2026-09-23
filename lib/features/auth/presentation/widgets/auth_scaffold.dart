import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

/// Shared shell for the auth screens: brand background, safe area, scroll,
/// and a single column capped at a comfortable reading width so the form
/// doesn't stretch across a tablet or a browser window.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({required this.children, super.key});

  /// Laid out in a centred column; the caller owns the spacing between them.
  final List<Widget> children;

  static const _maxContentWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      // The background sits behind the keyboard inset too, so the glow never
      // gets clipped into a hard edge when the keyboard opens.
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Keeps the CTA reachable with the keyboard open.
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  24 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxContentWidth,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Two very soft radial washes in the brand's own gradient colours, sampled
/// from the logo: enough to give the page depth and keep it from reading as
/// a flat template, far too faint to compete with the form.
class AuthBackground extends StatelessWidget {
  const AuthBackground({required this.child, super.key});

  static const _brandBlue = Color(0xFF005DFF);
  static const _brandPurple = Color(0xFF804FFF);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(color: context.colors.background),
      child: Stack(
        children: [
          // Plain gradients rather than blurred layers: a BackdropFilter here
          // would cost a full-screen blur on every frame for the same look.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.85, -0.9),
                  radius: 1.1,
                  colors: [
                    _brandBlue.withValues(alpha: isDark ? 0.20 : 0.12),
                    _brandBlue.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.9, 0.95),
                  radius: 1.0,
                  colors: [
                    _brandPurple.withValues(alpha: isDark ? 0.16 : 0.09),
                    _brandPurple.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
