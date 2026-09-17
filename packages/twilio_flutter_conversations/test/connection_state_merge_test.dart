import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/client/connection_state_merge.dart';
import 'package:twilio_flutter_conversations/src/models/client_connection_state.dart';
import 'package:twilio_flutter_conversations/src/models/connection_state.dart';

void main() {
  group('mergeSdkConnectionState', () {
    test('maps sdk disconnected to dart disconnected when connected', () {
      expect(
        mergeSdkConnectionState(
          TwilioConversationsConnectionState.connected,
          TwilioClientConnectionState.disconnected,
        ),
        TwilioConversationsConnectionState.disconnected,
      );
    });

    test('does not override disposing or disposed', () {
      expect(
        mergeSdkConnectionState(
          TwilioConversationsConnectionState.disconnecting,
          TwilioClientConnectionState.disconnected,
        ),
        TwilioConversationsConnectionState.disconnecting,
      );
      expect(
        mergeSdkConnectionState(
          TwilioConversationsConnectionState.disposed,
          TwilioClientConnectionState.connected,
        ),
        TwilioConversationsConnectionState.disposed,
      );
    });
  });
}
