import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/features/subscription/data/models/entitlement_json.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';

/// `GET me/entitlements`. Throws; the repository guards with
/// `guardRemoteCall`.
abstract interface class SubscriptionRemoteDataSource {
  Future<Entitlement> getEntitlement();
}

final class HttpSubscriptionRemoteDataSource
    implements SubscriptionRemoteDataSource {
  const HttpSubscriptionRemoteDataSource(this._client);

  final ApiHttpClient _client;

  @override
  Future<Entitlement> getEntitlement() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiPaths.meEntitlements,
    );
    final body =
        response.data ??
        (throw const FormatException('Expected a JSON object body'));
    return entitlementFromJson(body);
  }
}
