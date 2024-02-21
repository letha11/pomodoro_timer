import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:pomodoro_timer/core/constants.dart';

import '../../../core/exceptions/failures.dart';
import '../../../core/success.dart';
import '../models/setting_hive_model.dart';
import '../../../core/utils/logger.dart';
import '../../domain/entity/sound_setting_entity.dart';
import '../../domain/entity/timer_setting_entity.dart';
import '../../domain/repository/reactive_setting_repository.dart';
import '../datasource/local/setting_repository_db.dart';

class ReactiveSettingRepositoryImpl extends ReactiveSettingRepository {
  final SettingRepositoryDB _dbRepository;
  final ILogger? _logger;

  final StreamController<TimerSettingEntity> _timerController =
      StreamController<TimerSettingEntity>();
  late final Stream<TimerSettingEntity> _timerBroadcast;
  final StreamController<SoundSettingEntity> _soundController =
      StreamController<SoundSettingEntity>();
  late final Stream<SoundSettingEntity> _soundBroadcast;

  ReactiveSettingRepositoryImpl({
    required SettingRepositoryDB dbRepository,
    ILogger? logger,
  })  : _dbRepository = dbRepository,
        _logger = logger {
    _timerBroadcast = _timerController.stream.asBroadcastStream();
    _soundBroadcast = _soundController.stream.asBroadcastStream();
  }

  @override
  Either<Failure, Stream<SoundSettingEntity>> getSoundStream() {
    try {
      SoundSettingModel soundSettingModel = _dbRepository.getSound();
      _soundController.sink.add(soundSettingModel.toEntity());

      return Right(_soundBroadcast);
    } catch (e) {
      return Left(UnhandledFailure());
    }
  }

  @override
  Either<Failure, Stream<TimerSettingEntity>> getTimerStream() {
    try {
      TimerSettingModel timerSettingModel = _dbRepository.getTimer();
      _timerController.sink.add(timerSettingModel.toEntity());

      return Right(_timerBroadcast);
    } catch (e) {
      return Left(UnhandledFailure());
    }
  }

  @override
  Future<Either<Failure, Success>> storeSoundSetting({
    bool? playSound,
    SoundType? type,
    Uint8List? bytesData,
    String? importedFileName,
  }) async {
    try {
      SoundSettingModel newSoundSettingModel = SoundSettingModel(
        playSound: playSound,
        type: type?.valueAsString,
        bytesData: bytesData,
        importedFileName: importedFileName,
      );

      await _dbRepository.storeSoundSetting(
        playSound: newSoundSettingModel.playSound,
        type: newSoundSettingModel.type.toSoundType,
        bytesData: newSoundSettingModel.bytesData,
        importedFileName: newSoundSettingModel.importedFileName,
      );

      _soundController.sink.add(newSoundSettingModel.toEntity());

      return Right(Success());
    } catch (e) {
      return Left(UnhandledFailure());
    }
  }

  @override
  Future<Either<Failure, Success>> storeTimerSetting({
    int? pomodoroTime,
    int? shortBreak,
    int? longBreak,
    bool? pomodoroSequence,
  }) async {
    try {
      TimerSettingModel newTimerModel = TimerSettingModel(
        pomodoroTime: pomodoroTime,
        shortBreak: shortBreak,
        longBreak: longBreak,
        pomodoroSequence: pomodoroSequence,
      );

      await _dbRepository.storeTimerSetting(
        pomodoroTime: pomodoroTime,
        longBreak: longBreak,
        shortBreak: shortBreak,
        pomodoroSequence: pomodoroSequence,
      );

      _timerController.sink.add(newTimerModel.toEntity());

      return Right(Success());
    } catch (e) {
      return Left(UnhandledFailure());
    }
  }
}
