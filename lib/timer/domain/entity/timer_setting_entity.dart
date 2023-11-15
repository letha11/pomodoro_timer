import 'package:equatable/equatable.dart';

class TimerSettingEntity extends Equatable {
  final int pomodoroTime;
  final int shortBreak;
  final int longBreak;
  final bool pomodoroSequence;

  const TimerSettingEntity({
    required this.pomodoroTime,
    required this.shortBreak,
    required this.longBreak,
    required this.pomodoroSequence,
  });

  @override
  List<Object?> get props => [
        pomodoroTime,
        shortBreak,
        longBreak,
        pomodoroSequence,
      ];
}
