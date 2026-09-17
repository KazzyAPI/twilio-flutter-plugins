import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/mappers/pigeon_dto_mapper.dart';
import 'package:twilio_flutter_conversations/src/pigeon/conversations.pigeon.dart';

void main() {
  const mapper = PigeonDtoMapper();

  test('mapMessage decodes attributesJson', () {
    final message = mapper.mapMessage(
      PigeonMessageDto(
        sid: 'IMxxx',
        conversationSid: 'CHxxx',
        author: 'user',
        body: 'Hi',
        messageIndex: 1,
        dateCreatedEpochMs: 1700000000000,
        contentType: PigeonMessageContentType.text,
        attributesJson: '{"orderId":"123","priority":"high"}',
      ),
    );

    expect(message.attributes.entries['orderId'], '123');
    expect(message.attributes.entries['priority'], 'high');
  });
}
