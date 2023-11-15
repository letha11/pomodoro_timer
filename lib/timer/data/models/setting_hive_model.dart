import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';

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
  })  : pomodoroTime = pomodoroTime ?? 25,
        shortBreak = shortBreak ?? 5,
        longBreak = longBreak ?? 15,
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
  final String audioPath;

  const SoundSettingModel({
    bool? playSound,
    String? audioPath,
    // this.playSound = true,
    // this.audioPath = 'assets/audio/alarm.mp3',
  })  : playSound = playSound ?? true,
        audioPath = audioPath ?? 'assets/audio/alarm.mp3';

  @override
  List<Object?> get props => [
        playSound,
        audioPath,
      ];
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
      audioPath: audioPath,
    );
  }
}
