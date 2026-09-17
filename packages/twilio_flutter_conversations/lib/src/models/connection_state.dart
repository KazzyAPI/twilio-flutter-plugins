/// Connection state of [TwilioConversationsClient].
enum TwilioConversationsConnectionState {
  /// No active native session; safe to call [TwilioConversationsClient.connect].
  /// Set after explicit [TwilioConversationsClient.disconnect] or native teardown
  /// following [ClientConnectionStateChanged] connection loss.
  disconnected,

  /// [TwilioConversationsClient.connect] is in flight.
  connecting,

  /// Native client exists; SDK may still be synchronizing.
  connected,

  /// [TwilioConversationsClient.disconnect] is in flight.
  disconnecting,

  /// [TwilioConversationsClient.dispose] completed; instance must not be reused.
  disposed,
}
