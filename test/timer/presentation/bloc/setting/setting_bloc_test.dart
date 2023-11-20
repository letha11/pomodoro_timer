// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/core/utils/error_object.dart';
import 'package:pomodoro_timer/core/utils/logger.dart';
import 'package:pomodoro_timer/timer/domain/entity/sound_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_sound_setting.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_timer.dart';
import 'package:pomodoro_timer/timer/domain/usecase/set_sound_setting.dart';
import 'package:pomodoro_timer/timer/domain/usecase/set_timer.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/setting/setting_bloc.dart';

@GenerateNiceMocks([
  MockSpec<GetTimerUsecase>(),
  MockSpec<SetTimerUsecase>(),
  MockSpec<GetSoundSettingUsecase>(),
  MockSpec<SetSoundSettingUsecase>(),
])
import 'setting_bloc_test.mocks.dart';

class MockLoggerImpl extends Mock implements LoggerImpl {}

void main() {
  late TimerSettingEntity timerSettingEntity;
  late SoundSettingEntity soundSettingEntity;

  const timerSettingEntitySet = TimerSettingEntity(
    pomodoroTime: 100,
    longBreak: 300,
    shortBreak: 150,
    pomodoroSequence: false,
  );
  const soundSettingEntitySet = SoundSettingEntity(
    audioPath: 'assets/audio/somethingelse.wav',
    playSound: false,
  );

  late GetTimerUsecase getTimerUsecase;
  late SetTimerUsecase setTimerUsecase;
  late GetSoundSettingUsecase getSoundSettingUsecase;
  late SetSoundSettingUsecase setSoundSettingUsecase;
  late StreamController<TimerSettingEntity> timerStreamController;
  late StreamController<SoundSettingEntity> soundStreamController;
  late SettingBloc bloc;

  setUp(() {
    getTimerUsecase = MockGetTimerUsecase();
    setTimerUsecase = MockSetTimerUsecase();
    timerSettingEntity = TimerSettingEntity(
      pomodoroTime: 10,
      shortBreak: 5,
      longBreak: 7,
      pomodoroSequence: true,
    );
    soundSettingEntity = SoundSettingEntity(
      audioPath: 'assets/audio/alarm.wav',
      playSound: true,
    );
    setSoundSettingUsecase = MockSetSoundSettingUsecase();
    getSoundSettingUsecase = MockGetSoundSettingUsecase();
    timerStreamController = StreamController<TimerSettingEntity>();
    soundStreamController = StreamController<SoundSettingEntity>();
    bloc = SettingBloc(
      getTimerUsecase: getTimerUsecase,
      setTimerUsecase: setTimerUsecase,
      getSoundSettingUsecase: getSoundSettingUsecase,
      setSoundSettingUsecase: setSoundSettingUsecase,
    );
  });

  test('bloc state should be TimerInitial by default', () {
    expect(bloc.state, equals(SettingInitial()));
  });

  group('SettingGet', () {
    blocTest<SettingBloc, SettingState>(
        'should call both getTimerUsecase and getSoundSettingUsecase when GetSetting event registered',
        build: () => bloc,
        act: (b) => b.add(SettingGet()),
        setUp: () {
          when(getTimerUsecase())
              .thenReturn(Right(timerStreamController.stream));
          timerStreamController.add(timerSettingEntity);

          when(getSoundSettingUsecase())
              .thenReturn(Right(soundStreamController.stream));
          soundStreamController.add(soundSettingEntity);
        },
        verify: (_) {
          verify(getTimerUsecase()).called(1);
          verify(getSoundSettingUsecase()).called(1);
        });

    blocTest<SettingBloc, SettingState>(
      'should emit SettingLoading and SettingLoaded when db call success',
      build: () => bloc,
      act: (b) => b.add(SettingGet()),
      setUp: () {
        when(getTimerUsecase()).thenReturn(Right(timerStreamController.stream));
        timerStreamController.add(timerSettingEntity);

        when(getSoundSettingUsecase())
            .thenReturn(Right(soundStreamController.stream));
        soundStreamController.add(soundSettingEntity);
      },
      expect: () => <SettingState>[
        SettingLoading(),
        SettingLoaded(
          timer: timerSettingEntity,
          soundSetting: soundSettingEntity,
        ),
      ],
    );

    blocTest<SettingBloc, SettingState>(
      'should emit SettingFailure when db call getTimerUsecase failed',
      build: () => bloc,
      act: (b) => b.add(SettingGet()),
      setUp: () {
        when(getTimerUsecase()).thenReturn(Left(UnhandledFailure()));
      },
      expect: () => <SettingState>[
        SettingLoading(),
        SettingFailed(error: ErrorObject.mapFailureToError(UnhandledFailure()))
      ],
    );

    blocTest<SettingBloc, SettingState>(
      'should emit SettingFailure when db call getSoundSettingUsecase failed',
      build: () => bloc,
      act: (b) => b.add(SettingGet()),
      setUp: () {
        when(getTimerUsecase()).thenReturn(Right(timerStreamController.stream));
        when(getSoundSettingUsecase()).thenReturn(Left(UnhandledFailure()));
      },
      expect: () => <SettingState>[
        SettingLoading(),
        SettingFailed(error: ErrorObject.mapFailureToError(UnhandledFailure()))
      ],
    );

    blocTest<SettingBloc, SettingState>(
      'should emit SettingFailure when db call getSoundSettingUsecase or getTimerUsecase failed after first success',
      build: () => bloc,
      act: (b) async {
        // first event (Success)
        b.add(SettingGet());

        // stubbing for the second event
        await Future.delayed(const Duration(milliseconds: 1));
        when(getTimerUsecase()).thenReturn(Left(UnhandledFailure()));

        // second event fired (Failed)
        bloc.add(SettingGet());
      },
      setUp: () async {
        when(getTimerUsecase()).thenReturn(Right(timerStreamController.stream));
        timerStreamController.add(timerSettingEntity);

        when(getSoundSettingUsecase())
            .thenReturn(Right(soundStreamController.stream));
        soundStreamController.add(soundSettingEntity);
      },
      expect: () => <SettingState>[
        SettingLoading(),
        SettingLoaded(
          timer: timerSettingEntity,
          soundSetting: soundSettingEntity,
        ),

        // Second Event
        SettingLoading(),
        SettingFailed(error: ErrorObject.mapFailureToError(UnhandledFailure()))
      ],
    );
  });

  group('SettingSet', () {
    blocTest<SettingBloc, SettingState>(
      'should only call SetTimerUsecase when event arguments filled with Timer properties only',
      build: () => bloc,
      act: (b) {
        b.add(SettingGet());
        b.add(SettingSet(
          pomodoroTime: 120,
        ));
      },
      setUp: () {
        // SettingGet event stub
        when(getTimerUsecase()).thenReturn(Right(timerStreamController.stream));
        timerStreamController.add(timerSettingEntity);

        when(getSoundSettingUsecase())
            .thenReturn(Right(soundStreamController.stream));
        soundStreamController.add(soundSettingEntity);

        // SettingSet event stub
        when(setTimerUsecase(
          pomodoroTime: anyNamed("pomodoroTime"),
          longBreak: anyNamed("longBreak"),
          shortBreak: anyNamed("shortBreak"),
          pomodoroSequence: anyNamed("pomodoroSequence"),
        )).thenAnswer((realInvocation) async => Right(Success()));
      },
      verify: (_) => verify(setTimerUsecase(
        pomodoroTime: anyNamed("pomodoroTime"),
        longBreak: anyNamed("longBreak"),
        shortBreak: anyNamed("shortBreak"),
        pomodoroSequence: anyNamed("pomodoroSequence"),
      )).called(1),
    );

    blocTest<SettingBloc, SettingState>(
      'should only call SetSoundSettingUsecase when event arguments filled with Sound properties only',
      build: () => bloc,
      act: (b) {
        b.add(SettingGet());
        b.add(SettingSet(
          playSound: false,
        ));
      },
      setUp: () {
        // SettingGet event stub
        when(getTimerUsecase()).thenReturn(Right(timerStreamController.stream));
        timerStreamController.add(timerSettingEntity);

        when(getSoundSettingUsecase())
            .thenReturn(Right(soundStreamController.stream));
        soundStreamController.add(soundSettingEntity);

        // SettingSet event stub
        when(setSoundSettingUsecase(
          playSound: anyNamed('playSound'),
          audioPath: anyNamed('audioPath'),
        )).thenAnswer((realInvocation) async => Right(Success()));
      },
      verify: (_) => verify(setSoundSettingUsecase(
        playSound: anyNamed('playSound'),
        audioPath: anyNamed('audioPath'),
      )).called(1),
    );

    blocTest<SettingBloc, SettingState>(
      'should call both SetTimerUsecase, SetSoundSettingUsecase when event arguments filled with Both properties',
      build: () => bloc,
      act: (b) {
        b.add(SettingGet());
        b.add(SettingSet(
          pomodoroTime: 300,
          playSound: false,
        ));
      },
      setUp: () {
        // SettingGet event stub
        when(getTimerUsecase()).thenReturn(Right(timerStreamController.stream));
        timerStreamController.add(timerSettingEntity);

        when(getSoundSettingUsecase())
            .thenReturn(Right(soundStreamController.stream));
        soundStreamController.add(soundSettingEntity);

        // SettingSet event stub
        when(setTimerUsecase(
          pomodoroTime: anyNamed("pomodoroTime"),
          longBreak: anyNamed("longBreak"),
          shortBreak: anyNamed("shortBreak"),
          pomodoroSequence: anyNamed("pomodoroSequence"),
        )).thenAnswer((realInvocation) async => Right(Success()));
        when(setSoundSettingUsecase(
          playSound: anyNamed('playSound'),
          audioPath: anyNamed('audioPath'),
        )).thenAnswer((realInvocation) async => Right(Success()));
      },
      verify: (_) {
        verify(setTimerUsecase(
          pomodoroTime: anyNamed("pomodoroTime"),
          longBreak: anyNamed("longBreak"),
          shortBreak: anyNamed("shortBreak"),
          pomodoroSequence: anyNamed("pomodoroSequence"),
        )).called(1);
        verify(setSoundSettingUsecase(
          playSound: anyNamed('playSound'),
          audioPath: anyNamed('audioPath'),
        )).called(1);
      },
    );

    blocTest<SettingBloc, SettingState>(
      'should emit SettingLoaded again after an successful SettingGet',
      build: () => bloc,
      act: (b) {
        b.add(SettingGet());
        b.add(SettingSet(
          pomodoroTime: 300,
          playSound: false,
        ));
      },
      setUp: () {
        // SettingGet event stub
        when(getTimerUsecase()).thenReturn(Right(timerStreamController.stream));
        timerStreamController.add(timerSettingEntity);

        when(getSoundSettingUsecase())
            .thenReturn(Right(soundStreamController.stream));
        soundStreamController.add(soundSettingEntity);

        // SettingSet event stub
        when(setTimerUsecase(
          pomodoroTime: anyNamed("pomodoroTime"),
          longBreak: anyNamed("longBreak"),
          shortBreak: anyNamed("shortBreak"),
          pomodoroSequence: anyNamed("pomodoroSequence"),
        )).thenAnswer((realInvocation) async => Right(Success()));
        when(setSoundSettingUsecase(
          playSound: anyNamed('playSound'),
          audioPath: anyNamed('audioPath'),
        )).thenAnswer((realInvocation) async => Right(Success()));
        timerStreamController.add(timerSettingEntitySet);
        soundStreamController.add(soundSettingEntitySet);
      },
      expect: () => <SettingState>[
        SettingLoading(),
        SettingLoaded(
          timer: timerSettingEntity,
          soundSetting: soundSettingEntity,
        ),

        // SettingState from SettingSet
        SettingLoaded(
          timer: timerSettingEntitySet,
          soundSetting: soundSettingEntity,
        ),
        SettingLoaded(
          timer: timerSettingEntitySet,
          soundSetting: soundSettingEntitySet,
        ),
      ],
    );

    blocTest<SettingBloc, SettingState>(
      'should emit previous SettingLoaded state with an `error` field filled when error ocured while set data to local database',
      build: () => bloc,
      act: (b) {
        b.add(SettingGet());
        b.add(SettingSet(
          pomodoroTime: 300,
          playSound: true,
        ));
      },
      seed: () => SettingLoaded(
        soundSetting: soundSettingEntity,
        timer: timerSettingEntity,
      ),
      setUp: () {
        // SettingGet event stub
        when(getTimerUsecase()).thenReturn(Right(timerStreamController.stream));
        timerStreamController.add(timerSettingEntity);

        when(getSoundSettingUsecase())
            .thenReturn(Right(soundStreamController.stream));
        soundStreamController.add(soundSettingEntity);

        // SettingSet event stub
        when(setTimerUsecase(
          pomodoroTime: anyNamed("pomodoroTime"),
          longBreak: anyNamed("longBreak"),
          shortBreak: anyNamed("shortBreak"),
          pomodoroSequence: anyNamed("pomodoroSequence"),
        )).thenAnswer((realInvocation) async => Right(Success()));
        when(setSoundSettingUsecase(
          playSound: anyNamed('playSound'),
          audioPath: anyNamed('audioPath'),
        )).thenAnswer((realInvocation) async => Left(UnhandledFailure()));
        // timerStreamController.add(timerSettingEntitySet);
        // soundStreamController.add(soundSettingEntitySet);
      },
      wait: const Duration(seconds: 1),
      expect: () => <SettingState>[
        SettingLoading(),
        SettingLoaded(
          timer: timerSettingEntity,
          soundSetting: soundSettingEntity,
        ),
        SettingLoaded(
          timer: timerSettingEntity,
          soundSetting: soundSettingEntity,
          error: ErrorObject.mapFailureToError(UnhandledFailure()),
        ),
      ],
    );
  });
}
