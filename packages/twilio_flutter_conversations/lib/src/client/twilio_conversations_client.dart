import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

import '../events/conversations_event.dart';
import '../events/conversations_event_mapper.dart';
import '../mappers/pigeon_dto_mapper.dart';
import '../models/client_connection_state.dart';
import '../models/connection_state.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/participant.dart';
import '../models/send_media_message_command.dart';
import '../models/send_message_command.dart';
import '../pigeon/conversations.pigeon.dart';
import '../platform/platform_exception_mapper.dart';
import '../media/twilio_conversations_media_policy.dart';
import 'connect_session_guard.dart';
import 'connection_state_merge.dart';
import 'twilio_conversations_client_registry.dart';

/// Twilio Conversations client for Flutter apps.
///
/// Forwards native SDK callbacks on [events]. Call [connect] with a backend
/// access token, then listen for synchronization, conversation, message, and
/// token lifecycle updates.
///
/// Use one instance per Flutter engine (Pigeon registers a single event handler).
///
/// Prefer [TwilioConversationsSession] to avoid duplicate clients and event
/// subscriptions. Set [registerSingleton] to `false` in tests.
class TwilioConversationsClient {
  /// Pass a custom [hostApi] in tests to avoid platform channels.
  factory TwilioConversationsClient({
    TwilioConversationsHostApi? hostApi,
    ConversationsEventMapper? eventMapper,
    PigeonDtoMapper? dtoMapper,
    PlatformExceptionMapper? exceptionMapper,
    bool registerSingleton = true,
  }) {
    final resolvedDtoMapper = dtoMapper ?? _defaultDtoMapper;
    final client = TwilioConversationsClient._(
      hostApi: hostApi ?? TwilioConversationsHostApi(),
      dtoMapper: resolvedDtoMapper,
      eventMapper: eventMapper ??
          ConversationsEventMapper(dtoMapper: resolvedDtoMapper),
      exceptionMapper: exceptionMapper ?? PlatformExceptionMapper(),
    );
    if (registerSingleton) {
      TwilioConversationsClientRegistry.attach(client);
    }
    return client;
  }

  TwilioConversationsClient._({
    required TwilioConversationsHostApi hostApi,
    required ConversationsEventMapper eventMapper,
    required PigeonDtoMapper dtoMapper,
    required PlatformExceptionMapper exceptionMapper,
  })  : _hostApi = hostApi,
        _dtoMapper = dtoMapper,
        _eventMapper = eventMapper,
        _exceptionMapper = exceptionMapper;

  static const _defaultDtoMapper = PigeonDtoMapper();

  final TwilioConversationsHostApi _hostApi;
  final PigeonDtoMapper _dtoMapper;
  final ConversationsEventMapper _eventMapper;
  final PlatformExceptionMapper _exceptionMapper;
  final StreamController<TwilioConversationsEvent> _eventController =
      StreamController<TwilioConversationsEvent>.broadcast();

  var _flutterApiRegistered = false;
  var _ignoreSdkConnectionEventsUntilConnect = false;
  final ConnectSessionGuard _connectSessionGuard = ConnectSessionGuard();
  TwilioConversationsConnectionState _connectionState =
      TwilioConversationsConnectionState.disconnected;

  /// Client lifecycle state tracked on the Dart side.
  TwilioConversationsConnectionState get connectionState => _connectionState;

  /// Stream of conversation lifecycle events from the native SDK.
  Stream<TwilioConversationsEvent> get events => _eventController.stream;

  /// Connects to Twilio Conversations with an access token from your backend.
  ///
  /// Emits [ClientSynchronizationStatusUpdated] via [events] while the SDK
  /// synchronizes local state. Throws [TwilioFlutterException] when the native
  /// connect call fails or when already connected/connecting.
  Future<void> connect({required String accessToken}) async {
    _assertNotDisposed();
    if (_connectionState == TwilioConversationsConnectionState.connecting ||
        _connectionState == TwilioConversationsConnectionState.connected) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.alreadyConnected,
        message: 'Client is already connected or connecting.',
      );
    }

    _registerFlutterApi();
    _ignoreSdkConnectionEventsUntilConnect = false;
    final connectToken = _connectSessionGuard.beginConnect();
    _connectionState = TwilioConversationsConnectionState.connecting;
    try {
      await _hostApi.connect(
        PigeonConnectRequest(accessToken: accessToken),
      );
      if (_connectionState == TwilioConversationsConnectionState.disposed) {
        return;
      }
      if (!_connectSessionGuard.isActive(connectToken)) {
        _connectionState = TwilioConversationsConnectionState.disconnected;
        return;
      }
      _connectionState = TwilioConversationsConnectionState.connected;
    } on PlatformException catch (error) {
      if (_connectSessionGuard.isActive(connectToken) &&
          _connectionState != TwilioConversationsConnectionState.disposed) {
        _connectionState = TwilioConversationsConnectionState.disconnected;
      }
      throw _exceptionMapper.map(error);
    } catch (error) {
      if (_connectSessionGuard.isActive(connectToken) &&
          _connectionState != TwilioConversationsConnectionState.disposed) {
        _connectionState = TwilioConversationsConnectionState.disconnected;
      }
      rethrow;
    }
  }

  /// Disconnects and releases native SDK resources.
  ///
  /// Safe to call when already disconnected.
  Future<void> disconnect() async {
    if (_connectionState == TwilioConversationsConnectionState.disposed) {
      return;
    }
    if (_connectionState == TwilioConversationsConnectionState.disconnected) {
      return;
    }
    if (_connectionState == TwilioConversationsConnectionState.disconnecting) {
      return;
    }

    _connectSessionGuard.invalidate();
    _connectionState = TwilioConversationsConnectionState.disconnecting;
    try {
      await _hostApi.disconnect();
    } on PlatformException catch (error) {
      if (_connectionState != TwilioConversationsConnectionState.disposed) {
        _connectionState = TwilioConversationsConnectionState.disconnected;
      }
      throw _exceptionMapper.map(error);
    }
    if (_connectionState != TwilioConversationsConnectionState.disposed) {
      _connectionState = TwilioConversationsConnectionState.disconnected;
    }
  }

  /// Updates the access token after [TokenAboutToExpire] or [TokenExpired].
  ///
  /// Provide a fresh JWT from your backend token endpoint.
  Future<void> updateAccessToken(String accessToken) async {
    _assertConnectedForMutation('updateAccessToken');
    try {
      await _hostApi.updateAccessToken(accessToken);
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  /// Sends a text message to the conversation identified by [conversationSid].
  ///
  /// Optional [attributes] are custom JSON-compatible metadata stored on the
  /// Twilio message (for example `{'orderId': '123', 'priority': 'high'}`).
  /// Omit [attributes] (default empty map) to send without custom metadata.
  ///
  /// Returns the sent [TwilioMessage] metadata when the native SDK confirms
  /// delivery to Twilio's service.
  Future<TwilioMessage> sendMessage({
    required String conversationSid,
    required String body,
    Map<String, Object?> attributes = const {},
  }) async {
    return send(SendMessageCommand.create(
      conversationSid: conversationSid,
      body: body,
      attributes: attributes,
    ));
  }

  /// Sends a message using a [SendMessageCommand].
  Future<TwilioMessage> send(SendMessageCommand command) async {
    _assertConnectedForMutation('sendMessage');
    try {
      final dto = await _hostApi.sendMessage(
        PigeonSendMessageRequest(
          conversationSid: command.conversationSid,
          body: command.body,
          attributesJson: TwilioJsonObjectCodec.encode(command.attributes),
        ),
      );
      return _dtoMapper.mapMessage(dto);
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    } on TwilioFlutterException {
      rethrow;
    }
  }

  /// Returns conversations currently in the local SDK cache.
  Future<List<TwilioConversation>> listConversations() async {
    _assertConnectedForMutation('listConversations');
    try {
      final dtos = await _hostApi.listConversations();
      return dtos
          .whereType<PigeonConversationDto>()
          .map(_dtoMapper.mapConversation)
          .toList(growable: false);
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  /// Resolves a conversation by SID or unique name.
  Future<TwilioConversation> getConversation(String sidOrUniqueName) async {
    _assertConnectedForMutation('getConversation');
    try {
      final dto = await _hostApi.getConversation(sidOrUniqueName);
      return _dtoMapper.mapConversation(dto);
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  /// Loads messages with index strictly less than [beforeMessageIndex].
  Future<List<TwilioMessage>> getMessagesBefore({
    required String conversationSid,
    required int beforeMessageIndex,
    int count = 50,
  }) async {
    _assertConnectedForMutation('getMessagesBefore');
    try {
      final dtos = await _hostApi.getMessagesBefore(
        PigeonGetMessagesBeforeRequest(
          conversationSid: conversationSid,
          beforeMessageIndex: beforeMessageIndex,
          count: count,
        ),
      );
      return dtos
          .whereType<PigeonMessageDto>()
          .map(_dtoMapper.mapMessage)
          .toList(growable: false);
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  /// Sends a media message from a readable file path on device.
  ///
  /// Validates MIME type and size against [TwilioConversationsMediaPolicy]
  /// before calling native code.
  Future<TwilioMessage> sendMediaMessage(SendMediaMessageCommand command) async {
    _assertConnectedForMutation('sendMediaMessage');
    final file = File(command.filePath);
    if (!file.existsSync()) {
      throw TwilioFlutterException(
        code: TwilioErrorCode.invalidArgument,
        message: 'Media file not found: ${command.filePath}',
      );
    }
    TwilioConversationsMediaPolicy.validateUpload(
      mimeType: command.mimeType,
      sizeBytes: file.lengthSync(),
    );
    try {
      final dto = await _hostApi.sendMediaMessage(
        PigeonSendMediaMessageRequest(
          conversationSid: command.conversationSid,
          filePath: command.filePath,
          mimeType: command.mimeType,
          filename: command.filename,
          caption: command.caption.isEmpty ? null : command.caption,
          attributesJson: TwilioJsonObjectCodec.encode(command.attributes),
        ),
      );
      return _dtoMapper.mapMessage(dto);
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  /// Returns a short-lived HTTPS URL to download message media.
  Future<String> getMediaTemporaryUrl({
    required String conversationSid,
    required int messageIndex,
    required String mediaSid,
  }) async {
    _assertConnectedForMutation('getMediaTemporaryUrl');
    try {
      return await _hostApi.getMediaTemporaryUrl(
        PigeonGetMediaTemporaryUrlRequest(
          conversationSid: conversationSid,
          messageIndex: messageIndex,
          mediaSid: mediaSid,
        ),
      );
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  /// Loads the most recent [count] messages (1–100) for a conversation.
  Future<List<TwilioMessage>> getLastMessages({
    required String conversationSid,
    int count = 50,
  }) async {
    _assertConnectedForMutation('getLastMessages');
    try {
      final dtos = await _hostApi.getLastMessages(
        PigeonGetMessagesRequest(
          conversationSid: conversationSid,
          count: count,
        ),
      );
      return dtos
          .whereType<PigeonMessageDto>()
          .map(_dtoMapper.mapMessage)
          .toList(growable: false);
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  /// Returns participants for a conversation.
  Future<List<TwilioParticipant>> getParticipants(String conversationSid) async {
    _assertConnectedForMutation('getParticipants');
    try {
      final dtos = await _hostApi.getParticipants(
        PigeonConversationRequest(conversationSid: conversationSid),
      );
      return dtos
          .whereType<PigeonParticipantDto>()
          .map(_dtoMapper.mapParticipant)
          .toList(growable: false);
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  /// Sends a typing indicator for the local user in a conversation.
  Future<void> sendTyping(String conversationSid) async {
    _assertConnectedForMutation('sendTyping');
    try {
      await _hostApi.sendTyping(
        PigeonConversationRequest(conversationSid: conversationSid),
      );
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  /// Disconnects (if needed), closes the event stream, and clears the Flutter API handler.
  ///
  /// After [dispose], this instance must not be reused.
  Future<void> dispose() async {
    if (_connectionState == TwilioConversationsConnectionState.disposed) {
      return;
    }

    final shouldDisconnect =
        _connectionState == TwilioConversationsConnectionState.connected ||
        _connectionState == TwilioConversationsConnectionState.connecting ||
        _connectionState == TwilioConversationsConnectionState.disconnecting;

    _connectSessionGuard.invalidate();
    _connectionState = TwilioConversationsConnectionState.disposed;

    if (shouldDisconnect) {
      try {
        await _hostApi.disconnect();
      } on PlatformException {
        // Engine teardown: ignore native disconnect failures.
      }
    }

    TwilioConversationsFlutterApi.setup(null);
    _flutterApiRegistered = false;
    TwilioConversationsClientRegistry.detach(this);
    await _eventController.close();
  }

  void _registerFlutterApi() {
    if (_flutterApiRegistered) {
      return;
    }
    TwilioConversationsFlutterApi.setup(
      _TwilioConversationsFlutterHandler(
        eventMapper: _eventMapper,
        eventController: _eventController,
        onMappedEvent: _applySdkConnectionState,
      ),
    );
    _flutterApiRegistered = true;
  }

  void _assertNotDisposed() {
    if (_connectionState == TwilioConversationsConnectionState.disposed) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.internal,
        message: 'Client has been disposed.',
      );
    }
  }

  void _assertConnectedForMutation(String operation) {
    _assertNotDisposed();
    if (_connectionState != TwilioConversationsConnectionState.connected) {
      throw TwilioFlutterException(
        code: TwilioErrorCode.notConnected,
        message: 'Call connect() before $operation.',
      );
    }
  }

  void _applySdkConnectionState(TwilioClientConnectionState sdkState) {
    if (_ignoreSdkConnectionEventsUntilConnect) {
      return;
    }
    final previous = _connectionState;
    _connectionState = mergeSdkConnectionState(_connectionState, sdkState);
    if (previous == TwilioConversationsConnectionState.connected &&
        _connectionState == TwilioConversationsConnectionState.disconnected &&
        _isSdkConnectionLoss(sdkState)) {
      _ignoreSdkConnectionEventsUntilConnect = true;
      unawaited(_disconnectNativeAfterSdkLoss());
    }
  }

  bool _isSdkConnectionLoss(TwilioClientConnectionState sdkState) {
    return sdkState == TwilioClientConnectionState.disconnected ||
        sdkState == TwilioClientConnectionState.denied ||
        sdkState == TwilioClientConnectionState.error ||
        sdkState == TwilioClientConnectionState.fatal;
  }

  Future<void> _disconnectNativeAfterSdkLoss() async {
    _connectSessionGuard.invalidate();
    try {
      await _hostApi.disconnect();
    } on PlatformException {
      // Native client may already be torn down.
    }
  }

  /// Feeds a native event through the same path as the platform channel (tests).
  @visibleForTesting
  void ingestNativeEventForTesting(PigeonConversationsNativeEvent event) {
    _registerFlutterApi();
    if (_eventController.isClosed) {
      return;
    }
    try {
      final mapped = _eventMapper.map(event);
      if (mapped case ClientConnectionStateChanged(:final state)) {
        _applySdkConnectionState(state);
      }
      _eventController.add(mapped);
    } on TwilioFlutterException catch (error) {
      _eventController.add(ConversationsError(error));
    }
  }
}

class _TwilioConversationsFlutterHandler implements TwilioConversationsFlutterApi {
  _TwilioConversationsFlutterHandler({
    required ConversationsEventMapper eventMapper,
    required StreamController<TwilioConversationsEvent> eventController,
    required void Function(TwilioClientConnectionState state) onMappedEvent,
  })  : _eventMapper = eventMapper,
        _eventController = eventController,
        _onSdkConnectionState = onMappedEvent;

  final ConversationsEventMapper _eventMapper;
  final StreamController<TwilioConversationsEvent> _eventController;
  final void Function(TwilioClientConnectionState state) _onSdkConnectionState;

  @override
  void onNativeEvent(PigeonConversationsNativeEvent event) {
    if (_eventController.isClosed) {
      return;
    }
    try {
      final mapped = _eventMapper.map(event);
      if (mapped case ClientConnectionStateChanged(:final state)) {
        _onSdkConnectionState(state);
      }
      _eventController.add(mapped);
    } on TwilioFlutterException catch (error) {
      _eventController.add(ConversationsError(error));
    }
  }
}
