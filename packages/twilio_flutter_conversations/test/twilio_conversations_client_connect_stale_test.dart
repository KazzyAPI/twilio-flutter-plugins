// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/client/twilio_conversations_client.dart';
import 'package:twilio_flutter_conversations/src/models/connection_state.dart';
import 'package:twilio_flutter_conversations/src/pigeon/conversations.pigeon.dart';

class _DelayedConnectHostApi extends TwilioConversationsHostApi {
  final completer = Completer<void>();

  @override
  Future<void> connect(ConnectRequest arg_request) => completer.future;

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
  Future<ConversationDto> getConversation(String arg_sidOrUniqueName) async {
    throw UnimplementedError();
  }

  @override
  Future<List<MessageDto>> getLastMessages(
    GetMessagesRequest arg_request,
  ) async =>
      [];

  @override
  Future<List<ParticipantDto>> getParticipants(
    ConversationRequest arg_request,
  ) async =>
      [];

  @override
  Future<void> sendTyping(ConversationRequest arg_request) async {}

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
      'https://example.com/media';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stale connect after dispose does not change disposed state', () async {
    final host = _DelayedConnectHostApi();
    final client = TwilioConversationsClient(
      registerSingleton: false,
      hostApi: host,
    );

    final connectFuture = client.connect(accessToken: 'jwt');
    await client.dispose();

    expect(client.connectionState, TwilioConversationsConnectionState.disposed);
    host.completer.complete();
    await connectFuture;

    expect(client.connectionState, TwilioConversationsConnectionState.disposed);
  });
}
