# Feature Specification: Twilio Flutter Video

**Feature Directory**: `specs/002-twilio-flutter-video`  
**Status**: Active  
**Created**: 2026-03-17

## Summary

Typed Flutter plugin wrapping **Twilio Programmable Video** on iOS and Android. Integrators use `TwilioVideoSession` (recommended) or `TwilioVideoClient` with backend-minted access tokens and a room name or SID. Host methods include `connect`, `disconnect`, `setLocalAudioEnabled`, and `setLocalVideoEnabled`. Events include `RoomConnected`, `RoomDisconnected`, `ParticipantConnected`, `ParticipantDisconnected`, `DominantSpeakerChanged`, reconnecting/reconnected, and `VideoError`.

## User Stories

### P1 — Connect to a room

**Given** a valid Video access token and room name from the app backend, **when** the app calls `TwilioVideoClient.connect`, **then** the client joins the room and `RoomConnected` arrives on `events`.

**Independent test**: Unit tests with fake host API; manual test with `TWILIO_ACCESS_TOKEN` and room name.

### P1 — Disconnect and lifecycle

**Given** a connected client, **when** `disconnect` or `dispose` is called, **then** native room resources are released and Dart `connectionState` returns to disconnected.

### P1 — Local track toggles

**Given** a connected client with local audio/video published, **when** `setLocalAudioEnabled` or `setLocalVideoEnabled` is called, **then** the local participant track state matches on both platforms.

### P2 — Participant and room events

**Given** a connected room, **when** remote participants join, leave, or dominant speaker changes, **then** matching sealed `TwilioVideoEvent` values are emitted.

## Functional Requirements

| ID | Requirement |
| --- | --- |
| FR-1 | Pigeon host API: connect, disconnect, setLocalAudioEnabled, setLocalVideoEnabled |
| FR-2 | Flutter API: room and participant SDK callbacks → sealed `TwilioVideoEvent` |
| FR-3 | Connect request carries access token, room name, and optional initial audio/video enable flags |
| FR-4 | Stable `TwilioErrorCode` on all failure paths (`TwilioErrorCode.parse` for native codes) |
| FR-5 | One `TwilioVideoClient` per Flutter engine (documented) |
| FR-6 | Android Video SDK + iOS TwilioVideo pod (see `docs/COMPATIBILITY.md`) |

## Non-Functional Requirements

| ID | Requirement |
| --- | --- |
| NFR-1 | CI: analyze, test, pigeon drift for video package |
| NFR-2 | SDD + integrator docs updated with implementation |
| NFR-3 | Grok/doc validation against live Twilio Video mobile docs |

## Edge Cases

- Second connect while connected → `already_connected`
- Disconnect during in-flight connect
- Connect failure (invalid token, room full) → `sdk_failure` with message

## Documentation map

| Topic | Location |
| --- | --- |
| Consumer guide (pub.dev) | `docs/CONSUMER_GUIDE.md` |
| Video quickstart | `docs/VIDEO_QUICKSTART.md` |
| API coverage | `docs/API_COVERAGE.md` (Video section) |
| Versions | `docs/COMPATIBILITY.md` |
