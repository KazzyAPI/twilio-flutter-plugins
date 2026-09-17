import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_flutter_conversations/src/client/connect_session_guard.dart';

void main() {
  test('invalidate rejects stale connect token', () {
    final guard = ConnectSessionGuard();
    final tokenA = guard.beginConnect();
    guard.invalidate();
    final tokenB = guard.beginConnect();

    expect(guard.isActive(tokenA), isFalse);
    expect(guard.isActive(tokenB), isTrue);
  });
}
