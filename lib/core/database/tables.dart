import 'package:drift/drift.dart';

// Local schema (approved design, section 6). Conventions:
// - Ids are client-generated UUID strings (v7; occurrences use v5).
// - Instants are UTC `DateTime`s, stored as ISO-8601 text (build.yaml).
// - Local dates are `YYYY-MM-DD` text and wall times `HH:mm` text, so they
//   sort and compare correctly in SQL and never pass through a zone.
// - Durations are whole seconds.
// - Enums are stored as their wire strings; the feature data layer maps them.
// - `version` is the server's row version (0 = never acknowledged by the
//   server); it is the `base_version` of the next outbox op.
// - All user rows belong to the single bound user (UserDataStore), so there
//   is no user_id column: the store is wiped when a different user signs in.

/// Small key/value facts about this install (device id, bound user, sync
/// cursor). Survives sign-out; cleared only by reinstalling.
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Theme palette key (e.g. `blue`), not a raw colour, so dark mode works.
  TextColumn get colorKey => text()();
  TextColumn get iconKey => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Default categories are seeded with deterministic ids on every device.
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A task as the user defined it: what, how long, and when it repeats.
@DataClassName('TaskSeriesRow')
class TaskSeries extends Table {
  TextColumn get id => text()();

  /// Shared by all series produced by "change from this date" splits, so
  /// analytics can follow one activity across schedule changes.
  TextColumn get lineageId => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();

  /// No foreign key: a category may arrive by sync after the series.
  TextColumn get categoryId => text().nullable()();
  TextColumn get priority => text()();
  IntColumn get plannedDurationSeconds => integer()();

  // Schedule
  TextColumn get startDate => text()();

  /// Null for "any time that day".
  TextColumn get startTime => text().nullable()();
  TextColumn get timeZone => text()();
  TextColumn get frequency => text()();
  IntColumn get interval => integer().withDefault(const Constant(1))();

  /// Comma-separated ISO weekdays, e.g. `1,3,5`. Empty when not weekly.
  TextColumn get weekdays => text().withDefault(const Constant(''))();
  IntColumn get monthDay => integer().nullable()();
  TextColumn get untilDate => text().nullable()();
  IntColumn get occurrenceCount => integer().nullable()();

  /// Comma-separated seconds before start, e.g. `300`. Empty for none.
  TextColumn get reminderOffsets => text().withDefault(const Constant(''))();

  /// Last local date with occurrences; null for the series' first day.
  TextColumn get endedOn => text().nullable()();

  /// Occurrences exist up to this local date (materialization watermark).
  TextColumn get materializedThrough => text().nullable()();

  IntColumn get version => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One dated instance of a series with its own lifecycle.
@DataClassName('TaskOccurrenceRow')
@TableIndex(name: 'task_occurrences_scheduled_date', columns: {#scheduledDate})
class TaskOccurrences extends Table {
  /// `UUIDv5(series_id, original_date)`: identical on every device.
  TextColumn get id => text()();
  TextColumn get seriesId =>
      text().references(TaskSeries, #id, onDelete: KeyAction.cascade)();

  /// The date the recurrence rule produced. Never changes.
  TextColumn get originalDate => text()();

  /// The date the occurrence is currently planned for (changes on postpone).
  TextColumn get scheduledDate => text()();

  /// Null for "any time that day".
  DateTimeColumn get scheduledStart => dateTime().nullable()();

  /// The start the rule produced, kept for postpone analytics.
  DateTimeColumn get originalStart => dateTime().nullable()();
  IntColumn get plannedDurationSeconds => integer()();
  TextColumn get status => text()();
  IntColumn get postponeCount => integer().withDefault(const Constant(0))();

  /// First time work started (first work session).
  DateTimeColumn get actualStart => dateTime().nullable()();

  /// Null means "not measured" (completed without a timer), not zero.
  IntColumn get actualDurationSeconds => integer().nullable()();

  /// When it became completed, skipped or cancelled.
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  TextColumn get skipReason => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {seriesId, originalDate},
  ];
}

/// A span of time actually spent on an occurrence (start→pause, resume→done).
/// At most one open session per occurrence (partial unique index created in
/// AppDatabase).
@DataClassName('WorkSessionRow')
@TableIndex(name: 'work_sessions_occurrence', columns: {#occurrenceId})
class WorkSessions extends Table {
  TextColumn get id => text()();
  TextColumn get occurrenceId =>
      text().references(TaskOccurrences, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get endReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Append-only history of what happened to an occurrence (analytics input).
@DataClassName('OccurrenceEventRow')
@TableIndex(name: 'occurrence_events_occurrence', columns: {#occurrenceId})
class OccurrenceEvents extends Table {
  TextColumn get id => text()();
  TextColumn get occurrenceId =>
      text().references(TaskOccurrences, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();

  /// JSON object with type-specific details (e.g. postpone target).
  TextColumn get data => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local changes waiting to be pushed (`POST sync/push`, contract §4).
/// Written in the same transaction as the change it describes.
@DataClassName('OutboxOperationRow')
class OutboxOperations extends Table {
  /// Push order.
  IntColumn get seq => integer().autoIncrement()();

  /// UUIDv7; also the idempotency key.
  TextColumn get opId => text().unique()();
  TextColumn get type => text()();
  TextColumn get entityId => text()();
  IntColumn get baseVersion => integer().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get payloadSchema => integer().withDefault(const Constant(1))();

  /// JSON object, shapes in contract §4.1.
  TextColumn get payload => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// Changes the server refused (`rejected` in `sync/push`), kept so the
/// person can see what did not reach their other devices (Settings → Sync).
/// The rejected op itself is removed from the outbox.
@DataClassName('SyncIssueRow')
class SyncIssues extends Table {
  TextColumn get id => text()();

  /// The op type wire string, e.g. `series.create`.
  TextColumn get opType => text()();
  TextColumn get entityId => text()();

  /// The server's problem `code` (e.g. `LIMIT_REACHED`).
  TextColumn get code => text()();

  /// What the change was about (a task title), if known.
  TextColumn get label => text().nullable()();

  /// The local data still has to be re-read from the server (the read
  /// failed, e.g. offline); retried on every sync run until it succeeds.
  BoolColumn get repairPending =>
      boolean().withDefault(const Constant(false))();

  /// Hidden by the person; kept only until its repair is done.
  BoolColumn get dismissed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
