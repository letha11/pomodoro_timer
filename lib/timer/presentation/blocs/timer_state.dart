part of 'timer_bloc.dart';

@immutable
abstract class TimerState extends Equatable {
  const TimerState(this.duration);
  final int duration;

  @override
  List<Object?> get props => [duration];
}

class TimerInitial extends TimerState {
  const TimerInitial(super.duration);

  @override
  toString() => 'TimerInitial { duration: $duration } ';
}

class TimerInProgress extends TimerState {
  const TimerInProgress(super.duration);

  @override
  toString() => 'TimerRunInProgress { duration: $duration } ';
}

class TimerPause extends TimerState {
  const TimerPause(super.duration);

  @override
  toString() => 'TimerRunPause { duration: $duration } ';
}

class TimerComplete extends TimerState {
  const TimerComplete() : super(0);
}

class TimerFailure extends TimerState {
  final String? message;

  const TimerFailure(this.message) : super(0);
}
