import 'dart:convert';

import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/fake_credential_sources.dart';

/// In-memory implementation of the auth and account endpoints exactly as
/// specified in `contracts/api/v1.md` §3.1, including refresh-token rotation
/// and reuse detection. Lets the app and tests run without the server.
///
/// Seed account: `demo@example.com` / `password123`.
/// Password reset code: always `123456`.
final class AuthMockBackend {
  AuthMockBackend({required Clock clock, required IdGenerator ids})
    : _clock = clock,
      _ids = ids {
    _createAccount(
      email: 'demo@example.com',
      password: 'password123',
      displayName: 'Demo User',
      timeZone: 'Asia/Kolkata',
      locale: 'en-IN',
    );
  }

  static const resetCode = '123456';
  static const accessTokenTtl = Duration(minutes: 15);
  static const refreshTokenTtl = Duration(days: 60);

  final Clock _clock;
  final IdGenerator _ids;

  final Map<String, _Account> _accountsByEmail = {};
  final Map<String, _AccessToken> _accessTokens = {};
  final Map<String, _RefreshToken> _refreshTokens = {};
  final Set<String> _revokedFamilies = {};

  void register(MockApiAdapter adapter) {
    adapter
      ..on('POST', ApiPaths.authRegister, _register)
      ..on('POST', ApiPaths.authLogin, _login)
      ..on('POST', ApiPaths.authOAuthApple, (r) => _providerSignIn(r, 'apple'))
      ..on('POST', ApiPaths.authOAuthGoogle, (r) => _providerSignIn(r, 'google'))
      ..on('POST', ApiPaths.authRefresh, _refresh)
      ..on('POST', ApiPaths.authLogout, _logout)
      ..on('POST', ApiPaths.authPasswordForgot, (_) => const MockResponse(202))
      ..on('POST', ApiPaths.authPasswordReset, _resetPassword)
      ..on('GET', ApiPaths.me, _getMe)
      ..on('PATCH', ApiPaths.me, _patchMe);
  }

  /// Test hook: revokes every session of [email] (e.g. "signed out
  /// everywhere" from another device).
  void revokeAllSessions(String email) {
    final account = _accountsByEmail[email];
    if (account == null) return;
    for (final token in _refreshTokens.values) {
      if (token.userId == account.id) _revokedFamilies.add(token.family);
    }
    _accessTokens.removeWhere((_, t) => t.userId == account.id);
  }

  MockResponse _register(MockRequest request) {
    final body = _bodyOf(request);
    final email = _string(body, 'email').toLowerCase();
    final password = _string(body, 'password');
    final displayName = _string(body, 'display_name').trim();

    final errors = <Map<String, String>>[
      if (!email.contains('@'))
        {'field': 'email', 'message': 'must be an email address'},
      if (password.length < 10 || password.length > 128)
        {'field': 'password', 'message': 'must be 10 to 128 characters'},
      if (displayName.isEmpty)
        {'field': 'display_name', 'message': 'must not be empty'},
    ];
    if (errors.isNotEmpty) {
      return MockResponse.problem(
        status: 422,
        code: 'VALIDATION_FAILED',
        extra: {'errors': errors},
      );
    }
    if (_accountsByEmail.containsKey(email)) {
      return MockResponse.problem(status: 409, code: 'EMAIL_TAKEN');
    }
    final account = _createAccount(
      email: email,
      password: password,
      displayName: displayName,
      timeZone: _string(body, 'time_zone', fallback: 'UTC'),
      locale: _string(body, 'locale', fallback: 'en'),
    );
    return MockResponse.json(_authResult(account, isNewUser: true), status: 201);
  }

  MockResponse _login(MockRequest request) {
    final body = _bodyOf(request);
    final account = _accountsByEmail[_string(body, 'email').toLowerCase()];
    if (account == null || account.password != _string(body, 'password')) {
      return MockResponse.problem(status: 401, code: 'INVALID_CREDENTIALS');
    }
    return MockResponse.json(_authResult(account));
  }

  MockResponse _providerSignIn(MockRequest request, String provider) {
    final body = _bodyOf(request);
    final expected = provider == 'apple'
        ? FakeProviderTokens.apple
        : FakeProviderTokens.google;
    if (_string(body, 'id_token') != expected) {
      return MockResponse.problem(status: 401, code: 'INVALID_PROVIDER_TOKEN');
    }
    if (provider == 'apple' && _string(body, 'raw_nonce').isEmpty) {
      return MockResponse.problem(status: 401, code: 'INVALID_PROVIDER_TOKEN');
    }
    final email = '$provider.user@example.com';
    final existing = _accountsByEmail[email];
    final account =
        existing ??
        _createAccount(
          email: email,
          password: _ids.newId(),
          displayName: _string(
            body,
            'display_name',
            fallback: provider == 'apple' ? 'Apple User' : 'Google User',
          ),
          timeZone: _string(body, 'time_zone', fallback: 'UTC'),
          locale: _string(body, 'locale', fallback: 'en'),
        );
    return MockResponse.json(_authResult(account, isNewUser: existing == null));
  }

  MockResponse _refresh(MockRequest request) {
    final token = _string(_bodyOf(request), 'refresh_token');
    final stored = _refreshTokens[token];
    if (stored == null ||
        _revokedFamilies.contains(stored.family) ||
        !stored.expiresAt.isAfter(_clock.now())) {
      return MockResponse.problem(status: 401, code: 'REFRESH_TOKEN_INVALID');
    }
    if (stored.used) {
      // Reuse means the token leaked: revoke every token in the family.
      _revokedFamilies.add(stored.family);
      return MockResponse.problem(status: 401, code: 'REFRESH_TOKEN_REUSED');
    }
    stored.used = true;
    return MockResponse.json(_issueTokens(stored.userId, family: stored.family));
  }

  MockResponse _logout(MockRequest request) {
    final stored = _refreshTokens[_string(_bodyOf(request), 'refresh_token')];
    if (stored != null) _revokedFamilies.add(stored.family);
    return const MockResponse(204);
  }

  MockResponse _resetPassword(MockRequest request) {
    final body = _bodyOf(request);
    final account = _accountsByEmail[_string(body, 'email').toLowerCase()];
    final newPassword = _string(body, 'new_password');
    if (account == null || _string(body, 'code') != resetCode) {
      return MockResponse.problem(
        status: 400,
        code: 'INVALID_RESET_CODE',
        extra: {
          'errors': [
            {'field': 'code', 'message': 'is invalid or expired'},
          ],
        },
      );
    }
    if (newPassword.length < 10) {
      return MockResponse.problem(
        status: 422,
        code: 'VALIDATION_FAILED',
        extra: {
          'errors': [
            {'field': 'new_password', 'message': 'must be 10 to 128 characters'},
          ],
        },
      );
    }
    account.password = newPassword;
    revokeAllSessions(account.email);
    return const MockResponse(204);
  }

  MockResponse _getMe(MockRequest request) {
    final account = _authenticate(request);
    if (account == null) {
      return MockResponse.problem(status: 401, code: 'TOKEN_EXPIRED');
    }
    return MockResponse.json(account.toJson());
  }

  MockResponse _patchMe(MockRequest request) {
    final account = _authenticate(request);
    if (account == null) {
      return MockResponse.problem(status: 401, code: 'TOKEN_EXPIRED');
    }
    final ifMatch = request.headers[ApiHeaders.ifMatch]?.toString();
    if (ifMatch != '${account.version}') {
      return MockResponse.problem(status: 409, code: 'STALE_VERSION');
    }
    final displayName = _bodyOf(request)['display_name'];
    if (displayName is String) {
      if (displayName.trim().isEmpty) {
        return MockResponse.problem(
          status: 422,
          code: 'VALIDATION_FAILED',
          extra: {
            'errors': [
              {'field': 'display_name', 'message': 'must not be empty'},
            ],
          },
        );
      }
      account.displayName = displayName.trim();
    }
    account.version++;
    return MockResponse.json(account.toJson());
  }

  _Account? _authenticate(MockRequest request) {
    final header = request.headers[ApiHeaders.authorization]?.toString() ?? '';
    if (!header.startsWith('Bearer ')) return null;
    final token = _accessTokens[header.substring('Bearer '.length)];
    if (token == null || !token.expiresAt.isAfter(_clock.now())) return null;
    return _accountsByEmail.values.where((a) => a.id == token.userId).firstOrNull;
  }

  _Account _createAccount({
    required String email,
    required String password,
    required String displayName,
    required String timeZone,
    required String locale,
  }) => _accountsByEmail[email] = _Account(
    id: _ids.newId(),
    email: email,
    password: password,
    displayName: displayName,
    timeZone: timeZone,
    locale: locale,
  );

  Map<String, Object?> _authResult(_Account account, {bool isNewUser = false}) =>
      {
        'tokens': _issueTokens(account.id, family: _ids.newId()),
        'user': account.toJson(),
        'is_new_user': isNewUser,
      };

  Map<String, Object?> _issueTokens(String userId, {required String family}) {
    final now = _clock.now();
    final access = 'access-${_ids.newId()}';
    final refresh = 'refresh-${_ids.newId()}';
    final accessExpiry = now.add(accessTokenTtl);
    final refreshExpiry = now.add(refreshTokenTtl);
    _accessTokens[access] = _AccessToken(userId, accessExpiry);
    _refreshTokens[refresh] = _RefreshToken(
      userId: userId,
      family: family,
      expiresAt: refreshExpiry,
    );
    return {
      'access_token': access,
      'access_token_expires_at': accessExpiry.toIso8601String(),
      'refresh_token': refresh,
      'refresh_token_expires_at': refreshExpiry.toIso8601String(),
    };
  }

  /// The JSON body as a map, however Dio handed it over (a map, or an
  /// already-encoded JSON string).
  static Map<String, dynamic> _bodyOf(MockRequest request) {
    final body = request.body;
    final decoded = body is String && body.isNotEmpty
        ? _tryDecode(body)
        : body;
    return switch (decoded) {
      final Map<dynamic, dynamic> map => {
        for (final MapEntry(:key, :value) in map.entries) '$key': value,
      },
      _ => const <String, dynamic>{},
    };
  }

  static Object? _tryDecode(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }

  static String _string(
    Map<String, dynamic> body,
    String key, {
    String fallback = '',
  }) => switch (body[key]) {
    final String value => value,
    _ => fallback,
  };
}

final class _Account {
  _Account({
    required this.id,
    required this.email,
    required this.password,
    required this.displayName,
    required this.timeZone,
    required this.locale,
  });

  final String id;
  final String email;
  String password;
  String displayName;
  final String timeZone;
  final String locale;
  int version = 1;

  Map<String, Object?> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
    'time_zone': timeZone,
    'locale': locale,
    'week_start': 1,
    'email_verified': false,
    'version': version,
  };
}

final class _AccessToken {
  const _AccessToken(this.userId, this.expiresAt);

  final String userId;
  final DateTime expiresAt;
}

final class _RefreshToken {
  _RefreshToken({
    required this.userId,
    required this.family,
    required this.expiresAt,
  });

  final String userId;
  final String family;
  final DateTime expiresAt;
  bool used = false;
}
