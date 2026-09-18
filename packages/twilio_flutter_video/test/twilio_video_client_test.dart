import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_video/twilio_flutter_video.dart';

import 'fake_video_host_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TwilioVideoClient', () {
    test('connect forwards token and room to host', () async {
      final host = FakeVideoHostApi();
      final client = TwilioVideoClient(hostApi: host);

      await client.connect(
        accessToken: 'jwt',
        roomName: 'daily-standup',
        enableAudio: false,
        enableVideo: true,
      );

      expect(host.lastConnectRequest?.accessToken, 'jwt');
      expect(host.lastConnectRequest?.roomName, 'daily-standup');
      expect(host.lastConnectRequest?.enableAudio, isFalse);
      expect(host.lastConnectRequest?.enableVideo, isTrue);
      expect(client.connectionState, TwilioVideoConnectionState.connected);
    });

    test('second connect throws already_connected', () async {
      final client = TwilioVideoClient(hostApi: FakeVideoHostApi());
      await client.connect(accessToken: 'jwt', roomName: 'room');

      await expectLater(
        client.connect(accessToken: 'jwt', roomName: 'room2'),
        throwsA(
          isA<TwilioFlutterException>().having(
            (e) => e.code,
            'code',
            TwilioErrorCode.alreadyConnected,
          ),
        ),
      );
    });

    test('connect failure resets connection state', () async {
      final host = FakeVideoHostApi()..connectShouldThrow = true;
      final client = TwilioVideoClient(hostApi: host);

      await expectLater(
        client.connect(accessToken: 'jwt', roomName: 'room'),
        throwsA(isA<TwilioFlutterException>()),
      );
      expect(client.connectionState, TwilioVideoConnectionState.disconnected);
    });

    test('disconnect calls host and updates state', () async {
      final host = FakeVideoHostApi();
      final client = TwilioVideoClient(hostApi: host);
      await client.connect(accessToken: 'jwt', roomName: 'room');

      await client.disconnect();

      expect(host.disconnectCalls, 1);
      expect(client.connectionState, TwilioVideoConnectionState.disconnected);
    });

    test('setLocalAudioEnabled requires connection', () async {
      final client = TwilioVideoClient(hostApi: FakeVideoHostApi());

      await expectLater(
        client.setLocalAudioEnabled(true),
        throwsA(
          isA<TwilioFlutterException>().having(
            (e) => e.code,
            'code',
            TwilioErrorCode.notConnected,
          ),
        ),
      );
    });
  });
}
