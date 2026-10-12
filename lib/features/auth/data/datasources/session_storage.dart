import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:productivity_planner/features/auth/data/models/auth_dtos.dart';

/// Persists the session (tokens + cached profile) between launches.
abstract interface class SessionStorage {
  /// The stored session, or null if none or unreadable.
  Future<StoredSessionDto?> read();

  Future<void> write(StoredSessionDto session);

  Future<void> clear();
}

/// Keychain (iOS) / Keystore-backed encrypted storage (Android).
///
/// iOS accessibility `first_unlock_this_device`: readable in the background
/// after the first unlock (Phase 6 notification actions sync while locked),
/// and never synced to iCloud or restored onto another device.
///
/// The iOS Keychain survives uninstall; `discardSessionFromPreviousInstall`
/// (config/session) clears this storage when the local database is new, so
/// a reinstall never resumes an old session.
final class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  static const _key = 'auth.session.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredSessionDto?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return StoredSessionDto.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      // Corrupt or from an incompatible version: treat as signed out.
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(StoredSessionDto session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// For tests and previews.
final class InMemorySessionStorage implements SessionStorage {
  InMemorySessionStorage([this._session]);

  StoredSessionDto? _session;

  @override
  Future<StoredSessionDto?> read() async => _session;

  @override
  Future<void> write(StoredSessionDto session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
}
