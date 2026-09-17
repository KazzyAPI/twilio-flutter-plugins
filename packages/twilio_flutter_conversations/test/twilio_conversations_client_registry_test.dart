// ignore_for_file: non_constant_identifier_names

import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/client/twilio_conversations_client.dart';
import 'package:twilio_flutter_conversations/src/pigeon/conversations.pigeon.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

class _NoopHost extends TwilioConversationsHostApi {
  @override
  Future<void> connect(PigeonConnectRequest arg_request) async {}

  @override
  Future<void> disconnect() async {}

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
  Future<PigeonConversationDto> getConversation(
    String arg_sidOrUniqueName,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<PigeonMessageDto>> getLastMessages(
    PigeonGetMessagesRequest arg_request,
  ) async =>
      [];

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
      '';

  @override
  Future<List<PigeonParticipantDto>> getParticipants(
    PigeonConversationRequest arg_request,
  ) async =>
      [];

  @override
  Future<void> sendTyping(PigeonConversationRequest arg_request) async {}
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
