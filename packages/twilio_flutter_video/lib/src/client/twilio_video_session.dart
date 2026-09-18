import 'dart:async';

import 'package:twilio_flutter_core/twilio_flutter_core.dart';

import '../events/video_event.dart';
import '../models/connection_state.dart';
import 'twilio_video_client.dart';

/// App-level helper: one client, one event subscription, connect/disconnect API.
final class TwilioVideoSession {
  TwilioVideoSession({TwilioVideoClient? client})
      : client = client ?? TwilioVideoClient();

  final TwilioVideoClient client;

  StreamSubscription<TwilioVideoEvent>? _eventsSubscription;
  var _started = false;

  bool get isStarted => _started;

  Future<void> start({
    required String accessToken,
    required String roomName,
    required void Function(TwilioVideoEvent event) onEvent,
    void Function(Object error, StackTrace stackTrace)? onEventError,
    bool enableAudio = true,
    bool enableVideo = true,
  }) async {
    await _eventsSubscription?.cancel();
    _eventsSubscription = onEventError == null
        ? client.events.listen(onEvent)
        : client.events.listen(onEvent, onError: onEventError);

    switch (client.connectionState) {
      case TwilioVideoConnectionState.disposed:
        throw const TwilioFlutterException(
          code: TwilioErrorCode.internal,
          message: 'Client has been disposed.',
        );
      case TwilioVideoConnectionState.disconnecting:
        throw const TwilioFlutterException(
          code: TwilioErrorCode.internal,
          message: 'Client is disconnecting; wait before reconnecting.',
        );
      case TwilioVideoConnectionState.connected:
      case TwilioVideoConnectionState.connecting:
        _started = true;
        return;
      case TwilioVideoConnectionState.disconnected:
        break;
    }

    await client.connect(
      accessToken: accessToken,
      roomName: roomName,
      enableAudio: enableAudio,
      enableVideo: enableVideo,
    );
    _started = true;
  }

  Future<void> stop() async {
    await _eventsSubscription?.cancel();
    _eventsSubscription = null;
    await client.disconnect();
    _started = false;
  }

  Future<void> dispose() async {
    await stop();
    await client.dispose();
  }
}
