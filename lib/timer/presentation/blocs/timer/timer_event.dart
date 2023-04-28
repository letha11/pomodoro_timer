part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerGet extends TimerEvent {}

class TimerSet extends TimerEvent {
  final int? pomodoroTime;
  final int? breakTime;

  const TimerSet({this.pomodoroTime, this.breakTime});
}
