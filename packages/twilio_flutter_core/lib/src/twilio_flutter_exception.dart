import 'twilio_error_code.dart';

/// Exception thrown when a Twilio Flutter plugin operation fails.
class TwilioFlutterException implements Exception {
  /// Creates an exception with a stable [code], human-readable [message], and
  /// optional structured [details].
  const TwilioFlutterException({
    required this.code,
    required this.message,
    this.details = const {},
  });

  /// Builds an exception from native error envelope fields.
  factory TwilioFlutterException.nativeError({
    required String? errorCode,
    required String? errorMessage,
    Map<String, Object?> details = const {},
  }) {
    return TwilioFlutterException(
      code: TwilioErrorCode.parse(errorCode),
      message: errorMessage ?? 'Unknown SDK error',
      details: details,
    );
  }

  /// Stable error code for programmatic handling.
  final TwilioErrorCode code;

  /// Human-readable description of the failure.
  final String message;

  /// Structured details from the native layer (empty when omitted).
  final Map<String, Object?> details;

  @override
  String toString() {
    return 'TwilioFlutterException(${code.code}): $message';
  }
}
