# Example app

## Run (UI only)

```bash
cd packages/twilio_flutter_conversations/example
flutter run
```

The UI lists events from `TwilioConversationsClient.events`. Use **Connect** when a token is configured (below).

## Run with a real Conversations token

1. Deploy a backend endpoint that returns a Conversations JWT ([Create tokens](https://www.twilio.com/docs/conversations-classic/create-tokens)).
2. Ensure the identity is a **participant** in at least one conversation.
3. Launch with a compile-time token (dev only — never commit tokens):

```bash
flutter run \
  --dart-define=TWILIO_ACCESS_TOKEN='YOUR_JWT' \
  --dart-define=TWILIO_CONVERSATION_SID='CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

Optional: set `TWILIO_CONVERSATION_SID` to enable **Send test message** after sync completes.

## Integration tests (device)

With token defined:

```bash
flutter test integration_test/conversations_e2e_test.dart \
  --dart-define=TWILIO_ACCESS_TOKEN='YOUR_JWT'
```

Without `TWILIO_ACCESS_TOKEN`, E2E tests **skip** (CI-friendly).

## Platform notes

- iOS: `cd ios && pod install` after adding the plugin.
- Android: min SDK 21.

See root [README](../../../README.md) and [TROUBLESHOOTING](../../../docs/TROUBLESHOOTING.md).
