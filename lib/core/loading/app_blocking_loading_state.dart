import 'package:equatable/equatable.dart';

class AppBlockingLoadingState extends Equatable {
  const AppBlockingLoadingState({this.activeCount = 0, this.message});

  /// How many [AppBlockingLoadingCubit.run] calls are currently in flight.
  /// A reference count, not a bool: one operation finishing must not hide
  /// the overlay while another is still running.
  final int activeCount;

  /// The most recently started operation's message. Optional, and simply
  /// whatever the newest concurrent call passed -- there is no stacking of
  /// messages, only ever one line shown at a time.
  final String? message;

  bool get isVisible => activeCount > 0;

  AppBlockingLoadingState _withCount(int count, {String? message}) =>
      AppBlockingLoadingState(
        activeCount: count < 0 ? 0 : count,
        message: count <= 0 ? null : (message ?? this.message),
      );

  AppBlockingLoadingState increment({String? message}) =>
      _withCount(activeCount + 1, message: message);

  AppBlockingLoadingState decrement() => _withCount(activeCount - 1);

  @override
  List<Object?> get props => [activeCount, message];
}
