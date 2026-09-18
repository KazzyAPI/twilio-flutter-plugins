package com.twilioflutter.conversations.bridge

import com.twilioflutter.conversations.pigeon.ConnectRequest
import com.twilioflutter.conversations.pigeon.ConversationDto
import com.twilioflutter.conversations.pigeon.ConversationRequest
import com.twilioflutter.conversations.pigeon.GetMediaTemporaryUrlRequest
import com.twilioflutter.conversations.pigeon.GetMessagesBeforeRequest
import com.twilioflutter.conversations.pigeon.GetMessagesRequest
import com.twilioflutter.conversations.pigeon.MessageDto
import com.twilioflutter.conversations.pigeon.ParticipantDto
import com.twilioflutter.conversations.pigeon.SendMediaMessageRequest
import com.twilioflutter.conversations.pigeon.SendMessageRequest
import com.twilioflutter.conversations.pigeon.TwilioConversationsHostApi
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.suspendCancellableCoroutine

/** Adapts callback-based [ConversationsBridge] to Pigeon 29 suspend [TwilioConversationsHostApi]. */
class ConversationsBridgeHostAdapter(
  private val bridge: ConversationsBridge,
) : TwilioConversationsHostApi {
  override suspend fun connect(request: ConnectRequest) {
    awaitUnit { bridge.connect(request, it) }
  }

  override suspend fun disconnect() {
    awaitUnit { bridge.disconnect(it) }
  }

  override suspend fun updateAccessToken(accessToken: String) {
    awaitUnit { bridge.updateAccessToken(accessToken, it) }
  }

  override suspend fun sendMessage(request: SendMessageRequest): MessageDto =
    awaitResult { bridge.sendMessage(request, it) }

  override suspend fun listConversations(): List<ConversationDto> =
    awaitResult { bridge.listConversations(it) }

  override suspend fun getConversation(sidOrUniqueName: String): ConversationDto =
    awaitResult { bridge.getConversation(sidOrUniqueName, it) }

  override suspend fun getLastMessages(request: GetMessagesRequest): List<MessageDto> =
    awaitResult { bridge.getLastMessages(request, it) }

  override suspend fun getMessagesBefore(request: GetMessagesBeforeRequest): List<MessageDto> =
    awaitResult { bridge.getMessagesBefore(request, it) }

  override suspend fun sendMediaMessage(request: SendMediaMessageRequest): MessageDto =
    awaitResult { bridge.sendMediaMessage(request, it) }

  override suspend fun getMediaTemporaryUrl(request: GetMediaTemporaryUrlRequest): String =
    awaitResult { bridge.getMediaTemporaryUrl(request, it) }

  override suspend fun getParticipants(request: ConversationRequest): List<ParticipantDto> =
    awaitResult { bridge.getParticipants(request, it) }

  override suspend fun sendTyping(request: ConversationRequest) {
    awaitUnit { bridge.sendTyping(request, it) }
  }

  private suspend fun awaitUnit(block: (callback: (Result<Unit>) -> Unit) -> Unit) {
    suspendCancellableCoroutine { continuation ->
      block { result ->
        result.fold(
          onSuccess = { continuation.resume(Unit) },
          onFailure = { continuation.resumeWithException(it) },
        )
      }
    }
  }

  private suspend fun <T> awaitResult(block: (callback: (Result<T>) -> Unit) -> Unit): T =
    suspendCancellableCoroutine { continuation ->
      block { result ->
        result.fold(
          onSuccess = { continuation.resume(it) },
          onFailure = { continuation.resumeWithException(it) },
        )
      }
    }
}
