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
    guard let mediaItems = message.attachedMedia, !mediaItems.isEmpty else {
      return base
    }

    let attachments = mediaItems.compactMap { item -> MediaAttachmentDto? in
      guard let media = item else {
        return nil
      }
      return mapMedia(media)
    }

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
