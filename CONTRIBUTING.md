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

## Pull request checklist

- [ ] Pigeon regenerated and committed
- [ ] Tests added/updated
- [ ] API coverage matrix updated
- [ ] No duplicate message event paths (conversation listener only)
- [ ] Conversation listeners registered and cleared on disconnect/dispose
