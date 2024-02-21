import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pomodoro_timer/core/constants.dart';

import '../../domain/entity/sound_setting_entity.dart';
import '../../domain/entity/timer_setting_entity.dart';

part 'setting_hive_model.g.dart';

@HiveType(typeId: 0)
class SettingHiveModel extends Equatable {
  @HiveField(0)
  final TimerSettingModel timerSetting;

  @HiveField(1)
  final SoundSettingModel soundSetting;

  const SettingHiveModel({
    TimerSettingModel? timerSetting,
    SoundSettingModel? soundSetting,
  })  : timerSetting = timerSetting ?? const TimerSettingModel(),
        soundSetting = soundSetting ?? const SoundSettingModel();

  @override
  List<Object?> get props => [
        timerSetting,
        soundSetting,
      ];
}

@HiveType(typeId: 1)
class TimerSettingModel extends Equatable {
  @HiveField(0)
  final int pomodoroTime;

  @HiveField(1)
  final int shortBreak;

  @HiveField(2)
  final int longBreak;

  @HiveField(3)
  final bool pomodoroSequence;

  const TimerSettingModel({
    int? pomodoroTime,
    int? shortBreak,
    int? longBreak,
    bool? pomodoroSequence,
  })  : pomodoroTime = pomodoroTime ?? 1500,
        shortBreak = shortBreak ?? 300,
        longBreak = longBreak ?? 900,
        pomodoroSequence = pomodoroSequence ?? true;

  @override
  List<Object?> get props => [
        pomodoroTime,
        shortBreak,
        longBreak,
        pomodoroSequence,
      ];
}

@HiveType(typeId: 2)
class SoundSettingModel extends Equatable {
  @HiveField(0)
  final bool playSound;

  @HiveField(1)
  final String defaultAudioPath;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final Uint8List? bytesData;

  @HiveField(4)
  final String? importedFileName;

  const SoundSettingModel({
    bool? playSound,
    String? defaultAudioPath,
    String? type,
    this.bytesData,
    this.importedFileName,
  })  : playSound = playSound ?? true,
        defaultAudioPath = defaultAudioPath ?? 'assets/audio/alarm.wav',
        type = type ?? 'defaults';

  @override
  List<Object?> get props =>
      [playSound, defaultAudioPath, type, bytesData, importedFileName];
}

// create an extension method for each above model to convert into an Entity
extension TimerSettingModelX on TimerSettingModel {
  TimerSettingEntity toEntity() {
    return TimerSettingEntity(
      pomodoroTime: pomodoroTime,
      shortBreak: shortBreak,
      longBreak: longBreak,
      pomodoroSequence: pomodoroSequence,
    );
  }
}

extension SoundSettingModelX on SoundSettingModel {
  SoundSettingEntity toEntity() {
    return SoundSettingEntity(
      playSound: playSound,
      defaultAudioPath: defaultAudioPath,
      type: type.toSoundType,
      bytesData: bytesData,
      importedFileName: importedFileName,
    );
  }
}
