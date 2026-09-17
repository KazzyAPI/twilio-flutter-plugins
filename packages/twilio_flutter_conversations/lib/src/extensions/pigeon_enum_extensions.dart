import '../models/client_connection_state.dart';
import '../models/client_synchronization_status.dart';
import '../models/conversation_synchronization_status.dart';
import '../pigeon/conversations.pigeon.dart';

extension PigeonClientSynchronizationStatusX on PigeonClientSynchronizationStatus {
  TwilioClientSynchronizationStatus toPublic() {
    return switch (this) {
      PigeonClientSynchronizationStatus.started =>
        TwilioClientSynchronizationStatus.started,
      PigeonClientSynchronizationStatus.conversationsListCompleted =>
        TwilioClientSynchronizationStatus.conversationsListCompleted,
      PigeonClientSynchronizationStatus.completed =>
        TwilioClientSynchronizationStatus.completed,
      PigeonClientSynchronizationStatus.failed =>
        TwilioClientSynchronizationStatus.failed,
      PigeonClientSynchronizationStatus.unknown =>
        TwilioClientSynchronizationStatus.unknown,
    };
  }
}

extension NullablePigeonClientSynchronizationStatusX
    on PigeonClientSynchronizationStatus? {
  TwilioClientSynchronizationStatus toPublic() {
    return this?.toPublic() ?? TwilioClientSynchronizationStatus.unknown;
  }
}

extension PigeonClientConnectionStateX on PigeonClientConnectionState {
  TwilioClientConnectionState toPublic() {
    return switch (this) {
      PigeonClientConnectionState.connecting =>
        TwilioClientConnectionState.connecting,
      PigeonClientConnectionState.connected =>
        TwilioClientConnectionState.connected,
      PigeonClientConnectionState.disconnected =>
        TwilioClientConnectionState.disconnected,
      PigeonClientConnectionState.denied => TwilioClientConnectionState.denied,
      PigeonClientConnectionState.error => TwilioClientConnectionState.error,
      PigeonClientConnectionState.fatal => TwilioClientConnectionState.fatal,
      PigeonClientConnectionState.unknown =>
        TwilioClientConnectionState.unknown,
    };
  }
}

extension NullablePigeonClientConnectionStateX on PigeonClientConnectionState? {
  TwilioClientConnectionState toPublic() {
    return this?.toPublic() ?? TwilioClientConnectionState.unknown;
  }
}

extension PigeonConversationSynchronizationStatusX
    on PigeonConversationSynchronizationStatus {
  TwilioConversationSynchronizationStatus toPublic() {
    return switch (this) {
      PigeonConversationSynchronizationStatus.none =>
        TwilioConversationSynchronizationStatus.none,
      PigeonConversationSynchronizationStatus.identifier =>
        TwilioConversationSynchronizationStatus.identifier,
      PigeonConversationSynchronizationStatus.metadata =>
        TwilioConversationSynchronizationStatus.metadata,
      PigeonConversationSynchronizationStatus.syncWindow =>
        TwilioConversationSynchronizationStatus.syncWindow,
      PigeonConversationSynchronizationStatus.all =>
        TwilioConversationSynchronizationStatus.all,
      PigeonConversationSynchronizationStatus.failed =>
        TwilioConversationSynchronizationStatus.failed,
      PigeonConversationSynchronizationStatus.unknown =>
        TwilioConversationSynchronizationStatus.unknown,
    };
  }
}

extension NullablePigeonConversationSynchronizationStatusX
    on PigeonConversationSynchronizationStatus? {
  TwilioConversationSynchronizationStatus toPublic() {
    return this?.toPublic() ?? TwilioConversationSynchronizationStatus.unknown;
  }
}
