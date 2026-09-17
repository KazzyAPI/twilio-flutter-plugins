// Pigeon-generated method signatures use arg_* parameter names.
// ignore_for_file: non_constant_identifier_names

import 'package:twilio_flutter_conversations/src/pigeon/conversations.pigeon.dart';

class FakeConversationsHostApi extends TwilioConversationsHostApi {
  FakeConversationsHostApi({this.onConnect});

  void Function(PigeonConnectRequest request)? onConnect;
  var connectCount = 0;
  var disconnectCount = 0;

  @override
  Future<void> connect(PigeonConnectRequest arg_request) async {
    connectCount++;
    onConnect?.call(arg_request);
  }

  @override
  Future<void> disconnect() async {
    disconnectCount++;
  }

  @override
  Future<void> updateAccessToken(String arg_accessToken) async {}

  @override
  Future<PigeonMessageDto> sendMessage(
    PigeonSendMessageRequest arg_request,
  ) async {
    return PigeonMessageDto(
      sid: 'IMxxx',
      conversationSid: arg_request.conversationSid,
      author: 'test_user',
      body: arg_request.body,
      messageIndex: 1,
      dateCreatedEpochMs: DateTime.utc(2024, 1, 1).millisecondsSinceEpoch,
      contentType: PigeonMessageContentType.text,
      attributesJson: arg_request.attributesJson,
    );
  }

  @override
  Future<List<PigeonConversationDto>> listConversations() async => [];

  @override
  Future<PigeonConversationDto> getConversation(String arg_sidOrUniqueName) async {
    return PigeonConversationDto(
      sid: arg_sidOrUniqueName,
      uniqueName: '',
      friendlyName: '',
    );
  }

  @override
  Future<List<PigeonMessageDto>> getLastMessages(
    PigeonGetMessagesRequest arg_request,
  ) async =>
      [];

  @override
  Future<List<PigeonParticipantDto>> getParticipants(
    PigeonConversationRequest arg_request,
  ) async =>
      [];

  @override
  Future<void> sendTyping(PigeonConversationRequest arg_request) async {}

  @override
  Future<List<PigeonMessageDto>> getMessagesBefore(
    PigeonGetMessagesBeforeRequest arg_request,
  ) async =>
      [];

  @override
  Future<PigeonMessageDto> sendMediaMessage(
    PigeonSendMediaMessageRequest arg_request,
  ) async {
    return PigeonMessageDto(
      sid: 'IMmedia',
      conversationSid: arg_request.conversationSid,
      author: 'test_user',
      body: arg_request.caption ?? '',
      messageIndex: 2,
      dateCreatedEpochMs: DateTime.utc(2024, 1, 2).millisecondsSinceEpoch,
      contentType: PigeonMessageContentType.media,
    );
  }

  @override
  Future<String> getMediaTemporaryUrl(
    PigeonGetMediaTemporaryUrlRequest arg_request,
  ) async =>
      'https://example.com/media';
}
