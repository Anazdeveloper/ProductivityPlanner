# Mobile architecture

This document records how the Flutter app implements the approved product
architecture, where the implementation brief and the approved design differed,
and which rules are enforced by tests.

## 1. Validation against the approved design

| Topic | Approved design | Implementation brief | Resolution |
| --- | --- | --- | --- |
| Top-level folders | `app/`, `core/`, `features/` | `config/`, `core/`, `features/` | `config/` is the composition root: bootstrap, DI, router, theme, environment. Same role as `app/`, brief's name kept. |
| Home screen | `today` feature | "Dashboard" | Phase 5: Today and Planner are pages **of the tasks feature** (`features/tasks/presentation/pages`). Both render the same agenda rows and share `DailyPlannerCubit`; as separate features they would have needed cross-feature presentation imports, which rule 4 forbids. Today *is* the dashboard; Analytics stays a separate tab. |
| Domain entities | TaskSeries, TaskOccurrence, WorkSession, RecurrenceRule, OccurrenceEvent | Task, TaskOccurrence, TaskSchedule, TaskCompletion, ProductivityMetric | Phase 4 names: **Task** = series (intent + recurrence), **TaskSchedule** = recurrence value object, **TaskOccurrence** = dated instance with its own lifecycle, **TaskCompletion** = not a separate type: completion facts (`actualStart`, `actualDuration` — null = not measured — and `resolvedAt`) live on the occurrence, the time spent in its `WorkSession`s, **ProductivityMetric** = read models (daily/lineage stats). Series vs occurrence split is kept: it is what makes analytics, sync and reminders simple. |
| Blocs | TodayBloc, TaskEditorBloc, FocusTimerBloc, VoiceCaptureBloc, cubits for settings/auth/paywall | TaskBloc, TaskDetailBloc, DailyPlannerCubit, AnalyticsCubit, SubscriptionCubit, AuthBloc, NotificationCubit | No generic `TaskBloc` (it would become a god bloc). Phase 5 ships three **Cubits**: `DailyPlannerCubit` (Today and Planner), `TaskEditorCubit` (create/edit) and `TaskDetailCubit` (one occurrence). Their inputs are plain method calls with no event transformations, so Bloc events would add ceremony only. Still planned: `AuthBloc` ✅, `FocusTimerBloc` ✅, `AnalyticsCubit` ✅ (plus `ActivityAnalyticsCubit`), `VoiceCaptureBloc` ✅, `SubscriptionCubit` ✅, `NotificationCubit` ✅. |
| Offline sync timing | Outbox written from the first local write | Sync in Phase 11 | **Phase 4 creates the outbox table and every repository write enqueues an operation in the same transaction.** Phase 11 builds the engine that pushes/pulls it. Retrofitting the outbox later would mean rewriting every repository. |
| Typed routes | go_router + go_router_builder | go_router | Phase 1 uses path constants (`AppRoutes`) + a pure redirect function. Avoids a second code generator for ~10 routes; revisit if routes grow. |
| Sign-in | Required on first launch, Apple/Google in MVP | Authentication routes | Unauthenticated users can reach only `/splash` and `/sign-in`. Deep links are remembered in `?from=` and resumed after sign-in. |
| Material split | Flutter 3.47 moving Material/Cupertino into packages | — | Uses `package:flutter/material.dart` until the November stable; then `dart fix --apply --code=migrate_design_widgets`. |
| Backend API | Approved REST + sync contract | "Never invent APIs" | Phase 2 commits the approved endpoints as Dart interfaces + DTOs with mock data sources; nothing beyond the approved spec is assumed. |

## 2. Layers and dependency rules

```
presentation  ──▶  domain  ◀──  data
      │              ▲            │
      └──────▶  core (pure parts) ◀┘
config/ (composition root) ──▶ everything
```

| Layer | Contains | May import |
| --- | --- | --- |
| `features/*/domain` | entities, value objects, repository interfaces, use cases | pure Dart: `core/{error,result,usecase,time,entitlements,ids}`, `freezed_annotation`, `json_annotation` |
| `features/*/data` | DTOs, mappers, local (Drift) and remote (HTTP) data sources, repository implementations | domain, core |
| `features/*/presentation` | pages, widgets, blocs/cubits | own domain, core, flutter, flutter_bloc |
| `core/` | Result, Failure, Clock, UseCase, entitlement keys; later: network client, database, sync engine, reminder reconciler | never `features/` or `config/` |
| `config/` | bootstrap, DI, router, theme, environment | anything |

Enforced by `test/architecture/layer_rules_test.dart`:

1. `lib/` uses package imports only.
2. Domain code (and pure core folders) imports no Flutter, `dart:io`, `dart:ui`, HTTP, database, DI, router or bloc packages, and no `data/`, `presentation/` or `config/`.
3. Presentation never imports a `data/` folder, `core/network`, HTTP or the database.
4. A feature reaches another feature only through its `domain/`.
5. `core/` never imports `features/` or `config/`.
6. Only `config/` and `features/*/*_dependencies.dart` may use get_it.
7. Only `core/database`, `core/sync` and `data/` layers import drift.
8. Only `core/timezone` imports the `timezone` package (everything else uses the pure `TimeZoneConverter`).
9. Feature code imports `config/` only from its `*_dependencies.dart` registrar (shared UI pieces such as `AppStatusColors` live in `core/presentation`).

## 3. Errors

- Data sources throw; **repositories catch and map to `Failure`** and return `Result<T>`.
- Use cases and blocs only see `Result`/`Failure`.
- `failure.message(AppLocalizations.of(context))` (core/presentation) is the single source of user-facing wording; strings live in `lib/l10n/arb/app_en.arb`.
- `Failure.unexpected` = a bug: reported to error tracking, shown generically.
- Remote calls are wrapped in `guardRemoteCall`, which maps `DioException` with `mapDioException` (contract §2), reports malformed responses as `server(code: INVALID_RESPONSE)`, and reports anything else as `unexpected`.

## 4. Dependency injection

- `config/di/injection.dart#configureDependencies` registers in order: core → navigation, and from later phases auth, tasks, notifications, analytics, voice, subscription.
- Each feature exposes `registerXDependencies(GetIt)` in `features/x/x_dependencies.dart`.
- Blocs: `registerFactory`; repositories, database, sync engine, reminder service: `registerLazySingleton`.
- Widgets get blocs via `BlocProvider(create: (_) => sl<...>())` **in route builders** (config/), never inside feature widgets.

## 5. Navigation

- `StatefulShellRoute.indexedStack` with four tabs (Today, Planner, Insights, Settings); each tab keeps its stack.
- Bottom `NavigationBar` under 840 dp, `NavigationRail` above (tablets/landscape).
- Full-screen routes above the shell: `/tasks/new`, `/subscription`, `/occurrences/:id`.
- `/occurrences/:id` is the deep-link target for reminder notifications (Phase 6).
- Redirect logic is a pure function (`resolveAuthRedirect`) with unit tests; `?from=` accepts internal paths only (no open redirect, no loops).

## 6. Networking (Phase 2)

Contract: [`contracts/api/v1.md`](../../../contracts/api/v1.md). No endpoint is used unless it appears there; paths live in `core/network/api_paths.dart`.

| Piece | Role |
| --- | --- |
| `ApiHttpClient` | Authenticated client. Interceptors in order: client headers → auth → logging |
| `PublicHttpClient` | No auth: login, register, refresh, logout, password reset, config; also the retry client after a refresh. Separate types (not two `Dio`s) keep DI type-safe and break the cycle *token provider → refresh endpoint → client → token provider* |
| `ClientHeadersInterceptor` | `X-Request-Id` (kept on retry, so one request = one trace), `X-Device-Id`, and an `Idempotency-Key` on every POST (kept on retry; callers may supply their own, e.g. sync op ids) |
| `AuthInterceptor` (`QueuedInterceptor`) | Bearer token; on `401`: one refresh shared by concurrent requests, retry once via `public`. Rejected refresh → session ends. Refresh unreachable → network failure, session kept |
| `LoggingInterceptor` | Method, path, status, ms, request id. Never headers, query or bodies |
| `MockApiAdapter` | Fake backend at the transport layer, so the real interceptors, parsing and error mapping run. Unregistered routes answer `404 MOCK_ROUTE_MISSING`. Used in tests and with `env/dev-mock.json` |

`AuthTokenProvider` is the only thing the HTTP layer knows about the session; `AuthSessionManager` implements it.

## 7. Logging and error reporting (Phase 2)

- `AppLogger` → `DeveloperLogger` (`dart:developer`; no package). Context maps pass through `redactLogContext` (same key list as the server's pino redaction).
- `ErrorReporter` → `LoggingErrorReporter` now, Sentry in Phase 13. Wired to `FlutterError.onError`, `PlatformDispatcher.onError` and `AppBlocObserver.onError`.
- `AppBlocObserver` logs bloc and event **types**, never state contents.

## 8. IDs (Phase 2)

- New entities and sync ops: UUIDv7 (`IdGenerator`).
- Occurrences: `occurrenceIdFor(seriesId, originalLocalDate)` = UUIDv5(series id, `YYYY-MM-DD`), checked against the shared vectors in `contracts/vectors/occurrence_ids.json`.
- `DeviceIdProvider`: persisted in the local database since Phase 4 (wiped on reinstall, unlike the iOS Keychain).

## 9. Authentication (Phase 3)

```
SignInCubit ─┐                         ┌─ HttpAuthRemoteDataSource ── PublicHttpClient
RegisterCubit├─ use cases ─ AuthRepositoryImpl ─┤
ProfileCubit ┘     ▲                   ├─ HttpAccountRemoteDataSource ─ ApiHttpClient ─┐
AuthBloc ── WatchAuthState              ├─ Apple / Google credential sources            │
   │                                    └─ AuthSessionManager ◀── AuthInterceptor ◀─────┘
AuthBlocAuthGate ── GoRouter                 (session state, SecureSessionStorage,
                                              single-flight token refresh)
```

- **One session owner.** `AuthSessionManager` holds the in-memory session, persists it, publishes `AuthState`, and refreshes tokens for the HTTP layer. Sign-out by the user and expiry detected by the interceptor go through the same `end(reason)` path, so the UI and the tokens can never disagree.
- **Offline-first restore.** Start-up reads secure storage only. A stored session counts as signed in; the server's verdict arrives with the first request. An expired refresh token (by its stored expiry) restores as `unauthenticated(sessionExpired)`.
- **Refresh outcomes.** Server refused (401/403/4xx) → session ends with `sessionExpired`; couldn't ask (offline/5xx) → session kept, request fails as `network`. Refresh is single-flight because a refresh token is single-use (reuse revokes the family server-side).
- **Sign-out** always ends locally; server revocation is best-effort with a 5 s cap.
- **Apple**: iOS only. SHA-256(raw nonce) goes to Apple, the raw nonce to our server. **Google**: `google_sign_in` 7 (`initialize` + `authenticate`), hidden unless client ids are configured. In mock mode both use fake credential sources. Setup: [AUTH_SETUP.md](AUTH_SETUP.md).
- **Validation** lives in `CredentialRules` (domain). Forms show errors after the first submit; use cases re-check and return `Failure.validation` with `CredentialError` names as field codes. Server field messages are shown as-is.
- **Routing.** `AuthBlocAuthGate` adapts `AuthBloc` to the router and notifies only on status changes. Public routes: `/splash`, `/sign-in`, `/register`, `/forgot-password`. A deep link survives the sign-in → register detour via `?from=`.
- **Profile** has no data layer: it uses the auth domain (`RefreshCurrentUser`, `UpdateDisplayName`) because the session owns the cached profile. `PATCH me` sends `If-Match: version`.
- The iOS Keychain survives uninstall; since Phase 4 a freshly created local database clears session storage before the restore (section 11), so a reinstall starts signed out.

## 10. Time (Phase 4)

- `core/time` (pure): `LocalDate` (`YYYY-MM-DD`, no zone), `LocalTime` (`HH:mm`), `Clock`, and the `TimeZoneConverter` interface.
- `core/timezone/TzTimeZoneConverter` implements it with the IANA database bundled in the `timezone` package, so results do not depend on the device's tz data or current zone.
- Wall time → UTC: a time skipped by spring-forward moves forward by the gap; a repeated time resolves to the first instant. Shared vectors: `contracts/vectors/zone_resolution.json`.
- Every series stores its own IANA zone. "Today" for a series is computed in that zone; "today" for the app (agenda) comes from `HomeTimeZone` (profile zone, else device zone).
- Instants are UTC everywhere in Dart and in the database.

## 11. Local database and outbox (Phase 4)

`core/database/AppDatabase` (Drift, schema v2) is the source of truth the UI reads (offline-first). Tables: `app_meta`, `categories`, `task_series`, `task_occurrences`, `work_sessions`, `occurrence_events`, `outbox_operations`, and `sync_issues` (v2, Phase 11).

| Rule | Why |
| --- | --- |
| All tables live in `core/database`; features query them from their `data/` layer | one schema, one migration history, one file |
| Enums are stored as their API wire strings | rows push/pull without translation |
| Local dates/times as text, instants as ISO-8601 UTC text, durations in seconds | sortable, zone-free, readable |
| `UNIQUE(series_id, original_date)` + deterministic occurrence ids, inserted with "insert missing" | expansion on two devices (or the server) never duplicates |
| Partial unique index: one open work session per occurrence | a crash cannot leave two timers running on one task |
| Occurrence updates are in-place `UPDATE`s (never replace) | `REPLACE` would cascade-delete sessions and events |
| `version` = server row version, 0 = never acknowledged | becomes `base_version` of the next op |
| No `user_id` columns; `UserDataStore` binds the file to one user | a different user's sign-in wipes first; nothing can mix |

**Outbox.** `OutboxWriter.enqueue` is called inside the same transaction as the change (drift transactions are zone-scoped), so a change and its op commit or roll back together. Payload shapes: contract §4.1. Locally materialized occurrences are not pushed; occurrence ops carry `series_id` + `original_date` so the server materializes the same row. Phase 11 pushes the outbox; nothing in Phase 4 touches the network.

**Session lifecycle** (`config/session`):

| Event | Effect |
| --- | --- |
| Fresh install (database created this launch) | stored session cleared before restore (iOS Keychain survives uninstall) |
| Signed in | `bindToUser` (wipes a previous user's data), seed default categories (deterministic ids, contract §4.2), materialize occurrences |
| Signed out by the user | all user rows, outbox and sync cursor deleted, **unless unsynced ops exist** (then kept, still bound to that user); device id kept |
| A different user signs in | previous user's rows deleted first (including unsynced ops: logged as a warning) |
| Session expired | data kept (same user usually returns; unsynced changes survive) |
| App returns to the foreground (Phase 5) | occurrences topped up to the 14-day horizon (idempotent; skipped while signed out) |

Device id: `PersistentDeviceIdProvider` stores it in `app_meta`, so it survives restarts and sign-outs and changes on reinstall.

Migrations: bump `schemaVersion`, add a step in `AppDatabase.migration`, and snapshot with `dart run drift_dev make-migrations` (schemas in `drift_schemas/`, generated migration tests in `test/drift/`).

## 12. Tasks domain (Phase 4)

- **Task** (series) = intent: title, planned duration, category, priority, reminders, `TaskSchedule` (start date, optional start time, zone, `RecurrenceRule`).
- **TaskOccurrence** = one dated instance. Stored status: `scheduled`, `inProgress`, `completed`, `skipped`, `cancelled`. Derived (`OccurrenceStatusResolver`, depends on now): `upcoming`, `due`, `overdue`, `missed`, `paused`. Postpone is an event that changes `scheduledDate/Start`, keeps `originalDate/Start`, increments `postponeCount`.
- **RecurrenceExpander**: none/daily/weekly/monthly with interval, weekdays, month day, inclusive `until`, `count` from the start. Monthly days missing from a month are skipped. Pinned by `contracts/vectors/recurrence.json` (generated by a reference implementation the server shares).
- **OccurrencePlanner**: occurrences exist 14 days ahead (reminders, offline planner); a new series starts no earlier than today; missed days are back-filled up to 30 days when the app was closed.
- **OccurrenceLifecycle** (pure state machine): start/resume, pause, complete (tracked or entered duration; none = not measured), skip and postpone (only before work starts), cancel, reopen (back to paused if it was worked on), note. Starting a task auto-pauses any other running one. Invalid moves fail with `conflict(INVALID_TRANSITION)`, the server's code.
- **Schedule edits**: details (title, duration, …) edit in place; a new duration applies to not-started occurrences from today. "Change from date" edits in place when nothing precedes the date, otherwise splits the series (old ends the day before; new series shares `lineageId`). End/delete remove only untouched ("pristine") occurrences; anything the user worked on is history.
- **Validation** (`TaskRules`): field keys match API field names; codes (`required`, `too_long`, `out_of_range`, `invalid`, `in_past`, `unchanged`, `conflict`) are mapped to text by the UI in Phase 5.
- Plan limits (active/recurring series, advanced recurrence) are enforced in `CreateTask` from Phase 10.

### Tasks presentation (Phase 5)

| Piece | Responsibility |
| --- | --- |
| `AgendaSummarizer` (domain) | status at "now" and wall-clock start per item, day summary (done/total, planned and tracked time, next task) |
| `PostponeTargets` (domain) | "in 1 hour" (rounded to 5 min, only if still today) and "tomorrow, same time" in the task's zone |
| `DailyPlannerCubit` | watches the agenda for a day (Today) or Monday–Sunday week (Planner); re-derives statuses on each `Ticker` tick; follows midnight when showing today; complete/reopen toggle; quick add (any-time, 30 min, today) |
| `TaskEditorCubit` | form state; defaults (home zone, today, next half hour, 30 min, 5-min reminder); field errors come from `TaskRules` through the use cases; edit = details update and/or "reschedule from" the occurrence's date |
| `TaskDetailCubit` | one occurrence live; lifecycle actions; stop repeating; delete |
| `Ticker` (core/time) | injectable periodic "now" (30 s), so time-dependent labels refresh without database writes; tests tick manually |

Rules: widgets format and lay out only (`formatting/task_formatters.dart` maps values to localized text); every decision is in a cubit or the domain. A failed action surfaces once as a snackbar (a counter in state); a failed load shows an inline banner. Status is never colour-only (icon and label). Content is capped at 720 dp wide on tablets.

Start/pause and the live timer arrived in Phase 7 (§12b). Voice entry (Phase 9, §12d) opens the same editor pre-filled.

## 12a. Notifications (Phase 6)

Two mechanisms, as approved: **local notifications for task reminders**
and **FCM for server events**. Push never replaces a local reminder.

| Piece | Where | Responsibility |
| --- | --- | --- |
| `ReminderPlanner` | notifications/domain | upcoming agenda → desired reminders: one per offset, still in the future, only `scheduled` occurrences, earliest 48 (iOS keeps 64 per app) |
| `ReconcileReminders` | notifications/domain | diffs desired against the platform's pending list by id + fingerprint; schedules, replaces and cancels only what changed; idempotent |
| `HandleReminderAction` | notifications/domain | Done (complete, duration not measured) and Snooze 10 min; works in a background isolate |
| `PromptForRemindersIfNeeded` | notifications/domain | asks once, right after the user saves a task in the editor (foreground) and reminders could not be delivered because the user was never asked; never at launch or sign-in, never in the background |
| `LocalNotificationsClient`, `LocalReminderScheduler`, `LocalNotificationPermissions` | notifications/data | the only users of `flutter_local_notifications`; schedules in UTC; exact alarms when allowed, otherwise inexact-while-idle |
| `FirebasePushMessaging` / `NoopPushMessaging` | notifications/data | FCM token and messages; no-op when Firebase is not configured (mock builds, CI) |
| `ReminderSync` | config/session | reconciles on sign-in, occurrence changes in the window (debounced), the reminders switch, resume, day change and `sync` pushes; on any signed-out state ends the reminder session and removes every notification (pending and shown) |
| `DeviceSync` | config/session | `PUT devices/{id}` on sign-in, token refresh and switch change; on resume after a failure or when the last success is older than 12 h |
| `NotificationTapBridge` | config/notifications | reminder tap → occurrence; push tap → validated route; launch target; foreground action buttons |
| background handlers | config/notifications | `@pragma('vm:entry-point')` functions for action buttons and data pushes; build a small graph (database, tasks, reminders) with the same registrars, run one job, dispose |
| `NotificationCubit` | notifications/presentation | permission + reminders switch state (one app-wide instance shared by Today's banner and the settings page) |

Rules:

- Notification ids: `FNV-1a(kind|occurrence|offset)` masked to 31 bits, deterministic across isolates and runs. The payload is versioned JSON (`v`, `k`, `o`, `f`, `m`), so a pending notification from an older build is recognized or ignored, never misread. `m` records the Android alarm mode; a reminder armed inexact is re-armed once exact alarms are allowed.
- A device-level "reminder session" flag is set at sign-in and cleared at sign-out before cancelling. Background isolates act only while it is set, so a stale button press or push never re-schedules a signed-out user's tasks.
- Reminder text is built from facts without a `BuildContext` (`lookupAppLocalizations`), because it may run in a background isolate.
- A time-zone change needs no rescheduling: starts are absolute instants computed in each task's own zone.
- Today's banner comes from the router as a widget slot, because the tasks feature must not import notifications presentation.
- Contract §3.2 covers the device upsert, preferences and push payloads. `auth/logout` clears the device's push token on the server, so sign-out needs no extra call.

Native setup is in [NOTIFICATIONS_SETUP.md](NOTIFICATIONS_SETUP.md).

## 12b. Task execution and timers (Phase 7)

| Piece | Where | Responsibility |
| --- | --- | --- |
| `WorkTimer` / `TimerSnapshot` | tasks/domain | tracked time (all sessions, the open one up to now), current session, remaining/over plan, progress; `isImplausible` (over 12 h, or over max(3 × plan, plan + 2 h)) |
| `pickActiveWork` + `WatchActiveWork` | tasks/domain | the running occurrence, else the most recently paused one (`TaskRepository.watchInProgress`) |
| `FocusTimerBloc` | tasks/presentation | follows a target (active work on Today, one occurrence on the detail page); start/resume, pause, done with tracked time; asks before completing an implausible session; names a task that was auto-paused |
| `ActiveWorkCard`, `_TimerPanel`, `TimerToggleButton`, `ElapsedText`, `PlanProgress` | tasks/presentation | Today's "Working on" card and the detail page timer |

Rules:

- **Nothing counts in memory.** Every tick recomputes the snapshot from persisted work sessions and the clock, so a killed app, a sleeping phone or a change from another device or a notification button shows the right time on the next frame.
- A one-second ticker runs only while a session is open on a visible screen. Today's 30-second ticker stays for statuses.
- Why a **Bloc** here (the other screens use Cubits): three inputs interleave and their order matters. These are database changes, clock ticks and user commands.
- "Done" on a started task uses the tracked time. "Done with duration" overrides it. On a task that was never started, "Done" records no measurement, which is not the same as zero.
- Starting a task pauses any other running one (Phase 4 rule); the UI says which ("Paused “Emails”").
- Over-plan is shown in words and colour, never colour alone; screen readers get a minute-level label instead of digits changing every second.

## 12c. Analytics (Phase 8)

| Piece | Where | Responsibility |
| --- | --- | --- |
| `ExecutionRecord` | analytics/domain | flat analytics input per occurrence: scheduled and actual start, expected and actual duration, completion time and status, postponements, session time |
| `AnalyticsPeriod` | analytics/domain | a day, an ISO week (as in the planner) or a calendar month; previous/next; switching kind keeps the place in time |
| `PeriodMetrics`, `AnalyticsReport`, `ActivityStats` | analytics/domain | the brief's `ProductivityMetric`: counts and outcomes, completion rate, tracked vs planned, estimate ratio, on-time starts and median delay, postponements; per-day and per-activity breakdowns; streaks and history |
| `AnalyticsCalculator` | analytics/domain | pure; outcomes judged at a moment, each record's "today" in its series' zone; definitions in contract §3.3, pinned by `contracts/vectors/analytics_metrics.json` |
| `AnalyticsRepository` → `LocalAnalyticsRepository` | analytics/domain → data | live records, read through the tasks domain (`watchAgenda`, new `watchLineage`), so analytics never touch the tasks tables |
| `GetAnalyticsAccess`, `ApplyDurationSuggestion` | analytics/domain | history window and advanced-analytics flag from `FeatureAccessService`; a suggestion is applied through the tasks feature's `UpdateTaskDetails` (validated, outbox-synced) |
| `FeatureAccessService` | core/entitlements | `canUse(Feature)` / `limit(LimitKey)`; `UnrestrictedFeatureAccess` until Phase 10 implements plans |
| `AnalyticsCubit`, `ActivityAnalyticsCubit` | analytics/presentation | period navigation (bounded by today and the plan's window), live recompute on data changes and on the 30 s ticker, day rollover; activity stats over 90 days, suggestion apply |
| `BarChart` + `OutcomeChart`, `TimeChart`, `ActivityHistoryChart` | analytics/presentation | hand-drawn bar charts with round y-axis steps, legends and one semantics node per bar |

Decisions:

- **Computed on the device.** The local database holds the full history (and, from Phase 11, everything synced), so analytics work offline and update the moment a task changes. The server serves the same metrics (contract §3.3) for the web client and insights; the vectors keep both sides identical.
- **Definitions that do not punish an unfinished day.** Completion rate is over *decided* occurrences (done, skipped, missed); still-open ones are shown but not counted against. Missed is judged in the series' own zone. "Not measured" never counts as zero time.
- **Charts are clear rather than decorative.** Only bar charts: outcomes stacked per day (tap a day to open it), planned (outline) vs tracked (filled) time, and an activity's recent occurrences against a planned-time line. Every number is also in words (tiles, legends, per-bar screen-reader labels); "still to do" and "planned" are outlines so they do not rely on colour.
- **No chart package.** Bar charts are ~400 lines with accessibility and theming under our control; fl_chart and similar would add a large dependency, weaker semantics and API churn for three bar charts.
- **Plan gating through one seam.** The history window (`limit.analytics_history_days`, 30 days free) and duration suggestions (`feature.advanced_analytics`) are read from `FeatureAccessService`; no widget asks "is premium". Until Phase 10 everything is allowed.
- **Task-specific analytics follow the lineage**, so history survives "change from this date" splits; a suggestion applies to the series carrying the current schedule (found by looking 31 days ahead) and, like any duration edit, only to occurrences from today that have not started.
- Insights (server-generated suggestions, `GET insights`) wait for the backend; the duration suggestion covers the most useful one locally.

## 12d. Voice task creation (Phase 9)

The brief's pipeline, one piece per step:

| Step | Piece | Where |
| --- | --- | --- |
| Voice input → speech-to-text | `SpeechToTextEngine` (interface) → `DeviceSpeechToTextEngine` (`speech_to_text`: Apple Speech / Android SpeechRecognizer) | voice/domain → data |
| Natural-language extraction | `TaskTextParser` (interface) → `EnglishTaskTextParser` (on-device rules); `ParseSpokenTask` resolves "today", "now" and categories in the home zone | voice/domain → data |
| Structured draft | `ParsedTask` {title, date, startTime, expectedDuration, recurrence, category} → `TaskPrefill` (tasks domain) | voice/domain |
| User confirmation | `VoiceCapturePage` shows what was heard and understood; "Review and save" opens the **task editor** prefilled, with the sentence above the form | voice/presentation, tasks/presentation |
| Task creation | the editor's normal Save (`CreateTask`: validation, outbox) | tasks |

Decisions:

- **Confirmation is the editor.** It already validates every field and lets the person fix anything; a second form would drift from it. Nothing is created from speech without Save.
- **On-device parsing in V1.** English only at launch; rules are predictable, private, offline and testable (`docs/VOICE_SETUP.md` lists them). Anything not understood stays in the title. An NLP/LLM provider later implements `TaskTextParser` against `POST voice/parse` (contract §3.4) without touching the bloc or UI.
- **`VoiceCaptureBloc` is a Bloc**: recognizer events and taps interleave, and a session counter drops events from an abandoned session (retry, typed correction).
- **Typing is always possible** (no permission, no recognizer, a noisy room, a correction), and screen readers get the transcript as a live region; the pulse stops with reduced motion.
- **Feature boundaries**: voice reaches tasks through its domain only (`TaskPrefill`, `GetHomeTimeZone`, `WatchCategories`); the review summary widget belongs to tasks and is passed in by the router.
- Not in V1: the remote `voice_capture` flag from `GET config` (read in Phase 13 with minimum versions), counting `limit.voice_per_month` (only server parsing will count).

## 12e. Subscriptions and entitlements (Phase 10)

| Piece | Where | Responsibility |
| --- | --- | --- |
| `SubscriptionPlan`, `Entitlement`, `PlanOffer` | subscription/domain | the brief's types: plan (tier, features, limits), what the user has now (status, store, period, usage, verified), what the store sells |
| `SubscriptionRepository` | subscription/domain | the only door: current/watch, refresh, offers, purchase, restore, bind/unbind user |
| `EntitlementFeatureAccess` | subscription/domain | the app-wide `FeatureAccessService`; emits `changes` when the plan changes |
| `SubscriptionRepositoryImpl` | subscription/data | server (`GET me/entitlements`) is the truth; per-user cache in `app_meta`; provisional unlock after a store purchase (≤ 24 h); cached Pro lapses 3 days after its period |
| `PurchasesGateway` → `RevenueCatPurchasesGateway` / `UnavailablePurchasesGateway` / `MockPurchasesGateway` | subscription/data | the store provider, chosen in the registrar only |
| `TaskPlanPolicy` | tasks/domain | `limit.active_series`, `limit.recurring_series`, `feature.advanced_recurrence`; used by `CreateTask` and `RescheduleTaskFrom` |
| `SubscriptionSync` | config/session | binds purchases/cache on sign-in, free on sign-out, refresh on resume (6 h / unconfirmed) and on `subscription` push |
| `SubscriptionCubit`, `SubscriptionPage` | subscription/presentation | plan comparison from the server's free plan, store offers (annual preselected), purchase, restore, Pro status and store management |

Decisions:

- **No `if premium` anywhere.** Gates ask `FeatureAccessService`; analytics history and suggestions (Phase 8), task limits and "every N" repeats (this phase). Screens that stay alive (Insights tab) re-read access on `changes`, so an upgrade applies without a restart.
- **Server truth, store convenience.** The app never grants Pro from a receipt alone for long: the provisional unlock exists only so a purchase feels instant while the webhook lands.
- **Nothing is taken away.** Limits stop *new* use; a downgraded user keeps every task (contract §3.5). A limit or locked feature shows a message with "See plans" (Today, editor).
- **Offline-safe defaults.** Before the first server answer, and when signed out, the app applies the free plan (the same values as the server's `free` row).
- Store rules: price, period, trial and renewal terms on screen, restore button, links to terms/privacy and store management (setup in `docs/SUBSCRIPTIONS_SETUP.md`).

## 12f. Offline synchronization (Phase 11)

The device is never assumed online. Every change is written locally first, with its outbox op in the same transaction (§11); sync only moves what is already saved.

```
user action ─▶ repository ─▶ SQLite (row + outbox op, one transaction) ─▶ UI updates at once
                                         │
SyncScheduler ── triggers ──▶ SyncEngine ├─ push: outbox ─▶ POST sync/push ─▶ results settle ops
                                         └─ pull: GET sync/pull ─▶ handlers ─▶ SQLite (+ cursor, one transaction)
```

| Piece | Where | Responsibility |
| --- | --- | --- |
| `SyncEngine` | core/sync | push then pull; one run at a time (callers share it, and a call during a run makes it go once more); `watch()` state |
| `SyncRemoteDataSource` | core/sync | `sync/push` (with an `Idempotency-Key` derived from the batch's op ids) and `sync/pull`; tolerant parsing |
| `OutboxStore`, `SyncCursorStore`, `SyncIssueStore` | core/sync | read/settle the outbox, the pull cursor (`app_meta`), refused changes (`sync_issues`) |
| `SyncEntityHandler` → `TaskSyncHandler` | core/sync → tasks/data | applies pulled series/occurrences/sessions/categories, records server versions, repairs local data after a refusal |
| `ConnectivityMonitor` | core/device | connectivity_plus: a *hint* that triggers a run; never a reason to skip the offline path |
| `SyncScheduler` | config/session | when to run (below), backoff |
| `SyncRepository`, `SyncStatusCubit`, `SyncPage`, `SyncSettingsTile` | sync/ | status (pending count, online, last sync, last failure), "Sync now", refused changes |

**Triggers** (only while the signed-in user's data is bound and seeded — `UserSessionCoordinator.watchPreparedUser`): sign-in / app start with a session; 2 s after the outbox grows (a burst of edits is one push); app resume; network regained; a foreground `sync` push; every 15 min in the foreground; a last push when the app is hidden with changes queued; after a failure, backoff 30 s → 1 m → 2 m … capped at 15 min (none while offline — reconnecting triggers instead). The coordinator also gates the engine itself (`SyncEngine.enabled`), so "Sync now" cannot run before the data is bound either. Sign-out and a switch to another user wait for a run in flight before deleting or rebinding local data, so a pull never writes into a wiped database.

**Idempotency.** Every op has a UUIDv7 `op_id` (the server's idempotency key per op) and targets a stable id: series/categories get UUIDv7s at creation, occurrences are UUIDv5 of series + original date (§5, identical on every device and on the server), default categories are UUIDv5 of user + key (contract §4.2). An op resent after a lost response gets `duplicate` and is settled the same way. The request's `Idempotency-Key` is per request (kept on a transport retry), never derived from the ops, so a later run is never answered from a stored response that left ops unprocessed; ops the server did not answer stay queued and never count against the op. Pull pages are applied with their cursor in one transaction, so a crash never skips or repeats a page.

**Conflict strategy** (documented in contract §4.3):

1. **Ops are intents, not row snapshots.** `occurrence.complete`, `.skip`, `.postpone` … carry what the person did and when (`occurred_at`); the server merges concurrent intents per entity (`merged`) and refuses only what can no longer apply (`rejected` + code).
2. **Local unpushed changes win locally until pushed.** Push always runs before pull, and pull skips any entity (and the sessions of any occurrence) that still has queued ops; the merged result arrives in a later pull. The person never sees their change flicker away.
3. **The server's merged state wins once pushed.** Pulled rows overwrite local ones (keeping local `created_at`). A pulled schedule change re-plans only occurrences nobody touched (`isPristine`) from today on, exactly like a local schedule edit; started, done, skipped, postponed or annotated occurrences keep their history. A pulled duration change applies to not-started occurrences from today.
4. **Deletes win.** A pulled delete removes the task and its occurrences even if this device edited them (the edit is refused with `ENTITY_DELETED`).
5. **Refused changes are repaired and shown, never silently lost.** In the same transaction that removes a `rejected` op, the handler undoes what needs no server read (a refused create or split successor is removed; an `ENTITY_DELETED` / `NOT_FOUND` entity is deleted; a session opened by a refused start is removed), queued ops on anything that no longer exists are dropped (including occurrence ops of a removed series), and a `sync_issue` is recorded. Anything else is marked *repair pending* and re-read over REST (`GET series/{id}`, `GET occurrences/{id}`, `GET categories`) after the push, on this and every later run until the read succeeds; only the server's `404 NOT_FOUND` means deleted (a bare 404 from a proxy never deletes data). Repairs skip entities with queued ops (their push brings the merged state in the next pull). Issues show on the Sync page ("Changed on another device. That version was kept.") with a badge on the Settings row; dismissing one hides it without cancelling its repair.
6. **One bad op or row cannot block sync.** Only `400/409/413/422` count against ops; network errors, 5xx, 429, 401, 403 and 404 never do, so an outage or a misconfigured base URL never drains the queue. A refused batch is retried one op at a time; an op refused alone 5 times is given up as a `SYNC_FAILED` issue, so valid ops are never dropped with it. On the pull side, a change that cannot be read is reported and skipped, and each page is applied parents first.
7. **Occurrences always follow.** Whenever a run committed pulled or repaired state, handlers materialize occurrences at the end of the run, even if a later page failed.

The mock backend (`USE_MOCK_API`) answers push/pull as a single device: every op `applied`, replays `duplicate`, nothing to pull; `SyncMockBackend.rejectNext` exercises the issue flow by hand. It has no REST reads, so a repair after a refusal other than a create or a delete stays pending in mock builds (by design: a missing route never deletes data).

Migration v1 → v2 creates `sync_issues`. After pulling these sources, run `dart run drift_dev make-migrations` once to snapshot schema v2 into `drift_schemas/` and generate step-by-step migration tests in `test/drift/` (no snapshot of v1 exists because no build has run yet; `test/core/database/migration_test.dart` covers the v1 → v2 step by hand).

## 13. Package decisions

| Package | Why it is needed | Alternative rejected |
| --- | --- | --- |
| flutter_bloc / bloc | Required state management | — |
| get_it | Required DI; no codegen | injectable (second generator) |
| go_router | Required router; deep links, shell routes, redirects | go_router_builder (deferred) |
| freezed / freezed_annotation | Sealed unions with value equality (`Failure`, later states, entities, DTOs) | hand-written `==` for every type |
| json_serializable / json_annotation | DTO mapping (`ProblemDetailsDto` onward) | manual `fromJson` |
| dio | Interceptors (token refresh with queueing, request ids), timeouts, pluggable adapter for the mock backend | `package:http` (would need hand-built interceptor chain and refresh queueing) |
| uuid | UUIDv7 + UUIDv5 with RFC-correct bit layout | hand-rolled UUIDs (easy to get the version/variant bits wrong; v5 must match the server byte for byte) |
| flutter_localizations + intl | ARB-based strings, date/number formatting | hard-coded English |
| flutter_secure_storage | Tokens in Keychain / Keystore-backed encryption | shared preferences (plain text) |
| sign_in_with_apple | Native Apple sign-in | hand-written platform channel |
| google_sign_in | Official Google sign-in (Credential Manager on Android) | web OAuth flow |
| crypto | SHA-256 of the Apple nonce | hand-rolled hashing |
| flutter_timezone | IANA zone for registration; reused by reminders in Phase 6 | `DateTime.timeZoneName` (abbreviations like "IST" are ambiguous) |
| drift / drift_dev | Typed SQLite, reactive queries (the UI watches the database), transactions, migrations with schema snapshots | sqflite (raw SQL, no reactive queries), Isar/Hive (no relational constraints; uncertain maintenance) |
| drift_flutter | Opens the database file on each platform; shares one connection with background isolates (Phase 6) | `sqlite3_flutter_libs` + `path_provider` wiring by hand |
| timezone | IANA rules for wall time ↔ UTC in any zone, independent of the device | `DateTime` local time (only the device's own zone) |
| flutter_local_notifications | Scheduled local reminders (exact/inexact alarms, reboot re-arming), action buttons with a background isolate, permission APIs on both platforms | `awesome_notifications` (larger surface, its own scheduling model); writing platform channels |
| purchases_flutter | RevenueCat: StoreKit 1/2 and Play Billing behind one API, receipt validation, webhooks to our server, restore and cross-platform entitlement | `in_app_purchase` (we would build receipt validation, renewals and server notifications ourselves) |
| url_launcher | Opens store subscription settings and terms/privacy links (store review requirement) | — |
| connectivity_plus | Network up/down events so a sync runs the moment the device reconnects (§12f); used only as a trigger hint | polling the server on a timer (battery, and still blind to reconnects between ticks) |
| speech_to_text | Platform speech recognizers on iOS and Android behind `SpeechToTextEngine`; handles permissions, partial results, locales | writing two platform channels; cloud STT SDKs (cost, audio leaves the device by design) |
| firebase_core, firebase_messaging | The brief's FCM requirement: token, foreground/opened/background messages, APNs bridging | none (FCM is mandated) |
| build_runner | Runs the generators | — |
| bloc_test, mocktail | Bloc and repository tests | mockito (needs codegen) |
| very_good_analysis | Strict lint set | flutter_lints (weaker) |

Not added: a chart package (§12c), dartz/fpdart (sealed `Result` is ~60 lines), equatable (freezed covers equality), injectable, retrofit (dio + small data sources are enough), logger packages (`dart:developer` suffices), a background-work package such as workmanager (sync runs while the app is in use and on the server's `sync` push; OS background windows are unreliable and are left to Phase 13 if needed).

## 14. Planned per later phase

| Phase | Adds |
| --- | --- |
| 2 Core infrastructure ✅ | dio clients + interceptors, problem+json → Failure, `guardRemoteCall`, logging + redaction, error reporter seam, bloc observer, UUID v7/v5 + shared vectors, l10n, API contract v1, mock backend adapter |
| 3 Authentication ✅ | AuthBloc, AuthSessionManager, secure storage, email/Apple/Google sign-in, registration, password reset, profile name edit, AuthBlocAuthGate, auth contract + mock backend |
| 4 Task domain + database ✅ | Entities, recurrence expander + shared vectors, occurrence planner, lifecycle state machine, status resolver, validation, Drift schema v1, **outbox writes**, persisted device id, reinstall detection, user data binding/wipe, op payload contract |
| 5 Task creation + planner ✅ | Today (progress, next task, quick add, to-do/done), Planner (week strip), task editor (create/edit, repeat, reminder, category, validation), occurrence detail (complete, enter time, skip, postpone, cancel, reopen, note, stop repeating, delete) |
| 6 Notifications ✅ | Reminder planner + reconciler (≤ 48 pending), contextual permission prompt, Done/Snooze actions (background isolate), FCM with no-op fallback, device registration, notification preferences, settings screen |
| 7 Execution + timers ✅ | FocusTimerBloc, Today "Working on" card, detail timer panel, Start/Pause/Resume, timed completion with long-session check |
| 8 Analytics ✅ | On-device metrics (shared definitions + vectors), Day/Week/Month screen, activity analytics with streaks and a learned duration, `FeatureAccessService` seam, server analytics contract |
| 9 Voice ✅ | `SpeechToTextEngine` (platform recognizer) + `TaskTextParser` (English rules) interfaces, voice capture with review, editor prefill as the confirmation step, `voice/parse` contract for a later NLP provider |
| 10 Subscriptions ✅ | `SubscriptionRepository` (server truth + cache + store), `PurchasesGateway` (RevenueCat / unavailable / mock), `FeatureAccessService` from the entitlement, task limits (`TaskPlanPolicy`), plans screen, entitlement contract |
| 11 Offline sync ✅ | `SyncEngine` (push/pull, idempotent batches, cursor transactions), `TaskSyncHandler`, conflict strategy + refusal repair, `sync_issues` (schema v2), `SyncScheduler` triggers + backoff, connectivity monitor, Sync page and Settings row, mock sync backend, contract §4.3 |
| 12 Testing | Integration tests, coverage gates |
| 13 Hardening | Native flavors, obfuscation, Sentry, performance, accessibility pass |
