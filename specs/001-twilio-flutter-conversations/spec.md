# Feature Specification: Twilio Flutter Conversations

**Feature Directory**: `specs/001-twilio-flutter-conversations`  
**Status**: Active (baseline for monorepo)  
**Created**: 2026-03-17

## Summary

Typed Flutter plugin wrapping Twilio Conversations (classic) on iOS and Android. Integrators use `TwilioConversationsSession` (recommended), `TwilioConversationsClient`, `TwilioConversationsMediaPolicy`, `TwilioConversationsEvent`, `MessageAttributes`, `SendMessageCommand`, and `SendMediaMessageCommand` with backend-minted tokens. Host methods include `listConversations`, `getConversation`, `getLastMessages`, `getMessagesBefore`, `getParticipants`, `sendTyping`, `sendMediaMessage`, `getMediaTemporaryUrl`, `connect`, `disconnect`, `updateAccessToken`, and `sendMessage`. Events include `ClientConnectionStateChanged` (`TwilioClientConnectionState`) and participant updates mapped to `TwilioParticipant`.

## User Stories

### P1 — Connect and receive events

**Given** a valid Conversations JWT from the app backend, **when** the app calls `TwilioConversationsClient.connect`, **then** synchronization and conversation/message events arrive on `events`.

**Independent test**: Example app or integration test with `TWILIO_ACCESS_TOKEN`.

### P1 — Send text with attributes

**Given** a connected client and conversation SID, **when** `sendMessage` or `send(SendMessageCommand.create(...))` is called with body and attributes, **then** the message is sent and attributes round-trip on the returned `TwilioMessage` (`MessageAttributes`, never null) and `MessageAdded` events.

### P1 — Token lifecycle

**Given** a connected client, **when** the SDK signals token expiry, **then** `TokenAboutToExpire` / `TokenExpired` fire and `updateAccessToken` accepts a new JWT.

### P2 — Safe lifecycle

**Given** connect/disconnect/dispose interleaving, **then** no duplicate native clients leak and Dart `connectionState` remains consistent (including stale connect after dispose). **Given** `ClientConnectionStateChanged` reports connection loss while Dart was connected, **then** native `disconnect` runs, further SDK connection events are ignored until the next Dart `connect`, and the same Dart client can reconnect.

### P1 — Conversations, history, typing, media, pagination

**Given** a connected client, **when** the app calls `listConversations`, `getConversation`, `getLastMessages`, `getMessagesBefore`, `getParticipants`, `sendTyping`, `sendMediaMessage`, or `getMediaTemporaryUrl`, **then** native SDK results map to typed Dart models (`TwilioMessage`, `TwilioParticipant`, media URLs). Local uploads are validated by `TwilioConversationsMediaPolicy` before native I/O. Conversation, message, participant, typing, and user callbacks arrive on `events` (see `docs/EVENT_CATALOG.md`).

### P2 — Programmable Video (separate package)

`twilio_flutter_video` remains a scaffold; not part of this feature’s shipped surface.

## Functional Requirements

| ID | Requirement |
| --- | --- |
| FR-1 | Pigeon host API: connect, disconnect, updateAccessToken, sendMessage, list/get conversation, getLastMessages, getMessagesBefore, sendMediaMessage, getMediaTemporaryUrl, getParticipants, sendTyping |
| FR-2 | Flutter API: all client + conversation SDK callbacks → sealed `TwilioConversationsEvent` |
| FR-3 | Message attributes as `MessageAttributes` (JSON object via `TwilioJsonObjectCodec`; empty when omitted) |
| FR-4 | Stable `TwilioErrorCode` on all failure paths (`TwilioErrorCode.parse` for native codes) |
| FR-5 | One `TwilioConversationsClient` per Flutter engine (documented) |
| FR-6 | Android 6.2.1 + iOS TwilioConversationsClient ~> 4.0 |

## Non-Functional Requirements

| ID | Requirement |
| --- | --- |
| NFR-1 | CI: analyze, test, pigeon drift, SDD sync, doc sync, Android JVM tests, iOS simulator build |
| NFR-2 | Pre-commit: SDD sync + doc sync + comment style + analyze |
| NFR-3 | Spec Kit commands in `.cursor/commands/` for spec-driven changes |

## Edge Cases

- Disconnect/dispose during in-flight connect (generation guards)
- Empty attributes map vs omitted attributes on send
- Second connect while connected → `already_connected`

## Documentation map

| Topic | Location |
| --- | --- |
| Integrator quickstart | `docs/QUICKSTART.md` |
| Architecture | `docs/ARCHITECTURE.md` |
| API coverage | `docs/API_COVERAGE.md`, `docs/CONVERSATIONS_SDK_COVERAGE.md` |
| Events | `docs/EVENT_CATALOG.md` |
| Errors | `docs/TROUBLESHOOTING.md` |
| Versions | `docs/COMPATIBILITY.md` |
| Contributing | `CONTRIBUTING.md` |
