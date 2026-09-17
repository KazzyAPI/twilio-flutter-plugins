/// Stable error codes surfaced across Twilio Flutter packages.
enum TwilioErrorCode {
  /// The native plugin is not available on this platform.
  notImplemented('not_implemented'),

  /// Invalid or missing arguments were passed to a method.
  invalidArgument('invalid_argument'),

  /// The Conversations client is not connected.
  notConnected('not_connected'),

  /// The Conversations client is already connected.
  alreadyConnected('already_connected'),

  /// A native Twilio SDK operation failed.
  sdkFailure('sdk_failure'),

  /// An internal plugin error occurred.
  internal('internal');

  const TwilioErrorCode(this.code);

  /// Machine-readable code string.
  final String code;

  /// Resolves a wire [raw] code to a known value.
  factory TwilioErrorCode.parse(String? raw) {
    if (raw == null || raw.isEmpty) {
      return TwilioErrorCode.internal;
    }
    for (final value in TwilioErrorCode.values) {
      if (value.code == raw) {
        return value;
      }
    }
    return TwilioErrorCode.sdkFailure;
  }
}
