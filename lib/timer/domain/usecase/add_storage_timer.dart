import '../entity/timer_entity.dart';
import '../repository/timer_storage_repository.dart';

class AddStorageTimerUsecase {
  final TimerStorageRepository _repository;

  AddStorageTimerUsecase(this._repository);

  void call(TimerEntity timer) {
    return _repository.add(timer);
  }
}
