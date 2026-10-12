import 'package:productivity_planner/core/device/device_context.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/home_time_zone.dart';

/// The signed-in user's profile zone, falling back to the device zone.
final class ProfileHomeTimeZone implements HomeTimeZone {
  const ProfileHomeTimeZone({
    required WatchAuthState watchAuthState,
    required DeviceContext device,
  }) : _watchAuthState = watchAuthState,
       _device = device;

  final WatchAuthState _watchAuthState;
  final DeviceContext _device;

  @override
  Future<String> current() async {
    if (_watchAuthState.current case Authenticated(:final user)
        when user.timeZone.isNotEmpty) {
      return user.timeZone;
    }
    return await _device.timeZone();
  }
}
