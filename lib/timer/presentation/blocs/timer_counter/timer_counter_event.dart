part of 'timer_counter_bloc.dart';

@immutable
abstract class TimerCounterEvent {
  const TimerCounterEvent();
}

/// Inform TimerBloc that timer has started
class TimerCounterStarted extends TimerCounterEvent {
  const TimerCounterStarted({required this.duration});
  final int duration;
}

/// Inform TimerBloc that timer has been paused
class TimerCounterPaused extends TimerCounterEvent {}

/// Inform TimerBloc that timer has resumed
class TimerCounterResumed extends TimerCounterEvent {}

/// Inform TimerBloc that timer should be reset to the original state
class TimerCounterReset extends TimerCounterEvent {}

class TimerCounterChange extends TimerCounterEvent {
  const TimerCounterChange(this.type);

  final TimerType type;
}

/// Inform TimerBloc that a tick has occurred and that it needs to update its state accordingly
class _TimerCounterTicked extends TimerCounterEvent {
  const _TimerCounterTicked({required this.duration});
  final int duration;
}
