import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_state.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/shared/l10n/shared_strings.dart';
import 'package:aura/shared/widgets/app_loading_indicator.dart';

/// Sits once, above the whole routed app (see `App.build`'s
/// `MaterialApp.router(builder: ...)`) -- never per screen. Nothing under
/// it responds while it's up: taps, scroll and the Android back gesture
/// are all absorbed, and it appears the instant [AppBlockingLoadingCubit]
/// reports an operation in flight, no delay.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key});

  static const _fade = Duration(milliseconds: 160);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBlockingLoadingCubit, AppBlockingLoadingState>(
      builder: (context, state) {
        final reduced = MediaQuery.disableAnimationsOf(context);
        return IgnorePointer(
          ignoring: !state.isVisible,
          child: AnimatedSwitcher(
            duration: reduced ? Duration.zero : _fade,
            child: state.isVisible
                ? _Barrier(message: state.message)
                : const SizedBox.shrink(),
          ),
        );
      },
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
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLoadingIndicator(size: 32),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        message!,
                        style: TextStyle(color: colors.textPrimary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
