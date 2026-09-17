/// A participant in a Twilio conversation.
final class TwilioParticipant {
  const TwilioParticipant({
    required this.sid,
    required this.identity,
    required this.conversationSid,
  });

  final String sid;
  final String identity;
  final String conversationSid;
}
