import 'dart:async';
import 'dart:io';

import 'package:twilio_flutter_core/twilio_flutter_core.dart';

import '../events/conversations_event.dart';
import '../media/twilio_conversations_media_policy.dart';
import '../models/connection_state.dart';
import '../models/message.dart';
import '../models/send_media_message_command.dart';
import 'twilio_conversations_client.dart';
import 'twilio_conversations_client_registry.dart';

/// App-level helper: one client, one event subscription, same foreground/background API.
///
/// Create near the root of your chat feature (e.g. provider scope). Do not create a
/// new session on every widget rebuild or app resume.
final class TwilioConversationsSession {
  TwilioConversationsSession({
    TwilioConversationsClient? client,
    bool registerSingleton = true,
  })  : client = client ?? TwilioConversationsClient(registerSingleton: false),
        _registerSingleton = registerSingleton {
    if (_registerSingleton) {
      TwilioConversationsClientRegistry.attach(this.client);
    }
  }

  final TwilioConversationsClient client;
  final bool _registerSingleton;

  StreamSubscription<TwilioConversationsEvent>? _eventsSubscription;
  var _started = false;

  /// Whether [start] completed successfully at least once.
  bool get isStarted => _started;

  /// Subscribes to [client.events] once, then connects if needed.
  ///
  /// Calling again replaces the previous subscription (no stacked listeners).
  /// Use the same session when returning from background; do not create a new
  /// session on every resume.
  Future<void> start({
    required String accessToken,
    required void Function(TwilioConversationsEvent event) onEvent,
    void Function(Object error, StackTrace stackTrace)? onEventError,
  }) async {
    await _eventsSubscription?.cancel();
    _eventsSubscription = onEventError == null
        ? client.events.listen(onEvent)
        : client.events.listen(onEvent, onError: onEventError);

    switch (client.connectionState) {
      case TwilioConversationsConnectionState.disposed:
        throw const TwilioFlutterException(
          code: TwilioErrorCode.internal,
          message: 'Client has been disposed.',
        );
      case TwilioConversationsConnectionState.disconnecting:
        throw const TwilioFlutterException(
          code: TwilioErrorCode.notConnected,
          message: 'Client is disconnecting; wait for stop() to finish.',
        );
      case TwilioConversationsConnectionState.disconnected:
        await client.connect(accessToken: accessToken);
      case TwilioConversationsConnectionState.connecting:
        final waitUntil = DateTime.now().add(const Duration(seconds: 30));
        while (client.connectionState ==
                TwilioConversationsConnectionState.connecting &&
            DateTime.now().isBefore(waitUntil)) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
        if (client.connectionState ==
            TwilioConversationsConnectionState.connecting) {
          throw const TwilioFlutterException(
            code: TwilioErrorCode.internal,
            message: 'Timed out waiting for connect to finish.',
          );
        }
        if (client.connectionState ==
            TwilioConversationsConnectionState.connected) {
          await client.updateAccessToken(accessToken);
        } else if (client.connectionState ==
            TwilioConversationsConnectionState.disconnected) {
          await client.connect(accessToken: accessToken);
        } else if (client.connectionState ==
                TwilioConversationsConnectionState.disconnecting ||
            client.connectionState ==
                TwilioConversationsConnectionState.disposed) {
          throw const TwilioFlutterException(
            code: TwilioErrorCode.notConnected,
            message: 'Client is not available to start a session.',
          );
        }
      case TwilioConversationsConnectionState.connected:
        await client.updateAccessToken(accessToken);
    }
    if (client.connectionState == TwilioConversationsConnectionState.disposed) {
      throw const TwilioFlutterException(
        code: TwilioErrorCode.internal,
        message: 'Client has been disposed.',
      );
    }
    _started = true;
  }

  /// Sends media after local file and MIME validation.
  Future<TwilioMessage> sendMedia(SendMediaMessageCommand command) async {
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
    return client.sendMediaMessage(command);
  }

  /// Cancels the event subscription and disconnects the client.
  Future<void> stop() async {
    await _eventsSubscription?.cancel();
    _eventsSubscription = null;
    _started = false;
    if (client.connectionState != TwilioConversationsConnectionState.disposed) {
      await client.disconnect();
    }
  }

  /// Tears down the session and client. The session must not be used afterward.
  Future<void> dispose() async {
    await _eventsSubscription?.cancel();
    _eventsSubscription = null;
    _started = false;
    await client.dispose();
    if (_registerSingleton) {
      TwilioConversationsClientRegistry.detach(client);
    }
  }
}
