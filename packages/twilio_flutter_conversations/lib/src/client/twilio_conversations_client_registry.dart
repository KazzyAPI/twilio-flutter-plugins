import 'twilio_conversations_client.dart';
import '../models/connection_state.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

/// Ensures at most one live [TwilioConversationsClient] per Flutter engine.
abstract final class TwilioConversationsClientRegistry {
  static TwilioConversationsClient? _current;

  /// The active client for this engine, if any.
  static TwilioConversationsClient? get current => _current;

  /// Called when a client is constructed (production factory only).
  static void attach(TwilioConversationsClient client) {
    final existing = _current;
    if (existing != null &&
        existing != client &&
        existing.connectionState !=
            TwilioConversationsConnectionState.disposed) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.internal,
        message:
            'Only one TwilioConversationsClient per Flutter engine. Reuse '
            'TwilioConversationsSession or dispose the existing client first.',
      );
    }
    _current = client;
  }

  /// Called when a client is disposed.
  static void detach(TwilioConversationsClient client) {
    if (_current == client) {
      _current = null;
    }
  }
}
