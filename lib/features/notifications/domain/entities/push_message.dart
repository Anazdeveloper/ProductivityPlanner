import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_message.freezed.dart';

/// `data.type` of a push (contract §3.2).
enum PushMessageType { sync, account, subscription, insight, unknown }

/// A push message, already reduced to what the app acts on.
@freezed
abstract class PushMessage with _$PushMessage {
  const factory PushMessage({
    required PushMessageType type,

    /// Display text when the server sent a visible notification.
    String? title,
    String? body,

    /// `data.route`, unvalidated. Use `PushMessageRouter` before navigating.
    String? route,
  }) = _PushMessage;

  /// Parses an FCM `data` map. Unknown types become [PushMessageType.unknown].
  factory PushMessage.fromData(
    Map<String, Object?> data, {
    String? title,
    String? body,
  }) {
    final type = switch (data['type']) {
      'sync' => PushMessageType.sync,
      'account' => PushMessageType.account,
      'subscription' => PushMessageType.subscription,
      'insight' => PushMessageType.insight,
      _ => PushMessageType.unknown,
    };
    final route = data['route'];
    return PushMessage(
      type: type,
      title: title,
      body: body,
      route: route is String ? route : null,
    );
  }
}
