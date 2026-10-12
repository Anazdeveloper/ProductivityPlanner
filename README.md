# Productivity Planner — mobile app

Flutter client for the task planning and productivity app. Architecture and
layer rules: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Requirements

- Flutter **3.47.x** (Dart 3.13). Pinned in `.fvmrc`; with FVM: `fvm use`.
- Xcode / Android Studio for device builds.

## First-time setup

This folder holds the Dart sources. Generate the native Android/iOS projects
once, then remove the two files `flutter create` adds that we don't use:

```bash
cd apps/mobile
flutter create --org com.yourcompany --project-name productivity_planner --platforms=android,ios .
rm lib/main.dart test/widget_test.dart
flutter pub get
```

If `flutter pub get` cannot resolve a dependency marked `# verify` in
`pubspec.yaml`, delete that line and add it with `flutter pub add <name>`
(or `flutter pub add --dev <name>`).

## Commands

| Task | Command |
| --- | --- |
| Generate localizations | `flutter gen-l10n` (also runs on `flutter pub get`) |
| Generate code (one-off) | `dart run build_runner build --delete-conflicting-outputs` |
| Generate code (watch) | `dart run build_runner watch --delete-conflicting-outputs` |
| Snapshot the database schema (after changing tables) | `dart run drift_dev make-migrations` |
| Format | `dart format .` |
| Analyze | `flutter analyze` |
| Test | `flutter test` |
| Test with coverage | `flutter test --coverage` |
| Run (dev, Android emulator) | `flutter run -t lib/main_dev.dart --dart-define-from-file=env/dev.json` |
| Run against the in-app mock backend | `flutter run -t lib/main_dev.dart --dart-define-from-file=env/dev-mock.json` |
| Run (staging) | `flutter run -t lib/main_staging.dart --dart-define-from-file=env/staging.json` |
| Build Android (prod) | `flutter build appbundle -t lib/main_prod.dart --dart-define-from-file=env/prod.json --obfuscate --split-debug-info=build/symbols` |
| Build iOS (prod) | `flutter build ipa -t lib/main_prod.dart --dart-define-from-file=env/prod.json --obfuscate --split-debug-info=build/symbols` |

The local database is `app.sqlite` in the app support folder. The first
launch of a build with a new database (fresh install, cleared data, or the
first Phase 4 build) starts signed out by design: see docs/ARCHITECTURE.md §11.

Mock backend credentials: `demo@example.com` / `password123`; reset code `123456`.
Apple/Google sign-in configuration: [docs/AUTH_SETUP.md](docs/AUTH_SETUP.md).
Reminders and push (Android manifest, iOS delegate, Firebase): [docs/NOTIFICATIONS_SETUP.md](docs/NOTIFICATIONS_SETUP.md).

Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand and are
not committed — add `*.g.dart`, `*.freezed.dart` and `lib/l10n/generated/` to
`.gitignore`.
Codegen must run before `flutter analyze` and `flutter test`.

`env/dev.json` points at `10.0.2.2` (the Android emulator's view of your
machine). For the iOS simulator use `http://localhost:3000/v1`.
Env files contain public values only — never secrets.
