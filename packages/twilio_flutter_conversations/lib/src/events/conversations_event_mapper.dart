import 'package:twilio_flutter_core/twilio_flutter_core.dart';

import '../extensions/pigeon_enum_extensions.dart';
import '../mappers/pigeon_dto_mapper.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/participant.dart';
import '../models/user.dart';
import '../pigeon/conversations.pigeon.dart';
import 'conversations_event.dart';

/// Maps pigeon native events to public [TwilioConversationsEvent] types.
class ConversationsEventMapper {
  ConversationsEventMapper({PigeonDtoMapper? dtoMapper})
      : _dtoMapper = dtoMapper ?? const PigeonDtoMapper();

  final PigeonDtoMapper _dtoMapper;

  TwilioConversationsEvent map(PigeonConversationsNativeEvent nativeEvent) {
    switch (nativeEvent.type) {
      case PigeonConversationsEventType.clientSynchronizationStatusUpdated:
        return ClientSynchronizationStatusUpdated(
          nativeEvent.synchronizationStatus.toPublic(),
        );
      case PigeonConversationsEventType.connectionStateChanged:
        return ClientConnectionStateChanged(
          nativeEvent.connectionState.toPublic(),
        );
      case PigeonConversationsEventType.conversationAdded:
        return ConversationAdded(_requireConversation(nativeEvent));
      case PigeonConversationsEventType.conversationUpdated:
        return ConversationUpdated(
          _requireConversation(nativeEvent),
          nativeEvent.updateReason ?? '',
        );
      case PigeonConversationsEventType.conversationDeleted:
        return ConversationDeleted(_requireConversation(nativeEvent));
      case PigeonConversationsEventType.conversationSynchronizationUpdated:
        return ConversationSynchronizationUpdated(
          _requireConversation(nativeEvent),
          nativeEvent.conversationSyncStatus.toPublic(),
        );
      case PigeonConversationsEventType.messageAdded:
        return MessageAdded(_requireMessage(nativeEvent));
      case PigeonConversationsEventType.messageUpdated:
        return MessageUpdated(
          _requireMessage(nativeEvent),
          nativeEvent.updateReason ?? '',
        );
      case PigeonConversationsEventType.messageDeleted:
        return MessageDeleted(_requireMessage(nativeEvent));
      case PigeonConversationsEventType.participantAdded:
        return ParticipantAdded(_requireParticipant(nativeEvent));
      case PigeonConversationsEventType.participantUpdated:
        return ParticipantUpdated(
          _requireParticipant(nativeEvent),
          nativeEvent.updateReason ?? '',
        );
      case PigeonConversationsEventType.participantDeleted:
        return ParticipantDeleted(_requireParticipant(nativeEvent));
      case PigeonConversationsEventType.typingStarted:
        return TypingStarted(_requireParticipant(nativeEvent));
      case PigeonConversationsEventType.typingEnded:
        return TypingEnded(_requireParticipant(nativeEvent));
      case PigeonConversationsEventType.userUpdated:
        return UserUpdated(
          _requireUser(nativeEvent),
          nativeEvent.updateReason ?? '',
        );
      case PigeonConversationsEventType.userSubscribed:
        return UserSubscribed(_requireUser(nativeEvent));
      case PigeonConversationsEventType.userUnsubscribed:
        return UserUnsubscribed(_requireUser(nativeEvent));
      case PigeonConversationsEventType.tokenAboutToExpire:
        return const TokenAboutToExpire();
      case PigeonConversationsEventType.tokenExpired:
        return const TokenExpired();
      case PigeonConversationsEventType.notificationSubscribed:
        return const NotificationSubscribed();
      case PigeonConversationsEventType.error:
        return ConversationsError(
          TwilioFlutterException.nativeError(
            errorCode: nativeEvent.errorCode,
            errorMessage: nativeEvent.errorMessage,
          ),
        );
    }
  }

  TwilioConversation _requireConversation(PigeonConversationsNativeEvent event) {
    final conversation = event.conversation;
    if (conversation == null) {
      throw TwilioFlutterException.nativeError(
        errorCode: TwilioErrorCode.internal.code,
        errorMessage: '${event.type} event missing conversation payload.',
      );
    }
    return _dtoMapper.mapConversation(conversation);
  }

  TwilioMessage _requireMessage(PigeonConversationsNativeEvent event) {
    final message = event.message;
    if (message == null) {
      throw TwilioFlutterException.nativeError(
        errorCode: TwilioErrorCode.internal.code,
        errorMessage: '${event.type} event missing message payload.',
      );
    }
    return _dtoMapper.mapMessage(message);
  }

  TwilioParticipant _requireParticipant(PigeonConversationsNativeEvent event) {
    final participant = event.participant;
    if (participant == null) {
      throw TwilioFlutterException.nativeError(
        errorCode: TwilioErrorCode.internal.code,
        errorMessage: '${event.type} event missing participant payload.',
      );
    }
    return _dtoMapper.mapParticipant(participant);
  }

  TwilioUser _requireUser(PigeonConversationsNativeEvent event) {
    final user = event.user;
    if (user == null) {
      throw TwilioFlutterException.nativeError(
        errorCode: TwilioErrorCode.internal.code,
        errorMessage: '${event.type} event missing user payload.',
      );
    }
    return _dtoMapper.mapUser(user);
  }
}
