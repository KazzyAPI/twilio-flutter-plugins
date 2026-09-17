import Flutter
import UIKit

public class TwilioFlutterConversationsPlugin: NSObject {
  private var bridge: ConversationsBridge?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let bridge = ConversationsBridge(binaryMessenger: registrar.messenger())
    TwilioConversationsHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: bridge
    )

    let instance = TwilioFlutterConversationsPlugin()
    instance.bridge = bridge
  }

  deinit {
    bridge?.dispose()
  }
}
