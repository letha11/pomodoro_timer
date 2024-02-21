import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:pomodoro_timer/core/constants.dart';

class SoundSettingEntity extends Equatable {
  final bool playSound;
  final String defaultAudioPath;
  final SoundType type;
  final Uint8List? bytesData;
  final String? importedFileName;

  const SoundSettingEntity({
    required this.playSound,
    required this.defaultAudioPath,
    required this.type,
    this.importedFileName,
    this.bytesData,
  });

  @override
  List<Object?> get props => [
        playSound,
        defaultAudioPath,
        type,
        bytesData,
        importedFileName,
      ];
}
