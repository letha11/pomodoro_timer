import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/timer/domain/entity/sound_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/repository/reactive_setting_repository.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_sound_setting.dart';
import 'package:pomodoro_timer/timer/domain/usecase/set_sound_setting.dart';

@GenerateNiceMocks([MockSpec<ReactiveSettingRepository>()])
import 'sound_usecase_test.mocks.dart';

void main() {
  late ReactiveSettingRepository settingRepository;

  setUp(() {
    settingRepository = MockReactiveSettingRepository();
  });

  group('GetSoundSettingUsecase', () {
    StreamController<SoundSettingEntity> streamController =
        StreamController<SoundSettingEntity>();

    late final GetSoundSettingUsecase usecase;

    setUp(() {
      usecase = GetSoundSettingUsecase(settingRepository);
    });

    test('should return an the proper value ', () {
      when(settingRepository.getSoundStream())
          .thenReturn(Right(streamController.stream));

      var result = usecase();

      expect(result.isRight(), true);
      expect(result, equals(Right(streamController.stream)));

      when(settingRepository.getSoundStream())
          .thenReturn(Left(UnhandledFailure()));

      result = usecase();

      verify(settingRepository.getSoundStream()).called(2);
      verifyNoMoreInteractions(settingRepository);
      expect(result.isLeft(), true);
      expect(result, equals(Left(UnhandledFailure())));
    });
  });

  group('SetSoundSettingUsecase', () {
    late final SetSoundSettingUsecase usecase;

    setUp(() {
      usecase = SetSoundSettingUsecase(settingRepository);
    });

    test('should return correct value', () async {
      when(settingRepository.storeSoundSetting(
              playSound: anyNamed('playSound'),
              bytesData: anyNamed('bytesData'),
              type: anyNamed('type')))
          .thenAnswer((realInvocation) async => Right(Success()));

      var result = await usecase();

      expect(result.isRight(), true);
      expect(result, equals(Right(Success())));

      when(settingRepository.storeSoundSetting(
              playSound: anyNamed('playSound'),
              bytesData: anyNamed('bytesData'),
              type: anyNamed('type')))
          .thenAnswer((realInvocation) async => Left(UnhandledFailure()));

      result = await usecase();

      expect(result.isLeft(), true);
      expect(result, equals(Left(UnhandledFailure())));

      verify(settingRepository.storeSoundSetting(
              playSound: anyNamed('playSound'),
              bytesData: anyNamed('bytesData'),
              type: anyNamed('type')))
          .called(2);
      verifyNoMoreInteractions(settingRepository);
    });
  });
}
