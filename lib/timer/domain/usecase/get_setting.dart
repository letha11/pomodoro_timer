import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failures.dart';
import '../entity/setting_entity.dart';
import '../repository/setting_repository.dart';

class GetSettingUsecase {
  final SettingRepository _repository;

  GetSettingUsecase(this._repository);

  Future<Either<Failure, SettingEntity>> call() async =>
      await _repository.getSetting();
}
