/// Identifies this app install (`X-Device-Id`, sync `device_id`, refresh
/// token binding). Must survive restarts and reset on reinstall.
///
/// Implemented by `PersistentDeviceIdProvider` (stored in the local
/// database, which is deleted with the app).
abstract interface class DeviceIdProvider {
  Future<String> deviceId();
}
