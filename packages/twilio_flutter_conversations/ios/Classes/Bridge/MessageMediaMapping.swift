import Foundation
import TwilioConversationsClient

enum MessageMediaMapping {
  static func mapMedia(_ media: Media) -> MediaAttachmentDto {
    return MediaAttachmentDto(
      sid: media.sid ?? "",
      contentType: media.contentType ?? "application/octet-stream",
      filename: media.filename ?? "",
      sizeBytes: Int64(media.size)
    )
  }

  static func enrichMessageDto(
    base: MessageDto,
    message: TCHMessage
  ) -> MessageDto {
    let mediaItems = message.attachedMedia
    if mediaItems.isEmpty {
      return base
    }

    let attachments = mediaItems.map { mapMedia($0) }

    return MessageDto(
      sid: base.sid,
      conversationSid: base.conversationSid,
      author: base.author,
      body: base.body,
      messageIndex: base.messageIndex,
      dateCreatedEpochMs: base.dateCreatedEpochMs,
      contentType: .media,
      mediaAttachments: attachments,
      attributesJson: base.attributesJson
    )
  }
}
