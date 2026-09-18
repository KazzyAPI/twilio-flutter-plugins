import Flutter
import UIKit

public class TwilioFlutterVideoPlugin: NSObject, FlutterPlugin {
  private var bridge: VideoBridge?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let bridge = VideoBridge(binaryMessenger: registrar.messenger())
    TwilioVideoHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: bridge)

    let instance = TwilioFlutterVideoPlugin()
    instance.bridge = bridge
  }
}
