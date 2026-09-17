// Pigeon-generated method signatures use arg_* parameter names.
// ignore_for_file: non_constant_identifier_names

import 'package:twilio_flutter_conversations/src/pigeon/conversations.pigeon.dart';

/// Minimal host API stub for unit tests.
class FakeTwilioConversationsHostApi extends TwilioConversationsHostApi {
  FakeTwilioConversationsHostApi({this.onConnect});

  void Function(ConnectRequest request)? onConnect;
  var connectCount = 0;

  @override
  Future<void> connect(ConnectRequest arg_request) async {
    connectCount++;
    onConnect?.call(arg_request);
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> updateAccessToken(String arg_accessToken) async {}

  @override
  Future<MessageDto> sendMessage(
    SendMessageRequest arg_request,
  ) async {
    return MessageDto(
      sid: 'IMxxx',
      conversationSid: arg_request.conversationSid,
      author: 'test_user',
      body: arg_request.body,
      messageIndex: 1,
      dateCreatedEpochMs: DateTime.utc(2024, 1, 1).millisecondsSinceEpoch,
      contentType: MessageContentType.text,
      attributesJson: arg_request.attributesJson,
    );
  }

  @override
  Future<List<ConversationDto>> listConversations() async => [];

  @override
  Future<ConversationDto> getConversation(
    String arg_sidOrUniqueName,
  ) async {
    return ConversationDto(
      sid: arg_sidOrUniqueName,
      uniqueName: '',
      friendlyName: '',
    );
  }

  @override
  Future<List<MessageDto>> getLastMessages(
    GetMessagesRequest arg_request,
  ) async =>
      [];

  @override
  Future<List<ParticipantDto>> getParticipants(
    ConversationRequest arg_request,
  ) async =>
      [];

  @override
  Future<void> sendTyping(ConversationRequest arg_request) async {}

  @override
  Future<List<MessageDto>> getMessagesBefore(
    GetMessagesBeforeRequest arg_request,
  ) async =>
      [];

  @override
  Future<MessageDto> sendMediaMessage(
    SendMediaMessageRequest arg_request,
  ) async {
    return MessageDto(
      sid: 'IMmedia',
      conversationSid: arg_request.conversationSid,
      author: 'test_user',
      body: arg_request.caption ?? '',
      messageIndex: 2,
      dateCreatedEpochMs: DateTime.utc(2024, 1, 1).millisecondsSinceEpoch,
      contentType: MessageContentType.media,
    );
  }

  @override
  Future<String> getMediaTemporaryUrl(
    GetMediaTemporaryUrlRequest arg_request,
  ) async =>
      'https://example.com/media';
}
