part of 'timer_counter_bloc.dart';

@immutable
abstract class TimerCounterEvent {
  const TimerCounterEvent();
}

/// Inform TimerBloc that timer has started
class TimerCounterStarted extends TimerCounterEvent {
  // const TimerCounterStarted();
}

/// Inform TimerBloc that timer has been paused
class TimerCounterPaused extends TimerCounterEvent {}

/// Inform TimerBloc that timer has resumed
class TimerCounterResumed extends TimerCounterEvent {}

/// Inform TimerBloc that timer should be reset to the original state
class TimerCounterReset extends TimerCounterEvent {}

class TimerCounterTypeChange extends TimerCounterEvent {
  const TimerCounterTypeChange(this.type);

  final TimerType type;
}

class TimerCounterChange extends TimerCounterEvent {
  const TimerCounterChange(this.timer);

  final TimerEntity timer;
}

/// Inform TimerBloc that a tick has occurred and that it needs to update its state accordingly
class _TimerCounterTicked extends TimerCounterEvent {
  const _TimerCounterTicked({required this.formattedDuration});
  final String formattedDuration;
}
