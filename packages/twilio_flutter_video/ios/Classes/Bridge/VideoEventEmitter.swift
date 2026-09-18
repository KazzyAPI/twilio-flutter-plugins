import Foundation

final class VideoEventEmitter {
  private let flutterApi: TwilioVideoFlutterApi

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterApi = TwilioVideoFlutterApi(binaryMessenger: binaryMessenger)
  }

  func emit(event: VideoNativeEvent) {
    flutterApi.onNativeEvent(event: event) { _ in }
  }
}
