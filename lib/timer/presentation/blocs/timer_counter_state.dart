part of 'timer_counter_bloc.dart';

@immutable
abstract class TimerCounterState extends Equatable {
  const TimerCounterState(this.duration);
  final int duration;

  @override
  List<Object?> get props => [duration];
}

class TimerCounterInitial extends TimerCounterState {
  const TimerCounterInitial(super.duration);

  @override
  toString() => 'TimerInitial { duration: $duration } ';
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
  const TimerCounterComplete() : super(0);
}

class TimerCounterFailure extends TimerCounterState {
  final String? message;

  const TimerCounterFailure(this.message) : super(0);
}