import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/conversations.pigeon.dart',
    dartOptions: DartOptions(),
    swiftOut: 'ios/Classes/Pigeon/ConversationsPigeon.swift',
    swiftOptions: SwiftOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/twilioflutter/conversations/pigeon/ConversationsPigeon.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.twilioflutter.conversations.pigeon',
    ),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Client synchronization status mirrored from the Twilio Conversations SDK.
enum PigeonClientSynchronizationStatus {
  unknown,
  started,
  conversationsListCompleted,
  completed,
  failed,
}

/// Native client connection state.
enum PigeonClientConnectionState {
  unknown,
  connecting,
  connected,
  disconnected,
  denied,
  error,
  fatal,
}

/// Per-conversation synchronization state.
enum PigeonConversationSynchronizationStatus {
  unknown,
  none,
  identifier,
  metadata,
  syncWindow,
  all,
  failed,
}

/// Discriminator for events emitted from native code to Dart.
enum PigeonConversationsEventType {
  clientSynchronizationStatusUpdated,
  connectionStateChanged,
  conversationAdded,
  conversationUpdated,
  conversationDeleted,
  conversationSynchronizationUpdated,
  messageAdded,
  messageUpdated,
  messageDeleted,
  participantAdded,
  participantUpdated,
  participantDeleted,
  typingStarted,
  typingEnded,
  userUpdated,
  userSubscribed,
  userUnsubscribed,
  tokenAboutToExpire,
  tokenExpired,
  notificationSubscribed,
  error,
}

class PigeonConnectRequest {
  PigeonConnectRequest({required this.accessToken});

  String accessToken;
}

class PigeonConversationDto {
  PigeonConversationDto({
    required this.sid,
    required this.uniqueName,
    required this.friendlyName,
    this.lastMessageIndex,
  });

  String sid;
  String uniqueName;
  String friendlyName;
  int? lastMessageIndex;
}

enum PigeonMessageContentType {
  text,
  media,
}

class PigeonMediaAttachmentDto {
  PigeonMediaAttachmentDto({
    required this.sid,
    required this.contentType,
    required this.filename,
    required this.sizeBytes,
  });

  String sid;
  String contentType;
  String filename;
  int sizeBytes;
}

class PigeonMessageDto {
  PigeonMessageDto({
    required this.sid,
    required this.conversationSid,
    required this.author,
    required this.body,
    required this.messageIndex,
    required this.dateCreatedEpochMs,
    this.contentType = PigeonMessageContentType.text,
    this.mediaAttachments,
    this.attributesJson,
  });

  String sid;
  String conversationSid;
  String author;
  String body;
  int messageIndex;
  int dateCreatedEpochMs;
  PigeonMessageContentType contentType;
  List<PigeonMediaAttachmentDto?>? mediaAttachments;
  String? attributesJson;
}

class PigeonParticipantDto {
  PigeonParticipantDto({
    required this.sid,
    required this.identity,
    required this.conversationSid,
  });

  String sid;
  String identity;
  String conversationSid;
}

class PigeonUserDto {
  PigeonUserDto({
    required this.identity,
    this.friendlyName,
  });

  String identity;
  String? friendlyName;
}

class PigeonSendMessageRequest {
  PigeonSendMessageRequest({
    required this.conversationSid,
    required this.body,
    this.attributesJson,
  });

  String conversationSid;
  String body;
  String? attributesJson;
}

class PigeonGetMessagesRequest {
  PigeonGetMessagesRequest({
    required this.conversationSid,
    required this.count,
  });

  String conversationSid;
  int count;
}

class PigeonGetMessagesBeforeRequest {
  PigeonGetMessagesBeforeRequest({
    required this.conversationSid,
    required this.beforeMessageIndex,
    required this.count,
  });

  String conversationSid;
  int beforeMessageIndex;
  int count;
}

class PigeonSendMediaMessageRequest {
  PigeonSendMediaMessageRequest({
    required this.conversationSid,
    required this.filePath,
    required this.mimeType,
    required this.filename,
    this.caption,
    this.attributesJson,
  });

  String conversationSid;
  String filePath;
  String mimeType;
  String filename;
  String? caption;
  String? attributesJson;
}

class PigeonGetMediaTemporaryUrlRequest {
  PigeonGetMediaTemporaryUrlRequest({
    required this.conversationSid,
    required this.messageIndex,
    required this.mediaSid,
  });

  String conversationSid;
  int messageIndex;
  String mediaSid;
}

class PigeonConversationRequest {
  PigeonConversationRequest({required this.conversationSid});

  String conversationSid;
}

class PigeonConversationsNativeEvent {
  PigeonConversationsNativeEvent({
    required this.type,
    this.synchronizationStatus,
    this.connectionState,
    this.conversationSyncStatus,
    this.conversation,
    this.message,
    this.participant,
    this.user,
    this.updateReason,
    this.errorCode,
    this.errorMessage,
  });

  PigeonConversationsEventType type;
  PigeonClientSynchronizationStatus? synchronizationStatus;
  PigeonClientConnectionState? connectionState;
  PigeonConversationSynchronizationStatus? conversationSyncStatus;
  PigeonConversationDto? conversation;
  PigeonMessageDto? message;
  PigeonParticipantDto? participant;
  PigeonUserDto? user;
  String? updateReason;
  String? errorCode;
  String? errorMessage;
}

@HostApi()
abstract class TwilioConversationsHostApi {
  @async
  void connect(PigeonConnectRequest request);

  @async
  void disconnect();

  @async
  void updateAccessToken(String accessToken);

  @async
  PigeonMessageDto sendMessage(PigeonSendMessageRequest request);

  @async
  List<PigeonConversationDto> listConversations();

  @async
  PigeonConversationDto getConversation(String sidOrUniqueName);

  @async
  List<PigeonMessageDto> getLastMessages(PigeonGetMessagesRequest request);

  @async
  List<PigeonMessageDto> getMessagesBefore(PigeonGetMessagesBeforeRequest request);

  @async
  PigeonMessageDto sendMediaMessage(PigeonSendMediaMessageRequest request);

  @async
  String getMediaTemporaryUrl(PigeonGetMediaTemporaryUrlRequest request);

  @async
  List<PigeonParticipantDto> getParticipants(PigeonConversationRequest request);

  @async
  void sendTyping(PigeonConversationRequest request);
}

@FlutterApi()
abstract class TwilioConversationsFlutterApi {
  void onNativeEvent(PigeonConversationsNativeEvent event);
}
