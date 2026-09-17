# twilio_flutter_video

Scaffold for a sibling package to `twilio_flutter_conversations` in this monorepo.

## Status

- Package layout, plugin registration, and shared `twilio_flutter_core` dependency are in place.
- Pigeon schema, native Twilio Video SDK bridges, and public room APIs are **not** implemented yet.

## Next steps

1. Add `specs/002-twilio-flutter-video` (Spec Kit).
2. Define Pigeon host API (connect room, publish/subscribe tracks, events).
3. Wire Android/iOS Twilio Video SDKs and CI parity with conversations.
