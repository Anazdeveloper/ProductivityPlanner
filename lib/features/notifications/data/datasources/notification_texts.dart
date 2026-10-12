import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Localized strings for notifications, built without a widget tree: the
/// scheduler may run in a background isolate (notification actions, push
/// wake-ups) where no `BuildContext` exists.
///
/// The app ships English only; `locale` is the seam for more languages.
final class NotificationTexts {
  NotificationTexts({
    required TimeZoneConverter converter,
    Locale locale = const Locale('en'),
  }) : _converter = converter,
       _locale = locale,
       l10n = lookupAppLocalizations(locale);

  final TimeZoneConverter _converter;
  final Locale _locale;
  final AppLocalizations l10n;

  String title(ReminderRequest request) => request.taskTitle;

  String body(ReminderRequest request) {
    final time = _wallTime(request);
    return switch (request.kind) {
      ReminderKind.reminder => l10n.reminderNotificationBody(time),
      ReminderKind.snooze => l10n.snoozeNotificationBody(time),
    };
  }

  /// The start as the user would read it in the task's own zone, e.g.
  /// "7:00 PM".
  String _wallTime(ReminderRequest request) {
    final zone = _converter.isValidZone(request.timeZone)
        ? request.timeZone
        : 'UTC';
    final time = _converter.localTime(request.startAt, zone);
    return DateFormat.jm(
      _locale.toLanguageTag(),
    ).format(DateTime(2000, 1, 1, time.hour, time.minute));
  }
}
