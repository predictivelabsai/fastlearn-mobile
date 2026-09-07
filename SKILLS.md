# FastLearn Mobile delivery playbook

## Validate

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

Verify the live contract without credentials:

```bash
curl -fsS https://fastlearn.fun/api/v1/health
curl -fsS 'https://fastlearn.fun/api/v1/courses?limit=2&lang=en'
```

## Build Android

Local unsigned release builds are useful for compilation checks. Installable tester releases must be signed:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://fastlearn.fun/api/v1
```

Never commit `android/key.properties`, a keystore, passwords, service-account files, or API tokens.

## Publish

Push a validated commit to `main`. GitHub Actions runs formatting, analysis, tests, signed APK/AAB builds, signature verification, and creates the latest GitHub Release. Verify:

1. The workflow completed successfully for the exact commit.
2. The latest versioned release contains `fastlearn-mobile-latest.apk`.
3. The stable download URL returns an Android package.
4. The FastLearn landing-page button downloads that asset.

## Security boundary

The FastLMS `FASTSME_API_TOKEN` authorizes learner-wide integration operations. It is not mobile-user authentication and must never be embedded in the app. Add user-scoped mobile authentication on the server before implementing native synchronized progress or tutor requests.
