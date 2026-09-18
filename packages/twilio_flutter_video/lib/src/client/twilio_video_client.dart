import 'dart:async';

import 'package:flutter/services.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

import '../events/video_event.dart';
import '../events/video_event_mapper.dart';
import '../models/connection_state.dart';
import '../pigeon/video.pigeon.dart';
import '../platform/platform_exception_mapper.dart';

/// Twilio Programmable Video client for Flutter apps.
///
/// Forwards native room callbacks on [events]. Call [connect] with a backend
/// access token and room name, then listen for participant and room updates.
///
/// Use one instance per Flutter engine (Pigeon registers a single event handler).
/// Prefer [TwilioVideoSession] for app-level lifecycle.
class TwilioVideoClient {
  factory TwilioVideoClient({
    TwilioVideoHostApi? hostApi,
    VideoEventMapper? eventMapper,
    PlatformExceptionMapper? exceptionMapper,
  }) {
    return TwilioVideoClient._(
      hostApi: hostApi ?? TwilioVideoHostApi(),
      eventMapper: eventMapper ?? VideoEventMapper(),
      exceptionMapper: exceptionMapper ?? PlatformExceptionMapper(),
    );
  }

  TwilioVideoClient._({
    required this._hostApi,
    required this._eventMapper,
    required this._exceptionMapper,
  });

  final TwilioVideoHostApi _hostApi;
  final VideoEventMapper _eventMapper;
  final PlatformExceptionMapper _exceptionMapper;
  final StreamController<TwilioVideoEvent> _eventController =
      StreamController<TwilioVideoEvent>.broadcast();

  var _flutterApiRegistered = false;
  TwilioVideoConnectionState _connectionState =
      TwilioVideoConnectionState.disconnected;

  TwilioVideoConnectionState get connectionState => _connectionState;

  Stream<TwilioVideoEvent> get events => _eventController.stream;

  Future<void> connect({
    required String accessToken,
    required String roomName,
    bool enableAudio = true,
    bool enableVideo = true,
  }) async {
    _assertNotDisposed();
    if (_connectionState == TwilioVideoConnectionState.connecting ||
        _connectionState == TwilioVideoConnectionState.connected) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.alreadyConnected,
        message: 'Client is already connected or connecting.',
      );
    }

    _registerFlutterApi();
    _connectionState = TwilioVideoConnectionState.connecting;
    try {
      await _hostApi.connect(
        VideoConnectRequest(
          accessToken: accessToken,
          roomName: roomName,
          enableAudio: enableAudio,
          enableVideo: enableVideo,
        ),
      );
      if (_connectionState == TwilioVideoConnectionState.disposed) {
        return;
      }
      _connectionState = TwilioVideoConnectionState.connected;
    } on PlatformException catch (error) {
      if (_connectionState != TwilioVideoConnectionState.disposed) {
        _connectionState = TwilioVideoConnectionState.disconnected;
      }
      throw _exceptionMapper.map(error);
    } catch (error) {
      if (_connectionState != TwilioVideoConnectionState.disposed) {
        _connectionState = TwilioVideoConnectionState.disconnected;
      }
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_connectionState == TwilioVideoConnectionState.disposed ||
        _connectionState == TwilioVideoConnectionState.disconnected) {
      return;
    }
    if (_connectionState == TwilioVideoConnectionState.disconnecting) {
      return;
    }

    _connectionState = TwilioVideoConnectionState.disconnecting;
    try {
      await _hostApi.disconnect();
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    } finally {
      if (_connectionState != TwilioVideoConnectionState.disposed) {
        _connectionState = TwilioVideoConnectionState.disconnected;
      }
    }
  }

  Future<void> setLocalAudioEnabled(bool enabled) async {
    _assertConnected();
    try {
      await _hostApi.setLocalAudioEnabled(enabled);
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  Future<void> setLocalVideoEnabled(bool enabled) async {
    _assertConnected();
    try {
      await _hostApi.setLocalVideoEnabled(enabled);
    } on PlatformException catch (error) {
      throw _exceptionMapper.map(error);
    }
  }

  Future<void> dispose() async {
    if (_connectionState == TwilioVideoConnectionState.disposed) {
      return;
    }

    final shouldDisconnect =
        _connectionState == TwilioVideoConnectionState.connected ||
            _connectionState == TwilioVideoConnectionState.connecting ||
            _connectionState == TwilioVideoConnectionState.disconnecting;

    _connectionState = TwilioVideoConnectionState.disposed;

    if (shouldDisconnect) {
      try {
        await _hostApi.disconnect();
      } on PlatformException {
        // Engine teardown: ignore native disconnect failures.
      }
    }

    TwilioVideoFlutterApi.setUp(null);
    _flutterApiRegistered = false;
    await _eventController.close();
  }

  void _registerFlutterApi() {
    if (_flutterApiRegistered) {
      return;
    }
    TwilioVideoFlutterApi.setUp(_VideoFlutterApiHandler(this));
    _flutterApiRegistered = true;
  }

  void _assertNotDisposed() {
    if (_connectionState == TwilioVideoConnectionState.disposed) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.internal,
        message: 'Client has been disposed.',
      );
    }
  }

  void _assertConnected() {
    _assertNotDisposed();
    if (_connectionState != TwilioVideoConnectionState.connected) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.notConnected,
        message: 'Client is not connected to a room.',
      );
    }
  }

  void _handleNativeEvent(VideoNativeEvent event) {
    if (_connectionState == TwilioVideoConnectionState.disposed) {
      return;
    }
    final mapped = _eventMapper.map(event);
    if (mapped != null) {
      _eventController.add(mapped);
    }
    if (event.type == VideoEventType.roomDisconnected) {
      _connectionState = TwilioVideoConnectionState.disconnected;
    }
  }
}

final class _VideoFlutterApiHandler extends TwilioVideoFlutterApi {
  _VideoFlutterApiHandler(this._client);

  final TwilioVideoClient _client;

  @override
  void onNativeEvent(VideoNativeEvent event) {
    _client._handleNativeEvent(event);
  }
}
