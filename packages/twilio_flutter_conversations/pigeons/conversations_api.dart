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
enum ClientSynchronizationStatus {
  unknown,
  started,
  conversationsListCompleted,
  completed,
  failed,
}

/// Native client connection state.
enum ClientConnectionState {
  unknown,
  connecting,
  connected,
  disconnected,
  denied,
  error,
  fatal,
}

/// Per-conversation synchronization state.
enum ConversationSynchronizationStatus {
  unknown,
  none,
  identifier,
  metadata,
  syncWindow,
  all,
  failed,
}

/// Discriminator for events emitted from native code to Dart.
enum ConversationsEventType {
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

class ConnectRequest {
  ConnectRequest({required this.accessToken});

  String accessToken;
}

class ConversationDto {
  ConversationDto({
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

enum MessageContentType {
  text,
  media,
}

class MediaAttachmentDto {
  MediaAttachmentDto({
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

class MessageDto {
  MessageDto({
    required this.sid,
    required this.conversationSid,
    required this.author,
    required this.body,
    required this.messageIndex,
    required this.dateCreatedEpochMs,
    this.contentType = MessageContentType.text,
    this.mediaAttachments,
    this.attributesJson,
  });

  String sid;
  String conversationSid;
  String author;
  String body;
  int messageIndex;
  int dateCreatedEpochMs;
  MessageContentType contentType;
  List<MediaAttachmentDto?>? mediaAttachments;
  String? attributesJson;
}

class ParticipantDto {
  ParticipantDto({
    required this.sid,
    required this.identity,
    required this.conversationSid,
  });

  String sid;
  String identity;
  String conversationSid;
}

class UserDto {
  UserDto({
    required this.identity,
    this.friendlyName,
  });

  String identity;
  String? friendlyName;
}

class SendMessageRequest {
  SendMessageRequest({
    required this.conversationSid,
    required this.body,
    this.attributesJson,
  });

  String conversationSid;
  String body;
  String? attributesJson;
}

class GetMessagesRequest {
  GetMessagesRequest({
    required this.conversationSid,
    required this.count,
  });

  String conversationSid;
  int count;
}

class GetMessagesBeforeRequest {
  GetMessagesBeforeRequest({
    required this.conversationSid,
    required this.beforeMessageIndex,
    required this.count,
  });

  String conversationSid;
  int beforeMessageIndex;
  int count;
}

class SendMediaMessageRequest {
  SendMediaMessageRequest({
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

class GetMediaTemporaryUrlRequest {
  GetMediaTemporaryUrlRequest({
    required this.conversationSid,
    required this.messageIndex,
    required this.mediaSid,
  });

  String conversationSid;
  int messageIndex;
  String mediaSid;
}

class ConversationRequest {
  ConversationRequest({required this.conversationSid});

  String conversationSid;
}

class ConversationsNativeEvent {
  ConversationsNativeEvent({
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

  ConversationsEventType type;
  ClientSynchronizationStatus? synchronizationStatus;
  ClientConnectionState? connectionState;
  ConversationSynchronizationStatus? conversationSyncStatus;
  ConversationDto? conversation;
  MessageDto? message;
  ParticipantDto? participant;
  UserDto? user;
  String? updateReason;
  String? errorCode;
  String? errorMessage;
}

@HostApi()
abstract class TwilioConversationsHostApi {
  @async
  void connect(ConnectRequest request);

  @async
  void disconnect();

  @async
  void updateAccessToken(String accessToken);

  @async
  MessageDto sendMessage(SendMessageRequest request);

  @async
  List<ConversationDto> listConversations();

  @async
  ConversationDto getConversation(String sidOrUniqueName);

  @async
  List<MessageDto> getLastMessages(GetMessagesRequest request);

  @async
  List<MessageDto> getMessagesBefore(GetMessagesBeforeRequest request);

  @async
  MessageDto sendMediaMessage(SendMediaMessageRequest request);

  @async
  String getMediaTemporaryUrl(GetMediaTemporaryUrlRequest request);

  @async
  List<ParticipantDto> getParticipants(ConversationRequest request);

  @async
  void sendTyping(ConversationRequest request);
}

@FlutterApi()
abstract class TwilioConversationsFlutterApi {
  void onNativeEvent(ConversationsNativeEvent event);
}
