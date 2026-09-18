import '../models/video_participant.dart';
import '../models/video_room.dart';
import 'package:twilio_flutter_core/twilio_flutter_core.dart';

/// Events emitted by [TwilioVideoClient.events].
sealed class TwilioVideoEvent {
  const TwilioVideoEvent();
}

final class RoomConnected extends TwilioVideoEvent {
  const RoomConnected(this.room);

  final TwilioVideoRoom room;
}

final class RoomDisconnected extends TwilioVideoEvent {
  const RoomDisconnected(this.room);

  final TwilioVideoRoom room;
}

final class RoomReconnecting extends TwilioVideoEvent {
  const RoomReconnecting(this.room);

  final TwilioVideoRoom room;
}

final class RoomReconnected extends TwilioVideoEvent {
  const RoomReconnected(this.room);

  final TwilioVideoRoom room;
}

final class ParticipantConnected extends TwilioVideoEvent {
  const ParticipantConnected(this.participant);

  final TwilioVideoParticipant participant;
}

final class ParticipantDisconnected extends TwilioVideoEvent {
  const ParticipantDisconnected(this.participant);

  final TwilioVideoParticipant participant;
}

final class DominantSpeakerChanged extends TwilioVideoEvent {
  const DominantSpeakerChanged(this.participant);

  /// Null when no participant is the dominant speaker.
  final TwilioVideoParticipant? participant;
}

final class VideoError extends TwilioVideoEvent {
  const VideoError({
    required this.code,
    required this.message,
  });

  final TwilioErrorCode code;
  final String message;
}
