package com.twilioflutter.conversations.bridge

import com.twilio.conversations.Conversation
import com.twilio.conversations.ConversationListener
import com.twilio.conversations.Message
import com.twilio.conversations.Participant
import com.twilioflutter.conversations.pigeon.PigeonConversationsNativeEvent

/** Retains and removes per-conversation SDK listeners. */
class ConversationListenerRegistry(
  private val eventMapper: ConversationsEventMapper,
  private val emit: (PigeonConversationsNativeEvent) -> Unit,
) {
  private val listeners = linkedMapOf<String, ConversationListener>()

  fun register(conversation: Conversation) {
    val sid = conversation.sid
    if (listeners.containsKey(sid)) {
      return
    }

    val listener =
      object : ConversationListener {
        override fun onMessageAdded(message: Message) {
          emit(eventMapper.messageAddedEvent(message, sid))
        }

        override fun onMessageUpdated(message: Message, reason: Message.UpdateReason) {
          emit(eventMapper.messageUpdatedEvent(message, sid, reason))
        }

        override fun onMessageDeleted(message: Message) {
          emit(eventMapper.messageDeletedEvent(message, sid))
        }

        override fun onParticipantAdded(participant: Participant) {
          emit(eventMapper.participantAddedEvent(participant, sid))
        }

        override fun onParticipantUpdated(
          participant: Participant,
          reason: Participant.UpdateReason,
        ) {
          emit(eventMapper.participantUpdatedEvent(participant, sid, reason))
        }

        override fun onParticipantDeleted(participant: Participant) {
          emit(eventMapper.participantDeletedEvent(participant, sid))
        }

        override fun onTypingStarted(
          conversation: Conversation,
          participant: Participant,
        ) {
          emit(eventMapper.typingStartedEvent(participant, sid))
        }

        override fun onTypingEnded(
          conversation: Conversation,
          participant: Participant,
        ) {
          emit(eventMapper.typingEndedEvent(participant, sid))
        }

        override fun onSynchronizationChanged(conversation: Conversation) {
          emit(eventMapper.conversationSynchronizationEvent(conversation))
        }
      }

    conversation.addListener(listener)
    listeners[sid] = listener
  }

  fun unregister(conversationSid: String, conversation: Conversation?) {
    val listener = listeners.remove(conversationSid) ?: return
    conversation?.removeListener(listener)
  }

  fun clear(conversationsBySid: Map<String, Conversation>) {
    for ((sid, listener) in listeners) {
      conversationsBySid[sid]?.removeListener(listener)
    }
    listeners.clear()
  }
}
