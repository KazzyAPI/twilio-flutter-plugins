package com.twilioflutter.conversations.bridge

import com.twilio.conversations.Conversation
import com.twilio.conversations.ConversationsClient
import com.twilio.conversations.Message
import com.twilio.conversations.Participant
import com.twilio.conversations.User
import com.twilioflutter.conversations.pigeon.ClientConnectionState
import com.twilioflutter.conversations.pigeon.ClientSynchronizationStatus
import com.twilioflutter.conversations.pigeon.ConversationDto
import com.twilioflutter.conversations.pigeon.ConversationSynchronizationStatus
import com.twilioflutter.conversations.pigeon.ConversationsEventType
import com.twilioflutter.conversations.pigeon.ConversationsNativeEvent
import com.twilioflutter.conversations.pigeon.MessageDto
import com.twilioflutter.conversations.pigeon.ParticipantDto
import com.twilioflutter.conversations.pigeon.UserDto

/** Maps Twilio Conversations SDK models to pigeon DTOs. */
class ConversationsEventMapper {
  fun mapSynchronizationStatus(
    status: ConversationsClient.SynchronizationStatus,
  ): ClientSynchronizationStatus {
    return when (status) {
      ConversationsClient.SynchronizationStatus.NONE,
      ConversationsClient.SynchronizationStatus.IDENTITIES,
      -> ClientSynchronizationStatus.STARTED
      ConversationsClient.SynchronizationStatus.CONVERSATIONS ->
        ClientSynchronizationStatus.CONVERSATIONSLISTCOMPLETED
      ConversationsClient.SynchronizationStatus.COMPLETED ->
        ClientSynchronizationStatus.COMPLETED
      ConversationsClient.SynchronizationStatus.FAILED ->
        ClientSynchronizationStatus.FAILED
      else -> ClientSynchronizationStatus.UNKNOWN
    }
  }

  fun mapConnectionState(
    state: ConversationsClient.ConnectionState,
  ): ClientConnectionState {
    return when (state) {
      ConversationsClient.ConnectionState.CONNECTING ->
        ClientConnectionState.CONNECTING
      ConversationsClient.ConnectionState.CONNECTED ->
        ClientConnectionState.CONNECTED
      ConversationsClient.ConnectionState.DISCONNECTED ->
        ClientConnectionState.DISCONNECTED
      ConversationsClient.ConnectionState.DENIED ->
        ClientConnectionState.DENIED
      ConversationsClient.ConnectionState.ERROR ->
        ClientConnectionState.ERROR
      ConversationsClient.ConnectionState.FATAL ->
        ClientConnectionState.FATAL
      else -> ClientConnectionState.UNKNOWN
    }
  }

  fun mapConversationSynchronizationStatus(
    conversation: Conversation,
  ): ConversationSynchronizationStatus {
    return when (conversation.synchronizationStatus) {
      Conversation.SynchronizationStatus.NONE ->
        ConversationSynchronizationStatus.NONE
      Conversation.SynchronizationStatus.IDENTIFIER ->
        ConversationSynchronizationStatus.IDENTIFIER
      Conversation.SynchronizationStatus.METADATA ->
        ConversationSynchronizationStatus.METADATA
      Conversation.SynchronizationStatus.SYNCWINDOW ->
        ConversationSynchronizationStatus.SYNCWINDOW
      Conversation.SynchronizationStatus.ALL ->
        ConversationSynchronizationStatus.ALL
      Conversation.SynchronizationStatus.FAILED ->
        ConversationSynchronizationStatus.FAILED
      else -> ConversationSynchronizationStatus.UNKNOWN
    }
  }

  fun mapConversation(conversation: Conversation): ConversationDto {
    return ConversationDto(
      sid = conversation.sid,
      uniqueName = conversation.uniqueName ?: "",
      friendlyName = conversation.friendlyName ?: "",
      lastMessageIndex = conversation.lastMessageIndex,
    )
  }

  fun mapMessage(message: Message, conversationSid: String): MessageDto {
    val base =
      MessageDto(
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

  fun mapParticipant(participant: Participant, conversationSid: String): ParticipantDto {
    return ParticipantDto(
      sid = participant.sid,
      identity = participant.identity ?: "",
      conversationSid = conversationSid,
    )
  }

  fun mapUser(user: User): UserDto {
    return UserDto(
      identity = user.identity ?: "",
      friendlyName = user.friendlyName,
    )
  }

  fun synchronizationEvent(
    status: ConversationsClient.SynchronizationStatus,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.CLIENTSYNCHRONIZATIONSTATUSUPDATED,
      synchronizationStatus = mapSynchronizationStatus(status),
    )
  }

  fun connectionStateEvent(
    state: ConversationsClient.ConnectionState,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.CONNECTIONSTATECHANGED,
      connectionState = mapConnectionState(state),
    )
  }

  fun conversationAddedEvent(conversation: Conversation): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.CONVERSATIONADDED,
      conversation = mapConversation(conversation),
    )
  }

  fun conversationUpdatedEvent(
    conversation: Conversation,
    reason: Conversation.UpdateReason,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.CONVERSATIONUPDATED,
      conversation = mapConversation(conversation),
      updateReason = reason.name,
    )
  }

  fun conversationDeletedEvent(conversation: Conversation): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.CONVERSATIONDELETED,
      conversation = mapConversation(conversation),
    )
  }

  fun conversationSynchronizationEvent(
    conversation: Conversation,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.CONVERSATIONSYNCHRONIZATIONUPDATED,
      conversation = mapConversation(conversation),
      conversationSyncStatus = mapConversationSynchronizationStatus(conversation),
    )
  }

  fun messageAddedEvent(message: Message, conversationSid: String): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.MESSAGEADDED,
      message = mapMessage(message, conversationSid),
    )
  }

  fun messageUpdatedEvent(
    message: Message,
    conversationSid: String,
    reason: Message.UpdateReason,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.MESSAGEUPDATED,
      message = mapMessage(message, conversationSid),
      updateReason = reason.name,
    )
  }

  fun messageDeletedEvent(
    message: Message,
    conversationSid: String,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.MESSAGEDELETED,
      message = mapMessage(message, conversationSid),
    )
  }

  fun participantAddedEvent(
    participant: Participant,
    conversationSid: String,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.PARTICIPANTADDED,
      participant = mapParticipant(participant, conversationSid),
    )
  }

  fun participantUpdatedEvent(
    participant: Participant,
    conversationSid: String,
    reason: Participant.UpdateReason,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.PARTICIPANTUPDATED,
      participant = mapParticipant(participant, conversationSid),
      updateReason = reason.name,
    )
  }

  fun participantDeletedEvent(
    participant: Participant,
    conversationSid: String,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.PARTICIPANTDELETED,
      participant = mapParticipant(participant, conversationSid),
    )
  }

  fun typingStartedEvent(
    participant: Participant,
    conversationSid: String,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.TYPINGSTARTED,
      participant = mapParticipant(participant, conversationSid),
    )
  }

  fun typingEndedEvent(
    participant: Participant,
    conversationSid: String,
  ): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.TYPINGENDED,
      participant = mapParticipant(participant, conversationSid),
    )
  }

  fun userUpdatedEvent(user: User, reason: User.UpdateReason): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.USERUPDATED,
      user = mapUser(user),
      updateReason = reason.name,
    )
  }

  fun userSubscribedEvent(user: User): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.USERSUBSCRIBED,
      user = mapUser(user),
    )
  }

  fun userUnsubscribedEvent(user: User): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.USERUNSUBSCRIBED,
      user = mapUser(user),
    )
  }

  fun tokenAboutToExpireEvent(): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.TOKENABOUTTOEXPIRE,
    )
  }

  fun tokenExpiredEvent(): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.TOKENEXPIRED,
    )
  }

  fun notificationSubscribedEvent(): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.NOTIFICATIONSUBSCRIBED,
    )
  }

  fun errorEvent(code: String, message: String): ConversationsNativeEvent {
    return ConversationsNativeEvent(
      type = ConversationsEventType.ERROR,
      errorCode = code,
      errorMessage = message,
    )
  }
}
