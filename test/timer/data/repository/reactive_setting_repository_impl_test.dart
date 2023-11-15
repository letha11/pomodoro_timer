import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/timer/data/datasource/local/setting_repository_db.dart';
import 'package:pomodoro_timer/timer/data/models/setting_hive_model.dart';
import 'package:pomodoro_timer/timer/data/repository/reactive_setting_repository_impl.dart';
import 'package:pomodoro_timer/timer/domain/entity/sound_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/repository/reactive_setting_repository.dart';

import 'reactive_setting_repository_impl_test.mocks.dart';

@GenerateMocks([SettingRepositoryHiveDB])
void main() {
  const TimerSettingModel timerSettingModel = TimerSettingModel();
  const SoundSettingModel soundSettingModel = SoundSettingModel();

  late ReactiveSettingRepository reactiveSettingRepository;
  late SettingRepositoryDB dbRepository;

  setUp(() {
    dbRepository = MockSettingRepositoryHiveDB();
    reactiveSettingRepository =
        ReactiveSettingRepositoryImpl(dbRepository: dbRepository);
  });

  group('timer', () {
    test('getTimer should return a stream with the type of TimerSettingEntity',
        () async {
      when(dbRepository.getTimer()).thenReturn(timerSettingModel);

      final result = reactiveSettingRepository.getTimerStream();

      expect(result.isRight(), true);
      expect((result as Right).value, isA<Stream<TimerSettingEntity>>());
    });

    test('getTimer should return Left(Failure) when something went wrong', () {
      when(dbRepository.getTimer())
          .thenThrow(Exception('Something went Wrong!'));

      final result = reactiveSettingRepository.getTimerStream();

      expect(result.isLeft(), true);
      expect(result, equals(Left(UnhandledFailure())));
    });

    test('getTimer should initialize the first data with the stored value',
        () async {
      when(dbRepository.getTimer()).thenReturn(timerSettingModel);

      final timerStream = reactiveSettingRepository.getTimerStream();

      expect(timerStream.isRight(), true);

      final result =
          await (timerStream as Right<Failure, Stream<TimerSettingEntity>>)
              .value
              .first;

      expect(
        result,
        isA<TimerSettingEntity>()
            .having((p0) => p0.pomodoroTime, 'pomodoroTime',
                timerSettingModel.pomodoroTime)
            .having(
                (p0) => p0.longBreak, 'longBreak', timerSettingModel.longBreak)
            .having((p0) => p0.shortBreak, 'shortBreak',
                timerSettingModel.shortBreak),
      );
    });

    // storeTimer
    test(
        'storeTimer should call _dbRepository.storeTimerSetting and emit newly created data and return Right(Success)',
        () async {
      when(dbRepository.getTimer()).thenReturn(timerSettingModel);

      // arrange
      const newTimerModel = TimerSettingModel(
        longBreak: 30,
        pomodoroTime: 60,
        shortBreak: 15,
      );
      final getResult = reactiveSettingRepository.getTimerStream();

      expect(getResult.isRight(), true);

      final Stream<TimerSettingEntity> timerStream =
          (getResult as Right<Failure, Stream<TimerSettingEntity>>).value;

      final result = await reactiveSettingRepository.storeTimerSetting(
        longBreak: newTimerModel.longBreak,
        pomodoroTime: newTimerModel.pomodoroTime,
        shortBreak: newTimerModel.shortBreak,
      );

      expect(result.isRight(), true);
      expect(result, equals(Right(Success())));

      verify(dbRepository.storeTimerSetting(
        longBreak: newTimerModel.longBreak,
        pomodoroTime: newTimerModel.pomodoroTime,
        shortBreak: newTimerModel.shortBreak,
      )).called(1);

      expect(
        timerStream,
        emitsInOrder([
          timerSettingModel.toEntity(),
          newTimerModel.toEntity(),
        ]),
      );
    });

    test(
        'storeTimer should return Left(UnhandledError) when something unexpected happend',
        () async {
      when(dbRepository.getTimer()).thenReturn(timerSettingModel);
      when(dbRepository.storeTimerSetting(
        longBreak: anyNamed('longBreak'),
        pomodoroTime: anyNamed('pomodoroTime'),
        shortBreak: anyNamed('shortBreak'),
      )).thenThrow(Exception('X_X'));

      final result = await reactiveSettingRepository.storeTimerSetting(
        longBreak: 30,
        pomodoroTime: 60,
        shortBreak: 45,
      );

      expect(result.isLeft(), true);
      expect(result, equals(Left(UnhandledFailure())));
    });
  });

  group('sound', () {
    test('getSound should return a stream with the type of SoundSettingEntity',
        () {
      when(dbRepository.getSound()).thenReturn(soundSettingModel);

      final result = reactiveSettingRepository.getSoundStream();

      expect(result.isRight(), true);
      expect((result as Right).value, isA<Stream<SoundSettingEntity>>());
    });

    test(
        'getSound should return a Left(UnhandledFailure) when it throws an exception',
        () {
      when(dbRepository.getSound()).thenThrow(Exception('X_X'));

      final result = reactiveSettingRepository.getSoundStream();

      expect(result.isLeft(), true);
      expect((result as Left).value, isA<Failure>());
      expect(result, equals(Left(UnhandledFailure())));
    });

    test('getSound should initialize the first data with the storedValue',
        () async {
      when(dbRepository.getSound()).thenReturn(soundSettingModel);

      final soundStream = reactiveSettingRepository.getSoundStream();

      expect(soundStream.isRight(), true);

      // act
      final firstData =
          await (soundStream as Right<Failure, Stream<SoundSettingEntity>>)
              .value
              .first;

      expect(
        firstData,
        isA<SoundSettingEntity>()
            .having(
                (p0) => p0.playSound, 'playSound', soundSettingModel.playSound)
            .having(
                (p0) => p0.audioPath, 'audioPath', soundSettingModel.audioPath),
      );
    });

    test(
        'storeSound should call _dbRepository.storeSoundSetting and emits newly created data and return a Right(Success)',
        () async {
      when(dbRepository.getSound()).thenReturn(soundSettingModel);

      const newSoundSetting = SoundSettingModel(
        audioPath: 'test:)',
        playSound: false,
      );

      final result = reactiveSettingRepository.getSoundStream();

      expect(result.isRight(), true);

      final Stream<SoundSettingEntity> soundStream =
          (result as Right<Failure, Stream<SoundSettingEntity>>).value;

      final storeResult = await reactiveSettingRepository.storeSoundSetting(
        audioPath: newSoundSetting.audioPath,
        playSound: newSoundSetting.playSound,
      );

      expect(storeResult.isRight(), true);
      expect(storeResult, equals(Right(Success())));
      expect((storeResult as Right).value, isA<Success>());

      verify(dbRepository.storeSoundSetting(
        audioPath: newSoundSetting.audioPath,
        playSound: newSoundSetting.playSound,
      )).called(1);

      expect(
          soundStream,
          emitsInOrder([
            soundSettingModel.toEntity(),
            newSoundSetting.toEntity(),
          ]));
    });

    test(
        'storeSound should return a Left(UnhandledFailure) when something went wrong',
        () async {
      when(dbRepository.getSound()).thenReturn(soundSettingModel);
      when(dbRepository.storeSoundSetting(
              audioPath: anyNamed('audioPath'),
              playSound: anyNamed('playSound')))
          .thenThrow(Exception('X_X'));

      final result = await reactiveSettingRepository.storeSoundSetting(
        audioPath: '',
        playSound: false,
      );

      expect(result.isLeft(), true);
      expect(result, equals(Left(UnhandledFailure())));
    });
  });
}
