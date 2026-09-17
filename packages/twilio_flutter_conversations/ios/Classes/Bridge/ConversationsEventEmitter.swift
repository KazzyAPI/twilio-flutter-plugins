import Foundation

/// Sends canonical conversation events from iOS to Dart.
final class ConversationsEventEmitter {
  private let flutterApi: TwilioConversationsFlutterApi

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterApi = TwilioConversationsFlutterApi(binaryMessenger: binaryMessenger)
  }

  func emit(event: PigeonConversationsNativeEvent) {
    flutterApi.onNativeEvent(event: event) { _ in }
  }
}
