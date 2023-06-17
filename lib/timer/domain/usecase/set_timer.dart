import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failures.dart';
import '../../../core/success.dart';
import '../repository/timer_repository.dart';

class SetTimerUsecase {
  final TimerRepository _timerRepository;

  SetTimerUsecase(this._timerRepository);

  Future<Either<Failure, Success>> call({int? pomodoroTime, int? breakTime, int? longBreak}) {
    return _timerRepository.setTimer(pomodoroTime: pomodoroTime, breakTime: breakTime, longBreak: longBreak);
  }
}
