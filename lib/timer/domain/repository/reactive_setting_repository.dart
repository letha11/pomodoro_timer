import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failures.dart';
import '../../../core/success.dart';
import '../entity/sound_setting_entity.dart';
import '../entity/timer_setting_entity.dart';

abstract class ReactiveSettingRepository {
  Either<Failure, Stream<TimerSettingEntity>> getTimerStream();
  Either<Failure, Stream<SoundSettingEntity>> getSoundStream();

  Future<Either<Failure, Success>> storeTimerSetting(
      {int? pomodoroTime, int? shortBreak, int? longBreak});
  Future<Either<Failure, Success>> storeSoundSetting(
      {bool? playSound, String? audioPath});
}
