import 'package:flutter/services.dart';
import 'package:twilio_flutter_video/src/pigeon/video.pigeon.dart';

class FakeVideoHostApi extends TwilioVideoHostApi {
  VideoConnectRequest? lastConnectRequest;
  var disconnectCalls = 0;
  var connectShouldThrow = false;
  var connectDelay = Duration.zero;

  @override
  Future<void> connect(VideoConnectRequest request) async {
    lastConnectRequest = request;
    if (connectDelay > Duration.zero) {
      await Future<void>.delayed(connectDelay);
    }
    if (connectShouldThrow) {
      throw PlatformException(code: 'sdk_failure', message: 'connect failed');
    }
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
  }

  @override
  Future<void> setLocalAudioEnabled(bool enabled) async {}

  @override
  Future<void> setLocalVideoEnabled(bool enabled) async {}
}
