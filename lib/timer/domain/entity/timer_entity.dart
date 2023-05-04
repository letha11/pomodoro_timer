import 'package:equatable/equatable.dart';

class TimerEntity extends Equatable {
  final int pomodoroTime;
  final int breakTime;

  const TimerEntity({required this.pomodoroTime, required this.breakTime});

  @override
  List<Object?> get props => [pomodoroTime, breakTime];

  @override
  String toString() {
    return "TimerEntity: {pomodoroTime: $pomodoroTime, breakTime: $breakTime}";
  }
}
