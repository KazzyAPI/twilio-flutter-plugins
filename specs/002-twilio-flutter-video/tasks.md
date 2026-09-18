# Tasks: Twilio Flutter Video

Feature: `specs/002-twilio-flutter-video`

- [x] FR-1: Pigeon host API (connect, disconnect, local audio/video toggles)
- [x] FR-2: Flutter API events (`TwilioVideoEvent`)
- [x] FR-3: `VideoConnectRequest` with token, room name, initial track flags
- [x] FR-4: Error mapping via `TwilioErrorCode`
- [x] FR-5: Document single client per engine; optional session wrapper
- [x] FR-6: Pin Twilio Video Android + iOS SDKs in Gradle/podspec
- [x] CI: Align Conversations Android 6.2.1 + Pigeon 29 suspend Flutter APIs (shared `EventEmitter` coroutine dispatch; JVM-safe attribute JSON validation)
- [x] CI: iOS Conversations host adapter + `@MainActor` Flutter event dispatch (Pigeon 29)
- [x] CI: Example iOS UIScene + CocoaPods (disable SPM) for Twilio podspec plugins
- [x] CI: iOS event mapper enums aligned with Conversations SDK 4.x (drop syncWindow)
- [x] CI: iOS media temporary URLs via `getTemporaryContentUrlsForMedia`
- [ ] P2: Platform views for video rendering (future)
- [ ] Example app + device E2E (future)
