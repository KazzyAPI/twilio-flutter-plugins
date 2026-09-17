import Foundation
import TwilioConversationsClient

enum MessageMediaMapping {
  static func mapMedia(_ media: TCHMedia) -> PigeonMediaAttachmentDto {
    return PigeonMediaAttachmentDto(
      sid: media.sid ?? "",
      contentType: media.contentType ?? "application/octet-stream",
      filename: media.filename ?? "",
      sizeBytes: Int64(media.size)
    )
  }

  static func enrichMessageDto(
    base: PigeonMessageDto,
    message: TCHMessage
  ) -> PigeonMessageDto {
    guard let mediaItems = message.attachedMedia, !mediaItems.isEmpty else {
      return base
    }

    let attachments = mediaItems.compactMap { item -> PigeonMediaAttachmentDto? in
      guard let media = item else {
        return nil
      }
      return mapMedia(media)
    }

    return PigeonMessageDto(
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
