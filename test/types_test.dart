import 'package:flutter_test/flutter_test.dart';
import 'package:terra_flutter_rt/types.dart';

void main() {
  test('every DataType round-trips through its wire string', () {
    for (final type in DataType.values) {
      expect(datatypeTyped(type.datatypeString), type);
    }
  });

  test('jumpCount maps to JUMP_COUNT', () {
    expect(DataType.jumpCount.datatypeString, 'JUMP_COUNT');
  });

  test('a JUMP_COUNT update parses', () {
    final update = Update.fromJson(
        {'ts': '2026-11-11T09:15:25Z', 'type': 'JUMP_COUNT', 'val': 42});
    expect(update.type, DataType.jumpCount);
    expect(update.val, 42.0);
    expect(update.d, isNull);
  });
}
