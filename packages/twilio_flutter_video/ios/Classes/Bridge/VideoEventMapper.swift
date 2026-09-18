import Foundation
import TwilioVideo

final class VideoEventMapper {
  func roomConnected(room: Room) -> VideoNativeEvent {
    VideoNativeEvent(
      type: .roomConnected,
      room: mapRoom(room, state: .connected),
      participant: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func roomDisconnected(room: Room, error: Error?) -> VideoNativeEvent {
    let state: VideoRoomState = error == nil ? .disconnected : .disconnectedWithError
    return VideoNativeEvent(
      type: .roomDisconnected,
      room: mapRoom(room, state: state),
      participant: nil,
      errorCode: error == nil ? nil : "sdk_failure",
      errorMessage: error?.localizedDescription
    )
  }

  func roomReconnecting(room: Room) -> VideoNativeEvent {
    VideoNativeEvent(
      type: .roomReconnecting,
      room: mapRoom(room, state: .reconnecting),
      participant: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func roomReconnected(room: Room) -> VideoNativeEvent {
    VideoNativeEvent(
      type: .roomReconnected,
      room: mapRoom(room, state: .connected),
      participant: nil,
      errorCode: nil,
      errorMessage: nil
    )
  }

  func participantConnected(_ participant: RemoteParticipant) -> VideoNativeEvent {
    VideoNativeEvent(
      type: .participantConnected,
      room: nil,
      participant: mapParticipant(participant),
      errorCode: nil,
      errorMessage: nil
    )
  }

  func participantDisconnected(_ participant: RemoteParticipant) -> VideoNativeEvent {
    VideoNativeEvent(
      type: .participantDisconnected,
      room: nil,
      participant: mapParticipant(participant),
      errorCode: nil,
      errorMessage: nil
    )
  }

  func dominantSpeakerChanged(_ participant: RemoteParticipant?) -> VideoNativeEvent {
    VideoNativeEvent(
      type: .dominantSpeakerChanged,
      room: nil,
      participant: participant.map { mapParticipant($0) },
      errorCode: nil,
      errorMessage: nil
    )
  }

  func error(code: String, message: String) -> VideoNativeEvent {
    VideoNativeEvent(
      type: .error,
      room: nil,
      participant: nil,
      errorCode: code,
      errorMessage: message
    )
  }

  private func mapRoom(_ room: Room, state: VideoRoomState) -> VideoRoomDto {
    VideoRoomDto(
      sid: room.sid,
      name: room.name ?? "",
      state: state
    )
  }

  private func mapParticipant(_ participant: RemoteParticipant) -> VideoParticipantDto {
    VideoParticipantDto(
      sid: participant.sid,
      identity: participant.identity
    )
  }
}
