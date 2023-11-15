import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failures.dart';
import '../../../core/success.dart';
import '../repository/reactive_setting_repository.dart';

class SetTimerUsecase {
  final ReactiveSettingRepository _timerRepository;

  SetTimerUsecase(this._timerRepository);

  Future<Either<Failure, Success>> call({int? pomodoroTime, int? shortBreak, int? longBreak}) {
    return _timerRepository.storeTimerSetting(pomodoroTime: pomodoroTime, shortBreak: shortBreak, longBreak: longBreak);
  }
}
