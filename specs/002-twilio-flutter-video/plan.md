# Implementation Plan: Twilio Flutter Video

**Feature directory**: `specs/002-twilio-flutter-video`

## Phase 1 — Schema and Dart surface

1. Add `pigeons/video_api.dart` (host + flutter API, DTOs, event envelope).
2. Generate pigeon outputs; add `TwilioVideoClient`, session helper, event mapper, models.
3. Unit tests with fake host API (connect, disconnect, events, errors).

## Phase 2 — Native bridges

1. Android: `VideoBridge` using `com.twilio:video-android`, `Room.connect`, listeners, local tracks.
2. iOS: `VideoBridge` using `TwilioVideo`, `Room.connect`, `RoomDelegate`, local tracks.
3. Wire plugins to pigeon host setup and flutter API.

## Phase 3 — Docs and CI

1. `docs/VIDEO_QUICKSTART.md`, Video rows in `docs/API_COVERAGE.md` and `docs/COMPATIBILITY.md`.
2. CI + pre-commit pigeon drift for video.
3. Point `.specify/feature.json` at this feature during video work.

## Out of scope (follow-ups)

- Platform views for remote/local video rendering (Texture/PlatformView).
- Screen share, data tracks, bandwidth profiles, network quality UI.
- Example app under `packages/twilio_flutter_video/example`.
