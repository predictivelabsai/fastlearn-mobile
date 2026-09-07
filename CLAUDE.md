# FastLearn Mobile repository guidance

## Commands

```bash
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --release --dart-define=API_BASE_URL=https://fastlearn.fun/api/v1
```

## Architecture

FastLearn Mobile is a Flutter companion to `../FastLMS`. Public curriculum reads use `/api/v1`; never place `FASTSME_API_TOKEN` or any other server credential in Dart source, `--dart-define`, an APK, or committed configuration.

The initial release is intentionally safe and useful without a server credential: native catalogue, curricula and Markdown lessons, plus local completion state. Secure account, quiz, XP, and AI tutor flows open `fastlearn.fun` in the browser. Google SSO initiated by the Android app must return through the fixed `fastlearn://auth/complete` deep link; never accept an arbitrary OAuth return URI.

Keep the public API base configurable with `API_BASE_URL` and default it to `https://fastlearn.fun/api/v1`.

## Release

The Android identity is `fun.fastlearn.app`. Signed CI builds publish `fastlearn-mobile-latest.apk` on a versioned GitHub Release. GitHub's `/releases/latest/` route is the stable pointer used by the FastLMS landing page.
