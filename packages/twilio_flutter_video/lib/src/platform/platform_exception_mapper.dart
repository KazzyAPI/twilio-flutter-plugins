import 'package:flutter/services.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

class PlatformExceptionMapper {
  TwilioFlutterException map(PlatformException exception) {
    final details =
        exception.details is Map<String, Object?>
            ? Map<String, Object?>.from(
                exception.details as Map<String, Object?>,
              )
            : <String, Object?>{};
    return TwilioFlutterException(
      code: TwilioErrorCode.parse(exception.code),
      message: exception.message ?? 'Native platform call failed',
      details: details,
    );
  }
}
