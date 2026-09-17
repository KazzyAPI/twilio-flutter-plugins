# Twilio Conversations SDK ↔ plugin coverage

Reference for **classic** Conversations SDK (Android 6.2.x, iOS 4.x). This plugin forwards **client** and **conversation** listeners and exposes **query** host methods aligned with typical chat apps.

## Client listener (`ConversationsClientListener` / `TwilioConversationsClientDelegate`)

| SDK callback | Dart event |
| --- | --- |
| Client synchronization | `ClientSynchronizationStatusUpdated` |
| Connection state | `ClientConnectionStateChanged` |
| Conversation added | `ConversationAdded` |
| Conversation updated | `ConversationUpdated` |
| Conversation deleted | `ConversationDeleted` |
| Conversation synchronization | `ConversationSynchronizationUpdated` |
| User updated | `UserUpdated` |
| User subscribed / unsubscribed | `UserSubscribed`, `UserUnsubscribed` |
| Token about to expire / expired | `TokenAboutToExpire`, `TokenExpired` |
| Notification subscribed | `NotificationSubscribed` |
| Notification failed / generic error | `ConversationsError` |

## Conversation listener (`ConversationListener` / `TCHConversationDelegate`)

| SDK callback | Dart event |
| --- | --- |
| Message added / updated / deleted | `MessageAdded`, `MessageUpdated`, `MessageDeleted` |
| Participant joined / left / updated | `ParticipantAdded`, `ParticipantDeleted`, `ParticipantUpdated` |
| Typing started / ended | `TypingStarted`, `TypingEnded` |
| Synchronization changed | `ConversationSynchronizationUpdated` |

## Host methods (Dart → native)

| Operation | Dart |
| --- | --- |
| Connect / disconnect / refresh token | `connect`, `disconnect`, `updateAccessToken` |
| Send text message | `sendMessage`, `send` |
| List / resolve conversation | `listConversations`, `getConversation` |
| Message history (recent) | `getLastMessages` |
| Message history (before index) | `getMessagesBefore` |
| Send media file | `sendMediaMessage` |
| Media download URL | `getMediaTemporaryUrl` |
| Participants | `getParticipants` |
| Typing | `sendTyping` |

## Still use your backend (REST)

- Create Conversations, Services, or Users
- Add participants (SMS, WhatsApp, cross-product) at scale
- Issue access tokens
- Webhooks and moderation pipelines
- Server-side media retention and compliance rules — configure in Twilio Console; client uploads validated by `TwilioConversationsMediaPolicy` ([MEDIA_SUPPORT.md](MEDIA_SUPPORT.md))

## Verification

- Unit tests: Dart mappers + client guards
- CI: analyze, pigeon drift, Android unit tests, iOS simulator build
- Optional E2E: `example/integration_test` with `TWILIO_ACCESS_TOKEN`
