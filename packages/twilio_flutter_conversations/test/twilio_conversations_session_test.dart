// Pigeon-generated method signatures use arg_* parameter names.
// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/pigeon/conversations.pigeon.dart';
import 'package:twilio_flutter_conversations/twilio_flutter_conversations.dart';

import 'fake_conversations_host_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TwilioConversationsSession', () {
    test('start connects and marks session started', () async {
      final host = FakeConversationsHostApi();
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: host,
      );
      final session = TwilioConversationsSession(client: client);

      await session.start(accessToken: 'jwt', onEvent: (_) {});

      expect(session.isStarted, isTrue);
      expect(host.connectCount, 1);
      expect(
        client.connectionState,
        TwilioConversationsConnectionState.connected,
      );
      await session.dispose();
    });

    test('second start replaces subscription and refreshes token when connected',
        () async {
      var tokenUpdates = 0;
      final host = _TrackingHostApi(
        onUpdateToken: () => tokenUpdates++,
      );
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: host,
      );
      final session = TwilioConversationsSession(client: client);

      await session.start(accessToken: 'jwt-1', onEvent: (_) {});
      await session.start(accessToken: 'jwt-2', onEvent: (_) {});

      expect(host.connectCount, 1);
      expect(tokenUpdates, 1);
      await session.dispose();
    });

    test('sendMedia returns message when file exists', () async {
      final tempDir =
          await Directory.systemTemp.createTemp('twilio_media_test');
      final file = File('${tempDir.path}/photo.jpg');
      await file.writeAsBytes(List<int>.filled(64, 1));

      final host = _MediaHostApi();
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: host,
      );
      final session = TwilioConversationsSession(client: client);
      await session.start(accessToken: 'jwt', onEvent: (_) {});

      final message = await session.sendMedia(
        SendMediaMessageCommand.create(
          conversationSid: 'CHxxx',
          filePath: file.path,
          mimeType: 'image/jpeg',
          filename: 'photo.jpg',
        ),
      );

      expect(message.conversationSid, 'CHxxx');
      expect(host.sendMediaCount, 1);
      await session.dispose();
      await tempDir.delete(recursive: true);
    });

    test('sendMedia throws when file is missing', () async {
      final client = TwilioConversationsClient(
        registerSingleton: false,
        hostApi: FakeConversationsHostApi(),
      );
      final session = TwilioConversationsSession(client: client);
      await session.start(accessToken: 'jwt', onEvent: (_) {});

      await expectLater(
        session.sendMedia(
          SendMediaMessageCommand.create(
            conversationSid: 'CHxxx',
            filePath: '/no/such/file.jpg',
            mimeType: 'image/jpeg',
            filename: 'file.jpg',
          ),
        ),
        throwsA(
          isA<TwilioFlutterException>().having(
            (e) => e.code,
            'code',
            TwilioErrorCode.invalidArgument,
          ),
        ),
      );
      await session.dispose();
    });
  });
}

class _TrackingHostApi extends FakeConversationsHostApi {
  _TrackingHostApi({required this.onUpdateToken});

  final void Function() onUpdateToken;

  @override
  Future<void> updateAccessToken(String arg_accessToken) async {
    onUpdateToken();
  }
}

class _MediaHostApi extends FakeConversationsHostApi {
  var sendMediaCount = 0;

  @override
  Future<PigeonMessageDto> sendMediaMessage(
    PigeonSendMediaMessageRequest arg_request,
  ) async {
    sendMediaCount++;
    return PigeonMessageDto(
      sid: 'IMmedia',
      conversationSid: arg_request.conversationSid,
      author: 'test_user',
      body: '',
      messageIndex: 2,
      dateCreatedEpochMs: DateTime.utc(2024, 1, 2).millisecondsSinceEpoch,
      contentType: PigeonMessageContentType.media,
    );
  }
}
