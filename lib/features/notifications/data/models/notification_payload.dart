import 'dart:convert';

import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';

/// The `payload` string stored with every local notification this app
/// shows. It survives app restarts and reboots (the platform persists it),
/// so it is versioned and tolerant: anything unreadable is "not ours".
sealed class NotificationPayload {
  const NotificationPayload();

  static const _version = 1;

  /// Null for payloads this app did not write (or wrote in a future,
  /// incompatible format).
  static NotificationPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic> || json['v'] != _version) return null;
      switch (json['k']) {
        case 'reminder' || 'snooze':
          final occurrence = json['o'];
          final fingerprint = json['f'];
          final mode = json['m'];
          if (occurrence is! String || fingerprint is! String) return null;
          return ReminderPayload(
            occurrenceId: occurrence,
            kind: json['k'] == 'snooze'
                ? ReminderKind.snooze
                : ReminderKind.reminder,
            fingerprint: fingerprint,
            scheduleMode: mode is String ? mode : null,
          );
        case 'push':
          final route = json['r'];
          final type = json['t'];
          return PushPayload(
            type: type is String ? type : null,
            route: route is String ? route : null,
          );
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  String encode();
}

final class ReminderPayload extends NotificationPayload {
  const ReminderPayload({
    required this.occurrenceId,
    required this.kind,
    required this.fingerprint,
    this.scheduleMode,
  });

  ReminderPayload.of(ReminderRequest request, {this.scheduleMode})
    : occurrenceId = request.occurrenceId,
      kind = request.kind,
      fingerprint = request.fingerprint;

  final String occurrenceId;
  final ReminderKind kind;
  final String fingerprint;

  /// How the platform alarm was set (Android `exact` / `inexact`), so a
  /// reminder can be re-armed when the user allows exact alarms later.
  final String? scheduleMode;

  @override
  String encode() => jsonEncode({
    'v': NotificationPayload._version,
    'k': kind.name,
    'o': occurrenceId,
    'f': fingerprint,
    if(scheduleMode != null) 'm': scheduleMode,
  });
}

/// A push shown by the app itself (Android foreground messages).
final class PushPayload extends NotificationPayload {
  const PushPayload({this.type, this.route});

  /// The push's `data.type`, so a tap opens the right default screen.
  final String? type;
  final String? route;

  @override
  String encode() => jsonEncode({
    'v': NotificationPayload._version,
    'k': 'push',
    if(type != null) 't': type,
    if(route != null) 'r': route,
  });
}
