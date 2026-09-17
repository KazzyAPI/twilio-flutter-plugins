import 'package:twilio_flutter_core/twilio_flutter_core.dart';

import '../extensions/pigeon_message_extensions.dart';
import '../models/conversation.dart';
import '../models/media_attachment.dart';
import '../models/message.dart';
import '../models/participant.dart';
import '../models/user.dart';
import '../pigeon/conversations.pigeon.dart';

/// Maps pigeon DTOs to public Dart models.
class PigeonDtoMapper {
  const PigeonDtoMapper();

  TwilioConversation mapConversation(ConversationDto dto) {
    return TwilioConversation(
      sid: dto.sid,
      uniqueName: dto.uniqueName,
      friendlyName: dto.friendlyName,
      lastMessageIndex: dto.lastMessageIndex,
    );
  }

  TwilioMessage mapMessage(MessageDto dto) {
    final attachments =
        dto.mediaAttachments
            ?.whereType<MediaAttachmentDto>()
            .map(
              (media) => TwilioMediaAttachment(
                sid: media.sid,
                contentType: media.contentType,
                filename: media.filename,
                sizeBytes: media.sizeBytes,
              ),
            )
            .toList(growable: false) ??
        const [];
    return TwilioMessage(
      sid: dto.sid,
      conversationSid: dto.conversationSid,
      author: dto.author,
      body: dto.body,
      messageIndex: dto.messageIndex,
      dateCreated: DateTime.fromMillisecondsSinceEpoch(dto.dateCreatedEpochMs),
      contentType: dto.contentType.toPublic(),
      mediaAttachments: attachments,
      attributes: TwilioJsonObjectCodec.decode(dto.attributesJson),
    );
  }

  TwilioParticipant mapParticipant(ParticipantDto dto) {
    return TwilioParticipant(
      sid: dto.sid,
      identity: dto.identity,
      conversationSid: dto.conversationSid,
    );
  }

  TwilioUser mapUser(UserDto dto) {
    return TwilioUser(
      identity: dto.identity,
      friendlyName: dto.friendlyName ?? '',
    );
  }
}
