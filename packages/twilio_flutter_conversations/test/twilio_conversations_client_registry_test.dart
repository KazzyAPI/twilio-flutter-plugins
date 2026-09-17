// ignore_for_file: non_constant_identifier_names

import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/client/twilio_conversations_client.dart';
import 'package:twilio_flutter_conversations/src/pigeon/conversations.pigeon.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

class _NoopHost extends TwilioConversationsHostApi {
  @override
  Future<void> connect(ConnectRequest arg_request) async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> updateAccessToken(String arg_accessToken) async {}

  @override
  Future<MessageDto> sendMessage(
    SendMessageRequest arg_request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ConversationDto>> listConversations() async => [];

  @override
  Future<ConversationDto> getConversation(
    String arg_sidOrUniqueName,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<MessageDto>> getLastMessages(
    GetMessagesRequest arg_request,
  ) async =>
      [];

  @override
  Future<List<MessageDto>> getMessagesBefore(
    GetMessagesBeforeRequest arg_request,
  ) async =>
      [];

  @override
  Future<MessageDto> sendMediaMessage(
    SendMediaMessageRequest arg_request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<String> getMediaTemporaryUrl(
    GetMediaTemporaryUrlRequest arg_request,
  ) async =>
      '';

  @override
  Future<List<ParticipantDto>> getParticipants(
    ConversationRequest arg_request,
  ) async =>
      [];

  @override
  Future<void> sendTyping(ConversationRequest arg_request) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('rejects a second live client', () async {
    final first = TwilioConversationsClient(
      registerSingleton: true,
      hostApi: _NoopHost(),
    );
    expect(
      () => TwilioConversationsClient(
        registerSingleton: true,
        hostApi: _NoopHost(),
      ),
      throwsA(isA<TwilioFlutterException>()),
    );
    await first.dispose();
  });
}
