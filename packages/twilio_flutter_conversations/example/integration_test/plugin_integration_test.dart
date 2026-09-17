import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:twilio_flutter_conversations/twilio_flutter_conversations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TwilioConversationsClient exposes an event stream', (
    WidgetTester tester,
  ) async {
    final client = TwilioConversationsClient();
    expect(client.events, isA<Stream<TwilioConversationsEvent>>());
    await client.dispose();
  });
}
