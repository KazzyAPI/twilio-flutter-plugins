/// Media file attached to a Twilio Conversations message.
final class TwilioMediaAttachment {
  const TwilioMediaAttachment({
    required this.sid,
    required this.contentType,
    required this.filename,
    required this.sizeBytes,
  });

  final String sid;
  final String contentType;
  final String filename;
  final int sizeBytes;
}
