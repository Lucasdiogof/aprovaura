import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';

/// How long a content request may stay silent before it is treated as
/// failed. Without a limit, a connection that hangs (airplane mode on some
/// devices) leaves the screen on its loading state forever.
const Duration kRequestTimeout = Duration(seconds: 12);

/// Set once at startup (see injection_container) so every mapped failure and
/// every completed request feeds the connection monitor without each
/// repository knowing about it.
void Function(Failure failure)? onRequestFailure;
void Function()? onRequestSuccess;

/// Maps anything a Supabase call can throw to the [Failure] that tells the
/// person what actually happened.
Failure failureFromError(Object error) {
  final failure = _classify(error);
  if (isConnectionFailure(failure)) onRequestFailure?.call(failure);
  return failure;
}

Failure _classify(Object error) {
  if (error is TimeoutException) return RequestTimeoutFailure();
  if (error is PostgrestException) return ServerFailure();
  // Matched by name on purpose: dart:io's SocketException does not exist on
  // web, and package:http's ClientException / Supabase's retryable auth
  // fetch error are not imported here to keep this file free of their
  // internals.
  final name = error.runtimeType.toString();
  if (name == 'SocketException' ||
      name == 'HandshakeException' ||
      name == 'ClientException' ||
      name == 'AuthRetryableFetchException') {
    return NetworkFailure();
  }
  return UnexpectedFailure();
}

extension RequestTimeout<T> on Future<T> {
  Future<T> withRequestTimeout([Duration limit = kRequestTimeout]) =>
      timeout(limit).then((value) {
        onRequestSuccess?.call();
        return value;
      });
}
