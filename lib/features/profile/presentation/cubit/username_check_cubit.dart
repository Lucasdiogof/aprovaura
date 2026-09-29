import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/profile/presentation/cubit/username_check_state.dart';
import 'package:aura/shared/utils/validators.dart';

/// Asks the database whether a username is free.
typedef UsernameAvailability = Future<Result<bool>> Function(String username);

/// Checks a username against the database while it is typed -- the same
/// behaviour on sign-up and on "Minha conta". Only a well-formed name is
/// sent, once the typing pauses for [checkDelay]; an answer that arrives
/// after the text changed again is dropped.
///
/// This is only guidance for the person typing: the unique index on
/// lower(username) is what really keeps two people off the same name, and
/// a conflict it reports comes back through [markTaken].
class UsernameCheckCubit extends Cubit<UsernameCheckState> {
  UsernameCheckCubit({required this.isAvailable, String? currentUsername})
    : _current = currentUsername?.trim().toLowerCase(),
      super(const UsernameCheckState());

  final UsernameAvailability isAvailable;

  /// The person's own username ("Minha conta"): always theirs to keep, in
  /// any casing, without asking the database.
  final String? _current;
  Timer? _debounce;

  static const checkDelay = Duration(milliseconds: 400);

  void changed(String value) {
    final username = value.trim();
    if (state.username == username && state.status != UsernameCheck.failed) {
      return;
    }
    _debounce?.cancel();
    if (!isValidUsername(username)) {
      emit(UsernameCheckState(username: username));
      return;
    }
    if (_current != null && username.toLowerCase() == _current) {
      emit(
        UsernameCheckState(status: UsernameCheck.available, username: username),
      );
      return;
    }
    emit(
      UsernameCheckState(status: UsernameCheck.checking, username: username),
    );
    _debounce = Timer(checkDelay, () => _check(username));
  }

  /// The database refused [value] on save (someone took it after it was
  /// checked): show it as taken until the person types something else.
  void markTaken(String value) {
    _debounce?.cancel();
    emit(
      UsernameCheckState(status: UsernameCheck.taken, username: value.trim()),
    );
  }

  Future<void> _check(String username) async {
    final result = await isAvailable(username);
    if (isClosed || state.username != username) return;
    emit(
      UsernameCheckState(
        status: switch (result) {
          Success(:final data) =>
            data ? UsernameCheck.available : UsernameCheck.taken,
          Error() => UsernameCheck.failed,
        },
        username: username,
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
