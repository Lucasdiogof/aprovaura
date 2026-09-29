import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_state.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/shared/l10n/shared_strings.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';

/// Sits once, above the whole routed app (see `App.build`'s
/// `MaterialApp.router(builder: ...)`) -- never per screen. Nothing under
/// it responds while it's up: taps, scroll and the Android back gesture
/// are all absorbed, and it appears the instant [AppBlockingLoadingCubit]
/// reports an operation in flight, no delay.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key});

  /// Scrim and loader both arrive and leave over this (spec: 120-180ms).
  static const fade = Duration(milliseconds: 160);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBlockingLoadingCubit, AppBlockingLoadingState>(
      builder: (context, state) {
        final reduced = MediaQuery.disableAnimationsOf(context);
        return IgnorePointer(
          ignoring: !state.isVisible,
          child: AnimatedSwitcher(
            duration: reduced ? Duration.zero : fade,
            child: state.isVisible
                ? _Barrier(message: state.message)
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

/// Hosts the routed app under [AppLoadingOverlay] -- the one way to mount
/// it (see `App.build`'s `MaterialApp.router(builder: ...)`).
///
/// The overlay's barrier only stops pointers. While it is up, the screen
/// behind must also stop being reachable some other way: a screen reader
/// would still list its buttons with their tap actions, and a keyboard
/// could still move focus onto them -- in the middle of an operation that
/// cannot be interrupted. So the app is wrapped in [ExcludeSemantics] and
/// [ExcludeFocus] that switch on with the overlay. Both are always in the
/// tree and only their flag changes, so no screen behind loses its state.
class AppLoadingOverlayHost extends StatelessWidget {
  const AppLoadingOverlayHost({required this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child case final child?)
          BlocBuilder<AppBlockingLoadingCubit, AppBlockingLoadingState>(
            buildWhen: (a, b) => a.isVisible != b.isVisible,
            builder: (context, state) => ExcludeFocus(
              excluding: state.isVisible,
              child: ExcludeSemantics(excluding: state.isVisible, child: child),
            ),
          ),
        const AppLoadingOverlay(),
      ],
    );
  }
}

class _Barrier extends StatelessWidget {
  const _Barrier({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final t = SharedStrings(context.watch<LocaleCubit>().state);
    return PopScope(
      // The action behind this is critical and already in flight -- the
      // system back gesture must not be able to interrupt it.
      canPop: false,
      child: Semantics(
        container: true,
        liveRegion: true,
        label: message ?? t.loadingLabel,
        child: Stack(
          children: [
            ModalBarrier(dismissible: false, color: colors.loadingScrim),
            // The Aura loader over the dimmed screen, with the action's
            // short line under it when there is one ("Saindo..."). No card:
            // the screen behind stays visible, only inactive. The text uses
            // the theme's text colour, which reads on the scrim in both
            // themes (a darkened light page, a darker dark one).
            // Transparent Material: the overlay sits above the Navigator,
            // where there is no text style to inherit -- without it the
            // line would render with Flutter's yellow "no Material" underline.
            Material(
              type: MaterialType.transparency,
              child: Center(
                child: ExcludeSemantics(
                  // Said once by the label above, not again per element.
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : AppLoadingOverlay.fade,
                    curve: Curves.easeOut,
                    builder: (context, t, child) => Opacity(
                      opacity: t,
                      child: Transform.scale(
                        scale: 0.96 + 0.04 * t,
                        child: child,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppAuraLoader.large(),
                        if (message != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxl,
                            ),
                            child: Text(
                              message!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
