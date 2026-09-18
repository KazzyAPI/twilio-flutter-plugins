package com.twilioflutter.conversations.bridge

import android.content.Context
import com.twilio.conversations.CallbackListener
import com.twilio.conversations.Conversation
import com.twilio.conversations.ConversationsClient
import com.twilio.conversations.ConversationsClientListener
import com.twilio.util.ErrorInfo
import com.twilio.conversations.Message
import com.twilio.conversations.StatusListener
import com.twilioflutter.conversations.pigeon.FlutterError
import com.twilioflutter.conversations.pigeon.ConnectRequest
import com.twilioflutter.conversations.pigeon.ConversationDto
import com.twilioflutter.conversations.pigeon.ConversationRequest
import com.twilioflutter.conversations.pigeon.GetMediaTemporaryUrlRequest
import com.twilioflutter.conversations.pigeon.GetMessagesBeforeRequest
import com.twilioflutter.conversations.pigeon.GetMessagesRequest
import com.twilioflutter.conversations.pigeon.SendMediaMessageRequest
import com.twilio.conversations.MediaUploadListener
import java.io.File
import java.io.FileInputStream
import com.twilioflutter.conversations.pigeon.MessageDto
import com.twilioflutter.conversations.pigeon.ParticipantDto
import com.twilioflutter.conversations.pigeon.SendMessageRequest
import io.flutter.plugin.common.BinaryMessenger

/** Host-side bridge between Twilio Conversations SDK and Flutter pigeon APIs. */
class ConversationsBridge(
  context: Context,
  binaryMessenger: BinaryMessenger,
) {
  private val applicationContext = context.applicationContext
  private val eventEmitter = ConversationsEventEmitter(binaryMessenger)
  private val eventMapper = ConversationsEventMapper()
  private var client: ConversationsClient? = null
  private val connectSessionGuard = ConnectSessionGuard()
  private val conversationListenerRegistry =
    ConversationListenerRegistry(eventMapper) { event ->
      eventEmitter.emit(event)
    }

  private val clientListener =
    object : ConversationsClientListener {
      override fun onClientSynchronization(status: ConversationsClient.SynchronizationStatus) {
        eventEmitter.emit(eventMapper.synchronizationEvent(status))
      }

      override fun onConversationAdded(conversation: Conversation) {
        registerConversationListener(conversation)
        eventEmitter.emit(eventMapper.conversationAddedEvent(conversation))
      }

      override fun onConversationUpdated(
        conversation: Conversation,
        reason: Conversation.UpdateReason,
      ) {
        eventEmitter.emit(eventMapper.conversationUpdatedEvent(conversation, reason))
      }

      override fun onConversationDeleted(conversation: Conversation) {
        conversationListenerRegistry.unregister(conversation.sid, conversation)
        eventEmitter.emit(eventMapper.conversationDeletedEvent(conversation))
      }

      override fun onConversationSynchronizationChange(conversation: Conversation) {
        eventEmitter.emit(eventMapper.conversationSynchronizationEvent(conversation))
      }

      override fun onError(errorInfo: ErrorInfo) {
        eventEmitter.emit(
          eventMapper.errorEvent(
            code = "sdk_failure",
            message = errorInfo.message ?: "Twilio Conversations SDK error",
          ),
        )
      }

      override fun onUserUpdated(user: com.twilio.conversations.User, reason: com.twilio.conversations.User.UpdateReason) {
        eventEmitter.emit(eventMapper.userUpdatedEvent(user, reason))
      }

      override fun onUserSubscribed(user: com.twilio.conversations.User) {
        eventEmitter.emit(eventMapper.userSubscribedEvent(user))
      }

      override fun onUserUnsubscribed(user: com.twilio.conversations.User) {
        eventEmitter.emit(eventMapper.userUnsubscribedEvent(user))
      }

      override fun onNotificationSubscribed() {
        eventEmitter.emit(eventMapper.notificationSubscribedEvent())
      }

      override fun onNotificationFailed(errorInfo: ErrorInfo) {
        eventEmitter.emit(
          eventMapper.errorEvent(
            code = "sdk_failure",
            message = errorInfo.message ?: "Notification subscription failed",
          ),
        )
      }

      override fun onConnectionStateChange(state: ConversationsClient.ConnectionState) {
        eventEmitter.emit(eventMapper.connectionStateEvent(state))
      }

      override fun onTokenAboutToExpire() {
        eventEmitter.emit(eventMapper.tokenAboutToExpireEvent())
      }

      override fun onTokenExpired() {
        eventEmitter.emit(eventMapper.tokenExpiredEvent())
      }

      override fun onNewMessageNotification(
        conversationSid: String,
        messageSid: String,
        messageIndex: Long,
      ) {
      }

      override fun onAddedToConversationNotification(conversationSid: String) {}

      override fun onRemovedFromConversationNotification(conversationSid: String) {}
    }

  fun connect(request: ConnectRequest, callback: (Result<Unit>) -> Unit) {
    if (client != null || connectSessionGuard.isConnectInFlight()) {
      callback(
        Result.failure(
          FlutterError(
            code = "already_connected",
            message = "Twilio Conversations client is already connected.",
            details = null,
          ),
        ),
      )
      return
    }

    val generation =
      connectSessionGuard.beginConnect()
        ?: run {
          callback(
            Result.failure(
              FlutterError(
                code = "already_connected",
                message = "Twilio Conversations client is already connected.",
                details = null,
              ),
            ),
          )
          return
        }

    ConversationsClient.create(
      applicationContext,
      request.accessToken,
      ConversationsClient.Properties.newBuilder().createProperties(),
      object : CallbackListener<ConversationsClient> {
        override fun onSuccess(conversationsClient: ConversationsClient) {
          if (connectSessionGuard.completeConnect(generation) == ConnectCompletion.STALE) {
            conversationsClient.shutdown()
            callback(Result.success(Unit))
            return
          }

          client = conversationsClient
          conversationsClient.addListener(clientListener)
          conversationsClient.myConversations.forEach { conversation ->
            registerConversationListener(conversation)
          }
          callback(Result.success(Unit))
        }

        override fun onError(errorInfo: ErrorInfo) {
          if (connectSessionGuard.completeConnect(generation) == ConnectCompletion.STALE) {
            callback(Result.success(Unit))
            return
          }
          callback(
            Result.failure(
              FlutterError(
                code = "sdk_failure",
                message = errorInfo.message ?: "Failed to connect Conversations client",
                details = null,
              ),
            ),
          )
        }
      },
    )
  }

  fun disconnect(callback: (Result<Unit>) -> Unit) {
    invalidatePendingConnect()
    val activeClient = client
    if (activeClient == null) {
      callback(Result.success(Unit))
      return
    }

    val conversations =
      activeClient.myConversations.associateBy { conversation -> conversation.sid }
    conversationListenerRegistry.clear(conversations)
    activeClient.removeListener(clientListener)
    activeClient.shutdown()
    client = null
    callback(Result.success(Unit))
  }

  fun updateAccessToken(accessToken: String, callback: (Result<Unit>) -> Unit) {
    val activeClient = client
    if (activeClient == null) {
      callback(
        Result.failure(
          FlutterError(
            code = "not_connected",
            message = "Connect before updating the access token.",
            details = null,
          ),
        ),
      )
      return
    }

    activeClient.updateToken(
      accessToken,
      object : StatusListener {
        override fun onSuccess() {
          callback(Result.success(Unit))
        }

        override fun onError(errorInfo: ErrorInfo) {
          callback(
            Result.failure(
              FlutterError(
                code = "sdk_failure",
                message = errorInfo.message ?: "Failed to update access token",
                details = null,
              ),
            ),
          )
        }
      },
    )
  }

  fun listConversations(callback: (Result<List<ConversationDto>>) -> Unit) {
    val activeClient = client
    if (activeClient == null) {
      callback(
        Result.failure(
          FlutterError(
            code = "not_connected",
            message = "Connect before listing conversations.",
            details = null,
          ),
        ),
      )
      return
    }

    callback(
      Result.success(
        activeClient.myConversations.map { conversation ->
          eventMapper.mapConversation(conversation)
        },
      ),
    )
  }

  fun getConversation(
    sidOrUniqueName: String,
    callback: (Result<ConversationDto>) -> Unit,
  ) {
    resolveConversation(
      sidOrUniqueName,
      callback,
      onSuccess = { conversation ->
        callback(Result.success(eventMapper.mapConversation(conversation)))
      },
    )
  }

  fun getLastMessages(
    request: GetMessagesRequest,
    callback: (Result<List<MessageDto>>) -> Unit,
  ) {
    val count = request.count.coerceIn(1, 100).toInt()
    resolveConversation(
      request.conversationSid,
      callback,
      onSuccess = { conversation ->
        conversation.getLastMessages(
          count,
          object : CallbackListener<List<Message>> {
            override fun onSuccess(messages: List<Message>) {
              callback(
                Result.success(
                  messages.map { message ->
                    eventMapper.mapMessage(message, conversation.sid)
                  },
                ),
              )
            }

            override fun onError(errorInfo: ErrorInfo) {
              callback(
                Result.failure(
                  FlutterError(
                    code = "sdk_failure",
                    message = errorInfo.message ?: "Failed to load messages",
                    details = null,
                  ),
                ),
              )
            }
          },
        )
      },
    )
  }

  fun getMessagesBefore(
    request: GetMessagesBeforeRequest,
    callback: (Result<List<MessageDto>>) -> Unit,
  ) {
    val count = request.count.coerceIn(1, 100).toInt()
    resolveConversation(
      request.conversationSid,
      callback,
      onSuccess = { conversation ->
        conversation.getMessagesBefore(
          request.beforeMessageIndex,
          count,
          object : CallbackListener<List<Message>> {
            override fun onSuccess(messages: List<Message>) {
              callback(
                Result.success(
                  messages.map { message ->
                    eventMapper.mapMessage(message, conversation.sid)
                  },
                ),
              )
            }

            override fun onError(errorInfo: ErrorInfo) {
              callback(
                Result.failure(
                  FlutterError(
                    code = "sdk_failure",
                    message = errorInfo.message ?: "Failed to load messages",
                    details = null,
                  ),
                ),
              )
            }
          },
        )
      },
    )
  }

  fun sendMediaMessage(
    request: SendMediaMessageRequest,
    callback: (Result<MessageDto>) -> Unit,
  ) {
    resolveConversation(
      request.conversationSid,
      callback,
      onSuccess = { conversation ->
        val file = File(request.filePath)
        if (!file.isFile) {
          callback(
            Result.failure(
              FlutterError(
                code = "invalid_argument",
                message = "filePath must point to a readable file.",
                details = null,
              ),
            ),
          )
          return@resolveConversation
        }

        val messageBuilder = conversation.prepareMessage()
        if (!request.caption.isNullOrBlank()) {
          messageBuilder.setBody(request.caption)
        }
        if (!request.attributesJson.isNullOrBlank()) {
          try {
            messageBuilder.setAttributes(
              MessageAttributesJson.attributesFromJson(request.attributesJson),
            )
          } catch (exception: Exception) {
            callback(
              Result.failure(
                FlutterError(
                  code = "invalid_argument",
                  message = "attributesJson must be a valid JSON object.",
                  details = exception.message,
                ),
              ),
            )
            return@resolveConversation
          }
        }

        var mediaUploadFailed = false
        messageBuilder.addMedia(
          FileInputStream(file),
          request.mimeType,
          request.filename,
          object : MediaUploadListener {
            override fun onStarted() {}

            override fun onProgress(bytesSent: Long) {}

            override fun onCompleted(mediaSid: String) {}

            override fun onFailed(errorInfo: ErrorInfo) {
              mediaUploadFailed = true
              callback(
                Result.failure(
                  FlutterError(
                    code = "sdk_failure",
                    message = errorInfo.message ?: "Media upload failed",
                    details = null,
                  ),
                ),
              )
            }
          },
        )

        messageBuilder.buildAndSend(
          object : CallbackListener<Message> {
            override fun onSuccess(message: Message) {
              if (mediaUploadFailed) {
                return
              }
              callback(
                Result.success(
                  eventMapper.mapMessage(message, conversation.sid),
                ),
              )
            }

            override fun onError(errorInfo: ErrorInfo) {
              if (mediaUploadFailed) {
                return
              }
              callback(
                Result.failure(
                  FlutterError(
                    code = "sdk_failure",
                    message = errorInfo.message ?: "Failed to send media message",
                    details = null,
                  ),
                ),
              )
            }
          },
        )
      },
    )
  }

  fun getMediaTemporaryUrl(
    request: GetMediaTemporaryUrlRequest,
    callback: (Result<String>) -> Unit,
  ) {
    resolveConversation(
      request.conversationSid,
      callback,
      onSuccess = { conversation ->
        conversation.getMessageByIndex(
          request.messageIndex,
          object : CallbackListener<Message> {
            override fun onSuccess(message: Message) {
              val media =
                message.attachedMedia?.firstOrNull { attached ->
                  attached.sid == request.mediaSid
                }
              if (media == null) {
                callback(
                  Result.failure(
                    FlutterError(
                      code = "invalid_argument",
                      message = "Media not found on message.",
                      details = null,
                    ),
                  ),
                )
                return
              }

              media.getTemporaryContentUrl(
                object : CallbackListener<String> {
                  override fun onSuccess(url: String) {
                    callback(Result.success(url))
                  }

                  override fun onError(errorInfo: ErrorInfo) {
                    callback(
                      Result.failure(
                        FlutterError(
                          code = "sdk_failure",
                          message = errorInfo.message ?: "Failed to get media URL",
                          details = null,
                        ),
                      ),
                    )
                  }
                },
              )
            }

            override fun onError(errorInfo: ErrorInfo) {
              callback(
                Result.failure(
                  FlutterError(
                    code = "sdk_failure",
                    message = errorInfo.message ?: "Message not found",
                    details = null,
                  ),
                ),
              )
            }
          },
        )
      },
    )
  }

  fun getParticipants(
    request: ConversationRequest,
    callback: (Result<List<ParticipantDto>>) -> Unit,
  ) {
    resolveConversation(
      request.conversationSid,
      callback,
      onSuccess = { conversation ->
        callback(
          Result.success(
            conversation.participantsList.map { participant ->
              eventMapper.mapParticipant(participant, conversation.sid)
            },
          ),
        )
      },
    )
  }

  fun sendTyping(
    request: ConversationRequest,
    callback: (Result<Unit>) -> Unit,
  ) {
    resolveConversation(
      request.conversationSid,
      callback,
      onSuccess = { conversation ->
        conversation.typing()
        callback(Result.success(Unit))
      },
    )
  }

  fun sendMessage(
    request: SendMessageRequest,
    callback: (Result<MessageDto>) -> Unit,
  ) {
    val activeClient = client
    if (activeClient == null) {
      callback(
        Result.failure(
          FlutterError(
            code = "not_connected",
            message = "Connect before sending a message.",
            details = null,
          ),
        ),
      )
      return
    }

    activeClient.getConversation(
      request.conversationSid,
      object : CallbackListener<Conversation> {
        override fun onSuccess(conversation: Conversation) {
          val attributesJson = request.attributesJson
          val messageBuilder =
            conversation.prepareMessage().setBody(request.body)
          if (!attributesJson.isNullOrBlank()) {
            try {
              messageBuilder.setAttributes(
                MessageAttributesJson.attributesFromJson(attributesJson),
              )
            } catch (exception: Exception) {
              callback(
                Result.failure(
                  FlutterError(
                    code = "invalid_argument",
                    message = "attributesJson must be a valid JSON object.",
                    details = exception.message,
                  ),
                ),
              )
              return
            }
          }
          messageBuilder.buildAndSend(
              object : CallbackListener<Message> {
                override fun onSuccess(message: Message) {
                  callback(
                    Result.success(
                      eventMapper.mapMessage(message, conversation.sid),
                    ),
                  )
                }

                override fun onError(errorInfo: ErrorInfo) {
                  callback(
                    Result.failure(
                      FlutterError(
                        code = "sdk_failure",
                        message = errorInfo.message ?: "Failed to send message",
                        details = null,
                      ),
                    ),
                  )
                }
              },
            )
        }

        override fun onError(errorInfo: ErrorInfo) {
          callback(
            Result.failure(
              FlutterError(
                code = "sdk_failure",
                message = errorInfo.message ?: "Conversation not found",
                details = null,
              ),
            ),
          )
        }
      },
    )
  }

  /** Releases native resources when the Flutter engine detaches. */
  fun dispose() {
    invalidatePendingConnect()
    val activeClient = client
    if (activeClient != null) {
      val conversations =
        activeClient.myConversations.associateBy { conversation -> conversation.sid }
      conversationListenerRegistry.clear(conversations)
      activeClient.removeListener(clientListener)
      activeClient.shutdown()
    }
    client = null
  }

  private fun registerConversationListener(conversation: Conversation) {
    conversationListenerRegistry.register(conversation)
  }

  private fun invalidatePendingConnect() {
    connectSessionGuard.invalidatePendingConnect()
  }

  private fun <T> resolveConversation(
    sidOrUniqueName: String,
    callback: (Result<T>) -> Unit,
    onSuccess: (Conversation) -> Unit,
  ) {
    val activeClient = client
    if (activeClient == null) {
      callback(
        Result.failure(
          FlutterError(
            code = "not_connected",
            message = "Connect before accessing conversations.",
            details = null,
          ),
        ),
      )
      return
    }

    val cached =
      activeClient.myConversations.firstOrNull { conversation ->
        conversation.sid == sidOrUniqueName ||
          conversation.uniqueName == sidOrUniqueName
      }
    if (cached != null) {
      onSuccess(cached)
      return
    }

    activeClient.getConversation(
      sidOrUniqueName,
      object : CallbackListener<Conversation> {
        override fun onSuccess(conversation: Conversation) {
          registerConversationListener(conversation)
          onSuccess(conversation)
        }

        override fun onError(errorInfo: ErrorInfo) {
          callback(
            Result.failure(
              FlutterError(
                code = "sdk_failure",
                message = errorInfo.message ?: "Conversation not found",
                details = null,
              ),
            ),
          )
        }
      },
    )
  }
}
