import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/features/auth/data/datasources/session_storage.dart';

/// Signs out a session left behind by a previous install.
///
/// iOS keeps Keychain items after the app is deleted, so a reinstall would
/// otherwise resume the old session with an empty database. The database
/// file is deleted with the app, so "the database was just created" means
/// "fresh install" (or app data cleared), and any stored session is stale.
///
/// Must run before the session is restored.
Future<void> discardSessionFromPreviousInstall({
  required AppDatabase database,
  required SessionStorage sessionStorage,
  required AppLogger logger,
  required ErrorReporter reporter,
}) async {
  try {
    if (await database.createdOnThisLaunch()) {
      await sessionStorage.clear();
      logger.info('fresh install: stored session discarded');
    }
  } on Object catch (error, stackTrace) {
    // Never block startup; the worst case is the Phase 3 behaviour.
    await reporter.report(error, stackTrace, context: {'step': 'fresh_install'});
  }
}
