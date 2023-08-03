import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failures.dart';
import '../../../core/success.dart';
import '../repository/setting_repository.dart';

class StoreSettingUsecase {
  final SettingRepository _repository;

  StoreSettingUsecase(this._repository);

  Future<Either<Failure, Success>> call(
          {bool? pomodoroSequence, bool? playSound}) async =>
      await _repository.storeSetting(
        pomodoroSequence: pomodoroSequence,
        playSound: playSound,
      );
}
