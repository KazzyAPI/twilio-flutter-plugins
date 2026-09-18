import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/video.pigeon.dart',
    dartOptions: DartOptions(),
    swiftOut: 'ios/Classes/Pigeon/VideoPigeon.swift',
    swiftOptions: SwiftOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/twilioflutter/video/pigeon/VideoPigeon.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.twilioflutter.video.pigeon',
    ),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
enum VideoRoomState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  disconnectedWithError,
}

enum VideoEventType {
  roomConnected,
  roomDisconnected,
  roomReconnecting,
  roomReconnected,
  participantConnected,
  participantDisconnected,
  dominantSpeakerChanged,
  error,
}

class VideoConnectRequest {
  VideoConnectRequest({
    required this.accessToken,
    required this.roomName,
    this.enableAudio = true,
    this.enableVideo = true,
  });

  String accessToken;
  String roomName;
  bool enableAudio;
  bool enableVideo;
}

class VideoRoomDto {
  VideoRoomDto({
    required this.sid,
    required this.name,
    required this.state,
  });

  String sid;
  String name;
  VideoRoomState state;
}

class VideoParticipantDto {
  VideoParticipantDto({
    required this.sid,
    required this.identity,
  });

  String sid;
  String identity;
}

class VideoNativeEvent {
  VideoNativeEvent({
    required this.type,
    this.room,
    this.participant,
    this.errorCode,
    this.errorMessage,
  });

  VideoEventType type;
  VideoRoomDto? room;
  VideoParticipantDto? participant;
  String? errorCode;
  String? errorMessage;
}

@HostApi()
abstract class TwilioVideoHostApi {
  @async
  void connect(VideoConnectRequest request);

  @async
  void disconnect();

  @async
  void setLocalAudioEnabled(bool enabled);

  @async
  void setLocalVideoEnabled(bool enabled);
}

@FlutterApi()
abstract class TwilioVideoFlutterApi {
  void onNativeEvent(VideoNativeEvent event);
}
