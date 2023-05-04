import 'package:dartz/dartz.dart';

import '../exceptions/failures.dart';

class Countdown {
  const Countdown();

  Either<Failure, Stream<int>> count(int tick) {
    if (tick < 0) return Left(FormatFailure());

    return Right(
      Stream<int>.periodic(const Duration(seconds: 1), (count) => tick - count)
          .take(tick + 1), // +1 because the tick starts from 0
    );
  }
}
