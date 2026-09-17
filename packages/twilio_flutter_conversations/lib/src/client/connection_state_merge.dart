import '../models/client_connection_state.dart';
import '../models/connection_state.dart';

/// Merges native SDK connection signals into Dart client lifecycle state.
TwilioConversationsConnectionState mergeSdkConnectionState(
  TwilioConversationsConnectionState current,
  TwilioClientConnectionState sdkState,
) {
  if (current == TwilioConversationsConnectionState.disposed ||
      current == TwilioConversationsConnectionState.disconnecting) {
    return current;
  }
  switch (sdkState) {
    case TwilioClientConnectionState.connected:
      return TwilioConversationsConnectionState.connected;
    case TwilioClientConnectionState.connecting:
      if (current == TwilioConversationsConnectionState.disconnected) {
        return TwilioConversationsConnectionState.connecting;
      }
      return current;
    case TwilioClientConnectionState.disconnected:
    case TwilioClientConnectionState.denied:
    case TwilioClientConnectionState.error:
    case TwilioClientConnectionState.fatal:
      return TwilioConversationsConnectionState.disconnected;
    case TwilioClientConnectionState.unknown:
      return current;
  }
}
