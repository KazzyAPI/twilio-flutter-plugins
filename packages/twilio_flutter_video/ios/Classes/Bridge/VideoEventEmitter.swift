import Foundation

final class VideoEventEmitter {
  private let flutterApi: TwilioVideoFlutterApi

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterApi = TwilioVideoFlutterApi(binaryMessenger: binaryMessenger)
  }

  func emit(event: VideoNativeEvent) {
    Task { @MainActor in
      try? await flutterApi.onNativeEvent(event: event)
    }
  }
}
