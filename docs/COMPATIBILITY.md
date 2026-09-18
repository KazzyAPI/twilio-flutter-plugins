# Compatibility matrix

Pin versions together when upgrading. After bumping a Twilio SDK, run example app on device and re-read the matching changelog.

Use the repo [`.flutter-version`](../.flutter-version) (currently **3.47.4**) with FVM or your Flutter install so local builds match CI.

| Component | Pinned in repo | Changelog / reference |
| --- | --- | --- |
| Flutter | 3.47+ (CI: 3.47.4) | https://docs.flutter.dev/release/release-notes |
| Dart | 3.13+ | SDK with Flutter |
| Pigeon | ^29.0.2 (`pubspec.yaml`) | https://pub.dev/packages/pigeon/changelog |
| Twilio Conversations Android | **6.2.1** (`android/build.gradle`) | https://www.twilio.com/docs/conversations-classic/android/changelog |
| Twilio Conversations iOS | **~> 4.0** (`ios/twilio_flutter_conversations.podspec`) | https://www.twilio.com/docs/conversations-classic/ios/changelog; iOS bridge uses `PigeonError`, `conversation.typing()`, `TCHJsonAttributes`, and UInt message counts |
| Android min SDK | 21 | Twilio Conversations requirement |
| iOS deployment target | 13.0 | Podspec; example app uses UIScene lifecycle (Flutter 3.47+) and `enable-swift-package-manager: false` for CocoaPods-only Twilio SDKs |
| Twilio Video Android | **7.10.4** (`packages/twilio_flutter_video/android/build.gradle`) | https://www.twilio.com/docs/video/changelog |
| Twilio Video iOS | **~> 5.8** (`packages/twilio_flutter_video/ios/twilio_flutter_video.podspec`) | https://www.twilio.com/docs/video/ios |

## API reference URLs (match pinned majors)

- Android 6.2.x: https://media.twiliocdn.com/sdk/android/conversations/releases/6.2.0/docs/convo-android/
- iOS 4.x: https://media.twiliocdn.com/sdk/ios/conversations/latest/docs (verify against your resolved pod version in `Podfile.lock`)
- Android Video 7.x: https://twilio.github.io/twilio-video-android/docs/latest/
- iOS Video 5.x: https://twilio.github.io/twilio-video-ios/docs/latest/

## Upgrade checklist

1. Read Twilio Android **and** iOS changelog for breaking listener/API changes.
2. Bump Gradle dependency and pod constraint.
3. Regenerate pigeon only if schema changed (`dart run pigeon …`).
4. Run `flutter test`, Android `:twilio_flutter_conversations:testDebugUnitTest`, and example on one device per platform.

## Native bridge notes (Pigeon 29)

Generated Flutter APIs use **suspend**/`async` on Android and Swift. Native event emitters must call `onNativeEvent` from a coroutine (Android) or `Task { @MainActor in … }` (iOS), not synchronously from Twilio SDK callback threads. On iOS, callback-based bridge code sits behind `ConversationsBridgeHostAdapter` (same pattern as Android). Conversations Android **6.2.1** and iOS **4.x** moved several types and enum cases (for example `com.twilio.util.ErrorInfo`, removed conversation `syncWindow`, `TCH*Update` instead of `TCH*UpdateReason`, `Media` instead of `TCHMedia`, typing delegate selectors `typingStartedOn` / `typingEndedOn`, client-level `TwilioConversationsClientDelegate` for message/participant events, `getTemporaryContentUrlsFor(media:Set(...))` instead of per-media `getTemporaryUrl`, async `conversation(withSidOrUniqueName:completion:)` when not in `myConversations()`, `setAttributes(_:error:)` on `TCHMessageBuilder`, `addMedia(withData:contentType:filename:listener:)`, `MessageBuilder` (not `TCHMessageBuilder`), `TCHJsonAttributes` (not `JsonAttributes`), optional `message.index`; client sync enum case names may vary by minor SDK version; message APIs use `Int`/`UInt` counts in Swift, not `NSNumber`); keep bridges aligned with the pinned SDK reference when native CI compile fails after a bump.
