import 'package:twilio_flutter_core/twilio_flutter_core.dart';

import '../mappers/pigeon_dto_mapper.dart';
import '../pigeon/video.pigeon.dart';
import 'video_event.dart';

class VideoEventMapper {
  VideoEventMapper({PigeonDtoMapper? dtoMapper})
      : _dtoMapper = dtoMapper ?? const PigeonDtoMapper();

  final PigeonDtoMapper _dtoMapper;

  TwilioVideoEvent? map(VideoNativeEvent event) {
    return switch (event.type) {
      VideoEventType.roomConnected => RoomConnected(
          _dtoMapper.mapRoom(event.room!),
        ),
      VideoEventType.roomDisconnected => RoomDisconnected(
          _dtoMapper.mapRoom(event.room!),
        ),
      VideoEventType.roomReconnecting => RoomReconnecting(
          _dtoMapper.mapRoom(event.room!),
        ),
      VideoEventType.roomReconnected => RoomReconnected(
          _dtoMapper.mapRoom(event.room!),
        ),
      VideoEventType.participantConnected => ParticipantConnected(
          _dtoMapper.mapParticipant(event.participant!),
        ),
      VideoEventType.participantDisconnected => ParticipantDisconnected(
          _dtoMapper.mapParticipant(event.participant!),
        ),
      VideoEventType.dominantSpeakerChanged => DominantSpeakerChanged(
          event.participant == null
              ? null
              : _dtoMapper.mapParticipant(event.participant!),
        ),
      VideoEventType.error => VideoError(
          code: TwilioErrorCode.parse(event.errorCode),
          message: event.errorMessage ?? 'Twilio Video SDK error',
        ),
    };
  }
}
