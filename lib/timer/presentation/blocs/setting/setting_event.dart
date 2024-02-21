part of 'setting_bloc.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object> get props => [];
}

class SettingGet extends SettingEvent {}

class SettingSet extends SettingEvent {
  final int? pomodoroTime;
  final int? shortBreak;
  final int? longBreak;
  final bool? pomodoroSequence;
  final bool? playSound;
  final Uint8List? bytesData;
  final SoundType? type;
  final String? importedFileName;

  const SettingSet({
    this.pomodoroTime,
    this.shortBreak,
    this.longBreak,
    this.pomodoroSequence,
    this.playSound,
    this.bytesData,
    this.type,
    this.importedFileName,
  });
}

class _SettingChanged extends SettingEvent {
  final TimerSettingEntity? timer;
  final SoundSettingEntity? soundSetting;

  const _SettingChanged({required this.timer, required this.soundSetting});
}
