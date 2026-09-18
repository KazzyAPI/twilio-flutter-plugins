import Foundation

/// Adapts callback-based [ConversationsBridge] to Pigeon 29 `async throws` [TwilioConversationsHostApi].
final class ConversationsBridgeHostAdapter: TwilioConversationsHostApi {
  private let bridge: ConversationsBridge

  init(bridge: ConversationsBridge) {
    self.bridge = bridge
  }

  func connect(request: ConnectRequest) async throws {
    try await awaitUnit { bridge.connect(request: request, completion: $0) }
  }

  func disconnect() async throws {
    try await awaitUnit { bridge.disconnect(completion: $0) }
  }

  func updateAccessToken(accessToken: String) async throws {
    try await awaitUnit { bridge.updateAccessToken(accessToken: accessToken, completion: $0) }
  }

  func sendMessage(request: SendMessageRequest) async throws -> MessageDto {
    try await awaitResult { bridge.sendMessage(request: request, completion: $0) }
  }

  func listConversations() async throws -> [ConversationDto] {
    try await awaitResult { bridge.listConversations(completion: $0) }
  }

  func getConversation(sidOrUniqueName: String) async throws -> ConversationDto {
    try await awaitResult { bridge.getConversation(sidOrUniqueName: sidOrUniqueName, completion: $0) }
  }

  func getLastMessages(request: GetMessagesRequest) async throws -> [MessageDto] {
    try await awaitResult { bridge.getLastMessages(request: request, completion: $0) }
  }

  func getMessagesBefore(request: GetMessagesBeforeRequest) async throws -> [MessageDto] {
    try await awaitResult { bridge.getMessagesBefore(request: request, completion: $0) }
  }

  func sendMediaMessage(request: SendMediaMessageRequest) async throws -> MessageDto {
    try await awaitResult { bridge.sendMediaMessage(request: request, completion: $0) }
  }

  func getMediaTemporaryUrl(request: GetMediaTemporaryUrlRequest) async throws -> String {
    try await awaitResult { bridge.getMediaTemporaryUrl(request: request, completion: $0) }
  }

  func getParticipants(request: ConversationRequest) async throws -> [ParticipantDto] {
    try await awaitResult { bridge.getParticipants(request: request, completion: $0) }
  }

  func sendTyping(request: ConversationRequest) async throws {
    try await awaitUnit { bridge.sendTyping(request: request, completion: $0) }
  }

  private func awaitUnit(
    _ block: (@escaping (Result<Void, Error>) -> Void) -> Void
  ) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      block { result in
        continuation.resume(with: result)
      }
    }
  }

  private func awaitResult<T>(
    _ block: (@escaping (Result<T, Error>) -> Void) -> Void
  ) async throws -> T {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
      block { result in
        continuation.resume(with: result)
      }
    }
  }
}
