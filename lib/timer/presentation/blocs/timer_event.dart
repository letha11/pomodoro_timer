part of 'timer_bloc.dart';

@immutable
abstract class TimerEvent {
  const TimerEvent();
}

/// Inform TimerBloc that timer has started
class TimerStarted extends TimerEvent {
  const TimerStarted({required this.duration});
  final int duration;
}

/// Inform TimerBloc that timer has been paused
class TimerPaused extends TimerEvent {}

/// Inform TimerBloc that timer has resumed
class TimerResumed extends TimerEvent {}

/// Inform TimerBloc that timer should be reset to the original state
class TimerReset extends TimerEvent {}

/// Inform TimerBloc that a tick has occurred and that it needs to update its state accordingly
class _TimerTicked extends TimerEvent {
  const _TimerTicked({required this.duration});
  final int duration;
}
