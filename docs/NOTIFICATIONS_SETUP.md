# Notifications setup

The Dart side of reminders and push is complete. The native projects (made
by `flutter create`) need the changes below. Until then:

- **Reminders** need the Android manifest entries and the iOS delegate line;
  without them, scheduling fails on Android, or reminders are not shown
  while the app is open on iOS.
- **Push** stays off automatically when the Firebase config files are
  missing (and always in mock builds). Local reminders do not depend on it.

## Android

### `android/app/build.gradle.kts`

`flutter_local_notifications` needs core library desugaring and compileSdk 35
or higher:

```kotlin
android {
    compileSdk = 36

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### `android/app/src/main/AndroidManifest.xml`

Inside `<manifest>`:

```xml
<!-- Reminders survive reboots and app updates -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<!-- Exact reminder times (Android 12+); the app asks the user in
     Settings → Notifications. Without it reminders may be a few minutes late. -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

`POST_NOTIFICATIONS` (the Android 13+ prompt) is declared by the plugin.
We deliberately do **not** use `USE_EXACT_ALARM`: Google Play reserves it
for alarm-clock and calendar apps.

Inside `<application>`:

```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
<!-- "Done" / "Snooze" buttons -->
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />

<!-- Pushes that arrive while the app is closed use the same channel the
     app creates for account and update messages -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="account_updates" />
```

Notification icon: the launcher icon is used for now. Before release, add a
white-on-transparent `ic_stat_notification` drawable and change
`LocalNotificationsClient._androidIcon` (Phase 13 checklist).

Release builds: if you enable resource shrinking, keep the notification
icon resource (see the plugin's "Release build configuration" notes).

## iOS

### `ios/Runner/AppDelegate.swift`

Foreground presentation and the action isolate need two additions. With the
UIScene lifecycle (the default for projects created with Flutter 3.41 or
later):

```swift
import UIKit
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Lets the Done/Snooze background isolate use plugins.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
```

If the project has not migrated to UIScene, register the callback in
`didFinishLaunchingWithOptions` instead (see the plugin README, "Notification
Actions"). Keep whatever your generated `AppDelegate` already declares and
add only the marked lines.

### Xcode capabilities (for push)

Runner target → Signing & Capabilities:

- **Push Notifications**
- **Background Modes** → *Remote notifications* (for `sync` pings)

Local reminders need neither.

## Firebase (push)

1. Create a Firebase project per environment (dev, staging, prod) or one
   project with three apps.
2. Add the Android app (package name) and download `google-services.json`
   to `android/app/`. Add the Google services Gradle plugin as described
   in the Firebase console.
3. Add the iOS app (bundle id) and download `GoogleService-Info.plist` into
   `ios/Runner/` (add it to the Runner target in Xcode).
4. Upload an APNs authentication key in Firebase → Project settings →
   Cloud Messaging.
5. Run a non-mock build. The log shows `push disabled: Firebase is not
   configured` if the files are missing.

The app initializes Firebase from these native files. It does not use a
generated `firebase_options.dart` file, because one file per flavor would
then have to stay in step with the native configs.

## Behaviour summary

| Situation | Result |
| --- | --- |
| Saving a task in the editor while reminders can't be delivered (never asked) | The system prompt is shown once, in context. Never at launch or sign-in; the Today banner offers "Turn on" meanwhile. |
| Permission refused | A banner on Today and in Settings → Notifications opens the system settings |
| Android 12+, exact alarms not allowed | Reminders use inexact timing; Settings offers "Exact reminder times" |
| Device changes time zone | Nothing moves: reminders are absolute instants computed in each task's zone |
| Task edited, postponed, completed, deleted | Only the affected notifications are replaced or cancelled |
| Sign-out (any reason) | Every notification of the app removed, pending and shown; background buttons and pushes stop acting |
| Reboot / app update | The plugin re-arms pending reminders (boot receiver) |
| More than 48 upcoming reminders | The earliest 48 are scheduled; more are added as those fire, on launch, resume and every change |
