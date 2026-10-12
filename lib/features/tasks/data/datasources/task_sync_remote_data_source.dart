import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/http_clients.dart';

/// Server state of single entities (contract §4.3), read after the server
/// refused a change so the local copy can be put back in line. Each
/// returns the entity's `data` object plus `version`; throws on failure
/// (a `DioException` with status 404 when it does not exist).
abstract interface class TaskSyncRemoteDataSource {
  Future<Map<String, Object?>> getSeries(String id);

  Future<Map<String, Object?>> getOccurrence(String id);

  /// All the user's categories.
  Future<List<Map<String, Object?>>> getCategories();
}

final class HttpTaskSyncRemoteDataSource implements TaskSyncRemoteDataSource {
  const HttpTaskSyncRemoteDataSource(this._client);

  final ApiHttpClient _client;

  @override
  Future<Map<String, Object?>> getSeries(String id) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiPaths.seriesById(id),
    );
    return _object(response.data);
  }

  @override
  Future<Map<String, Object?>> getOccurrence(String id) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiPaths.occurrence(id),
    );
    return _object(response.data);
  }

  @override
  Future<List<Map<String, Object?>>> getCategories() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiPaths.categories,
    );
    final items = _object(response.data)['items'];
    if (items is! List) throw const FormatException('items', 'categories');
    return [
      for (final item in items)
        if (item is Map) Map<String, Object?>.from(item),
    ];
  }
}

Map<String, Object?> _object(Map<String, dynamic>? data) => data == null
    ? throw const FormatException('Expected a JSON object body')
    : Map<String, Object?>.from(data);
