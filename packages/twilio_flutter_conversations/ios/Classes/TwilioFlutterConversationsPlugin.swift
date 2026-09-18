import Flutter
import UIKit

public class TwilioFlutterConversationsPlugin: NSObject {
  private var bridge: ConversationsBridge?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let bridge = ConversationsBridge(binaryMessenger: registrar.messenger())
    let hostApi = ConversationsBridgeHostAdapter(bridge: bridge)
    TwilioConversationsHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: hostApi
    )

    let instance = TwilioFlutterConversationsPlugin()
    instance.bridge = bridge
  }

  deinit {
    bridge?.dispose()
  }
}
