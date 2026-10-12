import 'package:drift_flutter/drift_flutter.dart';
import 'package:productivity_planner/core/database/app_database.dart';

/// Opens the on-device database (`app.sqlite` in the app support folder).
///
/// `shareAcrossIsolates` lets the notification-action isolate (Phase 6) use
/// the same connection instead of opening a second writer on the file.
AppDatabase openAppDatabase() => AppDatabase(
  driftDatabase(
    name: 'app',
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  ),
);
