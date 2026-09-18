import AVFoundation
import Flutter
import Foundation
import TwilioVideo

final class VideoBridge: NSObject, TwilioVideoHostApi, RoomDelegate {
  private let eventEmitter: VideoEventEmitter
  private let eventMapper = VideoEventMapper()

  private var room: Room?
  private var localAudioTrack: LocalAudioTrack?
  private var localVideoTrack: LocalVideoTrack?
  private var cameraSource: CameraSource?
  private var connectContinuation: CheckedContinuation<Void, Error>?
  private var disconnectContinuation: CheckedContinuation<Void, Error>?

  init(binaryMessenger: FlutterBinaryMessenger) {
    eventEmitter = VideoEventEmitter(binaryMessenger: binaryMessenger)
    super.init()
  }

  func connect(request: VideoConnectRequest) async throws {
    if room != nil || connectContinuation != nil {
      throw PigeonError(
        code: "already_connected",
        message: "Twilio Video client is already connected or connecting.",
        details: nil
      )
    }

    releaseLocalTracks()

    if request.enableAudio {
      let audioOptions = AudioOptions { builder in
        builder.isEchoCancellationEnabled = true
      }
      localAudioTrack = LocalAudioTrack(options: audioOptions, enabled: true, name: "microphone")
      guard localAudioTrack != nil else {
        throw PigeonError(
          code: "sdk_failure",
          message: "Failed to create local audio track. Check microphone permission.",
          details: nil
        )
      }
    }

    if request.enableVideo {
      cameraSource = CameraSource(delegate: self)
      guard let cameraSource else {
        throw PigeonError(code: "sdk_failure", message: "Failed to create camera source.", details: nil)
      }
      guard let frontCamera = CameraSource.captureDevice(position: .front) else {
        throw PigeonError(code: "sdk_failure", message: "No front-facing camera found.", details: nil)
      }
      localVideoTrack = LocalVideoTrack(source: cameraSource, enabled: true, name: "camera")
      guard localVideoTrack != nil else {
        throw PigeonError(code: "sdk_failure", message: "Failed to create local video track.", details: nil)
      }
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        cameraSource.startCapture(device: frontCamera) { _, _, error in
          if let error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume()
          }
        }
      }
    }

    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      connectContinuation = continuation

      let connectOptions = ConnectOptions(token: request.accessToken) { builder in
        builder.roomName = request.roomName
        builder.isDominantSpeakerEnabled = true
        if let audio = self.localAudioTrack {
          builder.audioTracks = [audio]
        }
        if let video = self.localVideoTrack {
          builder.videoTracks = [video]
        }
      }

      room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
    }
  }

  func disconnect() async throws {
    if let pendingConnect = connectContinuation {
      connectContinuation = nil
      room?.disconnect()
      pendingConnect.resume(
        throwing: PigeonError(
          code: "internal",
          message: "Connect cancelled by disconnect.",
          details: nil
        )
      )
      return
    }

    guard let activeRoom = room else {
      return
    }

    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      disconnectContinuation = continuation
      activeRoom.disconnect()
    }
  }

  func setLocalAudioEnabled(enabled: Bool) async throws {
    guard room != nil else {
      throw PigeonError(code: "not_connected", message: "Not connected to a Video room.", details: nil)
    }
    localAudioTrack?.isEnabled = enabled
  }

  func setLocalVideoEnabled(enabled: Bool) async throws {
    guard room != nil else {
      throw PigeonError(code: "not_connected", message: "Not connected to a Video room.", details: nil)
    }
    localVideoTrack?.isEnabled = enabled
  }

  func roomDidConnect(room: Room) {
    self.room = room
    eventEmitter.emit(event: eventMapper.roomConnected(room: room))
    for remote in room.remoteParticipants {
      eventEmitter.emit(event: eventMapper.participantConnected(remote))
    }
    connectContinuation?.resume()
    connectContinuation = nil
  }

  func roomDidFailToConnect(room: Room, error: Error) {
    self.room = nil
    releaseLocalTracks()
    connectContinuation?.resume(
      throwing: PigeonError(
        code: "sdk_failure",
        message: error.localizedDescription,
        details: nil
      )
    )
    connectContinuation = nil
  }

  func roomDidDisconnect(room: Room, error: Error?) {
    guard room === self.room else {
      return
    }
    if let error {
      eventEmitter.emit(
        event: eventMapper.error(code: "sdk_failure", message: error.localizedDescription)
      )
    }
    eventEmitter.emit(event: eventMapper.roomDisconnected(room: room, error: error))
    cleanupAfterDisconnect()
    disconnectContinuation?.resume()
    disconnectContinuation = nil
  }

  func roomIsReconnecting(room: Room, error: Error) {
    eventEmitter.emit(event: eventMapper.roomReconnecting(room: room))
  }

  func roomDidReconnect(room: Room) {
    eventEmitter.emit(event: eventMapper.roomReconnected(room: room))
  }

  func participantDidConnect(room: Room, participant: RemoteParticipant) {
    eventEmitter.emit(event: eventMapper.participantConnected(participant))
  }

  func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
    eventEmitter.emit(event: eventMapper.participantDisconnected(participant))
  }

  func dominantSpeakerDidChange(room: Room, participant: RemoteParticipant?) {
    eventEmitter.emit(event: eventMapper.dominantSpeakerChanged(participant))
  }

  private func cleanupAfterDisconnect() {
    room = nil
    releaseLocalTracks()
  }

  private func releaseLocalTracks() {
    localAudioTrack = nil
    localVideoTrack = nil
    cameraSource?.stopCapture()
    cameraSource = nil
  }
}

extension VideoBridge: CameraSourceDelegate {
  func cameraSourceDidFail(source: CameraSource, error: Error) {
    eventEmitter.emit(
      event: eventMapper.error(code: "sdk_failure", message: error.localizedDescription)
    )
  }
}
