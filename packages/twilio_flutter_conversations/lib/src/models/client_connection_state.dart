/// Twilio SDK network connection state (not Dart [TwilioConversationsConnectionState]).
enum TwilioClientConnectionState {
  unknown,
  connecting,
  connected,
  disconnected,
  denied,
  error,
  fatal,
}
