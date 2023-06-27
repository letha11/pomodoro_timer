part of 'timer_counter_bloc.dart';

@immutable
abstract class TimerCounterState extends Equatable {
  const TimerCounterState(this.duration);
  final String duration;


  @override
  List<Object?> get props => [duration];
}

class TimerCounterInitial extends TimerCounterState {
  const TimerCounterInitial(super.duration, this.timeStamps);

  final int timeStamps;

  @override
  List<Object?> get props => [duration, timeStamps];
  
  @override
  toString() => 'TimerInitial { duration: $duration, timeStamps: $timeStamps } ';
}

class TimerCounterInProgress extends TimerCounterState {
  const TimerCounterInProgress(super.duration);

  @override
  toString() => 'TimerRunInProgress { duration: $duration } ';
}

class TimerCounterPause extends TimerCounterState {
  const TimerCounterPause(super.duration);

  @override
  toString() => 'TimerRunPause { duration: $duration } ';
}

class TimerCounterComplete extends TimerCounterState {
  const TimerCounterComplete() : super("00:00");
}

class TimerCounterFailure extends TimerCounterState {
  final ErrorObject error;

  const TimerCounterFailure(this.error) : super("00:00");

  @override
  List<Object> get props => [error];
}
