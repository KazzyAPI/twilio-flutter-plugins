import Foundation
import TwilioConversationsClient

/// Maps Twilio Conversations SDK models to pigeon DTOs.
final class ConversationsEventMapper {
  func mapSynchronizationStatus(
    _ status: TCHClientSynchronizationStatus
  ) -> ClientSynchronizationStatus {
    switch status {
    case .started:
      return .started
    case .conversationsListCompleted:
      return .conversationsListCompleted
    case .completed:
      return .completed
    case .failed:
      return .failed
    default:
      return .unknown
    }
  }

  func mapConnectionState(_ state: TCHClientConnectionState) -> ClientConnectionState {
    switch state {
    case .connecting:
      return .connecting
    case .connected:
      return .connected
    case .disconnected:
      return .disconnected
    case .denied:
      return .denied
    case .error:
      return .error
    @unknown default:
      if String(describing: state).lowercased().contains("fatal") {
        return .fatal
      }
      return .unknown
    }
  }

  func mapConversationSynchronizationStatus(
    _ status: TCHConversationSynchronizationStatus
  ) -> ConversationSynchronizationStatus {
    switch status {
    case .none:
      return .none
    case .identifier:
      return .identifier
    case .metadata:
      return .metadata
    case .all:
      return .all
    case .failed:
      return .failed
    default:
      return .unknown
    }
  }

  func mapConversation(_ conversation: TCHConversation) -> ConversationDto {
    return ConversationDto(
      sid: conversation.sid ?? "",
      uniqueName: conversation.uniqueName ?? "",
      friendlyName: conversation.friendlyName ?? "",
      lastMessageIndex: conversation.lastMessageIndex?.intValue
    )
  }

  func mapMessage(_ message: TCHMessage, conversationSid: String) -> MessageDto {
    let base = MessageDto(
      sid: message.sid ?? "",
      conversationSid: conversationSid,
      author: message.author ?? "",
      body: message.body ?? "",
      messageIndex: Int64(message.index),
      dateCreatedEpochMs: Int64((message.dateCreatedAsDate?.timeIntervalSince1970 ?? 0) * 1000),
      contentType: .text,
      mediaAttachments: nil,
      attributesJson: MessageAttributesJson.json(from: message)
    )
    return MessageMediaMapping.enrichMessageDto(base: base, message: message)
  }

  func mapParticipant(_ participant: TCHParticipant, conversationSid: String) -> ParticipantDto {
    return ParticipantDto(
      sid: participant.sid ?? "",
      identity: participant.identity ?? "",
      conversationSid: conversationSid
    )
  }

  func mapUser(_ user: TCHUser) -> UserDto {
    return UserDto(
      identity: user.identity ?? "",
      friendlyName: user.friendlyName
    )
  }

  func synchronizationEvent(
    status: TCHClientSynchronizationStatus
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .clientSynchronizationStatusUpdated,
      synchronizationStatus: mapSynchronizationStatus(status),
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func connectionStateEvent(state: TCHClientConnectionState) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .connectionStateChanged,
      synchronizationStatus: nil,
      connectionState: mapConnectionState(state),
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func conversationAddedEvent(_ conversation: TCHConversation) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .conversationAdded,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: mapConversation(conversation),
      message: nil,
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func conversationUpdatedEvent(
    _ conversation: TCHConversation,
    updated: TCHConversationUpdate
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .conversationUpdated,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: mapConversation(conversation),
      message: nil,
      participant: nil,
      user: nil,
      updateReason: String(describing: updated),
      errorCode: nil,
      errorMessage: nil
    )
  }

  func conversationDeletedEvent(_ conversation: TCHConversation) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .conversationDeleted,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: mapConversation(conversation),
      message: nil,
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func conversationSynchronizationEvent(
    _ conversation: TCHConversation
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .conversationSynchronizationUpdated,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: mapConversationSynchronizationStatus(
        conversation.synchronizationStatus
      ),
      conversation: mapConversation(conversation),
      message: nil,
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func messageAddedEvent(
    _ message: TCHMessage,
    conversationSid: String
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .messageAdded,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: mapMessage(message, conversationSid: conversationSid),
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func messageUpdatedEvent(
    _ message: TCHMessage,
    conversationSid: String,
    updated: TCHMessageUpdate
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .messageUpdated,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: mapMessage(message, conversationSid: conversationSid),
      participant: nil,
      user: nil,
      updateReason: String(describing: updated),
      errorCode: nil,
      errorMessage: nil
    )
  }

  func messageDeletedEvent(
    _ message: TCHMessage,
    conversationSid: String
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .messageDeleted,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: mapMessage(message, conversationSid: conversationSid),
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func participantAddedEvent(
    _ participant: TCHParticipant,
    conversationSid: String
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .participantAdded,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: mapParticipant(participant, conversationSid: conversationSid),
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func participantUpdatedEvent(
    _ participant: TCHParticipant,
    conversationSid: String,
    updated: TCHParticipantUpdate
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .participantUpdated,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: mapParticipant(participant, conversationSid: conversationSid),
      user: nil,
      updateReason: String(describing: updated),
      errorCode: nil,
      errorMessage: nil
    )
  }

  func participantDeletedEvent(
    _ participant: TCHParticipant,
    conversationSid: String
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .participantDeleted,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: mapParticipant(participant, conversationSid: conversationSid),
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func typingStartedEvent(
    _ participant: TCHParticipant,
    conversationSid: String
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .typingStarted,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: mapParticipant(participant, conversationSid: conversationSid),
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func typingEndedEvent(
    _ participant: TCHParticipant,
    conversationSid: String
  ) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .typingEnded,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: mapParticipant(participant, conversationSid: conversationSid),
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func userUpdatedEvent(_ user: TCHUser, updated: TCHUserUpdate) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .userUpdated,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: nil,
      user: mapUser(user),
      updateReason: String(describing: updated),
      errorCode: nil,
      errorMessage: nil
    )
  }

  func userSubscribedEvent(_ user: TCHUser) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .userSubscribed,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: nil,
      user: mapUser(user),
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func userUnsubscribedEvent(_ user: TCHUser) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .userUnsubscribed,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: nil,
      user: mapUser(user),
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func tokenAboutToExpireEvent() -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .tokenAboutToExpire,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func tokenExpiredEvent() -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .tokenExpired,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func notificationSubscribedEvent() -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .notificationSubscribed,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func errorEvent(code: String, message: String) -> ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type: .error,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: nil,
      user: nil,
      updateReason: nil,
      errorCode: code,
      errorMessage: message
    )
  }
}
