# Twilio Video quickstart

Full install, permissions, and Conversations + Video together: **[CONSUMER_GUIDE.md](CONSUMER_GUIDE.md)**.

## Install

```yaml
dependencies:
  twilio_flutter_video: ^0.1.0
```

## Connect

```dart
import 'package:twilio_flutter_video/twilio_flutter_video.dart';

final session = TwilioVideoSession();

await session.start(
  accessToken: tokenFromBackend,
  roomName: 'my-room',
  onEvent: (event) {
    switch (event) {
      case RoomConnected(:final room):
        debugPrint('In room ${room.name} (${room.sid})');
      case ParticipantConnected(:final participant):
        debugPrint('Joined: ${participant.identity}');
      default:
        break;
    }
  },
);

// Later
await session.stop();
await session.dispose();
```

## Local tracks

Pass `enableAudio` / `enableVideo` to `connect` or `session.start`. After connect, toggle with:

```dart
await session.client.setLocalAudioEnabled(false);
await session.client.setLocalVideoEnabled(true);
```

## Rendering video

This release wires **connect, disconnect, events, and local track toggles**. Platform views for rendering local/remote video tracks are a follow-up; use native Twilio Video samples alongside this plugin until views land.

## Permissions

Grant camera and microphone **before** calling `connect` / `session.start`. If permissions are missing, local track creation fails and connect throws `sdk_failure`.

- **Android**: `CAMERA`, `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS`, and network permissions in your app manifest; request runtime permissions in the app.
- **iOS**: `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` in `Info.plist`; call `AVCaptureDevice` / `AVAudioSession` request APIs before connect. Enable **Audio** background mode if the call should continue in background.

## Dominant speaker

Supported for **Group** rooms when enabled at connect (the plugin enables this by default). Events may carry a **null** participant when no one is dominant.

## Existing participants

When you join a room that already has remotes, the plugin emits `ParticipantConnected` for each existing remote participant right after `RoomConnected` (Twilio does not fire join callbacks for participants already in the room).

## Docs

- [API coverage](./API_COVERAGE.md) (Video section)
- [Compatibility](./COMPATIBILITY.md) (SDK pins)
