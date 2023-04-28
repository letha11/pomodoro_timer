// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/core/utils/error_object.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart';

import 'package:pomodoro_timer/timer/domain/usecase/get_timer.dart';
import 'package:pomodoro_timer/timer/domain/usecase/set_timer.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/timer/timer_bloc.dart';

@GenerateNiceMocks([MockSpec<GetTimerUsecase>(), MockSpec<SetTimerUsecase>()])
import './timer_bloc_test.mocks.dart';

// class MockGetTimerUsecase extends Mock implements GetTimerUsecase {}

// class MockSetTimerUsecase extends Mock implements SetTimerUsecase {}

void main() {
  const TimerEntity timer = TimerEntity(pomodoroTime: 10, breakTime: 5);
  late GetTimerUsecase getTimerUsecase;
  late SetTimerUsecase setTimerUsecase;
  late TimerBloc bloc;

  setUp(() {
    getTimerUsecase = MockGetTimerUsecase();
    setTimerUsecase = MockSetTimerUsecase();
    bloc = TimerBloc(
      getTimerUsecase: getTimerUsecase,
      setTimerUsecase: setTimerUsecase,
    );
  });

  group('TimerGet', () {
    blocTest<TimerBloc, TimerState>(
      'should only call getTimerUsecase()/getTimerUsecase.call() once',
      build: () => bloc,
      act: (b) => b.add(TimerGet()),
      setUp: () {
        when(getTimerUsecase.call()).thenAnswer((_) async => const Right(timer));
      },
      verify: (_) {
        verify(getTimerUsecase()).called(1);
      },
    );

    blocTest<TimerBloc, TimerState>(
      'should emit TimerLoading and TimerLoaded when finished fetching data from local database',
      build: () => bloc,
      act: (b) => b.add(TimerGet()),
      setUp: () {
        when(getTimerUsecase()).thenAnswer((realInvocation) async => const Right(timer));
      },
      verify: (_) {
        verify(getTimerUsecase()).called(1);
      },
      expect: () => <TimerState>[
        TimerLoading(),
        TimerLoaded(pomodoroTime: timer.pomodoroTime, breakTime: timer.breakTime)
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'should emit TimerLoading and TimerFailed when error ocured while fetching data from local database',
      build: () => bloc,
      act: (b) => b.add(TimerGet()),
      setUp: () {
        when(getTimerUsecase()).thenAnswer((realInvocation) async => Left(UnhandledFailure()));
      },
      verify: (_) {
        verify(getTimerUsecase()).called(1);
      },
      expect: () => <TimerState>[
        TimerLoading(),
        TimerFailed(error: ErrorObject.mapFailureToError(UnhandledFailure())),
      ],
    );
  });

  group('TimerSet', () {
    blocTest<TimerBloc, TimerState>(
      'should only call setTimerUsecase()/setTimerUsecase.call() once',
      build: () => bloc,
      setUp: () => when(
        setTimerUsecase(),
      ).thenAnswer((realInvocation) async => Right(Success())),
      act: (b) => b.add(const TimerSet()),
      seed: () => TimerLoaded(pomodoroTime: timer.pomodoroTime, breakTime: timer.breakTime),
      verify: (_) {
        verify(setTimerUsecase()).called(1);
      },
    );

    blocTest<TimerBloc, TimerState>(
      'should emit TimerLoaded on Success',
      build: () => bloc,
      setUp: () => when(
        setTimerUsecase(
          pomodoroTime: anyNamed('pomodoroTime'),
          breakTime: anyNamed('breakTime'),
        ),
      ).thenAnswer((realInvocation) async => Right(Success())),
      act: (b) => b.add(TimerSet(pomodoroTime: 5, breakTime: 3)),
      seed: () => TimerLoaded(pomodoroTime: timer.pomodoroTime, breakTime: timer.breakTime),
      expect: () => <TimerState>[TimerLoaded(pomodoroTime: 5, breakTime: 3)],
    );
  });
}
