## Unreleased

## 0.0.2

* Documentation: pub.dev install instructions and README (`^0.0.2`); declare `meta` for Pigeon-generated code.

## 0.0.1

* Toolchain: Flutter 3.47+, Dart 3.13+, Pigeon 29 (schema types renamed without `Pigeon` prefix; `TwilioConversationsFlutterApi.setUp`).
* Full Conversations SDK listener surface forwarded to Dart (conversation, message, participant, typing, user, connection state).
* Query APIs: `listConversations`, `getConversation`, `getLastMessages`, `getMessagesBefore`, `getParticipants`, `sendTyping`.
* Media: `sendMediaMessage`, `getMediaTemporaryUrl`, `TwilioConversationsMediaPolicy`, `SendMediaMessageCommand`.
* `TwilioConversationsSession` for one client + one event subscription; `TwilioConversationsClientRegistry` prevents duplicate clients.
* Dart `connectionState` tracks native `ClientConnectionStateChanged` for reconnect after SDK disconnect.
* `TwilioConversationsClient` factory; `send(SendMessageCommand)`; non-null `MessageAttributes`.
* Docs: `docs/MEDIA_SUPPORT.md`, `docs/APP_LIFECYCLE.md`, `docs/CONVERSATIONS_SDK_COVERAGE.md`, updated API/event catalogs.
* Initial scaffold: Pigeon host API, event-first `TwilioConversationsClient`, iOS/Android Twilio SDK bridges, and CI unit tests.
