/// Remote or local participant in a Video room.
final class TwilioVideoParticipant {
  const TwilioVideoParticipant({
    required this.sid,
    required this.identity,
  });

  final String sid;
  final String identity;
}
