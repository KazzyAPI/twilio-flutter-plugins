# Twilio Flutter plugins

Monorepo (`twilio-flutter-plugins`) for typed Flutter plugins on Twilio realtime products. **Conversations** and **Programmable Video** ship as **separate pub.dev packages** from this repo; the repo itself is not published as one artifact. **`twilio_flutter_core`** is shared Dart-only code used by the plugins.

**Conversations is implemented today**; **Video is a scaffold** in `packages/twilio_flutter_video` (same CI and core, not a combined mega-plugin).

## What this is

- Wraps the **official** Twilio Conversations (classic) SDKs on iOS and Android.
- Exposes **`TwilioConversationsSession`** (recommended) and **`TwilioConversationsClient`** with a single **event stream** so apps do not implement native listeners themselves.
- Uses **Pigeon** for null-safe platform calls and a documented event envelope.

What this is not: a replacement for your backend. Access tokens, conversation administration, and secrets stay on your server.

## Spec Kit (spec-driven development)

This repo uses [GitHub Spec Kit](https://github.github.com/spec-kit/). Active feature: `specs/001-twilio-flutter-conversations` (see `.specify/feature.json`).

In Cursor, use slash commands from `.cursor/commands/`:

- `/speckit.constitution` — project principles (`.specify/memory/constitution.md`)
- `/speckit.specify` / `/speckit.plan` / `/speckit.tasks` — update spec artifacts
- `/speckit.analyze` — cross-check spec vs code
- `/speckit.converge` — gap analysis vs implementation

## Packages

| Package | Purpose |
| --- | --- |
| `twilio_flutter_core` | Shared errors and JSON codecs |
| `twilio_flutter_conversations` | Conversations SDK (full mobile listener + query surface) |
| `twilio_flutter_video` | Video SDK scaffold (API TBD) |

## Documentation index

| Doc | Purpose |
| --- | --- |
| [Architecture](docs/ARCHITECTURE.md) | Layers, DRY boundaries, Video sibling package |
| [API coverage](docs/API_COVERAGE.md) | Supported vs planned Twilio features |
| [SDK coverage map](docs/CONVERSATIONS_SDK_COVERAGE.md) | Listener ↔ Dart event + host method matrix |
| [Event catalog](docs/EVENT_CATALOG.md) | Every Dart event and subscription rules |
| [Compatibility](docs/COMPATIBILITY.md) | Pinned SDK versions and upgrade checklist |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Error codes, tokens, builds |
| [Quickstart](docs/QUICKSTART.md) | Copy-paste connect → events → send → teardown |
| [Media support](docs/MEDIA_SUPPORT.md) | Allowed MIME types and size limits |
| [App lifecycle](docs/APP_LIFECYCLE.md) | Foreground/background, one client, no stacked listeners |
| [Contributing](CONTRIBUTING.md) | Pigeon workflow and PR checklist |
| [Example app](example/README.md) | Pointer to runnable example + dart-define |

```bash
./scripts/bootstrap.sh   # pub get, pigeon, test, analyze
```

## Supported versions

| Layer | Version |
| --- | --- |
| Flutter | 3.47+ (CI: 3.47.4) |
| Dart | 3.13+ (bundled with Flutter 3.47+) |
| Android min SDK | 21 |
| iOS min | 13.0 |
| Twilio Conversations Android | 6.2.1 (Maven Central) |
| Twilio Conversations iOS | TwilioConversationsClient ~> 4.0 (CocoaPods in podspec) |

Pin these in your app when you harden for production; bump only after reading Twilio changelogs.

## Twilio setup (Console + backend)

1. Create a Twilio account and a **Conversations Service** (Console → Conversations).
2. Create **API keys** for your backend (not in the mobile app).
3. Implement a **token endpoint** that mints Conversations JWTs for authenticated users ([Create tokens](https://www.twilio.com/docs/conversations-classic/create-tokens)).
4. Use the REST API or Console to create conversations and participants before clients join ([API overview](https://www.twilio.com/docs/conversations-classic/api)).

The mobile app receives only a **short-lived access token** from your backend.

## Add to your Flutter app

```yaml
dependencies:
  twilio_flutter_conversations:
    path: ../packages/twilio_flutter_conversations # or pub version when published
```

Android and iOS native dependencies are pulled by the plugin (`build.gradle` / `podspec`). Run `pod install` in `ios/` after adding the plugin.

## Client lifecycle

Twilio’s mobile SDK is **asynchronous** and **event-driven**. This plugin mirrors that model.

```
Backend token → connect() → SDK sync events → ready → sendMessage / listen
                    ↓
         tokenAboutToExpire / tokenExpired → updateAccessToken()
                    ↓
              disconnect() → native shutdown()
```

1. **Subscribe to events before or immediately after `connect`.** Synchronization events can arrive as soon as the native client is created.
2. **Wait for `ClientSynchronizationStatusUpdated` → `completed`** before assuming all conversations are local (exact UX is app-specific).
3. On **`TokenAboutToExpire` / `TokenExpired`**, fetch a new JWT from your backend and call **`updateAccessToken`**.
4. Call **`disconnect`** when the user logs out or leaves chat; native `shutdown()` is irreversible for that client instance.

Initialization details: [Initializing Conversations SDK clients](https://www.twilio.com/docs/conversations-classic/initializing-conversations-sdk-clients).

## Events (Dart)

| Event | When |
| --- | --- |
| `ClientSynchronizationStatusUpdated` | SDK sync state changes |
| `ConversationAdded` | Conversation appears in local cache |
| `MessageAdded` | New message in a tracked conversation |
| `TokenAboutToExpire` | Refresh token soon |
| `TokenExpired` | Must refresh token to continue |
| `ConversationsError` | SDK reported an error envelope |

Native SDK callbacks are normalized in Swift/Kotlin `ConversationsEventMapper` and forwarded through one pigeon channel.

## Sending messages and custom metadata

Text plus optional **attributes** (JSON object metadata on the Twilio message):

```dart
await client.sendMessage(
  conversationSid: 'CHxxxxxxxx',
  body: 'Order shipped',
  attributes: {
    'orderId': 'ord_123',
    'priority': 'high',
    'retryCount': 1,
  },
);
```

- Dart validates and encodes attributes via **`TwilioJsonObjectCodec`** (in `twilio_flutter_core`).
- Native code parses JSON once per platform (`MessageAttributesJson` on Android/iOS) into Twilio `Attributes`.
- Incoming messages and `MessageAdded` events surface **`TwilioMessage.attributes`** when the SDK provides them.

Twilio attribute rules and examples: [Sending messages and media](https://www.twilio.com/docs/conversations-classic/sending-messages-and-media). Prefer JSON-serializable values (string, number, bool, null, lists, nested maps).

## Error handling

Operations throw **`TwilioFlutterException`** with stable **`TwilioErrorCode`** values (`not_connected`, `already_connected`, `invalid_argument`, `sdk_failure`, …). Map these in your app for retry UI vs fatal logout.

## Development

```bash
# Core
cd packages/twilio_flutter_core && dart pub get && dart test && dart analyze --fatal-infos

# Conversations
cd packages/twilio_flutter_conversations && flutter pub get && flutter test && flutter analyze --fatal-infos
```

Regenerate Pigeon after editing `pigeons/conversations_api.dart`:

```bash
cd packages/twilio_flutter_conversations
dart run pigeon --input pigeons/conversations_api.dart
```

Optional: [Melos](https://melos.invertase.dev/) scripts in `melos.yaml`.

## CI

GitHub Actions (`.github/workflows/ci.yml`): analyze, unit tests, and **pigeon drift check** on every push/PR.

## Official documentation map

These are the pages integrators actually need (Twilio’s docs are useful but fragmented — “Conversations (classic)” naming and mixed Programmable Chat legacy results are common friction):

| Topic | URL |
| --- | --- |
| SDK install | https://www.twilio.com/docs/conversations-classic/sdk-download-install |
| Access tokens | https://www.twilio.com/docs/conversations-classic/create-tokens |
| Client init & sync | https://www.twilio.com/docs/conversations-classic/initializing-conversations-sdk-clients |
| Android quickstart | https://www.twilio.com/docs/conversations-classic/android/exploring-conversations-android-quickstart |
| iOS quickstart | https://www.twilio.com/docs/conversations-classic/ios/exploring-conversations-swift-quickstart |
| Messages & attributes | https://www.twilio.com/docs/conversations-classic/sending-messages-and-media |
| REST API | https://www.twilio.com/docs/conversations-classic/api |
| Android SDK reference | https://media.twiliocdn.com/sdk/android/conversations/releases/6.2.0/docs/convo-android/ |
| iOS SDK reference | https://media.twiliocdn.com/sdk/ios/conversations/latest/docs |

## Programmable Video

**Same monorepo, separate package.** Video will not be merged into `twilio_flutter_conversations`. Expect `packages/twilio_flutter_video` with its own Pigeon surface, PlatformViews, and lifecycle. Shared pieces stay in `twilio_flutter_core` (errors, JSON helpers, CI).

## Cold-start assessment (external)

An independent GPT pass (no repo context) rated implementing this style of plugin **~6/10** difficulty and finding Twilio docs **~6/10** discoverability — straightforward feature mapping, non-trivial lifecycle/event normalization and integration testing; docs require jumping between classic guides, quickstarts, and versioned API references. That matches why this README and [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) exist.

## License

See [LICENSE](LICENSE).
