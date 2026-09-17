// Pigeon-generated method signatures use arg_* parameter names.
// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/client/twilio_conversations_client.dart';
import 'package:twilio_flutter_conversations/src/models/send_media_message_command.dart';
import 'package:twilio_flutter_conversations/src/models/connection_state.dart';
import 'package:twilio_flutter_conversations/src/pigeon/conversations.pigeon.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

import 'fake_conversations_host_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TwilioConversationsClient', () {
    test('connect forwards access token to host api', () async {
      ConnectRequest? capturedRequest;
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: FakeConversationsHostApi(
          onConnect: (request) => capturedRequest = request,
        ),
      );

      await client.connect(accessToken: 'jwt-token');
      expect(capturedRequest?.accessToken, 'jwt-token');
      expect(client.connectionState, TwilioConversationsConnectionState.connected);
      await client.dispose();
    });

    test('rejects second connect while connected', () async {
      final host = FakeConversationsHostApi();
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: host,
      );
      await client.connect(accessToken: 'jwt-token');

      await expectLater(
        client.connect(accessToken: 'jwt-token-2'),
        throwsA(isA<TwilioFlutterException>()),
      );
      expect(host.connectCount, 1);
      await client.dispose();
    });

    test('sendMessage requires connected state', () async {
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: FakeConversationsHostApi(),
      );
      await expectLater(
        client.sendMessage(conversationSid: 'CH', body: 'x'),
        throwsA(
          isA<TwilioFlutterException>().having(
            (e) => e.code,
            'code',
            TwilioErrorCode.notConnected,
          ),
        ),
      );
      await client.dispose();
    });

    test('sendMessage returns mapped message metadata when connected', () async {
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: FakeConversationsHostApi(),
      );
      await client.connect(accessToken: 'jwt');
      final message = await client.sendMessage(
        conversationSid: 'CHxxx',
        body: 'Hello',
        attributes: {'k': 'v'},
      );

      expect(message.conversationSid, 'CHxxx');
      expect(message.attributes.entries['k'], 'v');
      await client.dispose();
    });

    test('sdk connection loss tears down native client for reconnect', () async {
      final host = FakeConversationsHostApi();
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: host,
      );
      await client.connect(accessToken: 'jwt');
      client.ingestNativeEventForTesting(
        ConversationsNativeEvent(
          type: ConversationsEventType.connectionStateChanged,
          connectionState: ClientConnectionState.disconnected,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        client.connectionState,
        TwilioConversationsConnectionState.disconnected,
      );
      expect(host.disconnectCount, 1);
      await client.connect(accessToken: 'jwt-2');
      expect(host.connectCount, 2);
      await client.dispose();
    });

    test('ignores sdk reconnect signals until dart connect after loss', () async {
      final host = FakeConversationsHostApi();
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: host,
      );
      await client.connect(accessToken: 'jwt');
      client.ingestNativeEventForTesting(
        ConversationsNativeEvent(
          type: ConversationsEventType.connectionStateChanged,
          connectionState: ClientConnectionState.disconnected,
        ),
      );
      client.ingestNativeEventForTesting(
        ConversationsNativeEvent(
          type: ConversationsEventType.connectionStateChanged,
          connectionState: ClientConnectionState.connecting,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        client.connectionState,
        TwilioConversationsConnectionState.disconnected,
      );
      await client.connect(accessToken: 'jwt-2');
      expect(host.connectCount, 2);
      await client.dispose();
    });

    test('getMessagesBefore and getMediaTemporaryUrl when connected', () async {
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: FakeConversationsHostApi(),
      );
      await client.connect(accessToken: 'jwt');
      final url = await client.getMediaTemporaryUrl(
        conversationSid: 'CHxxx',
        messageIndex: 1,
        mediaSid: 'MExxx',
      );
      expect(url, 'https://example.com/media');
      final messages = await client.getMessagesBefore(
        conversationSid: 'CHxxx',
        beforeMessageIndex: 10,
      );
      expect(messages, isEmpty);
      await client.dispose();
    });

    test('sendMediaMessage validates file and returns message', () async {
      final tempDir =
          await Directory.systemTemp.createTemp('twilio_client_media');
      final file = File('${tempDir.path}/pic.png');
      await file.writeAsBytes(List<int>.filled(32, 2));

      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: FakeConversationsHostApi(),
      );
      await client.connect(accessToken: 'jwt');
      final message = await client.sendMediaMessage(
        SendMediaMessageCommand.create(
          conversationSid: 'CHxxx',
          filePath: file.path,
          mimeType: 'image/png',
          filename: 'pic.png',
        ),
      );
      expect(message.conversationSid, 'CHxxx');
      await client.dispose();
      await tempDir.delete(recursive: true);
    });

    test('maps platform exceptions to TwilioFlutterException', () async {
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: _ThrowingHostApi(),
      );

      expect(
        () => client.connect(accessToken: 'bad'),
        throwsA(
          isA<TwilioFlutterException>().having(
            (error) => error.code,
            'code',
            TwilioErrorCode.sdkFailure,
          ),
        ),
      );
      expect(
        client.connectionState,
        TwilioConversationsConnectionState.disconnected,
      );
      await client.dispose();
    });
  });
}

class _ThrowingHostApi extends TwilioConversationsHostApi {
  @override
  Future<void> connect(ConnectRequest arg_request) {
    throw PlatformException(code: 'sdk_failure', message: 'Rejected');
  }

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
    return MessageDto(
      sid: 'IMmedia',
      conversationSid: arg_request.conversationSid,
      author: 'test_user',
      body: arg_request.caption ?? '',
      messageIndex: 2,
      dateCreatedEpochMs: DateTime.utc(2024, 1, 2).millisecondsSinceEpoch,
      contentType: MessageContentType.media,
    );
  }

  @override
  Future<String> getMediaTemporaryUrl(
    GetMediaTemporaryUrlRequest arg_request,
  ) async =>
      'https://example.com/media';
}
