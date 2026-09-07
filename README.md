# FastLearn Mobile

Early-access Flutter companion for [FastLearn](https://fastlearn.fun), powered by the open-source [FastLMS](https://github.com/predictivelabsai/FastLMS) platform.

## Current mobile experience

- Browse the live multilingual FastLearn course catalogue.
- Open a course curriculum and read Markdown lessons natively.
- Track completed lessons locally on the device.
- Open the secure FastLearn account and contextual AI tutor in the browser.
- Switch course content between English, Estonian, Lithuanian, and Spanish.

The app intentionally does not embed the FastLMS server-to-server integration token. Account progress, quizzes, XP, streaks, and tutor history remain on the secure FastLearn web experience until user-scoped mobile authentication is available.

## Run locally

```bash
flutter pub get
flutter test
flutter run --dart-define=API_BASE_URL=https://fastlearn.fun/api/v1
```

The production API URL is already the default. For a local FastLMS backend, use Android emulator host mapping:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5001/api/v1
```

## Android build

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://fastlearn.fun/api/v1
```

Release builds use `android/key.properties` when present. CI requires the repository secrets `KEYSTORE_BASE64`, `KEY_ALIAS`, `KEY_PASSWORD`, and `STORE_PASSWORD`, verifies both APK and AAB signatures, and publishes the APK as the latest GitHub Release.

Stable tester download:

<https://github.com/predictivelabsai/fastlearn-mobile/releases/latest/download/fastlearn-mobile-latest.apk>

Every versioned release also includes `fastlearn-mobile-latest.apk.sha256`; Android package signatures are verified in CI before publication.

## Architecture

- Flutter 3.44 / Dart 3.12
- Riverpod for API and local progress state
- Dio for the public FastLMS API
- Shared Preferences for on-device lesson completion
- `flutter_markdown` for native lesson rendering
- `url_launcher` for secure web account and AI tutor handoff

The repository began from the proven Android release and CI structure in `carhero-mobile`; the learner experience and API model are specific to FastLearn.

## License

Apache-2.0. See [LICENSE](LICENSE).
