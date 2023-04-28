part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object?> get props => [];
}

class TimerInitial extends TimerState {}

class TimerLoading extends TimerState {}

class TimerLoaded extends TimerState {
  final int pomodoroTime;
  final int breakTime;
  final ErrorObject? error;

  const TimerLoaded({required this.pomodoroTime, required this.breakTime, this.error});

  TimerLoaded copyWith({int? pomodoroTime, int? breakTime, ErrorObject? error}) => TimerLoaded(
        pomodoroTime: pomodoroTime ?? this.pomodoroTime,
        breakTime: breakTime ?? this.breakTime,
        error: error,
      );

  /// this is important, because if you didn't override the `props`
  /// when you try to compare `TimerLoaded` with another `TimerLoaded` with a different fields value
  /// it will return true/same because it only compare if the 2 classes are TimerLoaded, not the fields value.
  @override
  List<Object?> get props => [pomodoroTime, breakTime, error];
}

class TimerFailed extends TimerState {
  final ErrorObject error;

  const TimerFailed({required this.error});

  @override
  List<Object> get props => [error];
}
