package com.twilioflutter.conversations.bridge

import com.twilio.conversations.Media
import com.twilio.conversations.Message
import com.twilioflutter.conversations.pigeon.MediaAttachmentDto
import com.twilioflutter.conversations.pigeon.MessageContentType
import com.twilioflutter.conversations.pigeon.MessageDto

/** Maps Twilio [Message] values including media attachments. */
object MessageMediaMapping {
  fun mapMedia(media: Media): MediaAttachmentDto {
    return MediaAttachmentDto(
      sid = media.sid,
      contentType = media.contentType ?: "application/octet-stream",
      filename = media.filename ?: "",
      sizeBytes = media.size,
    )
  }

  fun enrichMessageDto(
    base: MessageDto,
    message: Message,
  ): MessageDto {
    val attachments =
      message.attachedMedia?.map { mapMedia(it) } ?: emptyList()
    if (attachments.isEmpty()) {
      return base
    }
    return MessageDto(
      sid = base.sid,
      conversationSid = base.conversationSid,
      author = base.author,
      body = base.body,
      messageIndex = base.messageIndex,
      dateCreatedEpochMs = base.dateCreatedEpochMs,
      contentType = MessageContentType.MEDIA,
      mediaAttachments = attachments,
      attributesJson = base.attributesJson,
    )
  }
}
