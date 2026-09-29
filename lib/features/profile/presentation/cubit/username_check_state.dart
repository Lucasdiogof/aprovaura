import 'package:equatable/equatable.dart';

/// Where the database check of a typed username stands.
enum UsernameCheck {
  /// Nothing to check: empty, or not a well-formed username yet.
  idle,

  /// Waiting for the typing to pause, or for the answer.
  checking,
  available,
  taken,

  /// The check itself failed (offline, server error). Blocks saving.
  failed,
}

class UsernameCheckState extends Equatable {
  const UsernameCheckState({
    this.status = UsernameCheck.idle,
    this.username = '',
  });

  final UsernameCheck status;

  /// The trimmed username [status] is about.
  final String username;

  /// Whether this state describes [value] (as typed, untrimmed) -- an
  /// answer about an older value says nothing about the current one.
  bool isAbout(String value) => username == value.trim();

  /// [value] is confirmed free (or is the person's own username).
  bool confirms(String value) =>
      isAbout(value) && status == UsernameCheck.available;

  @override
  List<Object?> get props => [status, username];
}
