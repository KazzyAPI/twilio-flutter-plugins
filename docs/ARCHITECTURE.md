# Architecture

## Monorepo intent

This repository is a **workspace for Twilio Flutter plugins**, not a single mega-plugin.

| Package | Role |
| --- | --- |
| `twilio_flutter_core` | Cross-plugin Dart utilities (errors, JSON attribute codec). No platform code. |
| `twilio_flutter_conversations` | Conversations SDK bridge (current focus). |
| `twilio_flutter_video` (planned) | Programmable Video bridge — **separate package**, same repo. |

**Video in this repo?** Yes, as a sibling package under `packages/`, sharing CI and `twilio_flutter_core`. No — as a combined dependency: apps should not be forced to pull WebRTC when they only need chat.

## Layering

```
App (Dart)
  └─ TwilioConversationsSession  ← recommended: one client + one listener
       └─ TwilioConversationsClient  ← host calls + event stream
            └─ Pigeon host/flutter APIs
                 └─ ConversationsBridge (Swift / Kotlin)
                      └─ Twilio Conversations SDK
```

## DRY rules

1. **DTO → Dart models:** `PigeonDtoMapper` only (never duplicate field mapping in the client and event mapper).
2. **JSON attributes:** `TwilioJsonObjectCodec` in `twilio_flutter_core` (Dart); `MessageAttributesJson` per platform for SDK `Attributes` types.
3. **Error codes:** `TwilioErrorCode` in core; native layers use the same string codes (`not_connected`, `sdk_failure`, etc.).
4. **Event envelope:** One pigeon `PigeonConversationsNativeEvent`; native `ConversationsEventMapper` builds payloads, `ConversationsEventEmitter` sends them.

## Pigeon workflow

Edit `packages/twilio_flutter_conversations/pigeons/conversations_api.dart`, then:

```bash
cd packages/twilio_flutter_conversations
dart run pigeon --input pigeons/conversations_api.dart
```

CI fails if generated files drift from the pigeon input.
