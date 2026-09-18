package com.twilioflutter.video.bridge

import android.content.Context
import com.twilio.video.Camera2Capturer
import com.twilio.video.ConnectOptions
import com.twilio.video.LocalAudioTrack
import com.twilio.video.LocalVideoTrack
import com.twilio.video.RemoteParticipant
import com.twilio.video.Room
import com.twilio.video.TwilioException
import com.twilio.video.Video
import com.twilioflutter.video.pigeon.FlutterError
import com.twilioflutter.video.pigeon.TwilioVideoHostApi
import com.twilioflutter.video.pigeon.VideoConnectRequest
import io.flutter.plugin.common.BinaryMessenger
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.suspendCancellableCoroutine
import tvi.webrtc.Camera2Enumerator

class VideoBridge(
  context: Context,
  binaryMessenger: BinaryMessenger,
) : TwilioVideoHostApi {
  private val applicationContext = context.applicationContext
  private val eventEmitter = VideoEventEmitter(binaryMessenger)
  private val eventMapper = VideoEventMapper()

  private var room: Room? = null
  private var localAudioTrack: LocalAudioTrack? = null
  private var localVideoTrack: LocalVideoTrack? = null
  private var cameraCapturer: Camera2Capturer? = null
  private var connectContinuation: kotlinx.coroutines.CancellableContinuation<Unit>? = null
  private var disconnectContinuation: kotlinx.coroutines.CancellableContinuation<Unit>? = null

  override suspend fun connect(request: VideoConnectRequest) {
    if (room != null || connectContinuation != null) {
      throw FlutterError(
        "already_connected",
        "Twilio Video client is already connected or connecting.",
        null,
      )
    }

    try {
      suspendCancellableCoroutine { continuation ->
        connectContinuation = continuation
        continuation.invokeOnCancellation {
          connectContinuation = null
          room?.disconnect()
        }

        releaseLocalTracks()

        if (request.enableAudio) {
          localAudioTrack =
            LocalAudioTrack.create(applicationContext, true, "microphone")
          if (localAudioTrack == null) {
            continuation.resumeWithException(
              FlutterError(
                "sdk_failure",
                "Failed to create local audio track. Check RECORD_AUDIO permission.",
                null,
              ),
            )
            connectContinuation = null
            return@suspendCancellableCoroutine
          }
        }
        if (request.enableVideo) {
          val enumerator = Camera2Enumerator(applicationContext)
          val deviceName =
            enumerator.deviceNames.firstOrNull { enumerator.isFrontFacing(it) }
          if (deviceName == null) {
            continuation.resumeWithException(
              FlutterError("sdk_failure", "No front-facing camera found.", null),
            )
            connectContinuation = null
            return@suspendCancellableCoroutine
          }
          cameraCapturer = Camera2Capturer(applicationContext, deviceName)
          localVideoTrack =
            LocalVideoTrack.create(
              applicationContext,
              true,
              cameraCapturer!!,
              "camera",
            )
          if (localVideoTrack == null) {
            continuation.resumeWithException(
              FlutterError(
                "sdk_failure",
                "Failed to create local video track. Check CAMERA permission.",
                null,
              ),
            )
            connectContinuation = null
            return@suspendCancellableCoroutine
          }
        }

        val optionsBuilder =
          ConnectOptions.Builder(request.accessToken)
            .roomName(request.roomName)
            .enableDominantSpeaker(true)
        localAudioTrack?.let { optionsBuilder.audioTracks(listOf(it)) }
        localVideoTrack?.let { optionsBuilder.videoTracks(listOf(it)) }

        val listener =
          object : Room.Listener {
            override fun onConnected(activeRoom: Room) {
              if (connectContinuation == null) {
                return
              }
              room = activeRoom
              eventEmitter.emit(eventMapper.roomConnected(activeRoom))
              activeRoom.remoteParticipants.forEach { remote ->
                eventEmitter.emit(eventMapper.participantConnected(remote))
              }
              connectContinuation?.resume(Unit)
              connectContinuation = null
            }

            override fun onConnectFailure(activeRoom: Room, e: TwilioException) {
              if (connectContinuation == null) {
                return
              }
              room = null
              releaseLocalTracks()
              connectContinuation?.resumeWithException(
                FlutterError(
                  "sdk_failure",
                  e.message ?: "Failed to connect to Video room",
                  null,
                ),
              )
              connectContinuation = null
            }

            override fun onDisconnected(activeRoom: Room, e: TwilioException?) {
              if (activeRoom != room) {
                return
              }
              if (e != null) {
                eventEmitter.emit(
                  eventMapper.error(
                    "sdk_failure",
                    e.message ?: "Room disconnected with error",
                  ),
                )
              }
              eventEmitter.emit(eventMapper.roomDisconnected(activeRoom, e))
              cleanupAfterDisconnect()
              disconnectContinuation?.resume(Unit)
              disconnectContinuation = null
            }

            override fun onReconnecting(activeRoom: Room, e: TwilioException) {
              eventEmitter.emit(eventMapper.roomReconnecting(activeRoom))
            }

            override fun onReconnected(activeRoom: Room) {
              eventEmitter.emit(eventMapper.roomReconnected(activeRoom))
            }

            override fun onParticipantConnected(
              activeRoom: Room,
              participant: RemoteParticipant,
            ) {
              eventEmitter.emit(eventMapper.participantConnected(participant))
            }

            override fun onParticipantDisconnected(
              activeRoom: Room,
              participant: RemoteParticipant,
            ) {
              eventEmitter.emit(eventMapper.participantDisconnected(participant))
            }

            override fun onDominantSpeakerChanged(
              activeRoom: Room,
              participant: RemoteParticipant?,
            ) {
              eventEmitter.emit(eventMapper.dominantSpeakerChanged(participant))
            }

            override fun onRecordingStarted(activeRoom: Room) {}

            override fun onRecordingStopped(activeRoom: Room) {}
          }

        room = Video.connect(applicationContext, optionsBuilder.build(), listener)
      }
    } catch (e: CancellationException) {
      room?.disconnect()
      throw FlutterError("internal", "Connect cancelled.", null)
    }
  }

  override suspend fun disconnect() {
    val pendingConnect = connectContinuation
    if (pendingConnect != null) {
      connectContinuation = null
      room?.disconnect()
      pendingConnect.resumeWithException(
        FlutterError("internal", "Connect cancelled by disconnect.", null),
      )
      return
    }
    val activeRoom = room ?: return
    suspendCancellableCoroutine { continuation ->
      disconnectContinuation = continuation
      activeRoom.disconnect()
    }
  }

  override suspend fun setLocalAudioEnabled(enabled: Boolean) {
    val activeRoom = room
      ?: throw FlutterError("not_connected", "Not connected to a Video room.", null)
    activeRoom.localParticipant?.localAudioTracks?.firstOrNull()?.localAudioTrack?.enable(
      enabled,
    )
  }

  override suspend fun setLocalVideoEnabled(enabled: Boolean) {
    val activeRoom = room
      ?: throw FlutterError("not_connected", "Not connected to a Video room.", null)
    activeRoom.localParticipant?.localVideoTracks?.firstOrNull()?.localVideoTrack?.enable(
      enabled,
    )
  }

  private fun cleanupAfterDisconnect() {
    room = null
    releaseLocalTracks()
  }

  private fun releaseLocalTracks() {
    localAudioTrack?.release()
    localAudioTrack = null
    localVideoTrack?.release()
    localVideoTrack = null
    cameraCapturer?.stopCapture()
    cameraCapturer = null
  }
}
