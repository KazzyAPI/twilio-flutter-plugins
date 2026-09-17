## Unreleased

* Full Conversations SDK listener surface forwarded to Dart (conversation, message, participant, typing, user, connection state).
* Query APIs: `listConversations`, `getConversation`, `getLastMessages`, `getMessagesBefore`, `getParticipants`, `sendTyping`.
* Media: `sendMediaMessage`, `getMediaTemporaryUrl`, `TwilioConversationsMediaPolicy`, `SendMediaMessageCommand`.
* `TwilioConversationsSession` for one client + one event subscription; `TwilioConversationsClientRegistry` prevents duplicate clients.
* Dart `connectionState` tracks native `ClientConnectionStateChanged` for reconnect after SDK disconnect.
* `TwilioConversationsClient` factory; `send(SendMessageCommand)`; non-null `MessageAttributes`.
* Docs: `docs/MEDIA_SUPPORT.md`, `docs/APP_LIFECYCLE.md`, `docs/CONVERSATIONS_SDK_COVERAGE.md`, updated API/event catalogs.

## 0.0.1

* Initial scaffold: Pigeon host API, event-first `TwilioConversationsClient`, iOS/Android Twilio SDK bridges, and CI unit tests.
