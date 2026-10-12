enum TaskPriority { low, medium, high }

/// How a series repeats. `none` is a one-off task.
enum RecurrenceFrequency { none, daily, weekly, monthly }

/// The stored lifecycle state of an occurrence. Time-dependent states
/// (upcoming, due, overdue, missed, paused) are derived, never stored: see
/// `DerivedStatus` and `OccurrenceStatusResolver`.
enum OccurrenceStatus {
  scheduled,
  inProgress,
  completed,
  skipped,
  cancelled;

  /// Completed, skipped and cancelled occurrences only change via reopen.
  bool get isResolved =>
      this == completed || this == skipped || this == cancelled;
}

/// What the UI shows for an occurrence at a given moment.
enum DerivedStatus {
  /// Scheduled for later.
  upcoming,

  /// Start time reached (or today, for an any-time task) and not started.
  due,

  /// Past its window today and not started.
  overdue,

  /// Its day ended without it being started or resolved.
  missed,

  /// Started; a work session is running.
  inProgress,

  /// Started; no work session is running.
  paused,
  completed,
  skipped,
  cancelled,
}

/// Why the user skipped an occurrence (analytics input).
enum SkipReason { noTime, notNeeded, tooTired, forgot, other }

/// Why a work session ended.
enum SessionEndReason {
  paused,

  /// Another task was started, which pauses this one.
  autoPaused,
  completed,
  cancelled,
}

/// Every change recorded in an occurrence's history. Also identifies the
/// sync op a change produces.
enum OccurrenceTransition {
  started,
  resumed,
  paused,
  completed,
  skipped,
  postponed,
  cancelled,
  reopened,
  noteUpdated,
}
