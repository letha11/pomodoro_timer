import 'package:pomodoro_timer/core/utils/time_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("TimeConverter", () {
    test('convert seconds to formatted strin using `fromSeconds` methods', () {
      expect(TimeConverter.fromSeconds(60), '01:00');
      expect(TimeConverter.fromSeconds(125), '02:05');
      expect(TimeConverter.fromSeconds(3600), '01:00:00');
      expect(TimeConverter.fromSeconds(3660), '01:01:00');
      expect(TimeConverter.fromSeconds(7323), '02:02:03');
    });
  });
}
