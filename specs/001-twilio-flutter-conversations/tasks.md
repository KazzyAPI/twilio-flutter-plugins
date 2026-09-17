# Tasks: Twilio Flutter Conversations (baseline)

## Requirement traceability

| ID | Where |
| --- | --- |
| FR-1 | Pigeon host API + bridges |
| FR-2 | `TwilioConversationsEvent` + mappers |
| FR-3 | `MessageAttributes` / send path |
| FR-4 | `TwilioErrorCode.parse` + mappers |
| NFR-1 | CI + `scripts/run_commit_hooks.sh` |

## Done

- [x] Pigeon schema + generated bindings
- [x] `TwilioConversationsClient` + event stream
- [x] Android/iOS bridges + listener registry
- [x] Connect session guards (Dart + Android)
- [x] Message attributes JSON path
- [x] Core + conversations unit tests
- [x] Docs suite + example with dart-define
- [x] CI analyze/test/pigeon/android/ios
- [x] Spec Kit init + feature spec/plan/tasks
- [x] Pre-commit + doc sync script
- [x] CI documentation-sync + comment-style jobs
- [x] `MessageAttributes`, `SendMessageCommand`, `TwilioErrorCode.parse`, client factory

## Planned

- [ ] `twilio_flutter_video` implementation (scaffold only; see `packages/twilio_flutter_video`)

## Done (messages + video scaffold)

- [x] Message pagination (`getMessagesBefore`)
- [x] Media send + temporary download URL (`sendMediaMessage`, `getMediaTemporaryUrl`)
- [x] `twilio_flutter_video` package scaffold

## Done (full SDK listener + query surface)

- [x] Conversation list / get by SID
- [x] `getLastMessages`, `getParticipants`, `sendTyping`
- [x] All client + conversation listener events forwarded to Dart

## Doc maintenance (ongoing)

When editing `lib/`, `pigeons/`, or native `bridge/`, update:

- [x] `docs/API_COVERAGE.md` / `docs/QUICKSTART.md` (attributes + send command)
- [x] `docs/EVENT_CATALOG.md` if events change
- [x] `specs/001-twilio-flutter-conversations/spec.md` (FR-3/FR-4)
- [x] Package `CHANGELOG.md` for user-visible changes
