import 'package:hive/hive.dart';

import '../../../data/models/timer_model.dart';
import '../../../../../core/utils/logger.dart';

abstract class TimerRepositoryDB {
  void setTimer({int? pomodoroTime, int? breakTime, int? longBreak});

  TimerModel getTimer();
}

class TimerRepositoryHiveDB implements TimerRepositoryDB {
  late HiveInterface _hive;
  late Box box;
  late ILogger? _logger;

  TimerRepositoryHiveDB._create({HiveInterface? hive, ILogger? logger}) {
    _hive = hive ?? Hive;
    _logger = logger;
  }

  Future<void> _initializeBox() async {
    box = await _hive.openBox('timer');
  }

  // Why I'm doing this complex/hard way to create an instance of this class are
  // because i want to run an asynchronous method when we create this class.
  // if we use a standard `ClassName() {}` constructor, it won't let us run an asynchronous method.
  // DISCLAIMER: well you can but you cannot await those method to finished or using `await` keyword
  // on the constructor.
  static Future<TimerRepositoryHiveDB> create(
      {HiveInterface? hive, ILogger? logger}) async {
    final timerRepositoryDB =
        TimerRepositoryHiveDB._create(hive: hive, logger: logger);

    await timerRepositoryDB._initializeBox();

    return timerRepositoryDB;
  }

  @override
  void setTimer({int? pomodoroTime, int? breakTime, int? longBreak}) {
    _logger?.log(Level.info,
        '[$this(setTimer)] : {pomodoroTime: $pomodoroTime, breakTime: $breakTime, longBreak: $longBreak}');
    if (pomodoroTime != null && pomodoroTime > 0) {
      box.put('pomodoro_time', pomodoroTime);
    }

    if (breakTime != null && breakTime > 0) {
      box.put('break_time', breakTime);
    }

    if (longBreak != null && longBreak > 0) {
      box.put('long_break', longBreak);
    }
  }

  @override
  TimerModel getTimer() {
    _logger?.log(Level.info, '[$this(getTimer)]');
    final pomodoroTime = box.get('pomodoro_time');
    final breakTime = box.get('break_time');
    final longBreak = box.get('long_break');

    return TimerModel(
      pomodoroTime: pomodoroTime,
      breakTime: breakTime,
      longBreak: longBreak,
    );
  }
}
