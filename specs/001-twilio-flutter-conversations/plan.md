# Implementation Plan: Twilio Flutter Conversations

## Tech stack

- Flutter 3.47+, Dart 3.13+
- Pigeon 29.x for platform channel types
- Twilio Conversations Android 6.2.1, iOS pod ~> 4.0
- GitHub Spec Kit (`.specify/`, `specs/`, `.cursor/commands/speckit.*`)

## Package layout

```
packages/twilio_flutter_core/          # errors, JSON codec
packages/twilio_flutter_conversations/ # plugin + public API
docs/                                  # integrator docs (synced with code)
specs/001-twilio-flutter-conversations/ # product spec (this feature)
```

## Layering

1. **Pigeon** (`pigeons/conversations_api.dart`) — host + flutter APIs, DTOs
2. **Dart public** — `TwilioConversationsSession`, `TwilioConversationsClient`, events, models, factories
3. **Native bridge** — `ConversationsBridge`, mappers, emitters, session guards
4. **Twilio SDK** — official Conversations clients

## Conventions (enforced)

- Factories for commands/exceptions (`SendMessageCommand`, `TwilioFlutterException.nativeError`)
- Enum extensions for pigeon → public enum mapping
- Comments state intent of the function only (no “high-level …” boilerplate)
- Documentation updated in same change set as API/bridge edits

## Verification

- `scripts/bootstrap.sh`
- `scripts/check_sdd_sync.sh`
- `scripts/check_documentation_sync.sh`
- `scripts/run_commit_hooks.sh` (manual pre-commit)
- `.github/workflows/ci.yml`
