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
import 'package:pomodoro_timer/timer/domain/entity/timer_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_timer.dart';
import 'package:pomodoro_timer/timer/domain/usecase/set_timer.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/timer/timer_bloc.dart';

@GenerateNiceMocks([
  MockSpec<GetTimerUsecase>(),
  MockSpec<SetTimerUsecase>(),
])
import './timer_bloc_test.mocks.dart';

class MockLoggerImpl extends Mock implements LoggerImpl {}

void main() {
  const timerSettingEntity = TimerSettingEntity(
    pomodoroTime: 10,
    shortBreak: 5,
    longBreak: 7,
    pomodoroSequence: true,
  );

  const timerSettingEntitySet = TimerSettingEntity(
    pomodoroTime: 100,
    longBreak: 300,
    shortBreak: 150,
    pomodoroSequence: false,
  );

  late GetTimerUsecase getTimerUsecase;
  late SetTimerUsecase setTimerUsecase;
  late StreamController<TimerSettingEntity> timerStreamController;
  late TimerBloc bloc;

  setUp(() {
    getTimerUsecase = MockGetTimerUsecase();
    setTimerUsecase = MockSetTimerUsecase();
    timerStreamController = StreamController<TimerSettingEntity>();
    bloc = TimerBloc(
      getTimerUsecase: getTimerUsecase,
      setTimerUsecase: setTimerUsecase,
    );
  });

  test('bloc state should be TimerInitial by default', () {
    expect(bloc.state, equals(TimerInitial()));
  });

  group('TimerGet', () {
    blocTest<TimerBloc, TimerState>(
      'should only call getTimerUsecase()/getTimerUsecase.call() and setStorageTimerUsecase once',
      build: () => bloc,
      act: (b) => b.add(TimerGet()),
      setUp: () {
        when(getTimerUsecase.call())
            .thenReturn(Right(timerStreamController.stream));
      },
      verify: (_) {
        verify(getTimerUsecase()).called(1);
      },
    );

    blocTest<TimerBloc, TimerState>(
      'should emit TimerLoading and TimerLoaded when finished fetching data from local database',
      build: () => bloc,
      act: (b) {
        b.add(TimerGet());
        timerStreamController.add(timerSettingEntity);
      },
      setUp: () {
        when(getTimerUsecase()).thenReturn(Right(timerStreamController.stream));
      },
      verify: (_) {
        verify(getTimerUsecase()).called(1);
      },
      expect: () => <TimerState>[
        TimerLoading(),
        TimerLoaded(timer: timerSettingEntity),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'should emit TimerLoading and TimerFailed when error ocured while fetching data from local database',
      build: () => bloc,
      act: (b) => b.add(TimerGet()),
      setUp: () {
        when(getTimerUsecase()).thenReturn(Left(UnhandledFailure()));
      },
      verify: (_) {
        verify(getTimerUsecase()).called(1);
      },
      wait: Duration.zero,
      // force your bloc to wait one frame before closing the bloc https://github.com/felangel/bloc/issues/1299
      expect: () => <TimerState>[
        TimerLoading(),
        TimerFailed(error: ErrorObject.mapFailureToError(UnhandledFailure())),
      ],
    );
  });

  group('TimerSet', () {
    blocTest<TimerBloc, TimerState>(
      'should call `setTimerUsecase` when TimerSet event added',
      build: () => bloc,
      setUp: () {
        when(setTimerUsecase.call())
            .thenAnswer((_) async => Right(Success()));
      },
      act: (b) => b.add(TimerSet()),
      seed: () => TimerLoaded(timer: timerSettingEntity),
      verify: (bloc) => verify(setTimerUsecase.call()).called(1),
    );

    blocTest<TimerBloc, TimerState>(
      'should emit TimerLoaded again after an successful TimerGet',
      build: () => bloc,
      setUp: () {
        when(getTimerUsecase()).thenReturn(Right(timerStreamController.stream));
      },
      act: (b) {
        b.add(TimerGet());
        timerStreamController.add(timerSettingEntity);
        Future.delayed(Duration(seconds: 2));
        b.add(TimerSet(pomodoroTime: 100, longBreak: 300, shortBreak: 150));
        timerStreamController.add(timerSettingEntitySet);
      },
      seed: () => TimerLoaded(timer: timerSettingEntity),
      verify: (_) {
        verify(getTimerUsecase()).called(1);
      },
      wait: Duration.zero,
      expect: () => <TimerState>[
        TimerLoading(),
        TimerLoaded(timer: timerSettingEntity),
        TimerLoaded(timer: timerSettingEntitySet)
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'should emit previous TimerLoaded state with an `error` field filled when error ocured while set data to local database',
      build: () => bloc,
      act: (b) => b.add(TimerSet()),
      setUp: () => when(setTimerUsecase.call())
          .thenAnswer((realInvocation) async => Left(UnhandledFailure())),
      seed: () => TimerLoaded(timer: timerSettingEntity),
      expect: () => <TimerState>[
        TimerLoaded(
          timer: timerSettingEntity,
          error: ErrorObject.mapFailureToError(UnhandledFailure()),
        ),
      ],
    );
  });
}
