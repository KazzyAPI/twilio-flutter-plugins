# App lifecycle (foreground, background, one client)

## Same API in foreground and background

You **do not** need separate code paths for foreground vs background. Use one `TwilioConversationsClient` (or `TwilioConversationsSession`) for the whole chat feature:

- Host calls (`sendMessage`, `getLastMessages`, `sendMediaMessage`, …) behave the same whenever the Dart isolate is running.
- Events arrive on `client.events` whether the UI is visible or not, as long as the process is alive and the native SDK stays connected.

## What the OS still controls

| Situation | What happens | What you should do |
| --- | --- | --- |
| App backgrounded | OS may suspend the process or tear down network; SDK may emit `ClientConnectionStateChanged` | Keep the **same** client; on resume call **`TwilioConversationsSession.start`** with a fresh JWT (handles `updateAccessToken` when still connected, or `connect` after SDK loss) — **do not** create a second client |
| Process killed | Connection lost | On next launch, create **one** new session and `connect` again |
| Push notification (optional) | Twilio can wake the app for new messages when configured | Configure FCM/APNs per Twilio docs; plugin emits `NotificationSubscribed` when SDK registers |

The plugin does **not** require different Dart APIs for background delivery. Optional push setup is native/Twilio configuration, not a second Flutter client.

## Avoid stacking clients and event listeners

### Do

- Use **`TwilioConversationsSession`** at app/feature scope (provider, service locator, or root State).
- Call `session.start(accessToken:, onEvent:)` once; it replaces any prior subscription on that session.
- Rely on **`TwilioConversationsClientRegistry`**: a second `TwilioConversationsClient()` throws until the first is `dispose()`d.

### Don’t

- Call `TwilioConversationsClient()` inside `build()` or on every `AppLifecycleState.resumed`.
- Call `events.listen` in multiple widgets without cancelling — prefer one listener in the session and fan out with your state layer.
- `connect()` again while already connected (throws `already_connected`).

### Recommended pattern

```dart
final TwilioConversationsSession chatSession = TwilioConversationsSession();

Future<void> openChat(String jwt) => chatSession.start(
  accessToken: jwt,
  onEvent: dispatchChatEvent,
);

Future<void> closeChat() => chatSession.stop();

@override
void dispose() {
  chatSession.dispose();
  super.dispose();
}
```

On resume from background, call **`TwilioConversationsSession.start`** again with a fresh JWT (it calls `updateAccessToken` when already connected) or call **`updateAccessToken`** yourself after `TokenAboutToExpire` / `TokenExpired`.

**Two connection enums:** `TwilioConversationsConnectionState` on the Dart client (`disconnected`, `connecting`, `connected`, …) tracks connect/dispose guards and is updated from `ClientConnectionStateChanged` when the native SDK drops offline (the plugin then calls native `disconnect` so `connect()` can run again on the same Dart client). `TwilioClientConnectionState` on that event is the SDK’s live connection signal — use both: guard host calls with `client.connectionState`, and react to background network loss via `ClientConnectionStateChanged` on your event handler.

## Android / iOS notes

- Android bridge uses `applicationContext` — activity rotation does not require a new plugin client.
- iOS: keep one client for the engine lifetime; use Twilio push docs if you need messages when the app is not running.

See also [QUICKSTART.md](QUICKSTART.md) and [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
