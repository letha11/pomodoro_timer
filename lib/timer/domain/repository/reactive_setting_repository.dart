import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:pomodoro_timer/core/constants.dart';

import '../../../core/exceptions/failures.dart';
import '../../../core/success.dart';
import '../entity/sound_setting_entity.dart';
import '../entity/timer_setting_entity.dart';

abstract class ReactiveSettingRepository {
  Either<Failure, Stream<TimerSettingEntity>> getTimerStream();

  Either<Failure, Stream<SoundSettingEntity>> getSoundStream();

  Future<Either<Failure, Success>> storeTimerSetting({
    int? pomodoroTime,
    int? shortBreak,
    int? longBreak,
    bool? pomodoroSequence,
  });

  Future<Either<Failure, Success>> storeSoundSetting(
      {bool? playSound,
      SoundType? type,
      Uint8List? bytesData,
      String? importedFileName});
}
