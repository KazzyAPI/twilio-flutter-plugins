import '../models/video_participant.dart';
import '../models/video_room.dart';
import '../pigeon/video.pigeon.dart';

class PigeonDtoMapper {
  const PigeonDtoMapper();

  TwilioVideoRoom mapRoom(VideoRoomDto dto) {
    return TwilioVideoRoom(
      sid: dto.sid,
      name: dto.name,
      state: _mapRoomState(dto.state),
    );
  }

  TwilioVideoParticipant mapParticipant(VideoParticipantDto dto) {
    return TwilioVideoParticipant(
      sid: dto.sid,
      identity: dto.identity,
    );
  }

  TwilioVideoRoomState _mapRoomState(VideoRoomState state) {
    return switch (state) {
      VideoRoomState.disconnected => TwilioVideoRoomState.disconnected,
      VideoRoomState.connecting => TwilioVideoRoomState.connecting,
      VideoRoomState.connected => TwilioVideoRoomState.connected,
      VideoRoomState.reconnecting => TwilioVideoRoomState.reconnecting,
      VideoRoomState.disconnectedWithError =>
        TwilioVideoRoomState.disconnectedWithError,
    };
  }
}
