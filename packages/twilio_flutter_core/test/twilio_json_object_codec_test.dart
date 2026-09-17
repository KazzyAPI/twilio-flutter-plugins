import 'package:test/test.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

void main() {
  group('MessageAttributes', () {
    test('empty factory has no wire json', () {
      expect(MessageAttributes.empty().toWireJson(), isNull);
    });

    test('fromMap round-trips through codec', () {
      final attributes = MessageAttributes.fromMap({
        'priority': 'high',
        'retryCount': 2,
      });
      final encoded = TwilioJsonObjectCodec.encode(attributes);
      final decoded = TwilioJsonObjectCodec.decode(encoded);
      expect(decoded.entries['priority'], 'high');
    });
  });
}
