part of 'setting_bloc.dart';

abstract class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object?> get props => [];
}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingLoaded extends SettingState {
  final TimerSettingEntity timer;
  final SoundSettingEntity soundSetting;
  final ErrorObject? error;

  const SettingLoaded(
      {required this.timer, required this.soundSetting, this.error});

  SettingLoaded copyWith({
    TimerSettingEntity? timer,
    SoundSettingEntity? soundSetting,
    ErrorObject? error,
  }) =>
      SettingLoaded(
        timer: timer ?? this.timer,
        soundSetting: soundSetting ?? this.soundSetting,
        error: error,
      );

  /// this is important, because if you didn't override the `props`
  /// when you try to compare `TimerLoaded` with another `TimerLoaded` with a different fields value
  /// it will return true/same because it only compare if the 2 classes are TimerLoaded, not the fields value.
  @override
  List<Object?> get props => [timer, soundSetting, error];
}

class SettingFailed extends SettingState {
  final ErrorObject error;

  const SettingFailed({required this.error});

  @override
  List<Object> get props => [error];
}
