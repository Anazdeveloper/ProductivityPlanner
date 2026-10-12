import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:productivity_planner/config/router/auth_gate.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/auth_bloc.dart';

/// Adapts [AuthBloc] to the router's [AuthGate]. Notifies only when the
/// routing-relevant status changes, so profile updates do not re-run
/// redirects.
final class AuthBlocAuthGate extends ChangeNotifier implements AuthGate {
  AuthBlocAuthGate(AuthBloc bloc) : _status = _statusOf(bloc.state) {
    _subscription = bloc.stream.listen((state) {
      final next = _statusOf(state);
      if (next == _status) return;
      _status = next;
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;
  AuthGateStatus _status;

  @override
  AuthGateStatus get status => _status;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }

  static AuthGateStatus _statusOf(AuthState state) => switch (state) {
    AuthUnknown() => AuthGateStatus.unknown,
    Authenticated() => AuthGateStatus.authenticated,
    Unauthenticated() => AuthGateStatus.unauthenticated,
  };
}
