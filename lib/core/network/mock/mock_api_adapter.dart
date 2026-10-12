import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A fake backend at the transport level. The real Dio clients, interceptors,
/// DTO parsing and error mapping all run; only the network is replaced.
///
/// Used by tests and by the `USE_MOCK_API` dev build until the NestJS server
/// exists. Each feature registers handlers for the endpoints it uses, shaped
/// exactly like `contracts/api/v1.md`; unregistered paths answer
/// `404 MOCK_ROUTE_MISSING` so a missing mock is obvious, never silent.
final class MockApiAdapter implements HttpClientAdapter {
  MockApiAdapter({this.latency = Duration.zero});

  final Duration latency;

  /// When true every request fails as if the device had no connection.
  bool offline = false;

  final List<MockRequest> received = [];
  final List<_Route> _routes = [];

  /// Registers [handler] for `method` + a path pattern relative to the base
  /// URL, e.g. `on('POST', 'occurrences/:id/complete', …)`.
  void on(String method, String pathPattern, MockHandler handler) {
    _routes.add(_Route(method.toUpperCase(), _segments(pathPattern), handler));
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'MockApiAdapter is offline',
      );
    }

    final path = _relativePath(options);
    final request = MockRequest(
      method: options.method.toUpperCase(),
      path: path,
      pathParameters: const {},
      queryParameters: options.queryParameters,
      headers: options.headers,
      body: options.data,
    );

    for (final route in _routes) {
      final params = route.match(request.method, _segments(path));
      if (params == null) continue;
      final matched = request.withPathParameters(params);
      received.add(matched);
      final response = await route.handler(matched);
      return response._toResponseBody();
    }

    received.add(request);
    return MockResponse.problem(
      status: 404,
      code: 'MOCK_ROUTE_MISSING',
      detail: 'No mock for ${request.method} $path',
    )._toResponseBody();
  }

  @override
  void close({bool force = false}) {}

  static String _relativePath(RequestOptions options) {
    final basePath = Uri.parse(options.baseUrl).path;
    final fullPath = options.uri.path;
    final relative = fullPath.startsWith(basePath)
        ? fullPath.substring(basePath.length)
        : fullPath;
    return relative.startsWith('/') ? relative.substring(1) : relative;
  }

  static List<String> _segments(String path) =>
      path.split('/').where((s) => s.isNotEmpty).toList();
}

typedef MockHandler = FutureOr<MockResponse> Function(MockRequest request);

final class MockRequest {
  const MockRequest({
    required this.method,
    required this.path,
    required this.pathParameters,
    required this.queryParameters,
    required this.headers,
    required this.body,
  });

  final String method;
  final String path;
  final Map<String, String> pathParameters;
  final Map<String, dynamic> queryParameters;
  final Map<String, dynamic> headers;

  /// The request body as passed to Dio (usually a JSON map).
  final Object? body;

  MockRequest withPathParameters(Map<String, String> params) => MockRequest(
    method: method,
    path: path,
    pathParameters: params,
    queryParameters: queryParameters,
    headers: headers,
    body: body,
  );
}

final class MockResponse {
  const MockResponse(this.statusCode, {this.body, this.contentType});

  factory MockResponse.json(Object? body, {int status = 200}) =>
      MockResponse(status, body: body, contentType: Headers.jsonContentType);

  /// An RFC 9457 error body matching the contract.
  factory MockResponse.problem({
    required int status,
    required String code,
    String? title,
    String? detail,
    Map<String, Object?> extra = const {},
  }) => MockResponse(
    status,
    contentType: 'application/problem+json',
    body: {
      'type': 'about:blank',
      'title': title ?? code,
      'status': status,
      'code': code,
      if (detail != null) 'detail': detail,
      ...extra,
    },
  );

  final int statusCode;
  final Object? body;
  final String? contentType;

  /// An empty body (e.g. `204`) is sent as `text/plain` so Dio does not try
  /// to decode it as JSON.
  ResponseBody _toResponseBody() => ResponseBody.fromString(
    body == null ? '' : jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [
        if (body == null)
          Headers.textPlainContentType
        else
          contentType ?? Headers.jsonContentType,
      ],
    },
  );
}

final class _Route {
  _Route(this.method, this.segments, this.handler);

  final String method;
  final List<String> segments;
  final MockHandler handler;

  /// Path parameters when [path] matches this route, otherwise null.
  Map<String, String>? match(String requestMethod, List<String> path) {
    if (requestMethod != method || path.length != segments.length) return null;
    final params = <String, String>{};
    for (var i = 0; i < segments.length; i++) {
      final pattern = segments[i];
      if (pattern.startsWith(':')) {
        params[pattern.substring(1)] = Uri.decodeComponent(path[i]);
      } else if (pattern != path[i]) {
        return null;
      }
    }
    return params;
  }
}
