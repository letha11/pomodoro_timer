// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/utils/countdown.dart';
import 'package:pomodoro_timer/timer/domain/usecase/usecases.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/timer_bloc.dart';

@GenerateNiceMocks([MockSpec<Countdown>()])
import 'timer_bloc_test.mocks.dart';

class MockGetTimerUsecase extends Mock implements GetTimerUsecase {}

class MockSetTimerUsecase extends Mock implements SetTimerUsecase {}

// class MockEmitter extends Mock implements Emitter<TimerState> {}
// class MockCountdown extends Mock implements Countdown {}

void main() {
  late GetTimerUsecase getTimerUsecase;
  late SetTimerUsecase setTimerUsecase;
  late Countdown countdown;
  late TimerBloc bloc;

  setUp(() {
    getTimerUsecase = MockGetTimerUsecase();
    setTimerUsecase = MockSetTimerUsecase();
    countdown = MockCountdown();
    bloc = TimerBloc(
      countdown: countdown,
      getTimerUsecase: getTimerUsecase,
      setTimerUsecase: setTimerUsecase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test(
    'initialState of bloc should be TimerInitial by default',
    () => expect(bloc.state, equals(const TimerInitial(0))),
  );

  group('TimerStarted event', () {
    final controller = StreamController<int>();
    const duration = 3;

    blocTest(
      'should call Counter.count to start the counter',
      build: () => bloc,
      setUp: () {
        when(countdown.count(duration)).thenReturn(Right(StreamController<int>().stream));
      },
      act: (b) => b.add(TimerStarted(duration: duration)),
      verify: (_) {
        verify(countdown.count(duration));
      },
    );

    /// Does the same as above code
    /// but using the `test` method from flutter
    // test('should call Counter.count to start the counter', () async {
    //   final mockStream =
    //       Stream<int>.periodic(const Duration(seconds: 1), (count) => duration - count)
    //           .take(duration);
    //
    //   when(countdown.count(duration)).thenReturn(Right(mockStream));
    //
    //   bloc.add(TimerStarted(duration: duration));
    //   await untilCalled(countdown.count(duration));
    //
    //   verify(countdown.count(duration));
    // });

    test('should emit an error when the duration is < 0', () async {
      when(countdown.count(duration)).thenReturn(Left(FormatFailure()));

      bloc.add(TimerStarted(duration: duration));
      await untilCalled(countdown.count(duration));
      expect(bloc.state, equals(TimerFailure('')));
    });

    blocTest(
      'should emit TimerInProgress 3,2,1,0 when the TimerStarted event get sent',
      build: () => bloc,
      setUp: () async {
        //   when(countdown.count(duration)).thenReturn(Right(
        //     // Stream.periodic(const Duration(seconds: 1), (count) => duration - count).take(duration),
        //     Stream.fromIterable([3, 2, 1, 0]),
        //   ));
        when(countdown.count(duration)).thenReturn(Right(controller.stream));
      },
      act: (b) async {
        b.add(const TimerStarted(duration: duration));
        await untilCalled(countdown.count(duration));
        controller.add(3);
        controller.add(2);
        controller.add(1);
        controller.add(0);

        controller.close();
      },
      expect: () => <TimerState>[
        const TimerInProgress(3),
        const TimerInProgress(2),
        const TimerInProgress(1),
        const TimerInProgress(0),
      ],
    );

    blocTest(
      'should emit TimerFailure when the count method had an error',
      build: () => bloc,
      setUp: () async {
        when(countdown.count(duration)).thenReturn(Left(FormatFailure()));
      },
      act: (b) async {
        b.add(const TimerStarted(duration: duration));
        await untilCalled(countdown.count(duration));
      },
      expect: () => <TimerState>[TimerFailure('')],
    );
  });

  group('TimerPaused event', () {
    blocTest<TimerBloc, TimerState>(
      'should emit TimerPause with the current/given duration when TimerPaused event get sent',
      build: () => bloc,
      seed: () => TimerInProgress(2),
      act: (b) => b.add(TimerPaused()),
      expect: () => <TimerState>[TimerPause(2)],
    );
  });
}
