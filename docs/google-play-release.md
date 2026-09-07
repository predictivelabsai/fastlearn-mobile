# Google Play release pipeline

The Play workflow builds a signed Android App Bundle on demand and can upload it only to the
Google Play **internal** track. It has no production-track path.

## Current release identity

- App name: `CarHero`
- Publisher: `Predictive Labs Ltd`
- Package: `chat.carhero.carhero`
- Version name: `1.0.0`
- Target SDK in the next audited CI artifact: 36
- Upload certificate SHA-1: `6B:5F:7F:9D:F0:B5:5B:4B:77:82:C8:02:7B:DA:F9:B8:84:AB:68:45`
- Upload certificate SHA-256: `64:3E:34:5B:2E:84:BD:E6:79:C7:BB:6D:3D:01:25:2D:A1:9C:2D:4C:E1:6D:F5:A4:F4:AF:C8:E2:78:D5:3C:00`

The manual workflow requires an explicit semantic version name and positive integer version code.
The first Play release uses `1.0.0` with version code `1`; every later upload must increase the
version code.

## GitHub configuration

Release signing uses encrypted repository secrets:

- `KEYSTORE_BASE64`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `STORE_PASSWORD`

Google authentication uses GitHub OIDC and Google Workload Identity Federation instead of a
downloadable JSON key. The workflow expects these repository variables:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_PLAY_SERVICE_ACCOUNT`

The service account is `github-actions-deploy@carhero-mobile.iam.gserviceaccount.com`.

## One-time Play Console bootstrap

Google's publishing API cannot create the first app record or perform the first upload.
After account verification completes:

1. Create **CarHero** in Play Console with package `chat.carhero.carhero` under
   **Predictive Labs Ltd**.
2. Enrol in Play App Signing and upload the first signed AAB manually to internal testing.
3. In **Users and permissions**, invite the service-account email above.
4. Give it app-specific permission to view the app and release builds to testing tracks only.
   Do not grant production, financial, or account-administration permissions.
5. Run **Prepare or Deploy Google Play Internal** with `upload_to_play=false` first and inspect
   the signed AAB artifact.
6. Run it with `upload_to_play=true`; leave `release_status=draft` until the internal release is
   ready. Select `completed` only to make that internal release available to configured testers.

The `upload_to_play` switch is intentionally false by default. Identity, policy declarations,
store listing, data safety, and production review remain human-controlled Play Console gates.
