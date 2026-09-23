# twilio_flutter_core

Shared Dart types for the [Twilio Flutter plugins](https://github.com/KazzyAPI/twilio-flutter-plugins): normalized errors, message attribute JSON, and small codecs used by `twilio_flutter_conversations` and `twilio_flutter_video`.

**Most apps should depend on a plugin directly**, not on this package. It is published so pub.dev can resolve plugin dependencies.

## What this package provides

- **`TwilioErrorCode`** — stable string codes from native bridges (`not_connected`, `sdk_failure`, …).
- **`TwilioFlutterException`** — Dart-side failures with optional native details.
- **`MessageAttributes`** — typed JSON object attributes for Conversations messages.
- **`TwilioJsonObjectCodec`** — encode/decode JSON object maps for attributes.

## Usage

You typically import a plugin instead:

```yaml
dependencies:
  twilio_flutter_conversations: ^0.0.1
```

If you handle errors explicitly:

```dart
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

try {
  // …
} on TwilioFlutterException catch (e) {
  final code = e.code; // TwilioErrorCode
}
```

## More information

- Repository: [KazzyAPI/twilio-flutter-plugins](https://github.com/KazzyAPI/twilio-flutter-plugins)
- Conversations plugin: [twilio_flutter_conversations](https://pub.dev/packages/twilio_flutter_conversations)
- Video plugin: [twilio_flutter_video](https://pub.dev/packages/twilio_flutter_video)
