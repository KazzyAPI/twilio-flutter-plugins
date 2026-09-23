# Contributing

## Prerequisites

- Flutter **3.47.4** (see [`.flutter-version`](.flutter-version) and [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md))
- Xcode + CocoaPods (iOS)
- Android SDK (API 21+)

```bash
./scripts/bootstrap.sh
pip install pre-commit   # or: brew install pre-commit
pre-commit install
```

Pre-commit runs SDD sync, integrator doc sync, comment style, pigeon drift, and analyze.

Manual hook run (no install):

```bash
chmod +x scripts/*.sh
./scripts/run_commit_hooks.sh
```

Full pipeline (SDD, docs, comment style, pigeon drift, analyze, tests):

```bash
./scripts/run_ci_checks.sh origin/main
```

Integrator-facing install and usage docs live in [`docs/CONSUMER_GUIDE.md`](docs/CONSUMER_GUIDE.md). Update that file when you change public Dart API or platform requirements.

## Add a host method or event (Pigeon workflow)

1. **Schema** — Edit `packages/twilio_flutter_conversations/pigeons/conversations_api.dart` (host API, flutter API, DTOs, enums only).
2. **Generate** — From that package directory:
   ```bash
   dart run pigeon --input pigeons/conversations_api.dart
   ```
3. **Dart**
   - Public API: `lib/src/client/twilio_conversations_client.dart` (with `///` docs).
   - Models/events: `lib/src/models/`, `lib/src/events/`.
   - DTO mapping: extend `PigeonDtoMapper` — do not duplicate field mapping elsewhere.
4. **Android** — `android/.../bridge/ConversationsBridge.kt` implements `TwilioConversationsHostApi`; map SDK types in `ConversationsEventMapper.kt`; emit via `ConversationsEventEmitter.kt`.
5. **iOS** — Mirror in `ios/Classes/Bridge/`.
6. **Tests** — Dart unit tests under `test/`; Android JVM tests under `android/src/test/` when logic is testable without a device.
7. **Docs** — Update [`docs/API_COVERAGE.md`](docs/API_COVERAGE.md) and [`docs/EVENT_CATALOG.md`](docs/EVENT_CATALOG.md) if behavior is user-visible.
8. **CI** — `flutter test`, `flutter analyze --fatal-infos`, pigeon drift check (see `.github/workflows/ci.yml`).

## DRY rules (required)

| Layer | Single owner |
| --- | --- |
| JSON attributes (Dart) | `TwilioJsonObjectCodec` in `twilio_flutter_core` |
| JSON attributes (native) | `MessageAttributesJson` per platform |
| Pigeon DTO → public models | `PigeonDtoMapper` |
| Error code strings | `TwilioErrorCode.code` |

## Releases

**Land changes via pull requests into `main`** (feature/fix PRs). Do not bump release versions on ad-hoc direct pushes.

Release Please then opens **Release PRs** into `main` (changelog + `pubspec.yaml`). Merging a Release PR creates a GitHub tag; [pub.dev automated publishing](https://dart.dev/tools/pub/automated-publishing) runs on that tag (OIDC, no long-lived token in Actions).

Use [Conventional Commits](https://www.conventionalcommits.org/) on changes under `packages/<name>/`.

Monorepo dev: run `./scripts/bootstrap.sh` (or `./scripts/link_pubspec_overrides.sh`) so path overrides for `twilio_flutter_core` are applied.

Details: [`docs/RELEASES.md`](docs/RELEASES.md).

## Pull request checklist

- [ ] Pigeon regenerated and committed
- [ ] Tests added/updated
- [ ] API coverage matrix updated
- [ ] No duplicate message event paths (conversation listener only)
- [ ] Conversation listeners registered and cleared on disconnect/dispose
