# twilio_flutter_conversations

Twilio Conversations (classic) for Flutter on iOS and Android.

**Install and usage (pub.dev, tokens, platform setup, copy-paste samples):** [Consumer guide](../../docs/CONSUMER_GUIDE.md#4-twilio-conversations-in-your-app).

## pub.dev

```yaml
dependencies:
  twilio_flutter_conversations: ^0.0.2
```

Latest version: [pub.dev/packages/twilio_flutter_conversations](https://pub.dev/packages/twilio_flutter_conversations).

## Minimal connect

```dart
import 'package:twilio_flutter_conversations/twilio_flutter_conversations.dart';

final TwilioConversationsSession chatSession = TwilioConversationsSession();

await chatSession.start(
  accessToken: tokenFromYourBackend,
  onEvent: (TwilioConversationsEvent event) {
    // ClientSynchronizationStatusUpdated, MessageAdded, TokenExpired, …
  },
);

await chatSession.client.sendMessage(
  conversationSid: 'CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
  body: 'Hello',
);

await chatSession.stop();
```

## Maintainer docs

- Regenerate Pigeon: `dart run pigeon --input pigeons/conversations_api.dart`
- Local CI checks: `../../scripts/run_ci_checks.sh` from repo root
