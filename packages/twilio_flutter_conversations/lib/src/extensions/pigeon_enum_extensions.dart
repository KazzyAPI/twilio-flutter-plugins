import '../models/client_connection_state.dart';
import '../models/client_synchronization_status.dart';
import '../models/conversation_synchronization_status.dart';
import '../pigeon/conversations.pigeon.dart';

extension ClientSynchronizationStatusX on ClientSynchronizationStatus {
  TwilioClientSynchronizationStatus toPublic() {
    return switch (this) {
      ClientSynchronizationStatus.started =>
        TwilioClientSynchronizationStatus.started,
      ClientSynchronizationStatus.conversationsListCompleted =>
        TwilioClientSynchronizationStatus.conversationsListCompleted,
      ClientSynchronizationStatus.completed =>
        TwilioClientSynchronizationStatus.completed,
      ClientSynchronizationStatus.failed =>
        TwilioClientSynchronizationStatus.failed,
      ClientSynchronizationStatus.unknown =>
        TwilioClientSynchronizationStatus.unknown,
    };
  }
}

extension NullableClientSynchronizationStatusX
    on ClientSynchronizationStatus? {
  TwilioClientSynchronizationStatus toPublic() {
    return this?.toPublic() ?? TwilioClientSynchronizationStatus.unknown;
  }
}

extension ClientConnectionStateX on ClientConnectionState {
  TwilioClientConnectionState toPublic() {
    return switch (this) {
      ClientConnectionState.connecting =>
        TwilioClientConnectionState.connecting,
      ClientConnectionState.connected =>
        TwilioClientConnectionState.connected,
      ClientConnectionState.disconnected =>
        TwilioClientConnectionState.disconnected,
      ClientConnectionState.denied => TwilioClientConnectionState.denied,
      ClientConnectionState.error => TwilioClientConnectionState.error,
      ClientConnectionState.fatal => TwilioClientConnectionState.fatal,
      ClientConnectionState.unknown =>
        TwilioClientConnectionState.unknown,
    };
  }
}

extension NullableClientConnectionStateX on ClientConnectionState? {
  TwilioClientConnectionState toPublic() {
    return this?.toPublic() ?? TwilioClientConnectionState.unknown;
  }
}

extension ConversationSynchronizationStatusX
    on ConversationSynchronizationStatus {
  TwilioConversationSynchronizationStatus toPublic() {
    return switch (this) {
      ConversationSynchronizationStatus.none =>
        TwilioConversationSynchronizationStatus.none,
      ConversationSynchronizationStatus.identifier =>
        TwilioConversationSynchronizationStatus.identifier,
      ConversationSynchronizationStatus.metadata =>
        TwilioConversationSynchronizationStatus.metadata,
      ConversationSynchronizationStatus.syncWindow =>
        TwilioConversationSynchronizationStatus.syncWindow,
      ConversationSynchronizationStatus.all =>
        TwilioConversationSynchronizationStatus.all,
      ConversationSynchronizationStatus.failed =>
        TwilioConversationSynchronizationStatus.failed,
      ConversationSynchronizationStatus.unknown =>
        TwilioConversationSynchronizationStatus.unknown,
    };
  }
}

extension NullableConversationSynchronizationStatusX
    on ConversationSynchronizationStatus? {
  TwilioConversationSynchronizationStatus toPublic() {
    return this?.toPublic() ?? TwilioConversationSynchronizationStatus.unknown;
  }
}
