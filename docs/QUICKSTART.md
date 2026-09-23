# Integrator quickstart (Conversations)

For pub.dev install, Android/iOS setup, and Video in the same app, start with **[CONSUMER_GUIDE.md](CONSUMER_GUIDE.md)**.

Copy-paste flow for a single user identity in your Flutter app.

## 1. Backend (required)

Mint a Conversations JWT for the logged-in user ([Create tokens](https://www.twilio.com/docs/conversations-classic/create-tokens)). The mobile app calls your HTTPS endpoint; never ship API secrets in the app.

Ensure the user is a **participant** in at least one conversation ([REST API](https://www.twilio.com/docs/conversations-classic/api)).

## 2. Add dependency

```yaml
dependencies:
  twilio_flutter_conversations: ^0.0.2
```

See [pub.dev](https://pub.dev/packages/twilio_flutter_conversations) for the latest version. Git install is optional in [CONSUMER_GUIDE.md](CONSUMER_GUIDE.md#1-add-dependencies).

Run `pod install` in your app `ios/` directory after the first `flutter pub get`.

## 3. One session for the app feature

Use **`TwilioConversationsSession`** so you do not stack clients or `events.listen` calls (same behavior foreground and background):

```dart
final TwilioConversationsSession chatSession = TwilioConversationsSession();

Future<void> startChat(String jwt) => chatSession.start(
  accessToken: jwt,
  onEvent: handleChatEvent,
);
```

See [APP_LIFECYCLE.md](APP_LIFECYCLE.md). Low-level: one `TwilioConversationsClient` per engine; a second constructor throws until the first is disposed.

## 4. Subscribe, connect, handle lifecycle

If you `disconnect()` or `dispose()` while `connect()` is still awaiting the native SDK, the call may return without reaching `connected` (stale connect). Always use a fresh client or await an in-flight `connect()` before tearing down.

```dart
import 'package:twilio_flutter_conversations/twilio_flutter_conversations.dart';

final TwilioConversationsSession chatSession = TwilioConversationsSession();

Future<void> startChat({required String accessToken}) async {
  await chatSession.start(
    accessToken: accessToken,
    onEvent: (event) {
    switch (event) {
      case ClientSynchronizationStatusUpdated(:final status):
        if (status == TwilioClientSynchronizationStatus.completed) {
          // Safe to send messages (for conversations already in cache).
        }
      case TokenAboutToExpire():
      case TokenExpired():
        unawaited(refreshChatToken()); // your backend → chatSession.client.updateAccessToken
      case MessageAdded(:final message):
        appendToUi(message);
      case ConversationsError(:final exception):
        logChatError(exception);
      default:
        break;
    }
  },
  );
}

Future<void> refreshChatToken() async {
  final jwt = await yourBackend.fetchConversationsToken();
  await chatSession.client.updateAccessToken(jwt);
}

Future<void> stopChat() async {
  await chatSession.stop();
}
```

## 5. Send a message with custom metadata

```dart
await chatSession.client.sendMessage(
  conversationSid: 'CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
  body: 'Hello',
  attributes: {
    'messageKind': 'status',
    'orderId': 'ord_123',
  },
);

// Or build an explicit command (same wire behavior):
await chatSession.client.send(
  SendMessageCommand.create(
    conversationSid: 'CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    body: 'Hello',
    attributes: {'orderId': 'ord_123'},
  ),
);
```

`TwilioMessage.attributes` is always a `MessageAttributes` value (use `isEmpty` when none were set).

## 6. List conversations, history, typing

```dart
final conversations = await chatSession.client.listConversations();
final thread = await chatSession.client.getConversation('CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
final history = await chatSession.client.getLastMessages(
  conversationSid: thread.sid,
  count: 30,
);
final participants = await chatSession.client.getParticipants(thread.sid);
await chatSession.client.sendTyping(thread.sid);
```

Handle `TypingStarted` / `TypingEnded`, `MessageUpdated`, and `ConversationUpdated` in your `start(onEvent: …)` handler.

Paginate older messages:

```dart
final older = await chatSession.client.getMessagesBefore(
  conversationSid: thread.sid,
  beforeMessageIndex: history.first.messageIndex,
  count: 30,
);
```

Send a photo from disk and fetch a download URL:

```dart
final sent = await chatSession.sendMedia(
  SendMediaMessageCommand.create(
    conversationSid: thread.sid,
    filePath: '/path/on/device/photo.jpg',
    mimeType: 'image/jpeg',
    filename: 'photo.jpg',
    caption: 'On site',
  ),
);
final media = sent.primaryMedia!;
final url = await chatSession.client.getMediaTemporaryUrl(
  conversationSid: thread.sid,
  messageIndex: sent.messageIndex,
  mediaSid: media.sid,
);
// Download bytes with http.get(url) in your app.
```

## 7. Verify on device

```bash
cd packages/twilio_flutter_conversations/example
flutter run \
  --dart-define=TWILIO_ACCESS_TOKEN='YOUR_JWT' \
  --dart-define=TWILIO_CONVERSATION_SID='CHxxxx'
```

## Next reads

- [Event catalog](EVENT_CATALOG.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [API coverage](API_COVERAGE.md)
