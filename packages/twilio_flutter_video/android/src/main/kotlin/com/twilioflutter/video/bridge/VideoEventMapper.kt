package com.twilioflutter.video.bridge

import com.twilio.video.RemoteParticipant
import com.twilio.video.Room
import com.twilio.video.TwilioException
import com.twilioflutter.video.pigeon.VideoEventType
import com.twilioflutter.video.pigeon.VideoNativeEvent
import com.twilioflutter.video.pigeon.VideoParticipantDto
import com.twilioflutter.video.pigeon.VideoRoomDto
import com.twilioflutter.video.pigeon.VideoRoomState

class VideoEventMapper {
  fun roomConnected(room: Room): VideoNativeEvent =
    VideoNativeEvent(
      type = VideoEventType.ROOM_CONNECTED,
      room = mapRoom(room, VideoRoomState.CONNECTED),
    )

  fun roomDisconnected(room: Room, error: TwilioException?): VideoNativeEvent {
    val state =
      if (error != null) VideoRoomState.DISCONNECTED_WITH_ERROR else VideoRoomState.DISCONNECTED
    return VideoNativeEvent(
      type = VideoEventType.ROOM_DISCONNECTED,
      room = mapRoom(room, state),
      errorCode = error?.let { "sdk_failure" },
      errorMessage = error?.message,
    )
  }

  fun roomReconnecting(room: Room): VideoNativeEvent =
    VideoNativeEvent(
      type = VideoEventType.ROOM_RECONNECTING,
      room = mapRoom(room, VideoRoomState.RECONNECTING),
    )

  fun roomReconnected(room: Room): VideoNativeEvent =
    VideoNativeEvent(
      type = VideoEventType.ROOM_RECONNECTED,
      room = mapRoom(room, VideoRoomState.CONNECTED),
    )

  fun participantConnected(participant: RemoteParticipant): VideoNativeEvent =
    VideoNativeEvent(
      type = VideoEventType.PARTICIPANT_CONNECTED,
      participant = mapParticipant(participant),
    )

  fun participantDisconnected(participant: RemoteParticipant): VideoNativeEvent =
    VideoNativeEvent(
      type = VideoEventType.PARTICIPANT_DISCONNECTED,
      participant = mapParticipant(participant),
    )

  fun dominantSpeakerChanged(participant: RemoteParticipant?): VideoNativeEvent =
    VideoNativeEvent(
      type = VideoEventType.DOMINANT_SPEAKER_CHANGED,
      participant = participant?.let { mapParticipant(it) },
    )

  fun error(code: String, message: String): VideoNativeEvent =
    VideoNativeEvent(
      type = VideoEventType.ERROR,
      errorCode = code,
      errorMessage = message,
    )

  private fun mapRoom(room: Room, state: VideoRoomState): VideoRoomDto =
    VideoRoomDto(
      sid = room.sid,
      name = room.name ?: "",
      state = state,
    )

  private fun mapParticipant(participant: RemoteParticipant): VideoParticipantDto =
    VideoParticipantDto(
      sid = participant.sid,
      identity = participant.identity,
    )
}
