/// Connected Programmable Video room metadata.
final class TwilioVideoRoom {
  const TwilioVideoRoom({
    required this.sid,
    required this.name,
    required this.state,
  });

  final String sid;
  final String name;
  final TwilioVideoRoomState state;
}

/// Room connection state from the Twilio Video SDK.
enum TwilioVideoRoomState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  disconnectedWithError,
}
