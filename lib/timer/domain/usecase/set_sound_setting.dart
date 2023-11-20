import 'package:dartz/dartz.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/timer/domain/repository/reactive_setting_repository.dart';

class SetSoundSettingUsecase {
  final ReactiveSettingRepository _repository;

  SetSoundSettingUsecase(this._repository);

  Future<Either<Failure, Success>> call({
    bool? playSound,
    String? audioPath,
  }) async {
    return _repository.storeSoundSetting(
      playSound: playSound,
      audioPath: audioPath,
    );
  }
}
