import Foundation
import TwilioConversationsClient

/// Maps Twilio Conversations SDK models to pigeon DTOs.
final class ConversationsEventMapper {
  func mapSynchronizationStatus(
    _ status: TCHClientSynchronizationStatus
  ) -> PigeonClientSynchronizationStatus {
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

  func mapConnectionState(_ state: TCHClientConnectionState) -> PigeonClientConnectionState {
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
    case .fatal:
      return .fatal
    default:
      return .unknown
    }
  }

  func mapConversationSynchronizationStatus(
    _ status: TCHConversationSynchronizationStatus
  ) -> PigeonConversationSynchronizationStatus {
    switch status {
    case .none:
      return .none
    case .identifier:
      return .identifier
    case .metadata:
      return .metadata
    case .syncWindow:
      return .syncWindow
    case .all:
      return .all
    case .failed:
      return .failed
    default:
      return .unknown
    }
  }

  func mapConversation(_ conversation: TCHConversation) -> PigeonConversationDto {
    return PigeonConversationDto(
      sid: conversation.sid ?? "",
      uniqueName: conversation.uniqueName ?? "",
      friendlyName: conversation.friendlyName ?? "",
      lastMessageIndex: conversation.lastMessageIndex?.intValue
    )
  }

  func mapMessage(_ message: TCHMessage, conversationSid: String) -> PigeonMessageDto {
    let base = PigeonMessageDto(
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

  func mapParticipant(_ participant: TCHParticipant, conversationSid: String) -> PigeonParticipantDto {
    return PigeonParticipantDto(
      sid: participant.sid ?? "",
      identity: participant.identity ?? "",
      conversationSid: conversationSid
    )
  }

  func mapUser(_ user: TCHUser) -> PigeonUserDto {
    return PigeonUserDto(
      identity: user.identity ?? "",
      friendlyName: user.friendlyName
    )
  }

  func synchronizationEvent(
    status: TCHClientSynchronizationStatus
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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

  func connectionStateEvent(state: TCHClientConnectionState) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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

  func conversationAddedEvent(_ conversation: TCHConversation) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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
    reason: TCHConversationUpdateReason
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type: .conversationUpdated,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: mapConversation(conversation),
      message: nil,
      participant: nil,
      user: nil,
      updateReason: String(describing: reason),
      errorCode: nil,
      errorMessage: nil
    )
  }

  func conversationDeletedEvent(_ conversation: TCHConversation) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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
    reason: TCHMessageUpdateReason
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type: .messageUpdated,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: mapMessage(message, conversationSid: conversationSid),
      participant: nil,
      user: nil,
      updateReason: String(describing: reason),
      errorCode: nil,
      errorMessage: nil
    )
  }

  func messageDeletedEvent(
    _ message: TCHMessage,
    conversationSid: String
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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
    reason: TCHParticipantUpdateReason
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type: .participantUpdated,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: mapParticipant(participant, conversationSid: conversationSid),
      user: nil,
      updateReason: String(describing: reason),
      errorCode: nil,
      errorMessage: nil
    )
  }

  func participantDeletedEvent(
    _ participant: TCHParticipant,
    conversationSid: String
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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
  ) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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

  func userUpdatedEvent(_ user: TCHUser, reason: TCHUserUpdateReason) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type: .userUpdated,
      synchronizationStatus: nil,
      connectionState: nil,
      conversationSyncStatus: nil,
      conversation: nil,
      message: nil,
      participant: nil,
      user: mapUser(user),
      updateReason: String(describing: reason),
      errorCode: nil,
      errorMessage: nil
    )
  }

  func userSubscribedEvent(_ user: TCHUser) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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

  func userUnsubscribedEvent(_ user: TCHUser) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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

  func tokenAboutToExpireEvent() -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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

  func tokenExpiredEvent() -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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

  func notificationSubscribedEvent() -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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

  func errorEvent(code: String, message: String) -> PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
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
