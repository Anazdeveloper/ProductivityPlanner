import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/core/device/device_id_provider.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';

/// Device id stored in the local database: stable across launches and
/// sign-outs, new after a reinstall (the database file is deleted with the
/// app, unlike iOS Keychain items).
final class PersistentDeviceIdProvider implements DeviceIdProvider {
  PersistentDeviceIdProvider({
    required AppMetaStore meta,
    required IdGenerator ids,
  }) : _meta = meta,
       _ids = ids;

  final AppMetaStore _meta;
  final IdGenerator _ids;

  /// Shared by concurrent first callers so only one id is ever created.
  Future<String>? _pending;

  @override
  Future<String> deviceId() => _pending ??= _loadOrCreate();

  Future<String> _loadOrCreate() async {
    try {
      final stored = await _meta.read(AppMetaKeys.deviceId);
      if (stored != null && stored.isNotEmpty) return stored;
      final created = _ids.newId();
      await _meta.write(AppMetaKeys.deviceId, created);
      return created;
    } on Object {
      // Allow a retry on the next call instead of caching the failure.
      _pending = null;
      rethrow;
    }
  }
}
