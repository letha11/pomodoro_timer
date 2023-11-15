import 'package:equatable/equatable.dart';

import 'sound_setting_entity.dart';
import 'timer_setting_entity.dart';

class SettingEntity extends Equatable {
  final TimerSettingEntity timerSetting;
  final SoundSettingEntity soundSetting;

  const SettingEntity({
    required this.timerSetting,
    required this.soundSetting,
  });

  @override
  List<Object> get props => [
        timerSetting,
        soundSetting,
      ];
}
