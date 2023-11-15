import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failures.dart';
import '../entity/timer_setting_entity.dart';
import '../repository/reactive_setting_repository.dart';

class GetTimerUsecase {
  final ReactiveSettingRepository _repository;

  GetTimerUsecase(this._repository);

  Either<Failure, Stream<TimerSettingEntity>> call() {
    return _repository.getTimerStream();
  }
}
