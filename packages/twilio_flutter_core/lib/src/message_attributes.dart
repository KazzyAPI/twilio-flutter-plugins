import 'dart:convert';

import 'twilio_error_code.dart';
import 'twilio_flutter_exception.dart';

/// JSON object metadata attached to a Twilio message.
final class MessageAttributes {
  MessageAttributes._(this._values);

  /// No custom attributes.
  factory MessageAttributes.empty() => _empty;

  /// Attributes from an integrator-supplied map (empty map → [empty]).
  factory MessageAttributes.fromMap(Map<String, Object?> values) {
    if (values.isEmpty) {
      return _empty;
    }
    return MessageAttributes._(Map<String, Object?>.unmodifiable(values));
  }

  /// Parses attributes from a native JSON object string.
  factory MessageAttributes.fromJsonObject(String jsonObject) {
    final decoded = jsonDecode(jsonObject);
    if (decoded is! Map) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.internal,
        message: 'Expected a JSON object for attributes.',
      );
    }
    return MessageAttributes.fromMap(Map<String, Object?>.from(decoded));
  }

  static final MessageAttributes _empty = MessageAttributes._(const {});

  final Map<String, Object?> _values;

  /// Whether any attributes are present.
  bool get isEmpty => _values.isEmpty;

  /// Read-only attribute entries.
  Map<String, Object?> get entries => _values;

  /// Encodes to a wire JSON object string, or absent when [isEmpty].
  String? toWireJson() {
    if (isEmpty) {
      return null;
    }
    try {
      return jsonEncode(_values);
    } on Object {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.invalidArgument,
        message: 'Attributes contain values that cannot be encoded as JSON.',
      );
    }
  }
}
