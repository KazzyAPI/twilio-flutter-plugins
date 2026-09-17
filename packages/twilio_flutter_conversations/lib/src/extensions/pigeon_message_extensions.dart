import '../models/message_content_type.dart';
import '../pigeon/conversations.pigeon.dart';

extension PigeonMessageContentTypeX on PigeonMessageContentType {
  TwilioMessageContentType toPublic() {
    return switch (this) {
      PigeonMessageContentType.media => TwilioMessageContentType.media,
      PigeonMessageContentType.text => TwilioMessageContentType.text,
    };
  }
}
