# twilio_flutter_conversations

Typed Flutter wrapper for the Twilio Conversations SDK.

**Full integrator documentation** (setup, lifecycle, events, attributes, doc links, Video monorepo plan): [repository README](../../README.md) and [ARCHITECTURE.md](../../docs/ARCHITECTURE.md).

## Quick API (recommended)

```dart
final chatSession = TwilioConversationsSession();

await chatSession.start(
  accessToken: tokenFromYourBackend,
  onEvent: (event) { /* sync, messages, token lifecycle */ },
);

await chatSession.client.sendMessage(
  conversationSid: sid,
  body: 'Hello',
  attributes: {'kind': 'status', 'level': 1},
);

await chatSession.stop(); // or chatSession.dispose() when tearing down the feature
```

Low-level API: [`TwilioConversationsClient`](lib/src/client/twilio_conversations_client.dart). See [QUICKSTART.md](../../docs/QUICKSTART.md) and [MEDIA_SUPPORT.md](../../docs/MEDIA_SUPPORT.md).

## Pigeon

```bash
dart run pigeon --input pigeons/conversations_api.dart
```
