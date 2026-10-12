import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/features/auth/data/models/auth_dtos.dart';

/// Unauthenticated `auth/*` endpoints (contract §3.1). Throws `DioException`
/// and JSON errors; callers wrap calls in `guardRemoteCall`.
abstract interface class AuthRemoteDataSource {
  Future<AuthResultDto> register(RegisterRequestDto request);

  Future<AuthResultDto> login(LoginRequestDto request);

  Future<AuthResultDto> signInWithApple(AppleSignInRequestDto request);

  Future<AuthResultDto> signInWithGoogle(GoogleSignInRequestDto request);

  Future<TokenPairDto> refresh(String refreshToken);

  Future<void> logout(String refreshToken);

  Future<void> requestPasswordReset(String email);

  Future<void> resetPassword(PasswordResetRequestDto request);
}

/// Uses the public client: these calls must never carry or refresh a bearer
/// token (refresh itself goes through here).
final class HttpAuthRemoteDataSource implements AuthRemoteDataSource {
  const HttpAuthRemoteDataSource(this._client);

  final PublicHttpClient _client;

  @override
  Future<AuthResultDto> register(RegisterRequestDto request) =>
      _postAuthResult(ApiPaths.authRegister, request.toJson());

  @override
  Future<AuthResultDto> login(LoginRequestDto request) =>
      _postAuthResult(ApiPaths.authLogin, request.toJson());

  @override
  Future<AuthResultDto> signInWithApple(AppleSignInRequestDto request) =>
      _postAuthResult(ApiPaths.authOAuthApple, request.toJson());

  @override
  Future<AuthResultDto> signInWithGoogle(GoogleSignInRequestDto request) =>
      _postAuthResult(ApiPaths.authOAuthGoogle, request.toJson());

  @override
  Future<TokenPairDto> refresh(String refreshToken) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiPaths.authRefresh,
      data: {'refresh_token': refreshToken},
    );
    return TokenPairDto.fromJson(_body(response.data));
  }

  @override
  Future<void> logout(String refreshToken) => _client.dio.post<void>(
    ApiPaths.authLogout,
    data: {'refresh_token': refreshToken},
  );

  @override
  Future<void> requestPasswordReset(String email) => _client.dio.post<void>(
    ApiPaths.authPasswordForgot,
    data: {'email': email},
  );

  @override
  Future<void> resetPassword(PasswordResetRequestDto request) =>
      _client.dio.post<void>(ApiPaths.authPasswordReset, data: request.toJson());

  Future<AuthResultDto> _postAuthResult(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      path,
      data: body,
    );
    return AuthResultDto.fromJson(_body(response.data));
  }
}

/// A 2xx without a JSON object breaks the contract.
Map<String, dynamic> _body(Map<String, dynamic>? data) =>
    data ?? (throw const FormatException('Expected a JSON object body'));
