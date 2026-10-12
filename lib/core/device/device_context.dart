import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Facts about the device the server needs when creating an account and,
/// from Phase 6, when scheduling reminders.
abstract interface class DeviceContext {
  /// IANA time-zone name, e.g. `Asia/Kolkata`. Falls back to `UTC`.
  Future<String> timeZone();

  /// BCP 47 language tag of the device locale, e.g. `en-IN`.
  String localeTag();
}

final class PlatformDeviceContext implements DeviceContext {
  const PlatformDeviceContext();

  @override
  Future<String> timeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final identifier = info.identifier;
      return identifier.isEmpty ? 'UTC' : identifier;
    } on Object {
      // Plugin unavailable (tests, unsupported platform): the user can fix
      // the zone in Profile; UTC is never wrong for storage.
      return 'UTC';
    }
  }

  @override
  String localeTag() =>
      WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag();
}
