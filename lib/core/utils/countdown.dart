import 'package:dartz/dartz.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';

class Countdown {
  static Either<Failure, Stream<int>> count(int tick) {
    if (tick <= 0) return Left(FormatFailure());

    return Right(
      Stream<int>.periodic(const Duration(seconds: 1), (count) => tick - count).take(tick),
    );
  }
}
