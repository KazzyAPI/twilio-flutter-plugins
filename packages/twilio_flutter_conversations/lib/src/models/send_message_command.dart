import 'package:twilio_flutter_core/twilio_flutter_core.dart';

/// Command to send a text message to a conversation.
final class SendMessageCommand {
  SendMessageCommand._({
    required this.conversationSid,
    required this.body,
    required this.attributes,
  });

  /// Creates a send-message command.
  factory SendMessageCommand.create({
    required String conversationSid,
    required String body,
    Map<String, Object?> attributes = const {},
  }) {
    return SendMessageCommand._(
      conversationSid: conversationSid,
      body: body,
      attributes: MessageAttributes.fromMap(attributes),
    );
  }

  /// Target conversation SID.
  final String conversationSid;

  /// Message body text.
  final String body;

  /// Custom metadata (never null; empty when omitted).
  final MessageAttributes attributes;
}
