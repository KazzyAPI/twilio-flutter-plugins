# twilio_flutter_video

Twilio Programmable Video for Flutter on iOS and Android.

Platform views for rendering video tracks are **not** included yet. The snippets below join a room, receive events, and toggle local audio/video.

**Full guide:** [Consumer guide](../../docs/CONSUMER_GUIDE.md#5-twilio-video-in-your-app).

## pub.dev

```yaml
dependencies:
  twilio_flutter_video: ^0.0.2
```

Latest version: [pub.dev/packages/twilio_flutter_video](https://pub.dev/packages/twilio_flutter_video).

## Permissions (before `session.start`)

Missing camera or microphone permission makes native connect throw `sdk_failure`.

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> ensureVideoPermissions() async {
  final statuses = await [Permission.camera, Permission.microphone].request();
  if (statuses[Permission.camera] != PermissionStatus.granted ||
      statuses[Permission.microphone] != PermissionStatus.granted) {
    throw StateError('Camera and microphone are required for video.');
  }
}
```

## Minimal join room

```dart
import 'package:twilio_flutter_video/twilio_flutter_video.dart';

final TwilioVideoSession session = TwilioVideoSession();

await ensureVideoPermissions();

await session.start(
  accessToken: tokenFromYourBackend,
  roomName: 'my-room',
  onEvent: (TwilioVideoEvent event) {
    switch (event) {
      case RoomConnected(:final room):
        print('In room ${room.sid}');
      case ParticipantConnected(:final participant):
        print('Joined: ${participant.identity}');
      default:
        break;
    }
  },
);

await session.client.setLocalAudioEnabled(false);
await session.stop();
```

## Maintainer docs

- Regenerate Pigeon: `dart run pigeon --input pigeons/video_api.dart`
- Local CI checks: `../../scripts/run_ci_checks.sh` from repo root
