import 'package:flutter/material.dart';
import 'package:aura/features/auth/presentation/widgets/auth_backdrop.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';

/// Shared shell for the auth screens: the painted backdrop, safe area,
/// scroll, and a single column capped at a comfortable width so the form
/// doesn't stretch across a tablet or a browser window.
///
/// The back-button row is always laid out, shown or not, so the rest of
/// the page sits at the same height on every auth screen and in both
/// themes.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.children,
    this.showBackButton = false,
    super.key,
  });

  /// Laid out in a column under the back-button row; the caller owns the
  /// spacing between them.
  final List<Widget> children;

  /// Sign-up sets it (it is pushed on top of login). Login only shows it
  /// when there is really something to go back to -- it is normally the
  /// app's front door.
  final bool showBackButton;

  static const backIcon = Icons.arrow_back_ios_new_rounded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.of(context).background,
      resizeToAvoidBottomInset: true,
      body: AuthBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Keeps the CTA reachable with the keyboard open.
                padding: EdgeInsets.fromLTRB(
                  AuthLayout.pagePadding,
                  0,
                  AuthLayout.pagePadding,
                  24 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: ConstrainedBox(
                  // Never negative on a very short viewport: BoxConstraints
                  // rejects a negative minHeight outright.
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 24).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  // Align, not Center: the column starts at the top, like
                  // the reference, however tall the screen is.
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AuthLayout.maxContentWidth,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: AuthLayout.backButtonSize,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: showBackButton
                                  ? const _BackButton()
                                  : null,
                            ),
                          ),
                          ...children,
                        ],
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

/// A small round button with a chevron, as in the reference.
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final palette = AuthPalette.of(context);
    final label = MaterialLocalizations.of(context).backButtonTooltip;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: palette.backFill,
        shape: CircleBorder(side: BorderSide(color: palette.backBorder)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          child: SizedBox.square(
            dimension: AuthLayout.backButtonSize,
            child: Icon(
              AuthScaffold.backIcon,
              size: 15,
              color: palette.backIcon,
            ),
          ),
        ),
      ),
    );
  }
}
