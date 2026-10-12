# Authentication setup

The Dart side of sign-in is complete. Apple and Google also need console and
native project configuration. Until it is done the buttons are **hidden
automatically**: the app checks availability and never shows a button that
would fail. Email sign-in needs no setup.

To try everything without any configuration, run against the mock backend:

```bash
flutter run -t lib/main_dev.dart --dart-define-from-file=env/dev-mock.json
```

- Demo account: `demo@example.com` / `password123`
- Password reset code: `123456`
- Apple and Google buttons are shown and succeed with fake tokens.

## Sign in with Apple (iOS)

1. Apple Developer account (paid membership required).
2. Certificates, Identifiers & Profiles → your App ID → enable **Sign in with Apple**.
3. Xcode → Runner target → Signing & Capabilities → **+ Capability → Sign in with Apple**.
4. Backend: verify the identity token against Apple's keys, audience = bundle id, and
   `nonce` claim = SHA-256(`raw_nonce`) from the request (contract §3.1).

Android is intentionally not supported for Apple sign-in (it needs a web
Service ID and redirect endpoint, and store rules don't require it there).

## Google sign-in

1. Google Cloud Console → APIs & Services → Credentials. Create:
   - **Web application** client → its id is `GOOGLE_SERVER_CLIENT_ID` (both platforms).
   - **iOS** client (bundle id) → its id is `GOOGLE_IOS_CLIENT_ID`.
   - **Android** client (package name + SHA-1 of each signing key, debug and release).
2. Put the two ids in `env/<flavor>.json`. They are public identifiers, not secrets.
3. iOS: add the iOS client's *reversed* client id as a URL scheme in
   `ios/Runner/Info.plist`:

   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array><string>com.googleusercontent.apps.YOUR-IOS-CLIENT-ID</string></array>
     </dict>
   </array>
   ```

4. Backend: verify the id token's signature and that `aud` is the web client id.

## Secure storage

- iOS: no setup. Items use `first_unlock_this_device` (readable in background
  after first unlock, never synced to iCloud).
- Android: `minSdkVersion` must satisfy `flutter_secure_storage` (check its
  README for the current minimum when you run `flutter create`).

## Store checklist (Phase 13)

- Replace the neutral provider buttons with the official Apple and Google
  button artwork required by their branding guidelines.
- App Store review: Sign in with Apple must be offered whenever Google sign-in
  is offered on iOS (already the case when both are configured).
