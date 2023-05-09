import 'dart:async';

import '../../domain/entity/timer_entity.dart';
import '../../domain/repository/timer_storage_repository.dart';

class TimerStorageRepositoryImpl extends TimerStorageRepository {
  final StreamController<TimerEntity> _controller =
      StreamController<TimerEntity>();

  @override
  void add(TimerEntity timer) {
    _controller.sink.add(timer);
  }

  @override
  Stream<TimerEntity> get stream => _controller.stream.asBroadcastStream();
}
