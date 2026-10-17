import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/network/request_guard.dart';

/// Whether the server is reachable right now, as far as the app can tell.
///
/// No platform plugin: reachability is inferred from real requests
/// ([reportFailure] / [reportSuccess], called by the repositories through
/// [failureFromError] callers) plus a cheap probe every few seconds while
/// offline. A device "connected" to a dead Wi-Fi is therefore offline here,
/// which is what matters. When the state flips back to online, [onReconnect]
/// listeners (the sync queue, open screens) run.
class ConnectionMonitor extends ChangeNotifier {
  ConnectionMonitor(this._client);

  final SupabaseClient _client;
  final List<Future<void> Function()> _reconnectListeners = [];

  bool _online = true;
  Timer? _probe;
  bool _probing = false;

  bool get isOnline => _online;

  /// Runs [listener] every time the app goes from offline back to online.
  void onReconnect(Future<void> Function() listener) =>
      _reconnectListeners.add(listener);

  void reportFailure(Failure failure) {
    if (!isConnectionFailure(failure)) return;
    if (_online) {
      _online = false;
      notifyListeners();
    }
    _probe ??= Timer.periodic(const Duration(seconds: 8), (_) => probe());
  }

  void reportSuccess() {
    if (_online) return;
    _online = true;
    _probe?.cancel();
    _probe = null;
    notifyListeners();
    for (final listener in List.of(_reconnectListeners)) {
      unawaited(listener());
    }
  }

  /// A request that only needs *any* answer from the server: even a refusal
  /// (RLS, bad params) proves the connection works. Only a connection-type
  /// failure keeps the app offline.
  Future<void> probe() async {
    if (_probing) return;
    _probing = true;
    try {
      await _client
          .from('catalog_nodes')
          .select('id')
          .limit(1)
          .timeout(const Duration(seconds: 5));
      reportSuccess();
    } catch (error) {
      final failure = failureFromError(error);
      if (isConnectionFailure(failure)) {
        reportFailure(failure);
      } else {
        reportSuccess();
      }
    } finally {
      _probing = false;
    }
  }

  @override
  void dispose() {
    _probe?.cancel();
    super.dispose();
  }
}
