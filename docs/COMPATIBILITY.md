# Compatibility matrix

Pin versions together when upgrading. After bumping a Twilio SDK, run example app on device and re-read the matching changelog.

Use the repo [`.flutter-version`](../.flutter-version) (currently **3.47.4**) with FVM or your Flutter install so local builds match CI.

| Component | Pinned in repo | Changelog / reference |
| --- | --- | --- |
| Flutter | 3.47+ (CI: 3.47.4) | https://docs.flutter.dev/release/release-notes |
| Dart | 3.13+ | SDK with Flutter |
| Pigeon | ^29.0.2 (`pubspec.yaml`) | https://pub.dev/packages/pigeon/changelog |
| Twilio Conversations Android | **6.2.1** (`android/build.gradle`) | https://www.twilio.com/docs/conversations-classic/android/changelog |
| Twilio Conversations iOS | **~> 4.0** (`ios/twilio_flutter_conversations.podspec`) | https://www.twilio.com/docs/conversations-classic/ios/changelog |
| Android min SDK | 21 | Twilio Conversations requirement |
| iOS deployment target | 13.0 | Podspec |

## API reference URLs (match pinned majors)

- Android 6.2.x: https://media.twiliocdn.com/sdk/android/conversations/releases/6.2.0/docs/convo-android/
- iOS 4.x: https://media.twiliocdn.com/sdk/ios/conversations/latest/docs (verify against your resolved pod version in `Podfile.lock`)

## Upgrade checklist

1. Read Twilio Android **and** iOS changelog for breaking listener/API changes.
2. Bump Gradle dependency and pod constraint.
3. Regenerate pigeon only if schema changed (`dart run pigeon …`).
4. Run `flutter test`, Android `:twilio_flutter_conversations:testDebugUnitTest`, and example on one device per platform.
