import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';
import 'package:twilio_flutter_video/twilio_flutter_video.dart';

void main() {
  test('connect is not implemented yet', () async {
    final client = TwilioVideoClient.create();
    await expectLater(
      client.connect(accessToken: 'jwt', roomName: 'room'),
      throwsA(isA<TwilioFlutterException>()),
    );
  });
}
