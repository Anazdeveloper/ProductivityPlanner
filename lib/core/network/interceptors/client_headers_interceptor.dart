import 'package:dio/dio.dart';
import 'package:productivity_planner/core/device/device_id_provider.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/network/api_paths.dart';

/// Adds `X-Request-Id` and `X-Device-Id` to every request, and an
/// `Idempotency-Key` to every POST (contract §1).
///
/// Existing values are kept, so a retried request (after a token refresh) is
/// traced and de-duplicated as the same request end to end, and callers such
/// as sync push can supply their own key (the op id).
final class ClientHeadersInterceptor extends Interceptor {
  ClientHeadersInterceptor({
    required IdGenerator ids,
    required DeviceIdProvider deviceIds,
  }) : _ids = ids,
       _deviceIds = deviceIds;

  final IdGenerator _ids;
  final DeviceIdProvider _deviceIds;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent(ApiHeaders.requestId, _ids.newId);
    if (options.method.toUpperCase() == 'POST') {
      options.headers.putIfAbsent(ApiHeaders.idempotencyKey, _ids.newId);
    }
    options.headers[ApiHeaders.deviceId] = await _deviceIds.deviceId();
    handler.next(options);
  }
}
