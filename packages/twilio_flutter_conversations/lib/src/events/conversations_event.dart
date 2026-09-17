import '../models/client_connection_state.dart';
import '../models/client_synchronization_status.dart';
import '../models/conversation.dart';
import '../models/conversation_synchronization_status.dart';
import '../models/message.dart';
import '../models/participant.dart';
import '../models/user.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

/// Events emitted by [TwilioConversationsClient.events].
sealed class TwilioConversationsEvent {
  const TwilioConversationsEvent();
}

final class ClientSynchronizationStatusUpdated extends TwilioConversationsEvent {
  const ClientSynchronizationStatusUpdated(this.status);

  final TwilioClientSynchronizationStatus status;
}

final class ClientConnectionStateChanged extends TwilioConversationsEvent {
  const ClientConnectionStateChanged(this.state);

  final TwilioClientConnectionState state;
}

final class ConversationAdded extends TwilioConversationsEvent {
  const ConversationAdded(this.conversation);

  final TwilioConversation conversation;
}

final class ConversationUpdated extends TwilioConversationsEvent {
  const ConversationUpdated(this.conversation, this.updateReason);

  final TwilioConversation conversation;
  final String updateReason;
}

final class ConversationDeleted extends TwilioConversationsEvent {
  const ConversationDeleted(this.conversation);

  final TwilioConversation conversation;
}

final class ConversationSynchronizationUpdated extends TwilioConversationsEvent {
  const ConversationSynchronizationUpdated(
    this.conversation,
    this.status,
  );

  final TwilioConversation conversation;
  final TwilioConversationSynchronizationStatus status;
}

final class MessageAdded extends TwilioConversationsEvent {
  const MessageAdded(this.message);

  final TwilioMessage message;
}

final class MessageUpdated extends TwilioConversationsEvent {
  const MessageUpdated(this.message, this.updateReason);

  final TwilioMessage message;
  final String updateReason;
}

final class MessageDeleted extends TwilioConversationsEvent {
  const MessageDeleted(this.message);

  final TwilioMessage message;
}

final class ParticipantAdded extends TwilioConversationsEvent {
  const ParticipantAdded(this.participant);

  final TwilioParticipant participant;
}

final class ParticipantUpdated extends TwilioConversationsEvent {
  const ParticipantUpdated(this.participant, this.updateReason);

  final TwilioParticipant participant;
  final String updateReason;
}

final class ParticipantDeleted extends TwilioConversationsEvent {
  const ParticipantDeleted(this.participant);

  final TwilioParticipant participant;
}

final class TypingStarted extends TwilioConversationsEvent {
  const TypingStarted(this.participant);

  final TwilioParticipant participant;
}

final class TypingEnded extends TwilioConversationsEvent {
  const TypingEnded(this.participant);

  final TwilioParticipant participant;
}

final class UserUpdated extends TwilioConversationsEvent {
  const UserUpdated(this.user, this.updateReason);

  final TwilioUser user;
  final String updateReason;
}

final class UserSubscribed extends TwilioConversationsEvent {
  const UserSubscribed(this.user);

  final TwilioUser user;
}

final class UserUnsubscribed extends TwilioConversationsEvent {
  const UserUnsubscribed(this.user);

  final TwilioUser user;
}

final class TokenAboutToExpire extends TwilioConversationsEvent {
  const TokenAboutToExpire();
}

final class TokenExpired extends TwilioConversationsEvent {
  const TokenExpired();
}

final class NotificationSubscribed extends TwilioConversationsEvent {
  const NotificationSubscribed();
}

final class ConversationsError extends TwilioConversationsEvent {
  const ConversationsError(this.exception);

  final TwilioFlutterException exception;
}
