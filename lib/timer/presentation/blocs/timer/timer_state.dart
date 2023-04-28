part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object> get props => [];
}

class TimerInitial extends TimerState {}

class TimerLoading extends TimerState {}

class TimerLoaded extends TimerState {
  final int pomodoroTime;
  final int breakTime;

  const TimerLoaded({required this.pomodoroTime, required this.breakTime});

  TimerLoaded copyWith({int? pomodoroTime, int? breakTime}) => TimerLoaded(
        pomodoroTime: pomodoroTime ?? this.pomodoroTime,
        breakTime: breakTime ?? this.breakTime,
      );

  /// this is important, because if you didn't override the `props`
  /// when you try to compare `TimerLoaded` with another `TimerLoaded` with a different fields value
  /// it will return true/same because it only compare if the 2 classes are TimerLoaded, not the fields value.
  @override
  List<Object> get props => [pomodoroTime, breakTime];
}

class TimerFailed extends TimerState {
  final ErrorObject error;

  const TimerFailed({required this.error});

  @override
  List<Object> get props => [error];
}
