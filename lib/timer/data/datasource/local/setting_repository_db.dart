import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:pomodoro_timer/core/constants.dart';
import 'package:pomodoro_timer/core/utils/logger.dart';

import '../../models/setting_hive_model.dart';

abstract class SettingRepositoryDB {
  TimerSettingModel getTimer();

  Future<void> storeTimerSetting({
    int? pomodoroTime,
    int? shortBreak,
    int? longBreak,
    bool? pomodoroSequence,
  });

  SoundSettingModel getSound();

  Future<void> storeSoundSetting({
    bool? playSound,
    String? audioPath,
    SoundType? type,
    Uint8List? bytesData,
    String? importedFileName,
  });
}

class SettingRepositoryHiveDB implements SettingRepositoryDB {
  late HiveInterface _hive;
  late Box<SettingHiveModel> _box;
  late ILogger? _logger;
  late SettingHiveModel _settingModel;

  SettingRepositoryHiveDB._create({HiveInterface? hive, ILogger? logger}) {
    _hive = hive ?? Hive;
    _logger = logger;
  }

  Future<void> _initializeBox() async {
    _box = await _hive.openBox<SettingHiveModel>('setting');

    // Initialize the box with default values
    var tempSettingModel = _box.get(0);
    if (tempSettingModel == null || tempSettingModel is! SettingHiveModel) {
      _settingModel = const SettingHiveModel();
      _box.put(0, _settingModel);
    } else {
      _settingModel = tempSettingModel;
    }
  }

  static Future<SettingRepositoryHiveDB> create(
      {HiveInterface? hive, ILogger? logger}) async {
    final settingRepositoryDB =
        SettingRepositoryHiveDB._create(hive: hive, logger: logger);

    await settingRepositoryDB._initializeBox();

    return settingRepositoryDB;
  }

  @override
  TimerSettingModel getTimer() {
    _logger?.log(Level.info, '[SettingRepositoryHiveDB(getTimer)]');
    return _settingModel.timerSetting;
  }

  @override
  Future<void> storeTimerSetting({
    int? pomodoroTime,
    int? shortBreak,
    int? longBreak,
    bool? pomodoroSequence,
  }) async {
    _logger?.log(Level.info, '''[SettingRepositoryHiveDB(storeTimer)]: {
      pomodoroTime: $pomodoroTime,
      shortBreak: $shortBreak,
      longBreak: $longBreak,
      pomodoroSequence: $pomodoroSequence,
    }''');

    _settingModel = SettingHiveModel(
      timerSetting: TimerSettingModel(
        pomodoroTime: pomodoroTime ?? _settingModel.timerSetting.pomodoroTime,
        longBreak: longBreak ?? _settingModel.timerSetting.longBreak,
        shortBreak: shortBreak ?? _settingModel.timerSetting.shortBreak,
        pomodoroSequence:
            pomodoroSequence ?? _settingModel.timerSetting.pomodoroSequence,
      ),
      soundSetting: _settingModel.soundSetting,
    );

    await _box.put(0, _settingModel);
  }

  @override
  SoundSettingModel getSound() {
    _logger?.log(Level.info, '[SettingRepositoryHiveDB(getSound)]');
    return _settingModel.soundSetting;
  }

  @override
  Future<void> storeSoundSetting({
    bool? playSound,
    String? audioPath,
    SoundType? type,
    Uint8List? bytesData,
    String? importedFileName,
  }) async {
    _logger?.log(Level.info, '''[SettingRepositoryHiveDB(storeSound)]: {
      isSoundOn: $playSound,
      audioPath: $audioPath,
      soundType: $type,
      bytesData: ${bytesData != null ? 'bytesData' : 'null'},
      importedFileName: $importedFileName,
    }''');

    _settingModel = SettingHiveModel(
      timerSetting: _settingModel.timerSetting,
      soundSetting: SoundSettingModel(
        playSound: playSound ?? _settingModel.soundSetting.playSound,
        defaultAudioPath:
            audioPath ?? _settingModel.soundSetting.defaultAudioPath,
        type: type?.valueAsString ?? _settingModel.soundSetting.type,
        bytesData: bytesData ?? _settingModel.soundSetting.bytesData,
        importedFileName:
            importedFileName ?? _settingModel.soundSetting.importedFileName,
      ),
    );

    await _box.put(0, _settingModel);
  }
}
