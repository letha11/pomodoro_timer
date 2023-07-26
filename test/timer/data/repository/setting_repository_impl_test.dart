import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/timer/data/datasource/local/setting_repository_db.dart';
import 'package:pomodoro_timer/timer/data/models/setting_model.dart';
import 'package:pomodoro_timer/timer/data/repository/setting_repository_impl.dart';
import 'package:pomodoro_timer/timer/domain/entity/setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/repository/setting_repository.dart';

@GenerateNiceMocks([MockSpec<SettingRepositoryHiveDB>()])
import 'setting_repository_impl_test.mocks.dart';

void main() {
  late SettingRepositoryDB settingRepositoryDB;
  late SettingRepository settingRepository;
  late SettingModel setting;

  setUp(() {
    settingRepositoryDB = MockSettingRepositoryHiveDB();
    settingRepository =
        SettingRepositoryImpl(settingRepositoryDB: settingRepositoryDB);
    setting = const SettingModel();
  });

  group('constructors', () {
    test('works', () {
      final result =
          SettingRepositoryImpl(settingRepositoryDB: settingRepositoryDB);

      expect(result, isNotNull);
      expect(result, isA<SettingRepository>());
    });
  });

  group('getSetting', () {
    test('should return Right(SettingEntity) on success', () async {
      when(settingRepositoryDB.get()).thenReturn(setting);

      final result = await settingRepository.getSetting();

      verify(settingRepositoryDB.get()).called(1);
      expect(result.isRight(), true);
      expect(result, equals(Right(setting)));
      expect((result as Right).value, isA<SettingEntity>());
    });

    test(
        'should return Left(Failure) when `settingRepositoryDB.get()` throws an error',
        () async {
      when(settingRepositoryDB.get()).thenThrow(Exception('oops'));

      final result = await settingRepository.getSetting();

      expect(result, equals(Left(UnhandledFailure())));
    });
  });

  group('storeSetting', () {
    test('should return Right(Success) when success storing', () async {
      final result = await settingRepository.storeSetting(setting);

      verify(settingRepositoryDB.store(setting)).called(1);
      expect(result, equals(Right(Success())));
      expect((result as Right).value, isA<Success>());
    });

    test('should return Left(Failure) when failed storing', () async {
      when(settingRepositoryDB.store(setting)).thenThrow(Exception('oops'));

      final result = await settingRepository.storeSetting(setting);

      expect(result, equals(Left(UnhandledFailure())));
    });
  });
}
