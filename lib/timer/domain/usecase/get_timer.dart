import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failures.dart';
import '../entity/timer_entity.dart';
import '../repository/timer_repository.dart';

class GetTimerUsecase {
  final TimerRepository _repository;

  GetTimerUsecase(this._repository);

  Future<Either<Failure, TimerEntity>> call() async {
    return _repository.getTimer();
  }
}
