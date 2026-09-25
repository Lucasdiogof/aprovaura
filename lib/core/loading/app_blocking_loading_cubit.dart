import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/loading/app_blocking_loading_state.dart';

/// Drives [AppLoadingOverlay] -- the one full-screen block for a critical
/// action (logout, deleting the account, submitting an essay, finishing a
/// mock exam...). Not for ordinary page/list loading, which keeps its own
/// inline spinner and lets the person keep using the rest of the screen.
///
/// A reference count, never a naive bool: [run] is safe to call from more
/// than one place at once, and the overlay only actually hides once every
/// concurrent call has finished.
class AppBlockingLoadingCubit extends Cubit<AppBlockingLoadingState> {
  AppBlockingLoadingCubit() : super(const AppBlockingLoadingState());

  /// Runs [action] behind the blocking overlay, showing [message] (if
  /// given) while it's in flight, and always hides its own share of the
  /// overlay afterwards -- on success, on error, or if [action] throws.
  Future<T> run<T>(Future<T> Function() action, {String? message}) async {
    emit(state.increment(message: message));
    try {
      return await action();
    } finally {
      emit(state.decrement());
    }
  }
}
