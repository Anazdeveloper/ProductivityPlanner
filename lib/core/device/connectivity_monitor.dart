import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Whether the device has a network interface up. A hint, not a promise:
/// "online" can still fail (captive portal, server down), so callers
/// treat it as a trigger to try and never as permission to skip the
/// offline path.
abstract interface class ConnectivityMonitor {
  /// The current state, then every change (no repeats).
  Stream<bool> watchOnline();

  Future<bool> isOnline();
}

/// connectivity_plus: "none" is the only offline answer; anything else
/// (wifi, mobile, ethernet, vpn, other) may reach the server.
final class PlatformConnectivityMonitor implements ConnectivityMonitor {
  PlatformConnectivityMonitor([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _online(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  Future<bool> isOnline() async {
    try {
      return _online(await _connectivity.checkConnectivity());
    } on Object {
      // Unknown: assume a network so a sync is attempted (it fails safely).
      return true;
    }
  }

  @override
  Stream<bool> watchOnline() => Stream<bool>.multi((controller) {
    bool? last;
    void emit(bool online) {
      if (online == last || !controller.hasListener) return;
      last = online;
      controller.add(online);
    }

    // The initial check only counts if no change event beat it.
    unawaited(
      isOnline().then((online) {
        if (last == null) emit(online);
      }),
    );
    final subscription = _connectivity.onConnectivityChanged.listen(
      (results) => emit(_online(results)),
      onError: (Object _) {},
    );
    controller.onCancel = subscription.cancel;
  });
}

/// Always online: tests and platforms without the plugin.
final class AlwaysOnlineConnectivityMonitor implements ConnectivityMonitor {
  const AlwaysOnlineConnectivityMonitor();

  @override
  Future<bool> isOnline() async => true;

  @override
  Stream<bool> watchOnline() => Stream.value(true);
}
