import 'package:hive/hive.dart';
import 'package:pomodoro_timer/timer/data/models/timer_model.dart';
// import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart';
// import 'package:pomodoro_timer/core/success.dart';
// import 'package:pomodoro_timer/core/exceptions/failures.dart';
// import 'package:dartz/dartz.dart';

abstract class TimerRepositoryDB {
  void setTimer({int? pomodoroTime, int? breakTime});
  TimerModel getTimer();
}

class TimerRepositoryHiveDB implements TimerRepositoryDB {
  late HiveInterface _hive;
  late Box box;

  TimerRepositoryHiveDB._create({HiveInterface? hive}) {
    _hive = hive ?? Hive;
  }

  void _initializeBox() async {
    box = await _hive.openBox('timer');
  }

  static Future<TimerRepositoryHiveDB> create({HiveInterface? hive}) async {
    final timerRepositoryDB = TimerRepositoryHiveDB._create(hive: hive);

    timerRepositoryDB._initializeBox();

    return timerRepositoryDB;
  }

  @override
  void setTimer({int? pomodoroTime, int? breakTime}) {
    if (pomodoroTime != null) {
      box.put('pomodoro_time', pomodoroTime);
    }

    if (breakTime != null) {
      box.put('break_time', breakTime);
    }
  }

  @override
  TimerModel getTimer() {
    final pomodoroTime = box.get('pomodoro_time');
    final breakTime = box.get('break_time');

    return TimerModel(pomodoroTime: pomodoroTime, breakTime: breakTime);
  }
}
