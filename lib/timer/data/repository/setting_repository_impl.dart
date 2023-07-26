import 'package:dartz/dartz.dart';
import 'package:pomodoro_timer/core/utils/logger.dart';
import 'package:pomodoro_timer/timer/data/models/setting_model.dart';

import '../../../core/exceptions/failures.dart';
import '../../../core/success.dart';
import '../../domain/entity/setting_entity.dart';
import '../../domain/repository/setting_repository.dart';
import '../datasource/local/setting_repository_db.dart';

class SettingRepositoryImpl implements SettingRepository {
  final SettingRepositoryDB _dbRepository;
  final ILogger? _logger;

  SettingRepositoryImpl({
    required SettingRepositoryDB settingRepositoryDB,
    ILogger? logger,
  })  : _dbRepository = settingRepositoryDB,
        _logger = logger;

  @override
  Future<Either<Failure, SettingEntity>> getSetting() async {
    try {
      final setting = _dbRepository.get();

      return Right(setting);
    } catch (e) {
      _logger?.log(Level.error,
          '[$this(getSetting)] failed on getting setting from local db', e);
      return Left(UnhandledFailure());
    }
  }

  @override
  Future<Either<Failure, Success>> storeSetting(SettingEntity entity) async {
    try {
      final model = SettingModel(
        pomodoroSequence: entity.pomodoroSequence,
        playSound: entity.playSound,
      );

      _dbRepository.store(model);

      return Right(Success());
    } catch (e) {
      _logger?.log(Level.error,
          '[$this(storeSetting)] failed on storing setting to local db', e);
      return Left(UnhandledFailure());
    }
  }
}
