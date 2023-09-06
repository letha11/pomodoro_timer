import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failures.dart';
import '../../domain/repository/setting_repository.dart';
import '../models/setting_model.dart';

class SettingManager {
  late SettingModel setting;
  final SettingRepository _repository;

  SettingManager(this._repository);
  

  bool get pomodoroSequence => setting.pomodoroSequence;

  bool get playSound => setting.playSound;
  set playSound(bool playSound) {
    setting.playSound = playSound;
  
  
  Future<Either<Failure, SettingModel>> getSetting() async {

    final result = await _repository.getSetting();

    return result;
  }

  void store({
    bool? pomodoroSequence,
    bool? playSound,
  }) async {
    await _repository.storeSetting(
      pomodoroSequence: pomodoroSequence,
      playSound: playSound,
    );

    setting = SettingModel(pomodoroSequence: pomodoroSequence, playSound: playSound);
  }
  
}
