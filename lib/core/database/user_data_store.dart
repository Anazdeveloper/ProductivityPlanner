import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/database/app_meta_store.dart';

/// Ties the local data to one user account.
///
/// Rows have no user column; instead the database records which user they
/// belong to and is emptied before a different user's data can mix in.
final class UserDataStore {
  const UserDataStore({required AppDatabase db, required AppMetaStore meta})
    : _db = db,
      _meta = meta;

  final AppDatabase _db;
  final AppMetaStore _meta;

  /// Makes [userId] the owner of the local data. If another user owned it,
  /// their data (including unsynced changes) is deleted first.
  ///
  /// Returns true when data was deleted.
  Future<bool> bindToUser(String userId) => _db.transaction(() async {
    final owner = await _meta.read(AppMetaKeys.boundUserId);
    if (owner == userId) return false;
    final wiped = owner != null;
    if (wiped) await _deleteUserRows();
    await _meta.write(AppMetaKeys.boundUserId, userId);
    return wiped;
  });

  /// Deletes all user data and the owner binding. The device id stays.
  Future<void> clearUserData() => _db.transaction(() async {
    await _deleteUserRows();
    await _meta.delete(AppMetaKeys.boundUserId);
  });

  /// Like [clearUserData], but only when nothing is waiting to be pushed:
  /// signing out must never destroy changes the server has not received.
  /// Returns whether the data was cleared.
  ///
  /// Kept data stays bound to its user: the same user gets it back on the
  /// next sign-in; a different user's sign-in replaces it ([bindToUser]).
  Future<bool> clearUserDataIfSynced() => _db.transaction(() async {
    final pending = await (_db.select(
      _db.outboxOperations,
    )..limit(1)).get();
    if (pending.isNotEmpty) return false;
    await _deleteUserRows();
    await _meta.delete(AppMetaKeys.boundUserId);
    return true;
  });

  Future<void> _deleteUserRows() async {
    // Children first; cascades would cover most of it, but being explicit
    // keeps this correct if a foreign key is ever relaxed.
    await _db.delete(_db.occurrenceEvents).go();
    await _db.delete(_db.workSessions).go();
    await _db.delete(_db.taskOccurrences).go();
    await _db.delete(_db.taskSeries).go();
    await _db.delete(_db.categories).go();
    await _db.delete(_db.outboxOperations).go();
    await _db.delete(_db.syncIssues).go();
    await _meta.delete(AppMetaKeys.syncCursor);
  }
}
