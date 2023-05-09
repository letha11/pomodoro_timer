// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/core/utils/error_object.dart';
import 'package:pomodoro_timer/core/utils/logger.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart';
import 'package:pomodoro_timer/timer/domain/usecase/add_storage_timer.dart';

import 'package:pomodoro_timer/timer/domain/usecase/get_timer.dart';
import 'package:pomodoro_timer/timer/domain/usecase/set_timer.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/timer/timer_bloc.dart';

@GenerateNiceMocks([
  MockSpec<GetTimerUsecase>(),
  MockSpec<SetTimerUsecase>(),
  MockSpec<AddStorageTimerUsecase>()
])
import './timer_bloc_test.mocks.dart';

class MockLoggerImpl extends Mock implements LoggerImpl {}

void main() {
  const TimerEntity timer = TimerEntity(pomodoroTime: 10, breakTime: 5);
  late GetTimerUsecase getTimerUsecase;
  late SetTimerUsecase setTimerUsecase;
  late AddStorageTimerUsecase addStorageTimerUsecase;
  late TimerBloc bloc;

  setUp(() {
    getTimerUsecase = MockGetTimerUsecase();
    setTimerUsecase = MockSetTimerUsecase();
    addStorageTimerUsecase = MockAddStorageTimerUsecase();
    bloc = TimerBloc(
      getTimerUsecase: getTimerUsecase,
      setTimerUsecase: setTimerUsecase,
      addStorageTimerUsecase: addStorageTimerUsecase,
    );
  });

  group('TimerGet', () {
    blocTest<TimerBloc, TimerState>(
      'should only call getTimerUsecase()/getTimerUsecase.call() and setStorageTimerUsecase once',
      build: () => bloc,
      act: (b) => b.add(TimerGet()),
      setUp: () {
        when(getTimerUsecase.call())
            .thenAnswer((_) async => const Right(timer));
        // when(addStorageTimerUsecase(timer))
        //     .thenAnswer((_) async => null));
      },
      verify: (_) {
        verify(getTimerUsecase()).called(1);
        verify(addStorageTimerUsecase(timer)).called(1);
      },
    );

    blocTest<TimerBloc, TimerState>(
      'should emit TimerLoading and TimerLoaded when finished fetching data from local database',
      build: () => bloc,
      act: (b) => b.add(TimerGet()),
      setUp: () {
        when(getTimerUsecase())
            .thenAnswer((realInvocation) async => const Right(timer));
      },
      verify: (_) {
        verify(getTimerUsecase()).called(1);
      },
      expect: () => <TimerState>[
        TimerLoading(),
        TimerLoaded(timer: timer),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'should emit TimerLoading and TimerFailed when error ocured while fetching data from local database',
      build: () => bloc,
      act: (b) => b.add(TimerGet()),
      setUp: () {
        when(getTimerUsecase())
            .thenAnswer((realInvocation) async => Left(UnhandledFailure()));
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
      setUp: () => when(setTimerUsecase())
          .thenAnswer((realInvocation) async => Right(Success())),
      act: (b) => b.add(const TimerSet()),
      seed: () => TimerLoaded(timer: timer),
      verify: (_) {
        verify(setTimerUsecase()).called(1);
        verify(addStorageTimerUsecase(timer)).called(1);
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
      seed: () => TimerLoaded(timer: timer),
      expect: () => <TimerState>[
        TimerLoaded(
          timer: TimerEntity(pomodoroTime: 5, breakTime: 3),
        )
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'should emit previous TimerLoaded state with an `error` field filled when error ocured while set data to local database',
      build: () => bloc,
      act: (b) => b.add(TimerSet()),
      setUp: () => when(setTimerUsecase())
          .thenAnswer((realInvocation) async => Left(UnhandledFailure())),
      seed: () => TimerLoaded(
        timer: TimerEntity(pomodoroTime: 5, breakTime: 3),
      ),
      expect: () => <TimerState>[
        TimerLoaded(
          timer: TimerEntity(pomodoroTime: 5, breakTime: 3),
          error: ErrorObject.mapFailureToError(UnhandledFailure()),
        ),
      ],
    );
  });
}
