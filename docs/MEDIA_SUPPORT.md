# Media support (Conversations chat)

## Supported file types (mobile chat uploads)

The plugin validates MIME types before upload using `TwilioConversationsMediaPolicy`. These align with common **Conversations chat** participant media (not SMS/WhatsApp channel limits).

| Category | MIME types |
| --- | --- |
| Images | `image/jpeg`, `image/jpg`, `image/png`, `image/gif`, `image/bmp`, `image/webp` |
| Video | `video/mp4`, `video/mpeg`, `video/quicktime`, `video/x-msvideo` |
| Audio | `audio/mpeg`, `audio/mp4`, `audio/wav`, `audio/x-wav`, `audio/ogg` |
| Documents | `application/pdf`, `text/plain`, `text/vcard` |

Programmatic list: `TwilioConversationsMediaPolicy.supportedMimeTypes`.

## Size limit

- **150 MiB** per file (`TwilioConversationsMediaPolicy.maxUploadBytes`), checked on device before native upload.
- Twilio may reject uploads that pass local checks if service limits change — handle `sdk_failure` on send.
- **iOS:** the bridge reads the full file into memory before upload. Stay within the policy limit; very large files may pressure memory on low-RAM devices.

## Send and download

Use `TwilioConversationsSession.sendMedia` in app code (same validation) or call the client directly:

```dart
await client.sendMediaMessage(
  SendMediaMessageCommand.create(
    conversationSid: sid,
    filePath: absolutePath,
    mimeType: 'image/jpeg',
    filename: 'photo.jpg',
    caption: 'Optional caption',
  ),
);

final url = await client.getMediaTemporaryUrl(
  conversationSid: sid,
  messageIndex: message.messageIndex,
  mediaSid: message.primaryMedia!.sid,
);
```

Temporary URLs expire in about **300 seconds**; call `getMediaTemporaryUrl` again when needed.

## API vs channels

| Path | Use when |
| --- | --- |
| `sendMediaMessage` (this plugin) | Chat participant in a Conversation on iOS/Android |
| Twilio REST + MCS | Server-side upload, SMS/WhatsApp, or stricter channel rules |

Official references:

- [Media support overview](https://www.twilio.com/docs/conversations-classic/media-support-conversations)
- [Classic media limits](https://www.twilio.com/docs/conversations/classic-media-limits)
