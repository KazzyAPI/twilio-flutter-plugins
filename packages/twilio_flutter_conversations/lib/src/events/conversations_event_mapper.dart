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

  TwilioConversationsEvent map(ConversationsNativeEvent nativeEvent) {
    switch (nativeEvent.type) {
      case ConversationsEventType.clientSynchronizationStatusUpdated:
        return ClientSynchronizationStatusUpdated(
          nativeEvent.synchronizationStatus.toPublic(),
        );
      case ConversationsEventType.connectionStateChanged:
        return ClientConnectionStateChanged(
          nativeEvent.connectionState.toPublic(),
        );
      case ConversationsEventType.conversationAdded:
        return ConversationAdded(_requireConversation(nativeEvent));
      case ConversationsEventType.conversationUpdated:
        return ConversationUpdated(
          _requireConversation(nativeEvent),
          nativeEvent.updateReason ?? '',
        );
      case ConversationsEventType.conversationDeleted:
        return ConversationDeleted(_requireConversation(nativeEvent));
      case ConversationsEventType.conversationSynchronizationUpdated:
        return ConversationSynchronizationUpdated(
          _requireConversation(nativeEvent),
          nativeEvent.conversationSyncStatus.toPublic(),
        );
      case ConversationsEventType.messageAdded:
        return MessageAdded(_requireMessage(nativeEvent));
      case ConversationsEventType.messageUpdated:
        return MessageUpdated(
          _requireMessage(nativeEvent),
          nativeEvent.updateReason ?? '',
        );
      case ConversationsEventType.messageDeleted:
        return MessageDeleted(_requireMessage(nativeEvent));
      case ConversationsEventType.participantAdded:
        return ParticipantAdded(_requireParticipant(nativeEvent));
      case ConversationsEventType.participantUpdated:
        return ParticipantUpdated(
          _requireParticipant(nativeEvent),
          nativeEvent.updateReason ?? '',
        );
      case ConversationsEventType.participantDeleted:
        return ParticipantDeleted(_requireParticipant(nativeEvent));
      case ConversationsEventType.typingStarted:
        return TypingStarted(_requireParticipant(nativeEvent));
      case ConversationsEventType.typingEnded:
        return TypingEnded(_requireParticipant(nativeEvent));
      case ConversationsEventType.userUpdated:
        return UserUpdated(
          _requireUser(nativeEvent),
          nativeEvent.updateReason ?? '',
        );
      case ConversationsEventType.userSubscribed:
        return UserSubscribed(_requireUser(nativeEvent));
      case ConversationsEventType.userUnsubscribed:
        return UserUnsubscribed(_requireUser(nativeEvent));
      case ConversationsEventType.tokenAboutToExpire:
        return const TokenAboutToExpire();
      case ConversationsEventType.tokenExpired:
        return const TokenExpired();
      case ConversationsEventType.notificationSubscribed:
        return const NotificationSubscribed();
      case ConversationsEventType.error:
        return ConversationsError(
          TwilioFlutterException.nativeError(
            errorCode: nativeEvent.errorCode,
            errorMessage: nativeEvent.errorMessage,
          ),
        );
    }
  }

  TwilioConversation _requireConversation(ConversationsNativeEvent event) {
    final conversation = event.conversation;
    if (conversation == null) {
      throw TwilioFlutterException.nativeError(
        errorCode: TwilioErrorCode.internal.code,
        errorMessage: '${event.type} event missing conversation payload.',
      );
    }
    return _dtoMapper.mapConversation(conversation);
  }

  TwilioMessage _requireMessage(ConversationsNativeEvent event) {
    final message = event.message;
    if (message == null) {
      throw TwilioFlutterException.nativeError(
        errorCode: TwilioErrorCode.internal.code,
        errorMessage: '${event.type} event missing message payload.',
      );
    }
    return _dtoMapper.mapMessage(message);
  }

  TwilioParticipant _requireParticipant(ConversationsNativeEvent event) {
    final participant = event.participant;
    if (participant == null) {
      throw TwilioFlutterException.nativeError(
        errorCode: TwilioErrorCode.internal.code,
        errorMessage: '${event.type} event missing participant payload.',
      );
    }
    return _dtoMapper.mapParticipant(participant);
  }

  TwilioUser _requireUser(ConversationsNativeEvent event) {
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
