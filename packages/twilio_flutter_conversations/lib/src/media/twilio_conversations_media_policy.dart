import 'package:twilio_flutter_core/twilio_flutter_core.dart';

/// Twilio Conversations chat media limits for mobile uploads.
///
/// Authoritative list and channel limits:
/// https://www.twilio.com/docs/conversations-classic/media-support-conversations
/// https://www.twilio.com/docs/conversations/classic-media-limits
abstract final class TwilioConversationsMediaPolicy {
  /// Maximum upload size enforced before calling native SDK (150 MiB).
  static const int maxUploadBytes = 150 * 1024 * 1024;

  /// MIME types commonly accepted for **chat** participants in Conversations.
  ///
  /// Twilio may accept other types; the SDK validates again on upload. SMS/WhatsApp
  /// channels have stricter limits — use REST for cross-channel media when needed.
  static const Set<String> supportedMimeTypes = {
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/bmp',
    'image/webp',
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'video/x-msvideo',
    'audio/mpeg',
    'audio/mp4',
    'audio/wav',
    'audio/x-wav',
    'audio/ogg',
    'application/pdf',
    'text/plain',
    'text/vcard',
  };

  /// Returns supported MIME types sorted for display.
  static List<String> get supportedMimeTypesSorted =>
      supportedMimeTypes.toList()..sort();

  /// Validates [mimeType] and [sizeBytes] before a media upload.
  static void validateUpload({
    required String mimeType,
    required int sizeBytes,
  }) {
    final normalized = mimeType.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.invalidArgument,
        message: 'mimeType is required for media messages.',
      );
    }
    if (!supportedMimeTypes.contains(normalized)) {
      throw TwilioFlutterException(
        code: TwilioErrorCode.invalidArgument,
        message:
            'Unsupported mimeType "$mimeType" for Conversations chat media. '
            'See TwilioConversationsMediaPolicy.supportedMimeTypes and '
            'docs/MEDIA_SUPPORT.md.',
      );
    }
    if (sizeBytes <= 0) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.invalidArgument,
        message: 'Media file is empty.',
      );
    }
    if (sizeBytes > maxUploadBytes) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.invalidArgument,
        message: 'Media file exceeds the 150 MiB upload limit.',
      );
    }
  }
}
