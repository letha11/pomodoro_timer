import 'package:hive/hive.dart';
import 'package:pomodoro_timer/core/utils/logger.dart';

import '../../models/setting_model.dart';

abstract class SettingRepositoryDB {
  void store(SettingModel model);

  SettingModel get();
}

class SettingRepositoryHiveDB implements SettingRepositoryDB {
  late HiveInterface _hive;
  late Box box;
  late ILogger? _logger;

  SettingRepositoryHiveDB._create({HiveInterface? hive, ILogger? logger}) {
    _hive = hive ?? Hive;
    _logger = logger;
  }

  Future<void> _initializeBox() async {
    box = await _hive.openBox('setting');
  }

  static Future<SettingRepositoryHiveDB> create(
      {HiveInterface? hive, ILogger? logger}) async {
    final settingRepositoryDB = SettingRepositoryHiveDB._create(hive: hive, logger: logger);

    await settingRepositoryDB._initializeBox();

    return settingRepositoryDB;
  }

  @override
  SettingModel get() {
    _logger?.log(Level.info, '[$this(getSetting)]');
    final pomodoroSequence = box.get('pomodoro_sequence');
    final playSound = box.get('play_sound');

    return SettingModel(
      playSound: playSound,
      pomodoroSequence: pomodoroSequence,
    );
  }

  @override
  void store(SettingModel model) {
    _logger?.log(Level.info, '[$this(storeSetting)]: ${model.toJson()}');

    box.put('pomodoro_sequence', model.pomodoroSequence);
    box.put('play_sound', model.playSound);
  }
}
