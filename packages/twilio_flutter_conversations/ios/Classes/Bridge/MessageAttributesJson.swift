import Foundation
import TwilioConversationsClient

/// Shared JSON ↔ Twilio attributes conversion for iOS.
enum MessageAttributesJson {
  static func attributes(fromJson jsonObject: String) throws -> TCHJsonAttributes {
    guard let data = jsonObject.data(using: .utf8) else {
      throw NSError(
        domain: "TwilioFlutterConversations",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Invalid UTF-8 in attributesJson."]
      )
    }
    let object = try JSONSerialization.jsonObject(with: data, options: [])
    guard let dictionary = object as? [String: Any] else {
      throw NSError(
        domain: "TwilioFlutterConversations",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "attributesJson must decode to a JSON object."]
      )
    }
    return TCHJsonAttributes(dictionary: dictionary)
  }

  static func json(from message: TCHMessage) -> String? {
    guard let dictionary = message.attributes()?.dictionary as? [String: Any] else {
      return nil
    }
    if dictionary.isEmpty {
      return nil
    }
    guard
      let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
      let json = String(data: data, encoding: .utf8)
    else {
      return nil
    }
    return json
  }
}
