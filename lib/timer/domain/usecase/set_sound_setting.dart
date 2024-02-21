import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:pomodoro_timer/core/constants.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/timer/domain/repository/reactive_setting_repository.dart';

class SetSoundSettingUsecase {
  final ReactiveSettingRepository _repository;

  SetSoundSettingUsecase(this._repository);

  Future<Either<Failure, Success>> call({
    bool? playSound,
    Uint8List? bytesData,
    SoundType? type,
    String? importedFileName,
  }) async {
    return _repository.storeSoundSetting(
      playSound: playSound,
      bytesData: bytesData,
      type: type,
      importedFileName: importedFileName,
    );
  }
}
