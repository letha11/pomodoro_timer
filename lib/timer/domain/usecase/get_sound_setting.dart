import 'package:dartz/dartz.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/timer/domain/entity/sound_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/repository/reactive_setting_repository.dart';

class GetSoundSettingUsecase {
  final ReactiveSettingRepository _repository;

  GetSoundSettingUsecase(this._repository);

  Either<Failure, Stream<SoundSettingEntity>> call() {
    return _repository.getSoundStream();
  }
}