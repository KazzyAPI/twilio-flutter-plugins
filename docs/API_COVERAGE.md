# API coverage matrix

Maps **Twilio Conversations classic mobile SDK** capabilities to this plugin. **Supported** = typed end-to-end (Pigeon + Dart + iOS/Android). **REST/backend** = intentionally not on device. **Planned** = follow-up host APIs.

## Client lifecycle

| Capability | Status | Dart API |
| --- | --- | --- |
| Connect with access token | Supported | `connect` |
| Client synchronization status | Supported | `ClientSynchronizationStatusUpdated` |
| SDK connection state | Supported | `ClientConnectionStateChanged` |
| Update access token | Supported | `updateAccessToken` |
| Disconnect / shutdown | Supported | `disconnect`, `dispose` |
| Dart connection guard | Supported | `connectionState` |
| Push notification subscribed (SDK callback) | Supported | `NotificationSubscribed` event |

## Conversations

| Capability | Status | Dart API |
| --- | --- | --- |
| Conversation added | Supported | `ConversationAdded` |
| Conversation updated | Supported | `ConversationUpdated` (+ `updateReason`) |
| Conversation deleted | Supported | `ConversationDeleted` |
| Conversation sync status | Supported | `ConversationSynchronizationUpdated` |
| List cached conversations | Supported | `listConversations` |
| Get by SID or unique name | Supported | `getConversation` |
| Create conversation / add participant | REST/backend | Twilio REST or your server |

## Messages

| Capability | Status | Dart API |
| --- | --- | --- |
| Send text + attributes | Supported | `sendMessage`, `send(SendMessageCommand.create(...))` |
| Message added / updated / deleted | Supported | `MessageAdded`, `MessageUpdated`, `MessageDeleted` |
| Last N messages | Supported | `getLastMessages` (count 1–100) |
| Paginate before index | Supported | `getMessagesBefore` |
| Media send (local file) | Supported | `sendMediaMessage` + `TwilioConversationsMediaPolicy` validation |
| Media download URL | Supported | `getMediaTemporaryUrl` (+ `TwilioMediaAttachment` on messages) |

## Participants & typing

| Capability | Status | Dart API |
| --- | --- | --- |
| List participants | Supported | `getParticipants` |
| Participant added / updated / removed | Supported | `ParticipantAdded`, `ParticipantUpdated`, `ParticipantDeleted` |
| Typing indicators | Supported | `sendTyping`, `TypingStarted`, `TypingEnded` |

## Users & tokens

| Capability | Status | Dart API |
| --- | --- | --- |
| User updated / subscribed / unsubscribed | Supported | `UserUpdated`, `UserSubscribed`, `UserUnsubscribed` |
| Token about to expire / expired | Supported | `TokenAboutToExpire`, `TokenExpired` |
| SDK errors | Supported | `ConversationsError`, `TwilioFlutterException` on host calls |

## Not in scope (mobile plugin)

| Capability | Status | Notes |
| --- | --- | --- |
| Web / desktop | Unsupported | iOS + Android only |
| Mint JWT / API keys in-app | REST/backend | Security |
| Admin REST at scale | REST/backend | Server-side |
| Webhooks | REST/backend | Twilio console / server |

See [CONVERSATIONS_SDK_COVERAGE.md](CONVERSATIONS_SDK_COVERAGE.md) for listener ↔ event mapping and REST boundaries.

When adding a row, update this file, `EVENT_CATALOG.md`, and the active feature `sdd-api-surface.txt` in the same change set.

## Programmable Video (`twilio_flutter_video`)

| Capability | Status | Dart API |
| --- | --- | --- |
| Connect to room (token + room name) | Supported | `connect`, `TwilioVideoSession.start` |
| Disconnect | Supported | `disconnect`, `stop`, `dispose` |
| Local audio/video toggle | Supported | `setLocalAudioEnabled`, `setLocalVideoEnabled` |
| Room connected / disconnected | Supported | `RoomConnected`, `RoomDisconnected` |
| Reconnecting / reconnected | Supported | `RoomReconnecting`, `RoomReconnected` |
| Remote participant join/leave | Supported | `ParticipantConnected`, `ParticipantDisconnected` |
| Dominant speaker | Supported | `DominantSpeakerChanged` |
| SDK errors (event + host throws) | Supported | `VideoError`, `TwilioFlutterException` |
| Local/remote video rendering | Planned | Platform views (not in v0.0.1) |
| Screen share, data tracks | Planned | Follow-up host APIs |

Quickstart: [VIDEO_QUICKSTART.md](VIDEO_QUICKSTART.md). Spec: `specs/002-twilio-flutter-video/`.
