import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/timer/domain/entity/setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/repository/setting_repository.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_setting.dart';
import 'package:pomodoro_timer/timer/domain/usecase/store_setting.dart';

@GenerateNiceMocks([MockSpec<SettingRepository>()])
import 'setting_usecase_test.mocks.dart';

void main() {
  late SettingRepository repository;
  late GetSettingUsecase getSetting;
  late StoreSettingUsecase storeSetting;

  const SettingEntity entity =
      SettingEntity(pomodoroSequence: true, playSound: false);

  setUp(() {
    repository = MockSettingRepository();
    getSetting = GetSettingUsecase(repository);
    storeSetting = StoreSettingUsecase(repository);
  });

  group("GetSettingUsecase", () {
    test('should return Right(SettingEntity) when success', () async {
      when(repository.getSetting())
          .thenAnswer((_) async => const Right(entity));

      final result = await getSetting();

      verify(repository.getSetting()).called(1);
      expect(result.isRight(), true);
      expect(result, equals(const Right(entity)));
      expect(
        (result as Right).value,
        isA<SettingEntity>()
            .having((p0) => p0.pomodoroSequence, "pomodoroSequence",
                entity.pomodoroSequence)
            .having((p0) => p0.playSound, "playSound", entity.playSound),
      );
    });

    test(
        "should return Left(Failure_subclass) when repository throws an exception",
        () async {
      when(repository.getSetting())
          .thenAnswer((_) async => Left(UnhandledFailure()));

      final result = await getSetting();

      verify(repository.getSetting()).called(1);
      expect(result, equals(Left(UnhandledFailure())));
    });
  });

  group(StoreSettingUsecase, () {
    test('should return Right(Success) when there is no error', () async {
      when(repository.storeSetting(
        pomodoroSequence: anyNamed('pomodoroSequence'),
        playSound: anyNamed('playSound'),
      )).thenAnswer((realInvocation) async => Right(Success()));

      final result =
          await storeSetting(pomodoroSequence: !entity.pomodoroSequence);

      verify(repository.storeSetting(
        pomodoroSequence: anyNamed('pomodoroSequence'),
        playSound: anyNamed('playSound'),
      )).called(1);
      expect(result.isRight(), true);
      expect(result, equals(Right(Success())));
      expect((result as Right).value, isA<Success>());
    });

    test('should return Left(Failure) when there is error', () async {
      when(repository.storeSetting(
        pomodoroSequence: anyNamed('pomodoroSequence'),
        playSound: anyNamed('playSound'),
      )).thenAnswer((realInvocation) async => Left(UnhandledFailure()));

      final result = await storeSetting(playSound: false);

      verify(repository.storeSetting(
        pomodoroSequence: anyNamed('pomodoroSequence'),
        playSound: anyNamed('playSound'),
      )).called(1);
      expect(result.isLeft(), true);
      expect(result, equals(Left(UnhandledFailure())));
    });
  });
}
