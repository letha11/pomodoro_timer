import 'dart:async';

import '../entity/timer_entity.dart';

abstract class TimerStorageRepository {
  Stream<TimerEntity> get stream;
  void add(TimerEntity timer);
}
