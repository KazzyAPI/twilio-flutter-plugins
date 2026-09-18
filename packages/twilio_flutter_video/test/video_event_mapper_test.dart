import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_video/src/events/video_event.dart';
import 'package:twilio_flutter_video/src/events/video_event_mapper.dart';
import 'package:twilio_flutter_video/src/pigeon/video.pigeon.dart';

void main() {
  test('maps participant connected event', () {
    final mapper = VideoEventMapper();
    final event = mapper.map(
      VideoNativeEvent(
        type: VideoEventType.participantConnected,
        participant: VideoParticipantDto(sid: 'PA1', identity: 'alice'),
      ),
    );

    expect(event, isA<ParticipantConnected>());
    final connected = event! as ParticipantConnected;
    expect(connected.participant.sid, 'PA1');
    expect(connected.participant.identity, 'alice');
  });
}
