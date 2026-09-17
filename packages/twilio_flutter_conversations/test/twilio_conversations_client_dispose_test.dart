// ignore_for_file: non_constant_identifier_names

import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/client/twilio_conversations_client.dart';
import 'package:twilio_flutter_conversations/src/models/connection_state.dart';
import 'package:twilio_flutter_conversations/src/pigeon/conversations.pigeon.dart';

class _SlowDisconnectHostApi extends TwilioConversationsHostApi {
  @override
  Future<void> connect(PigeonConnectRequest arg_request) async {}

  @override
  Future<void> disconnect() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> updateAccessToken(String arg_accessToken) async {}

  @override
  Future<PigeonMessageDto> sendMessage(
    PigeonSendMessageRequest arg_request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<PigeonConversationDto>> listConversations() async => [];

  @override
  Future<PigeonConversationDto> getConversation(String arg_sidOrUniqueName) async {
    throw UnimplementedError();
  }

  @override
  Future<List<PigeonMessageDto>> getLastMessages(
    PigeonGetMessagesRequest arg_request,
  ) async =>
      [];

  @override
  Future<List<PigeonParticipantDto>> getParticipants(
    PigeonConversationRequest arg_request,
  ) async =>
      [];

  @override
  Future<void> sendTyping(PigeonConversationRequest arg_request) async {}

  @override
  Future<List<PigeonMessageDto>> getMessagesBefore(
    PigeonGetMessagesBeforeRequest arg_request,
  ) async =>
      [];

  @override
  Future<PigeonMessageDto> sendMediaMessage(
    PigeonSendMediaMessageRequest arg_request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<String> getMediaTemporaryUrl(
    PigeonGetMediaTemporaryUrlRequest arg_request,
  ) async =>
      'https://example.com/media';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dispose stays disposed if disconnect completes late', () async {
    final client = TwilioConversationsClient(
      registerSingleton: false,
      hostApi: _SlowDisconnectHostApi(),
    );
    await client.connect(accessToken: 'jwt');
    final disposeFuture = client.dispose();
    expect(client.connectionState, TwilioConversationsConnectionState.disposed);
    await disposeFuture;
    expect(client.connectionState, TwilioConversationsConnectionState.disposed);
  });
}
