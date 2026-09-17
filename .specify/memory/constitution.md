# Twilio Flutter SDK Constitution

## Core Principles

### I. Spec-first delivery

Features are defined under `specs/` (GitHub Spec Kit) before substantial code changes. The active feature directory is `specs/001-twilio-flutter-conversations` (see `.specify/feature.json`).

### II. Typed, non-null Dart APIs

Public Dart APIs avoid nullable fields and nullable factory returns unless the underlying Twilio SDK requires absence on the wire. Prefer factories, sealed types, and enum extensions over ad-hoc null checks.

### III. Documentation moves with code

Any change to public Dart API, Pigeon schema, or native bridge behavior MUST update matching docs: `specs/`, `docs/`, package `README.md`, and `CHANGELOG.md` as applicable. CI and pre-commit enforce this.

### IV. DRY across layers

- `PigeonDtoMapper` — DTO → public models
- `TwilioJsonObjectCodec` — JSON attributes
- `ConnectSessionGuard` — connect/dispose races (Dart + Android)
- Per-platform `MessageAttributesJson` — SDK attributes

### V. Event-first integrator experience

Apps listen to `TwilioConversationsClient.events`; the plugin owns native listeners and normalization.

### VI. Monorepo packages

- `twilio_flutter_core` — shared types
- `twilio_flutter_conversations` — Conversations plugin (current)
- `twilio_flutter_video` — planned sibling package, not merged into Conversations

## Quality gates

- `flutter analyze --fatal-infos` / `dart analyze --fatal-infos`
- Unit tests for Dart and Android JVM bridge helpers
- Pigeon drift check in CI
- Documentation sync check when implementation paths change
- Spec Kit `/speckit.analyze` before major releases

## Governance

This constitution overrides ad-hoc practices. Amend via PR updating this file and running `/speckit.constitution`.

**Version**: 1.0.0 | **Ratified**: 2026-03-17 | **Last Amended**: 2026-03-17
