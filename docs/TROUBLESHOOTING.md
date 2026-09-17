# Troubleshooting

## Error codes (`TwilioErrorCode`)

| Code | Typical cause | Retry? |
| --- | --- | --- |
| `not_implemented` | Platform channel missing (web/desktop) | No — unsupported platform |
| `invalid_argument` | Bad args (empty attributes map, invalid JSON) | Fix input |
| `not_connected` | `sendMessage` / `updateAccessToken` before successful `connect` | Call `connect` |
| `already_connected` | Second `connect` while connected/connecting | `disconnect` first |
| `sdk_failure` | Twilio SDK rejected operation (token, network, permissions) | Depends on message |
| `internal` | Plugin bug or malformed native event | Report with logs |

Host calls throw `TwilioFlutterException`. SDK asynchronous errors arrive on `events` as `ConversationsError`.

## Token failures

- **Symptom:** Connect fails immediately or `TokenExpired` fires.
- **Check:** Token minted for the correct **Conversations Service SID** and **identity**; clock skew minimal; JWT not expired.
- **Fix:** Backend token endpoint; handle `TokenAboutToExpire` by calling `updateAccessToken`.

## Synchronization never reaches `completed`

- **Check:** Network/firewall allows Twilio Conversations endpoints (see Twilio fundamentals doc).
- **Check:** User is a **participant** in at least one conversation (empty account can sync but show no conversations).
- **Debug:** Log all `ClientSynchronizationStatusUpdated` values.

## Android build

- **Symptom:** Gradle cannot resolve `com.twilio:conversations-android`.
- **Fix:** `mavenCentral()` in project repositories; min SDK ≥ 21; Java 8+ (`compileOptions` in plugin `build.gradle`).

## iOS build

- **Symptom:** Pod install fails or undefined symbols.
- **Fix:** iOS 13+ deployment target; `pod install` in app `ios/`; use `TwilioConversationsClient` version compatible with podspec.

## Duplicate clients or doubled events

- **Symptom:** Duplicate `MessageAdded`, `already_connected`, or missed events.
- **Fix:** Use one `TwilioConversationsSession` (or one `TwilioConversationsClient` with a single `events.listen`). Do not create a client on app resume — reuse the session and refresh the token if needed ([APP_LIFECYCLE.md](APP_LIFECYCLE.md)).
- **Guard:** A second `TwilioConversationsClient()` throws while the first is alive (`TwilioConversationsClientRegistry`).

## Media upload rejected

- **Check:** MIME type is in `TwilioConversationsMediaPolicy.supportedMimeTypes` and file ≤ 150 MiB ([MEDIA_SUPPORT.md](MEDIA_SUPPORT.md)).
- **Check:** Absolute `filePath` exists on device before `sendMediaMessage`.

## Duplicate or missing messages

- Plugin emits **one** `MessageAdded` per message via **conversation-level** listeners (not duplicated client delegate on iOS).
- If messages are missing, confirm conversation listener registered (`ConversationAdded` fired) and conversation synchronized.

## Disconnect or dispose during connect

If `dispose()` runs while `connect()` is in flight, native bridges invalidate the pending connect generation and shut down any client that completes late. Use one `TwilioConversationsClient` per engine and await `connect()` before `dispose()` when possible.

## Pigeon drift CI failure

Run locally:

```bash
cd packages/twilio_flutter_conversations
dart run pigeon --input pigeons/conversations_api.dart
git diff
```

Commit regenerated files with your schema change.
