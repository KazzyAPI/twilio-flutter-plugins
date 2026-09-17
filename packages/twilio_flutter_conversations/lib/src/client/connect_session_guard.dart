/// Guards stale [TwilioConversationsClient.connect] completions on the Dart side.
class ConnectSessionGuard {
  var _generation = 0;

  /// Starts a connect attempt; returns a token compared when the host call completes.
  int beginConnect() => _generation;

  /// Invalidates in-flight connect attempts (disconnect, dispose).
  void invalidate() {
    _generation += 1;
  }

  /// Returns true when [token] is still the active connect generation.
  bool isActive(int token) => token == _generation;
}
