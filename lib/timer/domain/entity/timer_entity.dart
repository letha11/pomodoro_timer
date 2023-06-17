import 'package:equatable/equatable.dart';

class TimerEntity extends Equatable {
  final int pomodoroTime;
  final int breakTime;
  final int longBreak;

  const TimerEntity({
    required this.pomodoroTime,
    required this.breakTime,
    required this.longBreak,
  });

  @override
  List<Object?> get props => [pomodoroTime, breakTime, longBreak];

  @override
  String toString() {
    return "TimerEntity: {pomodoroTime: $pomodoroTime, breakTime: $breakTime, longBreak: $longBreak}";
  }
}
