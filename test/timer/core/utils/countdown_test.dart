import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/utils/countdown.dart';

void main() {
  group('count()', () {
    late Countdown countdown;
    setUp(() {
      countdown = const Countdown();
    });

    test(
        'should count from given tick, to 0 and emit every 1 second when the seconds is not below - point',
        () async {
      const seconds = 3;
      const countdown = Countdown();
      final stream = countdown.count(seconds);

      await stream.fold(
        (l) => fail('failed'),
        (r) async {
          expect(r, isA<Stream<int>>());
          expect(r, emitsInOrder([3, 2, 1, 0]));
        },
      );
    });

    test('should return Left(Failure) when the duration/seconds is below -',
        () {
      const seconds = -1;
      final stream = countdown.count(seconds);

      expect(stream, isA<Left>());
      expect((stream as Left).value, isA<FormatFailure>());
    });
  });
}
