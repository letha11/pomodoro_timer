import 'package:pomodoro_timer/timer/data/datasource/local/timer_repository_db.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:pomodoro_timer/timer/domain/repository/timer_repository.dart';

class TimerRepositoryImpl implements TimerRepository {
  final TimerRepositoryDB _DBRepository;

  TimerRepositoryImpl({required TimerRepositoryDB timerRepositoryDB}) : _DBRepository = timerRepositoryDB;

  @override
  Future<Either<Failure, TimerEntity>> getTimer() async {
    try {
      final result = _DBRepository.getTimer();

      return Right(result);
    } catch (e) {
      return Left(UnhandledFailure());
    }
  }

  @override
  Future<Either<Failure, Success>> setTimer({int? pomodoroTime, int? breakTime}) {
    throw UnimplementedError();
  }
}
