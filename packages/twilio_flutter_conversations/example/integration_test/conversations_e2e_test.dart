import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:twilio_flutter_conversations/twilio_flutter_conversations.dart';

const _accessToken = String.fromEnvironment('TWILIO_ACCESS_TOKEN');
const _conversationSid = String.fromEnvironment('TWILIO_CONVERSATION_SID');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('connects and receives synchronization events when token provided', (
    WidgetTester tester,
  ) async {
    if (_accessToken.isEmpty) {
      // ignore: avoid_print
      print('Skipping E2E: set --dart-define=TWILIO_ACCESS_TOKEN');
      return;
    }

    final client = TwilioConversationsClient();
    final statuses = <TwilioClientSynchronizationStatus>[];
    final sub = client.events.listen((event) {
      if (event is ClientSynchronizationStatusUpdated) {
        statuses.add(event.status);
      }
    });

    await client.connect(accessToken: _accessToken);
    expect(client.connectionState, TwilioConversationsConnectionState.connected);

    await Future<void>.delayed(const Duration(seconds: 15));
    expect(statuses, isNotEmpty);

    if (_conversationSid.isNotEmpty) {
      final message = await client.sendMessage(
        conversationSid: _conversationSid,
        body: 'twilio_flutter_conversations e2e ping',
        attributes: {'source': 'integration_test'},
      );
      expect(message.body, contains('e2e'));
    }

    await client.disconnect();
    expect(client.connectionState, TwilioConversationsConnectionState.disconnected);
    await sub.cancel();
    await client.dispose();
  });
}
