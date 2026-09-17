import 'package:test/test.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

void main() {
  group('TwilioErrorCode', () {
    test('parse resolves known codes', () {
      expect(
        TwilioErrorCode.parse('not_connected'),
        TwilioErrorCode.notConnected,
      );
      expect(TwilioErrorCode.parse('unknown'), TwilioErrorCode.sdkFailure);
      expect(TwilioErrorCode.parse(null), TwilioErrorCode.internal);
    });
  });

  group('TwilioFlutterException', () {
    test('toString includes code and message', () {
      const exception = TwilioFlutterException(
        code: TwilioErrorCode.sdkFailure,
        message: 'Token rejected',
      );
      expect(
        exception.toString(),
        'TwilioFlutterException(sdk_failure): Token rejected',
      );
    });

    test('nativeError factory parses codes', () {
      final exception = TwilioFlutterException.nativeError(
        errorCode: 'not_connected',
        errorMessage: 'offline',
      );
      expect(exception.code, TwilioErrorCode.notConnected);
      expect(exception.message, 'offline');
    });
  });
}
