package com.twilioflutter.conversations.bridge

import com.twilio.conversations.Conversation
import com.twilio.conversations.ConversationsClient
import com.twilio.conversations.Message
import com.twilio.conversations.Participant
import com.twilio.conversations.User
import com.twilioflutter.conversations.pigeon.PigeonClientConnectionState
import com.twilioflutter.conversations.pigeon.PigeonClientSynchronizationStatus
import com.twilioflutter.conversations.pigeon.PigeonConversationDto
import com.twilioflutter.conversations.pigeon.PigeonConversationSynchronizationStatus
import com.twilioflutter.conversations.pigeon.PigeonConversationsEventType
import com.twilioflutter.conversations.pigeon.PigeonConversationsNativeEvent
import com.twilioflutter.conversations.pigeon.PigeonMessageDto
import com.twilioflutter.conversations.pigeon.PigeonParticipantDto
import com.twilioflutter.conversations.pigeon.PigeonUserDto

/** Maps Twilio Conversations SDK models to pigeon DTOs. */
class ConversationsEventMapper {
  fun mapSynchronizationStatus(
    status: ConversationsClient.SynchronizationStatus,
  ): PigeonClientSynchronizationStatus {
    return when (status) {
      ConversationsClient.SynchronizationStatus.NONE,
      ConversationsClient.SynchronizationStatus.IDENTITIES,
      -> PigeonClientSynchronizationStatus.STARTED
      ConversationsClient.SynchronizationStatus.CONVERSATIONS ->
        PigeonClientSynchronizationStatus.CONVERSATIONSLISTCOMPLETED
      ConversationsClient.SynchronizationStatus.COMPLETED ->
        PigeonClientSynchronizationStatus.COMPLETED
      ConversationsClient.SynchronizationStatus.FAILED ->
        PigeonClientSynchronizationStatus.FAILED
      else -> PigeonClientSynchronizationStatus.UNKNOWN
    }
  }

  fun mapConnectionState(
    state: ConversationsClient.ConnectionState,
  ): PigeonClientConnectionState {
    return when (state) {
      ConversationsClient.ConnectionState.CONNECTING ->
        PigeonClientConnectionState.CONNECTING
      ConversationsClient.ConnectionState.CONNECTED ->
        PigeonClientConnectionState.CONNECTED
      ConversationsClient.ConnectionState.DISCONNECTED ->
        PigeonClientConnectionState.DISCONNECTED
      ConversationsClient.ConnectionState.DENIED ->
        PigeonClientConnectionState.DENIED
      ConversationsClient.ConnectionState.ERROR ->
        PigeonClientConnectionState.ERROR
      ConversationsClient.ConnectionState.FATAL ->
        PigeonClientConnectionState.FATAL
      else -> PigeonClientConnectionState.UNKNOWN
    }
  }

  fun mapConversationSynchronizationStatus(
    conversation: Conversation,
  ): PigeonConversationSynchronizationStatus {
    return when (conversation.synchronizationStatus) {
      Conversation.SynchronizationStatus.NONE ->
        PigeonConversationSynchronizationStatus.NONE
      Conversation.SynchronizationStatus.IDENTIFIER ->
        PigeonConversationSynchronizationStatus.IDENTIFIER
      Conversation.SynchronizationStatus.METADATA ->
        PigeonConversationSynchronizationStatus.METADATA
      Conversation.SynchronizationStatus.SYNCWINDOW ->
        PigeonConversationSynchronizationStatus.SYNCWINDOW
      Conversation.SynchronizationStatus.ALL ->
        PigeonConversationSynchronizationStatus.ALL
      Conversation.SynchronizationStatus.FAILED ->
        PigeonConversationSynchronizationStatus.FAILED
      else -> PigeonConversationSynchronizationStatus.UNKNOWN
    }
  }

  fun mapConversation(conversation: Conversation): PigeonConversationDto {
    return PigeonConversationDto(
      sid = conversation.sid,
      uniqueName = conversation.uniqueName ?: "",
      friendlyName = conversation.friendlyName ?: "",
      lastMessageIndex = conversation.lastMessageIndex,
    )
  }

  fun mapMessage(message: Message, conversationSid: String): PigeonMessageDto {
    val base =
      PigeonMessageDto(
        sid = message.sid,
        conversationSid = conversationSid,
        author = message.author ?: "",
        body = message.body ?: "",
        messageIndex = message.messageIndex,
        dateCreatedEpochMs = message.dateCreatedAsDate?.time ?: 0L,
        attributesJson = MessageAttributesJson.jsonFromMessage(message),
      )
    return MessageMediaMapping.enrichMessageDto(base, message)
  }

  fun mapParticipant(participant: Participant, conversationSid: String): PigeonParticipantDto {
    return PigeonParticipantDto(
      sid = participant.sid,
      identity = participant.identity ?: "",
      conversationSid = conversationSid,
    )
  }

  fun mapUser(user: User): PigeonUserDto {
    return PigeonUserDto(
      identity = user.identity ?: "",
      friendlyName = user.friendlyName,
    )
  }

  fun synchronizationEvent(
    status: ConversationsClient.SynchronizationStatus,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.CLIENTSYNCHRONIZATIONSTATUSUPDATED,
      synchronizationStatus = mapSynchronizationStatus(status),
    )
  }

  fun connectionStateEvent(
    state: ConversationsClient.ConnectionState,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.CONNECTIONSTATECHANGED,
      connectionState = mapConnectionState(state),
    )
  }

  fun conversationAddedEvent(conversation: Conversation): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.CONVERSATIONADDED,
      conversation = mapConversation(conversation),
    )
  }

  fun conversationUpdatedEvent(
    conversation: Conversation,
    reason: Conversation.UpdateReason,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.CONVERSATIONUPDATED,
      conversation = mapConversation(conversation),
      updateReason = reason.name,
    )
  }

  fun conversationDeletedEvent(conversation: Conversation): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.CONVERSATIONDELETED,
      conversation = mapConversation(conversation),
    )
  }

  fun conversationSynchronizationEvent(
    conversation: Conversation,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.CONVERSATIONSYNCHRONIZATIONUPDATED,
      conversation = mapConversation(conversation),
      conversationSyncStatus = mapConversationSynchronizationStatus(conversation),
    )
  }

  fun messageAddedEvent(message: Message, conversationSid: String): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.MESSAGEADDED,
      message = mapMessage(message, conversationSid),
    )
  }

  fun messageUpdatedEvent(
    message: Message,
    conversationSid: String,
    reason: Message.UpdateReason,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.MESSAGEUPDATED,
      message = mapMessage(message, conversationSid),
      updateReason = reason.name,
    )
  }

  fun messageDeletedEvent(
    message: Message,
    conversationSid: String,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.MESSAGEDELETED,
      message = mapMessage(message, conversationSid),
    )
  }

  fun participantAddedEvent(
    participant: Participant,
    conversationSid: String,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.PARTICIPANTADDED,
      participant = mapParticipant(participant, conversationSid),
    )
  }

  fun participantUpdatedEvent(
    participant: Participant,
    conversationSid: String,
    reason: Participant.UpdateReason,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.PARTICIPANTUPDATED,
      participant = mapParticipant(participant, conversationSid),
      updateReason = reason.name,
    )
  }

  fun participantDeletedEvent(
    participant: Participant,
    conversationSid: String,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.PARTICIPANTDELETED,
      participant = mapParticipant(participant, conversationSid),
    )
  }

  fun typingStartedEvent(
    participant: Participant,
    conversationSid: String,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.TYPINGSTARTED,
      participant = mapParticipant(participant, conversationSid),
    )
  }

  fun typingEndedEvent(
    participant: Participant,
    conversationSid: String,
  ): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.TYPINGENDED,
      participant = mapParticipant(participant, conversationSid),
    )
  }

  fun userUpdatedEvent(user: User, reason: User.UpdateReason): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.USERUPDATED,
      user = mapUser(user),
      updateReason = reason.name,
    )
  }

  fun userSubscribedEvent(user: User): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.USERSUBSCRIBED,
      user = mapUser(user),
    )
  }

  fun userUnsubscribedEvent(user: User): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.USERUNSUBSCRIBED,
      user = mapUser(user),
    )
  }

  fun tokenAboutToExpireEvent(): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.TOKENABOUTTOEXPIRE,
    )
  }

  fun tokenExpiredEvent(): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.TOKENEXPIRED,
    )
  }

  fun notificationSubscribedEvent(): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.NOTIFICATIONSUBSCRIBED,
    )
  }

  fun errorEvent(code: String, message: String): PigeonConversationsNativeEvent {
    return PigeonConversationsNativeEvent(
      type = PigeonConversationsEventType.ERROR,
      errorCode = code,
      errorMessage = message,
    )
  }
}
