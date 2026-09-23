# Consume the Twilio Flutter plugins

App developers add **`twilio_flutter_conversations`** and/or **`twilio_flutter_video`**. Shared **`twilio_flutter_core`** lives only inside the Git monorepo and is resolved automatically when you use a **git `path:` dependency** on a plugin.

| Package | Install name | Use when |
| --- | --- | --- |
| Conversations | `twilio_flutter_conversations` | Chat threads, messages, typing, media in Conversations |
| Video | `twilio_flutter_video` | Join a Programmable Video room (audio/video signaling and events) |
| Core | *(not published)* | Do not depend on it directly; pulled in via the plugin’s path dep |

**Supported platforms:** iOS and Android only (no web or desktop).

---

## Before you begin

1. **Flutter** 3.47 or newer and **Dart** 3.13 or newer (match your CI; this repo pins Flutter 3.47.4 in [`.flutter-version`](../.flutter-version)).
2. A **Twilio account** with Conversations and/or Video enabled.
3. A **backend** that mints short-lived access tokens (JWT). The Flutter app must never contain your Twilio Account SID, Auth Token, or API keys.
4. For Conversations: at least one **Conversation** and your user added as a **Participant** ([REST API](https://www.twilio.com/docs/conversations-classic/api)).
5. For Video: a **room name** (or SID) your token is allowed to join ([access tokens for Video](https://www.twilio.com/docs/video/tutorials/user-identity-access-tokens)).

Token docs:

- Conversations: [Create tokens](https://www.twilio.com/docs/conversations-classic/create-tokens)
- Video: [User identity & access tokens](https://www.twilio.com/docs/video/tutorials/user-identity-access-tokens)

---

## 1. Add dependencies

Use a **git dependency** so pub can resolve the plugin’s internal `path: ../twilio_flutter_core`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  twilio_flutter_conversations:
    git:
      url: https://github.com/KazzyAPI/twilio-flutter-plugins.git
      path: packages/twilio_flutter_conversations
      ref: main   # or a release tag, e.g. twilio_flutter_conversations-v0.0.1

  # Optional:
  # twilio_flutter_video:
  #   git:
  #     url: https://github.com/KazzyAPI/twilio-flutter-plugins.git
  #     path: packages/twilio_flutter_video
  #     ref: main
```

When pub.dev publishing is enabled in the future, you may switch to `twilio_flutter_conversations: ^0.1.0` if that version is hosted there.

Use the latest versions shown on [pub.dev](https://pub.dev) for each package. Until first publish, use a Git dependency:

```yaml
dependencies:
  twilio_flutter_conversations:
    git:
      url: https://github.com/KazzyAPI/twilio-flutter-plugins.git
      path: packages/twilio_flutter_conversations
  twilio_flutter_video:
    git:
      url: https://github.com/KazzyAPI/twilio-flutter-plugins.git
      path: packages/twilio_flutter_video
```

Then:

```bash
flutter pub get
cd ios && pod install && cd ..
```

---

## 2. Platform configuration

### Android (`android/app/src/main/AndroidManifest.xml`)

Conversations needs network access. Video also needs camera and microphone at runtime **before** you call `session.start` / `connect`.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <!-- Video only -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <!-- … your application tag … -->
</manifest>
```

Request `CAMERA` and `RECORD_AUDIO` with [`permission_handler`](https://pub.dev/packages/permission_handler) (or your own platform channel) before starting Video.

**minSdkVersion:** 21 or higher (Twilio Conversations requirement).

### iOS (`ios/Runner/Info.plist`)

Video (and optional Conversations voice/media attachments):

```xml
<key>NSCameraUsageDescription</key>
<string>This app uses the camera for video calls.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app uses the microphone for calls and chat.</string>
```

For Video calls that continue in the background, enable **Background Modes → Audio** in Xcode for your Runner target.

After changing native deps, run `pod install` in `ios/`.

---

## 3. Mint tokens on your server

Your mobile app calls **your** HTTPS endpoint; the endpoint returns a JWT string.

Example response shape your app should expect:

```json
{ "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." }
```

Implement token creation with Twilio’s server SDKs (Node, Python, etc.) using the docs linked in [Before you begin](#before-you-begin). Refresh Conversations tokens when you receive `TokenAboutToExpire` or `TokenExpired` on the client (see section 4).

---

## 4. Twilio Conversations in your app

### 4.1 Imports and session

Create **one** `TwilioConversationsSession` for the chat feature (same instance when returning from background). Do not create a new session on every widget rebuild.

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twilio_flutter_conversations/twilio_flutter_conversations.dart';

class ChatController {
  ChatController(this.fetchConversationsToken);

  final Future<String> Function() fetchConversationsToken;

  final TwilioConversationsSession _session = TwilioConversationsSession();

  TwilioConversationsSession get session => _session;

  Future<void> open(String accessToken) {
    return _session.start(
      accessToken: accessToken,
      onEvent: _onEvent,
    );
  }

  Future<void> close() => _session.stop();

  Future<void> shutdown() => _session.dispose();

  void _onEvent(TwilioConversationsEvent event) {
    switch (event) {
      case ClientSynchronizationStatusUpdated(:final status):
        if (status == TwilioClientSynchronizationStatus.completed) {
          // SDK finished initial sync; cached conversations are usable.
        }
      case TokenAboutToExpire():
      case TokenExpired():
        unawaited(_refreshToken());
      case MessageAdded(:final message):
        debugPrint('New message: ${message.body}');
      case ConversationsError(:final exception):
        debugPrint('Conversations error: ${exception.code} ${exception.message}');
      default:
        break;
    }
  }

  Future<void> _refreshToken() async {
    final jwt = await fetchConversationsToken();
    await _session.client.updateAccessToken(jwt);
  }
}
```

### 4.2 Connect from your UI

```dart
Future<void> startChat(ChatController chat) async {
  final jwt = await chat.fetchConversationsToken();
  await chat.open(jwt);
}

Future<void> stopChat(ChatController chat) async {
  await chat.close();
}
```

### 4.3 Send a text message

You need a **Conversation SID** (`CH…`) from your backend or from `listConversations()` after sync completes.

```dart
await chat.session.client.sendMessage(
  conversationSid: 'CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
  body: 'Hello from Flutter',
  attributes: {
    'messageKind': 'user_text',
    'clientMessageId': 'msg-${DateTime.now().millisecondsSinceEpoch}',
  },
);
```

Optional explicit command (same behavior):

```dart
await chat.session.client.send(
  SendMessageCommand.create(
    conversationSid: 'CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    body: 'Hello from Flutter',
    attributes: {'messageKind': 'user_text'},
  ),
);
```

### 4.4 List conversations and load history

```dart
final conversations = await chat.session.client.listConversations();

final thread = await chat.session.client.getConversation(
  'CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
);

final messages = await chat.session.client.getLastMessages(
  conversationSid: thread.sid,
  count: 30,
);

final older = await chat.session.client.getMessagesBefore(
  conversationSid: thread.sid,
  beforeMessageIndex: messages.first.messageIndex,
  count: 30,
);
```

### 4.5 Typing indicator

```dart
await chat.session.client.sendTyping('CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
```

Listen for `TypingStarted` and `TypingEnded` in your `onEvent` handler.

### 4.6 Send a photo from disk

Validate path and MIME type before calling native code (or use `TwilioConversationsMediaPolicy` in tests). Example:

```dart
final sent = await chat.session.sendMedia(
  SendMediaMessageCommand.create(
    conversationSid: thread.sid,
    filePath: '/var/mobile/Containers/Data/photo.jpg',
    mimeType: 'image/jpeg',
    filename: 'photo.jpg',
    caption: 'Field photo',
  ),
);

final media = sent.primaryMedia!;
final temporaryUrl = await chat.session.client.getMediaTemporaryUrl(
  conversationSid: thread.sid,
  messageIndex: sent.messageIndex,
  mediaSid: media.sid,
);
// Download with package:http or dio using temporaryUrl.
```

### 4.7 Disconnect and dispose

| Call | When |
| --- | --- |
| `session.stop()` | User leaves chat UI; keeps Dart session object; disconnects native client |
| `session.dispose()` | Tear down the feature permanently; do not reuse the session |

If `session.start()` is still in flight, wait for it to finish or fail before calling `stop()` / `dispose()` (Video `stop()` during connect fails that connect with `internal`; see [APP_LIFECYCLE.md](APP_LIFECYCLE.md)).

---

## 5. Twilio Video in your app

This package connects to a room, publishes local audio/video (when permitted), and emits room/participant events. **Rendering** video on screen (PlatformViews) is not included yet; you still use this plugin for join/leave and track toggles.

### 5.1 Request permissions first (Video)

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> ensureVideoPermissions() async {
  final statuses = await [
    Permission.camera,
    Permission.microphone,
  ].request();
  if (statuses[Permission.camera] != PermissionStatus.granted ||
      statuses[Permission.microphone] != PermissionStatus.granted) {
    throw StateError('Camera and microphone are required for video.');
  }
}
```

### 5.2 Session and events

```dart
import 'package:flutter/foundation.dart';
import 'package:twilio_flutter_video/twilio_flutter_video.dart';

class VideoCallController {
  VideoCallController(this.fetchVideoToken);

  final Future<String> Function() fetchVideoToken;
  final TwilioVideoSession _session = TwilioVideoSession();

  Future<void> joinRoom({
    required String roomName,
    void Function(TwilioVideoEvent event)? onEvent,
  }) async {
    final token = await fetchVideoToken();
    await _session.start(
      accessToken: token,
      roomName: roomName,
      enableAudio: true,
      enableVideo: true,
      onEvent: onEvent ?? _defaultOnEvent,
    );
  }

  Future<void> leaveRoom() => _session.stop();

  Future<void> shutdown() => _session.dispose();

  Future<void> muteAudio(bool muted) =>
      _session.client.setLocalAudioEnabled(!muted);

  Future<void> muteVideo(bool muted) =>
      _session.client.setLocalVideoEnabled(!muted);

  void _defaultOnEvent(TwilioVideoEvent event) {
    switch (event) {
      case RoomConnected(:final room):
        debugPrint('Connected to ${room.name} (${room.sid})');
      case ParticipantConnected(:final participant):
        debugPrint('Participant joined: ${participant.identity}');
      case ParticipantDisconnected(:final participant):
        debugPrint('Participant left: ${participant.identity}');
      case DominantSpeakerChanged(:final participant):
        debugPrint(
          'Dominant speaker: ${participant?.identity ?? "(none)"}',
        );
      case VideoError(:final code, :final message):
        debugPrint('Video error: ${code.code} $message');
      default:
        break;
    }
  }
}
```

### 5.3 Join and leave from UI

```dart
final video = VideoCallController(yourBackend.fetchVideoAccessToken);

Future<void> onJoinPressed() async {
  await ensureVideoPermissions();
  await video.joinRoom(roomName: 'support-room-42');
}

Future<void> onLeavePressed() async {
  await video.leaveRoom();
}
```

### 5.4 Direct client (without session)

If you manage subscriptions yourself:

```dart
final client = TwilioVideoClient();

await client.connect(
  accessToken: token,
  roomName: 'support-room-42',
  enableAudio: true,
  enableVideo: true,
);

client.events.listen((event) {
  if (event is RoomDisconnected) {
    // UI: call ended
  }
});

await client.setLocalAudioEnabled(false);
await client.disconnect();
await client.dispose();
```

**One** `TwilioVideoClient` per Flutter engine. Registering a second event handler replaces the first.

### 5.5 Dominant speaker and existing participants

- Dominant speaker events apply to **Group** rooms; the plugin enables dominant speaker at connect.
- `DominantSpeakerChanged` may carry a **null** participant when nobody is dominant.
- When you join a room that already has participants, the plugin emits `ParticipantConnected` for each existing remote right after `RoomConnected`.

---

## 6. Use Conversations and Video together

Dependencies:

```yaml
dependencies:
  twilio_flutter_conversations: ^0.1.0
  twilio_flutter_video: ^0.1.0
```

Use **separate** session objects and **separate** tokens (Conversations JWT vs Video JWT). Your backend may expose one endpoint that returns both:

```json
{
  "conversationsToken": "eyJ…",
  "videoToken": "eyJ…"
}
```

```dart
final chat = ChatController(backend.fetchConversationsToken);
final video = VideoCallController(backend.fetchVideoToken);

await chat.open(await backend.fetchConversationsToken());
await ensureVideoPermissions();
await video.joinRoom(roomName: 'room-name');
```

Teardown:

```dart
await video.leaveRoom();
await chat.close();
```

---

## 7. Handle errors

Host calls throw `TwilioFlutterException` with a stable `TwilioErrorCode`:

| Code | Typical cause |
| --- | --- |
| `not_connected` | Method requires an active connection |
| `already_connected` | Second `connect` while connected or connecting |
| `sdk_failure` | Twilio native SDK rejected the operation |
| `invalid_argument` | Bad SID, empty body, etc. |
| `not_implemented` | Platform or API not available |
| `internal` | Client disposed, connect cancelled, or plugin timeout |

```dart
try {
  await chat.session.client.sendMessage(
    conversationSid: sid,
    body: body,
  );
} on TwilioFlutterException catch (e) {
  if (e.code == TwilioErrorCode.notConnected) {
    // Show "Reconnecting…" and retry after start()
  }
}
```

More scenarios: [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

---

## 8. Verify on a device

Conversations example (monorepo):

```bash
cd packages/twilio_flutter_conversations/example
flutter run \
  --dart-define=TWILIO_ACCESS_TOKEN='YOUR_CONVERSATIONS_JWT' \
  --dart-define=TWILIO_CONVERSATION_SID='CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

Run on a physical device when testing camera, microphone, or push-related behavior.

---

## 9. Reference

| Topic | Document |
| --- | --- |
| Conversations events | [EVENT_CATALOG.md](EVENT_CATALOG.md) |
| Supported APIs | [API_COVERAGE.md](API_COVERAGE.md) |
| SDK versions | [COMPATIBILITY.md](COMPATIBILITY.md) |
| App lifecycle / one client | [APP_LIFECYCLE.md](APP_LIFECYCLE.md) |
| Media limits | [MEDIA_SUPPORT.md](MEDIA_SUPPORT.md) |
| Architecture | [ARCHITECTURE.md](ARCHITECTURE.md) |

Shorter topic guides: [QUICKSTART.md](QUICKSTART.md) (Conversations), [VIDEO_QUICKSTART.md](VIDEO_QUICKSTART.md) (Video).
