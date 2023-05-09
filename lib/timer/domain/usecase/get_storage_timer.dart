import '../entity/timer_entity.dart';
import '../repository/timer_storage_repository.dart';

class GetStorageTimerUsecase {
  final TimerStorageRepository _repository;

  GetStorageTimerUsecase(this._repository);

  Stream<TimerEntity> call() {
    return _repository.stream;
  }
}
