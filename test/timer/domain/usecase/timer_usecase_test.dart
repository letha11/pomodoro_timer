import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/repository/reactive_setting_repository.dart';
import 'package:pomodoro_timer/timer/domain/usecase/usecases.dart';

/// Null safety
@GenerateNiceMocks([MockSpec<ReactiveSettingRepository>()])
import 'timer_usecase_test.mocks.dart';

void main() {
  late ReactiveSettingRepository settingRepository;

  setUp(() {
    settingRepository = MockReactiveSettingRepository();
  });

  group('GetTimerUsecase', () {
    late GetTimerUsecase usecase;
    late StreamController<TimerSettingEntity> timerStream;

    setUp(() {
      settingRepository = MockReactiveSettingRepository();
      usecase = GetTimerUsecase(settingRepository);
      timerStream = StreamController<TimerSettingEntity>();
    });

    test('should get Right(Stream<TimerSettingEntity>) from repository',
        () async {
      when(settingRepository.getTimerStream())
          .thenReturn(Right(timerStream.stream));

      final stream = usecase();

      verify(settingRepository.getTimerStream()).called(1);
      verifyNoMoreInteractions(settingRepository);
      expect(stream.isRight(), true);
      expect(stream, equals(Right(timerStream.stream)));
    });

    test(
        'should return Left from repository when something unexpected went wrong',
        () {
      when(settingRepository.getTimerStream())
          .thenReturn(Left(UnhandledFailure()));

      final result = usecase();

      verify(settingRepository.getTimerStream()).called(1);
      verifyNoMoreInteractions(settingRepository);
      expect(result.isLeft(), true);
    });
  });

  group('SetTimerUsecase', () {
    late SetTimerUsecase usecase;

    setUp(() {
      settingRepository = MockReactiveSettingRepository();
      usecase = SetTimerUsecase(settingRepository);
    });

    test('should return Right(Success) from repository', () async {
      when(settingRepository.storeTimerSetting(
              pomodoroTime: anyNamed('pomodoroTime'),
              shortBreak: anyNamed('shortBreak'),
              longBreak: anyNamed('longBreak')))
          .thenAnswer((realInvocation) async => Right(Success()));

      final response = await usecase();

      verify(settingRepository.storeTimerSetting(
              pomodoroTime: anyNamed('pomodoroTime'),
              shortBreak: anyNamed('shortBreak'),
              longBreak: anyNamed('longBreak')))
          .called(1);
      expect(response.isRight(), true);
      expect(response, equals(Right(Success())));
    });
    
    test('should return Left from repository when something unexpected happend', () async {
      when(settingRepository.storeTimerSetting(
              pomodoroTime: anyNamed('pomodoroTime'),
              shortBreak: anyNamed('shortBreak'),
              longBreak: anyNamed('longBreak')))
          .thenAnswer((realInvocation) async => Left(UnhandledFailure()));
      
      final response = await usecase();
      
      verify(settingRepository.storeTimerSetting(
              pomodoroTime: anyNamed('pomodoroTime'),
              shortBreak: anyNamed('shortBreak'),
              longBreak: anyNamed('longBreak')))
          .called(1);
      expect(response.isLeft(), true);
      expect(response, equals(Left(UnhandledFailure())));
    });
  });
}
