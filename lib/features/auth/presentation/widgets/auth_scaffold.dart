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
                  // Never negative: on a very short viewport (a small
                  // browser window, a landscape phone) maxHeight - 48 can
                  // go below zero, which BoxConstraints rejects outright.
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 48).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  // Align, not Center: the content's own height is short
                  // relative to a tall screen, and under the unbounded
                  // height a SingleChildScrollView gives its child, Center
                  // (and mainAxisAlignment on a Column inside it) both
                  // collapse to the content's natural size and centre
                  // that -- there is no bounded space for "start" to mean
                  // anything against. Align has no such ambiguity: it
                  // fills the ConstrainedBox's minHeight and places its
                  // child at the top, full stop.
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxContentWidth,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [const SizedBox(height: 12), ...children],
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

/// Two very soft radial washes in the two ends of the Aprovaura gradient
/// (Aura cyan top-right, brand violet bottom-left): enough to give the page
/// depth and keep it from reading as a flat template, far too faint to
/// compete with the form -- and fainter still on the light theme.
class AuthBackground extends StatelessWidget {
  const AuthBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cyan = context.colors.auraCyan;
    final violet = context.colors.primaryFill;
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
                    cyan.withValues(alpha: isDark ? 0.12 : 0.10),
                    cyan.withValues(alpha: 0),
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
                    violet.withValues(alpha: isDark ? 0.20 : 0.08),
                    violet.withValues(alpha: 0),
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
