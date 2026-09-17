import '../models/message_content_type.dart';
import '../pigeon/conversations.pigeon.dart';

extension MessageContentTypeX on MessageContentType {
  TwilioMessageContentType toPublic() {
    return switch (this) {
      MessageContentType.media => TwilioMessageContentType.media,
      MessageContentType.text => TwilioMessageContentType.text,
    };
  }
}
