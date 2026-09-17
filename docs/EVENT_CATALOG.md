# Event catalog

Native SDK callbacks are normalized to `PigeonConversationsNativeEvent`, then to sealed `TwilioConversationsEvent` types.

## Subscription timing

Subscribe to `TwilioConversationsClient.events` **before** or **immediately when** calling `connect()`.

## Client-level events

| Dart type | Payload |
| --- | --- |
| `ClientSynchronizationStatusUpdated` | `TwilioClientSynchronizationStatus` |
| `ClientConnectionStateChanged` | `TwilioClientConnectionState` |
| `ConversationAdded` | `TwilioConversation` |
| `ConversationUpdated` | `TwilioConversation`, `updateReason` |
| `ConversationDeleted` | `TwilioConversation` |
| `ConversationSynchronizationUpdated` | `TwilioConversation`, `TwilioConversationSynchronizationStatus` |
| `UserUpdated` | `TwilioUser`, `updateReason` |
| `UserSubscribed` / `UserUnsubscribed` | `TwilioUser` |
| `TokenAboutToExpire` / `TokenExpired` | none — refresh token via backend |
| `NotificationSubscribed` | none |
| `ConversationsError` | `TwilioFlutterException` |

## Conversation-level events

| Dart type | Payload |
| --- | --- |
| `MessageAdded` / `MessageUpdated` / `MessageDeleted` | `TwilioMessage` (+ `updateReason` on update) |
| `ParticipantAdded` / `ParticipantUpdated` / `ParticipantDeleted` | `TwilioParticipant` (+ `updateReason` on update) |
| `TypingStarted` / `TypingEnded` | `TwilioParticipant` |

## Ordering

No global ordering is guaranteed beyond the Twilio SDK. Host API futures complete independently of the event stream.

## Mapping

- Native: `ConversationsEventMapper` (Kotlin/Swift)
- Dart: `ConversationsEventMapper`, `PigeonDtoMapper`
