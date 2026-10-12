import 'package:flutter/foundation.dart';

enum AuthGateStatus { unknown, unauthenticated, authenticated }

/// What the router needs to know about the session, and nothing more.
/// Implemented by `AuthBlocAuthGate`; tests can supply their own.
abstract interface class AuthGate implements Listenable {
  AuthGateStatus get status;
}
