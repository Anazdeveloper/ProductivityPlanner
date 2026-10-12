import 'package:dio/dio.dart';
import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/features/auth/data/models/auth_dtos.dart';

/// Authenticated account endpoints (`me`). Throws; callers guard.
abstract interface class AccountRemoteDataSource {
  Future<UserDto> getMe();

  /// [version] is sent as `If-Match`; a stale value yields `409 STALE_VERSION`.
  Future<UserDto> updateMe(UpdateProfileRequestDto request, {required int version});
}

final class HttpAccountRemoteDataSource implements AccountRemoteDataSource {
  const HttpAccountRemoteDataSource(this._client);

  final ApiHttpClient _client;

  @override
  Future<UserDto> getMe() async {
    final response = await _client.dio.get<Map<String, dynamic>>(ApiPaths.me);
    return UserDto.fromJson(_body(response.data));
  }

  @override
  Future<UserDto> updateMe(
    UpdateProfileRequestDto request, {
    required int version,
  }) async {
    final response = await _client.dio.patch<Map<String, dynamic>>(
      ApiPaths.me,
      data: request.toJson(),
      options: Options(headers: {ApiHeaders.ifMatch: '$version'}),
    );
    return UserDto.fromJson(_body(response.data));
  }
}

Map<String, dynamic> _body(Map<String, dynamic>? data) =>
    data ?? (throw const FormatException('Expected a JSON object body'));
