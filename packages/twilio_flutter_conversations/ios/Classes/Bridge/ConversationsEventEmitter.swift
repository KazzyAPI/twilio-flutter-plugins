import Foundation

/// Sends canonical conversation events from iOS to Dart.
final class ConversationsEventEmitter {
  private let flutterApi: TwilioConversationsFlutterApi

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterApi = TwilioConversationsFlutterApi(binaryMessenger: binaryMessenger)
  }

  func emit(event: ConversationsNativeEvent) {
    Task { @MainActor in
      try? await flutterApi.onNativeEvent(event: event)
    }
  }
}
