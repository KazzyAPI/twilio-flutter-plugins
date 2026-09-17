import 'package:twilio_flutter_core/twilio_flutter_core.dart';

/// Sends a local file as a Twilio Conversations media message.
final class SendMediaMessageCommand {
  SendMediaMessageCommand._({
    required this.conversationSid,
    required this.filePath,
    required this.mimeType,
    required this.filename,
    required this.caption,
    required this.attributes,
  });

  factory SendMediaMessageCommand.create({
    required String conversationSid,
    required String filePath,
    required String mimeType,
    required String filename,
    String caption = '',
    Map<String, Object?> attributes = const {},
  }) {
    return SendMediaMessageCommand._(
      conversationSid: conversationSid,
      filePath: filePath,
      mimeType: mimeType,
      filename: filename,
      caption: caption,
      attributes: MessageAttributes.fromMap(attributes),
    );
  }

  final String conversationSid;
  final String filePath;
  final String mimeType;
  final String filename;
  final String caption;
  final MessageAttributes attributes;
}
