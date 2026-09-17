import 'package:twilio_flutter_core/twilio_flutter_core.dart';

/// Placeholder entry point for the Twilio Video Flutter plugin.
///
/// Room connect, tracks, and events will be added in a follow-up feature spec.
final class TwilioVideoClient {
  TwilioVideoClient._();

  /// Creates a client instance for the current Flutter engine.
  factory TwilioVideoClient.create() => TwilioVideoClient._();

  /// Throws until native Video bridges are implemented.
  Future<void> connect({
    required String accessToken,
    required String roomName,
  }) async {
    throw const TwilioFlutterException(
      code: TwilioErrorCode.notImplemented,
      message:
          'Twilio Video is not implemented yet. See packages/twilio_flutter_video/README.md.',
    );
  }
}
