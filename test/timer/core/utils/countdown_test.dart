import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/utils/countdown.dart';

void main() {
  group('count()', () {
    test(
        'should count from given tick, to 0 and emit every 1 second when the seconds is not below - point',
        () {
      const seconds = 2;
      final stream = Countdown.count(seconds);

      // Stream<int> stream = Countdown.count(seconds);

      // stream.fold
      expect(stream, isA<Right>());
      expectLater((stream as Right).value, emitsInOrder([2, 1]));
    });

    test('should return Left(Failure) when the duration/seconds is below -', () {
      const seconds = -1;
      final stream = Countdown.count(seconds);

      // Stream<int> stream = Countdown.count(seconds);

      // stream.fold
      expect(stream, isA<Left>());
      expect((stream as Left).value, isA<FormatFailure>());
    });
  });
}
