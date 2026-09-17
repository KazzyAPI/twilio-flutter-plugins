/// Conversation metadata exposed to Flutter apps.
class TwilioConversation {
  /// Creates conversation metadata.
  const TwilioConversation({
    required this.sid,
    required this.uniqueName,
    required this.friendlyName,
    this.lastMessageIndex,
  });

  /// Twilio conversation SID.
  final String sid;

  /// Unique name, if set on the server.
  final String uniqueName;

  /// Human-readable title.
  final String friendlyName;

  /// Index of the last message in the conversation, if known.
  final int? lastMessageIndex;
}
