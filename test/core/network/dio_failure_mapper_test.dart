import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/network/dio_failure_mapper.dart';

void main() {
  final request = RequestOptions(path: 'me');

  DioException badResponse(int status, [Object? body]) => DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: status,
      data: body,
    ),
  );

  group('connectivity', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ]) {
      test('$type → network', () {
        expect(
          mapDioException(DioException(requestOptions: request, type: type)),
          const Failure.network(),
        );
      });
    }

    test('unknown error without a response → network', () {
      expect(
        mapDioException(
          DioException(requestOptions: request, error: Exception('socket')),
        ),
        const Failure.network(),
      );
    });
  });

  group('problem+json responses', () {
    test('422 with field errors → validation', () {
      final failure = mapDioException(
        badResponse(422, {
          'code': 'VALIDATION_FAILED',
          'detail': 'Invalid task',
          'errors': [
            {'field': 'title', 'message': 'must not be empty'},
          ],
        }),
      );
      expect(
        failure,
        const Failure.validation(
          fieldErrors: {'title': 'must not be empty'},
          message: 'Invalid task',
        ),
      );
    });

    test('401 → unauthenticated', () {
      expect(mapDioException(badResponse(401)), const Failure.unauthenticated());
    });

    test('403 ENTITLEMENT_REQUIRED with a known feature → entitlementRequired', () {
      expect(
        mapDioException(
          badResponse(403, {
            'code': 'ENTITLEMENT_REQUIRED',
            'feature': 'feature.insights',
          }),
        ),
        const Failure.entitlementRequired(feature: Feature.insights),
      );
    });

    test('403 LIMIT_REACHED → limitReached with allowed', () {
      expect(
        mapDioException(
          badResponse(403, {
            'code': 'LIMIT_REACHED',
            'limit': 'limit.active_series',
            'allowed': 20,
          }),
        ),
        const Failure.limitReached(limit: LimitKey.activeSeries, allowed: 20),
      );
    });

    test('403 with an unknown feature key → forbidden', () {
      expect(
        mapDioException(
          badResponse(403, {'code': 'ENTITLEMENT_REQUIRED', 'feature': 'feature.new'}),
        ),
        const Failure.forbidden(),
      );
    });

    test('409 keeps the server code', () {
      expect(
        mapDioException(badResponse(409, {'code': 'ALREADY_RESOLVED'})),
        const Failure.conflict(code: 'ALREADY_RESOLVED'),
      );
    });

    test('409 without a body → generic CONFLICT', () {
      expect(
        mapDioException(badResponse(409)),
        const Failure.conflict(code: 'CONFLICT'),
      );
    });

    test('5xx → server with request id', () {
      expect(
        mapDioException(
          badResponse(503, {'code': 'UNAVAILABLE', 'request_id': 'req-1'}),
        ),
        const Failure.server(
          statusCode: 503,
          code: 'UNAVAILABLE',
          requestId: 'req-1',
        ),
      );
    });

    test('a non-JSON error body still maps by status', () {
      expect(
        mapDioException(badResponse(502, '<html>Bad gateway</html>')),
        const Failure.server(statusCode: 502),
      );
    });

    test('a JSON string body is decoded', () {
      expect(
        mapDioException(badResponse(409, '{"code":"STALE_VERSION"}')),
        const Failure.conflict(code: 'STALE_VERSION'),
      );
    });
  });
}
