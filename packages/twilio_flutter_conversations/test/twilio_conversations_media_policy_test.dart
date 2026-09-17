import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/media/twilio_conversations_media_policy.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

void main() {
  test('accepts supported mime types', () {
    expect(
      () => TwilioConversationsMediaPolicy.validateUpload(
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
      ),
      returnsNormally,
    );
  });

  test('rejects unknown mime types', () {
    expect(
      () => TwilioConversationsMediaPolicy.validateUpload(
        mimeType: 'application/x-msdownload',
        sizeBytes: 1024,
      ),
      throwsA(isA<TwilioFlutterException>()),
    );
  });

  test('rejects oversize uploads', () {
    expect(
      () => TwilioConversationsMediaPolicy.validateUpload(
        mimeType: 'image/png',
        sizeBytes: TwilioConversationsMediaPolicy.maxUploadBytes + 1,
      ),
      throwsA(isA<TwilioFlutterException>()),
    );
  });
}
