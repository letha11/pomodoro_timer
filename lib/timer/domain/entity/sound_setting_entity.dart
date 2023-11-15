import 'package:equatable/equatable.dart';

class SoundSettingEntity extends Equatable {
  final bool playSound;
  final String audioPath;

  const SoundSettingEntity({
    required this.playSound,
    required this.audioPath,
  });

  @override
  List<Object?> get props => [
        playSound,
        audioPath,
      ];
}
