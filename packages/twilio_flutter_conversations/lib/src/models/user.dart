/// A Twilio Conversations user identity surfaced from SDK events.
final class TwilioUser {
  const TwilioUser({
    required this.identity,
    this.friendlyName = '',
  });

  final String identity;
  final String friendlyName;
}
