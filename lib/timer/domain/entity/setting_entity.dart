import 'package:equatable/equatable.dart';

class SettingEntity extends Equatable {
  final bool pomodoroSequence;
  final bool playSound;

  const SettingEntity({required this.pomodoroSequence, required this.playSound});

  @override
  List<Object> get props => [pomodoroSequence, playSound];

  @override
  String toString() {
    return '''
      TimerEntity: {
        pomdoroSequence: $pomodoroSequence,
        playSound: $playSound
      }
    ''';
  }
}