import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failures.dart';
import '../../../core/success.dart';
import '../entity/setting_entity.dart';

abstract class SettingRepository {
  Future<Either<Failure, SettingEntity>> getSetting();
  Future<Either<Failure, Success>> storeSetting({bool? pomodoroSequence, bool? playSound});
}