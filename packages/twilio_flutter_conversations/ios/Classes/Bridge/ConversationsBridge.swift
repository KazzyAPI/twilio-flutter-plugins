import Flutter
import Foundation
import TwilioConversationsClient

/// Host-side bridge between Twilio Conversations SDK and Flutter pigeon APIs.
final class ConversationsBridge: NSObject {
  private let eventEmitter: ConversationsEventEmitter
  private let eventMapper = ConversationsEventMapper()
  private var client: TwilioConversationsClient?
  private var connectGeneration: Int = 0
  private var isConnectInFlight: Bool = false

  init(binaryMessenger: FlutterBinaryMessenger) {
    eventEmitter = ConversationsEventEmitter(binaryMessenger: binaryMessenger)
    super.init()
  }

  func connect(
    request: ConnectRequest,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    if client != nil || isConnectInFlight {
      completion(
        .failure(
          FlutterError(
            code: "already_connected",
            message: "Twilio Conversations client is already connected.",
            details: nil
          )
        )
      )
      return
    }

    isConnectInFlight = true
    let generation = connectGeneration

    TwilioConversationsClient.conversationsClient(
      withToken: request.accessToken,
      properties: nil,
      delegate: self
    ) { [weak self] result, conversationsClient in
      guard let self else {
        return
      }

      if generation != self.connectGeneration {
        conversationsClient?.shutdown()
        completion(.success(()))
        return
      }

      self.isConnectInFlight = false
      if let conversationsClient {
        self.client = conversationsClient
        completion(.success(()))
        return
      }

      let message = result.error?.localizedDescription ?? "Failed to connect Conversations client"
      completion(
        .failure(
          FlutterError(
            code: "sdk_failure",
            message: message,
            details: nil
          )
        )
      )
    }
  }

  func disconnect(completion: @escaping (Result<Void, Error>) -> Void) {
    invalidatePendingConnect()
    guard let activeClient = client else {
      completion(.success(()))
      return
    }

    activeClient.delegate = nil
    activeClient.shutdown()
    client = nil
    completion(.success(()))
  }

  func updateAccessToken(
    accessToken: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let activeClient = client else {
      completion(
        .failure(
          FlutterError(
            code: "not_connected",
            message: "Connect before updating the access token.",
            details: nil
          )
        )
      )
      return
    }

    activeClient.updateToken(accessToken) { result in
      if result.isSuccessful {
        completion(.success(()))
        return
      }

      completion(
        .failure(
          FlutterError(
            code: "sdk_failure",
            message: result.error?.localizedDescription ?? "Failed to update access token",
            details: nil
          )
        )
      )
    }
  }

  func listConversations(completion: @escaping (Result<[ConversationDto], Error>) -> Void) {
    guard let activeClient = client else {
      completion(notConnectedFailure())
      return
    }

    let conversations =
      activeClient.myConversations()?.map { eventMapper.mapConversation($0) } ?? []
    completion(.success(conversations))
  }

  func getConversation(
    sidOrUniqueName: String,
    completion: @escaping (Result<ConversationDto, Error>) -> Void
  ) {
    resolveConversation(sidOrUniqueName: sidOrUniqueName) { result in
      switch result {
      case .success(let conversation):
        completion(.success(self.eventMapper.mapConversation(conversation)))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func getLastMessages(
    request: GetMessagesRequest,
    completion: @escaping (Result<[MessageDto], Error>) -> Void
  ) {
    let count = max(1, min(request.count, 100))
    resolveConversation(sidOrUniqueName: request.conversationSid) { result in
      switch result {
      case .success(let conversation):
        guard let sid = conversation.sid else {
          completion(
            .failure(
              FlutterError(
                code: "internal",
                message: "Conversation missing SID.",
                details: nil
              )
            )
          )
          return
        }

        conversation.getLastMessages(withCount: NSNumber(value: count)) { fetchResult, messages in
          if let messages {
            completion(
              .success(
                messages.map { self.eventMapper.mapMessage($0, conversationSid: sid) }
              )
            )
            return
          }

          completion(
            .failure(
              FlutterError(
                code: "sdk_failure",
                message: fetchResult.error?.localizedDescription ?? "Failed to load messages",
                details: nil
              )
            )
          )
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func getMessagesBefore(
    request: GetMessagesBeforeRequest,
    completion: @escaping (Result<[MessageDto], Error>) -> Void
  ) {
    let count = max(1, min(request.count, 100))
    resolveConversation(sidOrUniqueName: request.conversationSid) { result in
      switch result {
      case .success(let conversation):
        guard let sid = conversation.sid else {
          completion(
            .failure(
              FlutterError(code: "internal", message: "Conversation missing SID.", details: nil)
            )
          )
          return
        }

        conversation.getMessagesBefore(
          NSNumber(value: request.beforeMessageIndex),
          withCount: NSNumber(value: count)
        ) { fetchResult, messages in
          if let messages {
            completion(
              .success(messages.map { self.eventMapper.mapMessage($0, conversationSid: sid) })
            )
            return
          }

          completion(
            .failure(
              FlutterError(
                code: "sdk_failure",
                message: fetchResult.error?.localizedDescription ?? "Failed to load messages",
                details: nil
              )
            )
          )
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func sendMediaMessage(
    request: SendMediaMessageRequest,
    completion: @escaping (Result<MessageDto, Error>) -> Void
  ) {
    resolveConversation(sidOrUniqueName: request.conversationSid) { result in
      switch result {
      case .success(let conversation):
        guard let sid = conversation.sid else {
          completion(
            .failure(
              FlutterError(code: "internal", message: "Conversation missing SID.", details: nil)
            )
          )
          return
        }

        let fileUrl = URL(fileURLWithPath: request.filePath)
        guard FileManager.default.fileExists(atPath: fileUrl.path) else {
          completion(
            .failure(
              FlutterError(
                code: "invalid_argument",
                message: "filePath must point to a readable file.",
                details: nil
              )
            )
          )
          return
        }

        let data: Data
        do {
          data = try Data(contentsOf: fileUrl)
        } catch {
          completion(
            .failure(
              FlutterError(
                code: "invalid_argument",
                message: "Could not read file at filePath.",
                details: error.localizedDescription
              )
            )
          )
          return
        }

        let preparedMessage = conversation.prepareMessage()
        if let caption = request.caption, !caption.isEmpty {
          preparedMessage.setBody(caption)
        }
        if let attributesJson = request.attributesJson, !attributesJson.isEmpty {
          if let error = Self.applyAttributesJson(attributesJson, to: preparedMessage) {
            completion(
              .failure(
                FlutterError(
                  code: "invalid_argument",
                  message: error.localizedDescription,
                  details: nil
                )
              )
            )
            return
          }
        }

        preparedMessage.addMedia(
          withData: data,
          contentType: request.mimeType,
          filename: request.filename,
          listener: nil
        )

        preparedMessage.buildAndSend { [weak self] sendResult, message in
          guard let self else {
            return
          }
          if let message {
            completion(.success(self.eventMapper.mapMessage(message, conversationSid: sid)))
            return
          }
          completion(
            .failure(
              FlutterError(
                code: "sdk_failure",
                message: sendResult.error?.localizedDescription ?? "Failed to send media message",
                details: nil
              )
            )
          )
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func getMediaTemporaryUrl(
    request: GetMediaTemporaryUrlRequest,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    resolveConversation(sidOrUniqueName: request.conversationSid) { result in
      switch result {
      case .success(let conversation):
        conversation.message(withIndex: NSNumber(value: request.messageIndex)) { fetchResult, message in
          guard let message else {
            completion(
              .failure(
                FlutterError(
                  code: "sdk_failure",
                  message: fetchResult.error?.localizedDescription ?? "Message not found",
                  details: nil
                )
              )
            )
            return
          }

          guard
            let media = message.attachedMedia.first(where: {
              ($0.sid ?? "") == request.mediaSid
            })
          else {
            completion(
              .failure(
                FlutterError(
                  code: "invalid_argument",
                  message: "Media not found on message.",
                  details: nil
                )
              )
            )
            return
          }

          guard let activeClient = self.client else {
            completion(
              .failure(
                FlutterError(
                  code: "not_connected",
                  message: "Connect before accessing media URLs.",
                  details: nil
                )
              )
            )
            return
          }

          activeClient.getTemporaryContentUrlsForMedia(Set([media])) { urlResult, sidToUrl in
            let url = sidToUrl?[request.mediaSid] ?? sidToUrl?[media.sid ?? ""]
            if let url {
              completion(.success(url))
              return
            }
            completion(
              .failure(
                FlutterError(
                  code: "sdk_failure",
                  message: urlResult.error?.localizedDescription ?? "Failed to get media URL",
                  details: nil
                )
              )
            )
          }
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func getParticipants(
    request: ConversationRequest,
    completion: @escaping (Result<[ParticipantDto], Error>) -> Void
  ) {
    resolveConversation(sidOrUniqueName: request.conversationSid) { result in
      switch result {
      case .success(let conversation):
        guard let sid = conversation.sid else {
          completion(
            .failure(
              FlutterError(
                code: "internal",
                message: "Conversation missing SID.",
                details: nil
              )
            )
          )
          return
        }

        let participants =
          conversation.participants()?.compactMap { participant -> ParticipantDto? in
            guard let participant else {
              return nil
            }
            return self.eventMapper.mapParticipant(participant, conversationSid: sid)
          } ?? []
        completion(.success(participants))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func sendTyping(
    request: ConversationRequest,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    resolveConversation(sidOrUniqueName: request.conversationSid) { result in
      switch result {
      case .success(let conversation):
        conversation.sendTyping { sendResult in
          if sendResult.isSuccessful {
            completion(.success(()))
            return
          }
          completion(
            .failure(
              FlutterError(
                code: "sdk_failure",
                message: sendResult.error?.localizedDescription ?? "Failed to send typing indicator",
                details: nil
              )
            )
          )
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func sendMessage(
    request: SendMessageRequest,
    completion: @escaping (Result<MessageDto, Error>) -> Void
  ) {
    resolveConversation(sidOrUniqueName: request.conversationSid) { result in
      switch result {
      case .success(let conversation):
        guard let sid = conversation.sid else {
          completion(
            .failure(
              FlutterError(
                code: "internal",
                message: "Conversation missing SID.",
                details: nil
              )
            )
          )
          return
        }

        let preparedMessage = conversation.prepareMessage()
        preparedMessage.setBody(request.body)

        if let attributesJson = request.attributesJson, !attributesJson.isEmpty {
          if let error = Self.applyAttributesJson(attributesJson, to: preparedMessage) {
            completion(
              .failure(
                FlutterError(
                  code: "invalid_argument",
                  message: error.localizedDescription,
                  details: nil
                )
              )
            )
            return
          }
        }

        preparedMessage.buildAndSend { [weak self] sendResult, message in
          guard let self else {
            return
          }

          if let message {
            completion(.success(self.eventMapper.mapMessage(message, conversationSid: sid)))
            return
          }

          completion(
            .failure(
              FlutterError(
                code: "sdk_failure",
                message: sendResult.error?.localizedDescription ?? "Failed to send message",
                details: nil
              )
            )
          )
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func dispose() {
    invalidatePendingConnect()
    client?.delegate = nil
    client?.shutdown()
    client = nil
  }

  private static func applyAttributesJson(
    _ attributesJson: String,
    to builder: TCHMessageBuilder
  ) -> Error? {
    do {
      let attributes = try MessageAttributesJson.attributes(fromJson: attributesJson)
      var error: NSError?
      _ = builder.setAttributes(attributes, error: &error)
      if let error {
        return error
      }
      return nil
    } catch {
      return error
    }
  }

  private func notConnectedFailure() -> Result<[ConversationDto], Error> {
    .failure(
      FlutterError(
        code: "not_connected",
        message: "Connect before accessing conversations.",
        details: nil
      )
    )
  }

  private func resolveConversation(
    sidOrUniqueName: String,
    completion: @escaping (Result<TCHConversation, Error>) -> Void
  ) {
    guard let activeClient = client else {
      completion(
        .failure(
          FlutterError(
            code: "not_connected",
            message: "Connect before accessing conversations.",
            details: nil
          )
        )
      )
      return
    }

    if let cached = activeClient.myConversations()?.first(where: {
      $0.sid == sidOrUniqueName || $0.uniqueName == sidOrUniqueName
    }) {
      completion(.success(cached))
      return
    }

    activeClient.conversation(withSidOrUniqueName: sidOrUniqueName) { result, conversation in
      guard result.isSuccessful, let conversation else {
        completion(
          .failure(
            FlutterError(
              code: "sdk_failure",
              message: result.error?.localizedDescription ?? "Conversation not found",
              details: nil
            )
          )
        )
        return
      }
      completion(.success(conversation))
    }
  }

  private func invalidatePendingConnect() {
    connectGeneration += 1
    isConnectInFlight = false
  }

  private func conversationSid(_ conversation: TCHConversation) -> String {
    conversation.sid ?? ""
  }
}

extension ConversationsBridge: TwilioConversationsClientDelegate {
  func conversationsClient(
    _ client: TwilioConversationsClient,
    synchronizationStatusUpdated status: TCHClientSynchronizationStatus
  ) {
    eventEmitter.emit(event: eventMapper.synchronizationEvent(status: status))
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    connectionStateUpdated state: TCHClientConnectionState
  ) {
    eventEmitter.emit(event: eventMapper.connectionStateEvent(state: state))
  }

  func conversationsClient(_ client: TwilioConversationsClient, conversationAdded conversation: TCHConversation) {
    eventEmitter.emit(event: eventMapper.conversationAddedEvent(conversation))
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    conversation: TCHConversation,
    updated: TCHConversationUpdate
  ) {
    eventEmitter.emit(event: eventMapper.conversationUpdatedEvent(conversation, updated: updated))
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    conversationDeleted conversation: TCHConversation
  ) {
    eventEmitter.emit(event: eventMapper.conversationDeletedEvent(conversation))
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    conversation: TCHConversation,
    synchronizationStatusUpdated status: TCHConversationSynchronizationStatus
  ) {
    eventEmitter.emit(event: eventMapper.conversationSynchronizationEvent(conversation))
  }

  func conversationsClient(_ client: TwilioConversationsClient, errorReceived error: TCHError) {
    eventEmitter.emit(
      event: eventMapper.errorEvent(
        code: "sdk_failure",
        message: error.localizedDescription
      )
    )
  }

  func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
    eventEmitter.emit(event: eventMapper.tokenAboutToExpireEvent())
  }

  func conversationsClientTokenDidExpire(_ client: TwilioConversationsClient) {
    eventEmitter.emit(event: eventMapper.tokenExpiredEvent())
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    user: TCHUser,
    updated: TCHUserUpdate
  ) {
    eventEmitter.emit(event: eventMapper.userUpdatedEvent(user, updated: updated))
  }

  func conversationsClient(_ client: TwilioConversationsClient, userSubscribed user: TCHUser) {
    eventEmitter.emit(event: eventMapper.userSubscribedEvent(user))
  }

  func conversationsClient(_ client: TwilioConversationsClient, userUnsubscribed user: TCHUser) {
    eventEmitter.emit(event: eventMapper.userUnsubscribedEvent(user))
  }

  func conversationsClientNotificationSubscribed(_ client: TwilioConversationsClient) {
    eventEmitter.emit(event: eventMapper.notificationSubscribedEvent())
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    conversation: TCHConversation,
    messageAdded message: TCHMessage
  ) {
    eventEmitter.emit(
      event: eventMapper.messageAddedEvent(message, conversationSid: conversationSid(conversation))
    )
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    conversation: TCHConversation,
    message: TCHMessage,
    updated: TCHMessageUpdate
  ) {
    eventEmitter.emit(
      event: eventMapper.messageUpdatedEvent(
        message,
        conversationSid: conversationSid(conversation),
        updated: updated
      )
    )
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    conversation: TCHConversation,
    messageDeleted message: TCHMessage
  ) {
    eventEmitter.emit(
      event: eventMapper.messageDeletedEvent(message, conversationSid: conversationSid(conversation))
    )
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    conversation: TCHConversation,
    participantJoined participant: TCHParticipant
  ) {
    eventEmitter.emit(
      event: eventMapper.participantAddedEvent(
        participant,
        conversationSid: conversationSid(conversation)
      )
    )
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    conversation: TCHConversation,
    participantLeft participant: TCHParticipant
  ) {
    eventEmitter.emit(
      event: eventMapper.participantDeletedEvent(
        participant,
        conversationSid: conversationSid(conversation)
      )
    )
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    conversation: TCHConversation,
    participant: TCHParticipant,
    updated: TCHParticipantUpdate
  ) {
    eventEmitter.emit(
      event: eventMapper.participantUpdatedEvent(
        participant,
        conversationSid: conversationSid(conversation),
        updated: updated
      )
    )
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    typingStartedOn conversation: TCHConversation,
    participant: TCHParticipant
  ) {
    eventEmitter.emit(
      event: eventMapper.typingStartedEvent(
        participant,
        conversationSid: conversationSid(conversation)
      )
    )
  }

  func conversationsClient(
    _ client: TwilioConversationsClient,
    typingEndedOn conversation: TCHConversation,
    participant: TCHParticipant
  ) {
    eventEmitter.emit(
      event: eventMapper.typingEndedEvent(
        participant,
        conversationSid: conversationSid(conversation)
      )
    )
  }
}
