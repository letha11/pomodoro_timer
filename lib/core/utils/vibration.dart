import 'package:vibration/vibration.dart';

abstract class VibrationL {
  void vibrate({int duration});
  Future<bool?> hasCustomVibrationsSupport();
}

class VibrationLImpl extends VibrationL {
  @override
  void vibrate({int duration = 500}) {
    Vibration.vibrate(duration: duration);
  }

  @override
  Future<bool?> hasCustomVibrationsSupport() {
    return Vibration.hasCustomVibrationsSupport();
  }
}
