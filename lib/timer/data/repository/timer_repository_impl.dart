import 'package:dartz/dartz.dart';
import '../../data/datasource/local/timer_repository_db.dart';
import '../../domain/entity/timer_entity.dart';
import '../../../../core/success.dart';
import '../../../../core/exceptions/failures.dart';
import '../../domain/repository/timer_repository.dart';
import '../../../../core/utils/logger.dart';

class TimerRepositoryImpl implements TimerRepository {
  final TimerRepositoryDB _dbRepository;
  final ILogger? _logger;

  TimerRepositoryImpl({
    required TimerRepositoryDB timerRepositoryDB,
    ILogger? logger,
  })  : _dbRepository = timerRepositoryDB,
        _logger = logger;

  @override
  Future<Either<Failure, TimerEntity>> getTimer() async {
    try {
      final result = _dbRepository.getTimer();

      return Right(result);
    } catch (e) {
      _logger?.log(Level.error,
          '[$this(getTimer)] failed on getting timer from local db', e);
      return Left(UnhandledFailure());
    }
  }

  @override
  Future<Either<Failure, Success>> setTimer(
      {int? pomodoroTime, int? breakTime, int? longBreak}) async {
    try {
      _dbRepository.setTimer(
          pomodoroTime: pomodoroTime,
          breakTime: breakTime,
          longBreak: longBreak);

      return Right(Success());
    } catch (e) {
      _logger?.log(Level.error,
          '[$this(setTimer)] failed on setting a timer to local db', e);
      return Left(UnhandledFailure());
    }
  }
}
