import 'package:productivity_planner/features/notifications/domain/entities/push_message.dart';

/// Turns a tapped push into an in-app location.
///
/// `data.route` comes from the server, so only relative in-app paths are
/// accepted (never a scheme, host or `//`); anything else falls back to the
/// type's default screen. The router's auth guard still applies on top.
final class PushMessageRouter {
  const PushMessageRouter({required this.defaults});

  /// Default location per type (e.g. subscription → the paywall). Supplied
  /// by the composition root, which owns the route table.
  final Map<PushMessageType, String> defaults;

  /// Null when the message should not navigate (sync pings, unknown types).
  String? locationFor(PushMessage message) {
    if (message.type == PushMessageType.sync ||
        message.type == PushMessageType.unknown) {
      return null;
    }
    return _safe(message.route) ?? defaults[message.type];
  }

  static String? _safe(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (!raw.startsWith('/') || raw.startsWith('//')) return null;
    final parsed = Uri.tryParse(raw);
    if (parsed == null || parsed.hasScheme || parsed.hasAuthority) return null;
    return raw;
  }
}
