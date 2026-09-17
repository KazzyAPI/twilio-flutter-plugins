import 'message_attributes.dart';

/// Encodes and decodes JSON objects used for Twilio attributes/metadata.
class TwilioJsonObjectCodec {
  /// Encodes [attributes] for native bridges.
  static String? encode(MessageAttributes attributes) => attributes.toWireJson();

  /// Decodes native JSON into [MessageAttributes].
  static MessageAttributes decode(String? jsonObject) {
    if (jsonObject == null || jsonObject.trim().isEmpty) {
      return MessageAttributes.empty();
    }
    return MessageAttributes.fromJsonObject(jsonObject);
  }
}
