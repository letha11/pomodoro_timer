import 'package:hive/hive.dart';
import 'package:pomodoro_timer/timer/data/models/timer_model.dart';

import '../../../../core/utils/logger.dart';

abstract class TimerRepositoryDB {
  void setTimer({int? pomodoroTime, int? breakTime});
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

  void _initializeBox() async {
    box = await _hive.openBox('timer');
  }

  static Future<TimerRepositoryHiveDB> create(
      {HiveInterface? hive, ILogger? logger}) async {
    final timerRepositoryDB =
        TimerRepositoryHiveDB._create(hive: hive, logger: logger);

    timerRepositoryDB._initializeBox();

    return timerRepositoryDB;
  }

  @override
  void setTimer({int? pomodoroTime, int? breakTime}) {
    _logger?.log(Level.info,
        '[$this(setTimer)] : {pomodoroTime: $pomodoroTime, breakTime: $breakTime}');
    if (pomodoroTime != null) {
      box.put('pomodoro_time', pomodoroTime);
    }

    if (breakTime != null) {
      box.put('break_time', breakTime);
    }
  }

  @override
  TimerModel getTimer() {
    _logger?.log(Level.info, '[$this(getTimer)]');
    final pomodoroTime = box.get('pomodoro_time');
    final breakTime = box.get('break_time') ?? 500;

    return TimerModel(pomodoroTime: pomodoroTime, breakTime: breakTime);
  }
}
