import 'package:twilio_flutter_core/twilio_flutter_core.dart';

import 'media_attachment.dart';
import 'message_content_type.dart';

/// Message metadata exposed to Flutter apps.
class TwilioMessage {
  const TwilioMessage({
    required this.sid,
    required this.conversationSid,
    required this.author,
    required this.body,
    required this.messageIndex,
    required this.dateCreated,
    required this.contentType,
    required this.mediaAttachments,
    required this.attributes,
  });

  final String sid;
  final String conversationSid;
  final String author;
  final String body;
  final int messageIndex;
  final DateTime dateCreated;
  final TwilioMessageContentType contentType;
  final List<TwilioMediaAttachment> mediaAttachments;
  final MessageAttributes attributes;

  /// First attached media, if any.
  TwilioMediaAttachment? get primaryMedia =>
      mediaAttachments.isEmpty ? null : mediaAttachments.first;
}
