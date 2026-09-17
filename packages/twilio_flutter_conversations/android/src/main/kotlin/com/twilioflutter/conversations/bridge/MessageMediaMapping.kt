package com.twilioflutter.conversations.bridge

import com.twilio.conversations.Media
import com.twilio.conversations.Message
import com.twilioflutter.conversations.pigeon.PigeonMediaAttachmentDto
import com.twilioflutter.conversations.pigeon.PigeonMessageContentType
import com.twilioflutter.conversations.pigeon.PigeonMessageDto

/** Maps Twilio [Message] values including media attachments. */
object MessageMediaMapping {
  fun mapMedia(media: Media): PigeonMediaAttachmentDto {
    return PigeonMediaAttachmentDto(
      sid = media.sid,
      contentType = media.contentType ?: "application/octet-stream",
      filename = media.filename ?: "",
      sizeBytes = media.size.toInt(),
    )
  }

  fun enrichMessageDto(
    base: PigeonMessageDto,
    message: Message,
  ): PigeonMessageDto {
    val attachments =
      message.attachedMedia?.map { mapMedia(it) } ?: emptyList()
    if (attachments.isEmpty()) {
      return base
    }
    return PigeonMessageDto(
      sid = base.sid,
      conversationSid = base.conversationSid,
      author = base.author,
      body = base.body,
      messageIndex = base.messageIndex,
      dateCreatedEpochMs = base.dateCreatedEpochMs,
      contentType = PigeonMessageContentType.MEDIA,
      mediaAttachments = attachments,
      attributesJson = base.attributesJson,
    )
  }
}
