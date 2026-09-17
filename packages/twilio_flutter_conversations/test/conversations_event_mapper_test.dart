import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/events/conversations_event.dart';
import 'package:twilio_flutter_conversations/src/events/conversations_event_mapper.dart';
import 'package:twilio_flutter_conversations/src/models/client_synchronization_status.dart';
import 'package:twilio_flutter_conversations/src/pigeon/conversations.pigeon.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

void main() {
  final mapper = ConversationsEventMapper();

  group('ConversationsEventMapper', () {
    test('maps synchronization status updates', () {
      final event = mapper.map(
        PigeonConversationsNativeEvent(
          type: PigeonConversationsEventType
              .clientSynchronizationStatusUpdated,
          synchronizationStatus: PigeonClientSynchronizationStatus.completed,
        ),
      );

      expect(event, isA<ClientSynchronizationStatusUpdated>());
      expect(
        (event as ClientSynchronizationStatusUpdated).status,
        TwilioClientSynchronizationStatus.completed,
      );
    });

    test('maps conversation added events', () {
      final event = mapper.map(
        PigeonConversationsNativeEvent(
          type: PigeonConversationsEventType.conversationAdded,
          conversation: PigeonConversationDto(
            sid: 'CHxxx',
            uniqueName: 'general',
            friendlyName: 'General',
            lastMessageIndex: 3,
          ),
        ),
      );

      expect(event, isA<ConversationAdded>());
      final conversation = (event as ConversationAdded).conversation;
      expect(conversation.sid, 'CHxxx');
      expect(conversation.lastMessageIndex, 3);
    });

    test('maps message added events', () {
      final event = mapper.map(
        PigeonConversationsNativeEvent(
          type: PigeonConversationsEventType.messageAdded,
          message: PigeonMessageDto(
            sid: 'IMxxx',
            conversationSid: 'CHxxx',
            author: 'user_1',
            body: 'Hello',
            messageIndex: 4,
            dateCreatedEpochMs: 1700000000000,
            contentType: PigeonMessageContentType.text,
          ),
        ),
      );

      expect(event, isA<MessageAdded>());
      final message = (event as MessageAdded).message;
      expect(message.author, 'user_1');
      expect(message.messageIndex, 4);
    });

    test('maps token lifecycle events', () {
      expect(
        mapper.map(
          PigeonConversationsNativeEvent(
            type: PigeonConversationsEventType.tokenAboutToExpire,
          ),
        ),
        isA<TokenAboutToExpire>(),
      );
      expect(
        mapper.map(
          PigeonConversationsNativeEvent(
            type: PigeonConversationsEventType.tokenExpired,
          ),
        ),
        isA<TokenExpired>(),
      );
    });

    test('maps connection and participant events', () {
      final connection = mapper.map(
        PigeonConversationsNativeEvent(
          type: PigeonConversationsEventType.connectionStateChanged,
          connectionState: PigeonClientConnectionState.disconnected,
        ),
      );
      expect(connection, isA<ClientConnectionStateChanged>());

      final participant = mapper.map(
        PigeonConversationsNativeEvent(
          type: PigeonConversationsEventType.participantAdded,
          participant: PigeonParticipantDto(
            sid: 'MBxxx',
            conversationSid: 'CHxxx',
            identity: 'user_1',
          ),
        ),
      );
      expect(participant, isA<ParticipantAdded>());
    });

    test('maps message update/delete and typing events', () {
      expect(
        mapper.map(
          PigeonConversationsNativeEvent(
            type: PigeonConversationsEventType.messageUpdated,
            message: PigeonMessageDto(
              sid: 'IMxxx',
              conversationSid: 'CHxxx',
              author: 'a',
              body: 'b',
              messageIndex: 1,
              dateCreatedEpochMs: 1,
              contentType: PigeonMessageContentType.text,
            ),
          ),
        ),
        isA<MessageUpdated>(),
      );
      expect(
        mapper.map(
          PigeonConversationsNativeEvent(
            type: PigeonConversationsEventType.typingStarted,
            participant: PigeonParticipantDto(
              sid: 'MBxxx',
              conversationSid: 'CHxxx',
              identity: 'user_1',
            ),
          ),
        ),
        isA<TypingStarted>(),
      );
    });

    test('maps sdk error events', () {
      final event = mapper.map(
        PigeonConversationsNativeEvent(
          type: PigeonConversationsEventType.error,
          errorCode: TwilioErrorCode.notConnected.code,
          errorMessage: 'Client is not connected',
        ),
      );

      expect(event, isA<ConversationsError>());
      final error = (event as ConversationsError).exception;
      expect(error.code, TwilioErrorCode.notConnected);
      expect(error.message, 'Client is not connected');
    });
  });
}
