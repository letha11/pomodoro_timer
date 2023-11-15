part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerGet extends TimerEvent {}

class TimerSet extends TimerEvent {
  final int? pomodoroTime;
  final int? shortBreak;
  final int? longBreak;

  const TimerSet({this.pomodoroTime, this.shortBreak, this.longBreak});
}

class _TimerChanged extends TimerEvent {
  final TimerSettingEntity timer;

  const _TimerChanged({required this.timer});
}
