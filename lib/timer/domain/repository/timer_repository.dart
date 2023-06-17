import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failures.dart';
import '../../../core/success.dart';
import '../entity/timer_entity.dart';

abstract class TimerRepository {
  Future<Either<Failure, TimerEntity>> getTimer();
  Future<Either<Failure, Success>> setTimer({int? pomodoroTime, int? breakTime, int? longBreak});
}
 
