// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/utils/countdown.dart';
import 'package:pomodoro_timer/core/utils/error_object.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/timer_counter/timer_counter_bloc.dart';

@GenerateNiceMocks([MockSpec<Countdown>(), MockSpec<StreamSubscription<int>>()])
import 'timer_counter_bloc_test.mocks.dart';

void main() {
  const timer = TimerEntity(
    pomodoroTime: 5,
    breakTime: 3,
  );
  late Countdown countdown;
  late TimerCounterBloc bloc;
  late StreamSubscription<int>? subscription;
  late StreamController<int> controller;

  const duration = 3;
  setUp(() {
    countdown = MockCountdown();
    subscription = MockStreamSubscription();
    controller = StreamController<int>();

    bloc = TimerCounterBloc(
        countdown: countdown, timer: timer, streamSubscription: subscription);
  });

  // _emulateTimerStarted({Function()? callback}) async {
  //   await untilCalled(countdown.count(duration));
  //   controller.add(3);
  //   controller.add(2);
  //   if (callback != null) callback();
  //   controller.add(1);
  //   controller.add(0);
  //
  //   controller.close();
  // }

  tearDown(() {
    bloc.close();
  });

  test(
    'initialState of bloc should be TimerCounterInitial by default',
    () => expect(bloc.state, equals(TimerCounterInitial(timer.pomodoroTime))),
  );

  group('TimerCounterStarted event', () {
    blocTest(
      'should call Counter.count to start the counter',
      build: () => bloc,
      setUp: () {
        when(countdown.count(duration))
            .thenReturn(Right(StreamController<int>().stream));
      },
      act: (b) => b.add(TimerCounterStarted(duration: duration)),
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

      bloc.add(TimerCounterStarted(duration: duration));
      await untilCalled(countdown.count(duration));
      expect(
        bloc.state,
        equals(
          TimerCounterFailure(
            ErrorObject.mapFailureToError(
              FormatFailure(),
            ),
          ),
        ),
      );
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
        b.add(const TimerCounterStarted(duration: duration));
        await untilCalled(countdown.count(duration));
        controller.add(3);
        controller.add(2);
        controller.add(1);
        controller.add(0);

        controller.close();
      },
      expect: () => <TimerCounterState>[
        const TimerCounterInProgress(3),
        const TimerCounterInProgress(2),
        const TimerCounterInProgress(1),
        const TimerCounterInProgress(0),
      ],
    );

    blocTest(
      'should emit TimerFailure when the count method had an error',
      build: () => bloc,
      setUp: () async {
        when(countdown.count(duration)).thenReturn(Left(FormatFailure()));
      },
      act: (b) async {
        b.add(const TimerCounterStarted(duration: duration));
        await untilCalled(countdown.count(duration));
      },
      expect: () => <TimerCounterState>[
        TimerCounterFailure(ErrorObject.mapFailureToError(
          FormatFailure(),
        ))
      ],
    );

    blocTest(
      'should emit TimerFailure when the given duration is not above 0 (duration < 0)',
      build: () => bloc,
      setUp: () {
        when(countdown.count(duration)).thenReturn(Right(controller.stream));
      },
      act: (b) {
        b.add(const TimerCounterStarted(duration: 0));
      },
      expect: () => <TimerCounterState>[
        TimerCounterFailure(ErrorObject(message: "Could not start time from 0"))
      ],
    );
  });

  group('TimerCounterPaused event', () {
    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit TimerPause with the current/given duration when TimerPaused event get sent',
      build: () => bloc,
      seed: () => TimerCounterInProgress(2),
      act: (b) => b.add(TimerCounterPaused()),
      expect: () => <TimerCounterState>[TimerCounterPause(2)],
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit nothing when the state.duration is at 0',
      build: () => bloc,
      seed: () => TimerCounterInProgress(2),
      act: (b) => b.add(TimerCounterPaused()),
      expect: () => <TimerCounterState>[TimerCounterPause(2)],
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit nothing when the state is not TimerInProgress',
      build: () => bloc,
      seed: () => TimerCounterComplete(),
      act: (b) => b.add(TimerCounterPaused()),
      expect: () => <TimerCounterState>[],
    );
  });

  group('TimerCounterResumed', () {
    blocTest<TimerCounterBloc, TimerCounterState>(
      'should call `.resume` method on StreamSubscription when TimerResumed() get sent',
      build: () => bloc,
      setUp: () {
        when(subscription?.isPaused).thenReturn(true);
      },
      act: (b) => b.add(TimerCounterResumed()),
      seed: () => TimerCounterPause(2),
      verify: (_) {
        verify(subscription?.resume());
      },
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should NOT call `.resume`(do nothing) method on StreamSubscription when StreamSubscription.isPaused is not paused(true)',
      build: () => bloc,
      setUp: () {
        when(subscription?.isPaused).thenReturn(false);
      },
      act: (b) => b.add(TimerCounterResumed()),
      seed: () => TimerCounterPause(2),
      verify: (_) {
        verifyNever(subscription?.resume());
      },
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should NOT call `.resume`(do nothing) method on StreamSubscription when state is not TimerPause',
      build: () => bloc,
      setUp: () {
        when(subscription?.isPaused).thenReturn(true);
      },
      act: (b) => b.add(TimerCounterResumed()),
      seed: () => TimerCounterInProgress(2),
      verify: (_) {
        verifyNever(subscription?.resume());
      },
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should NOT call `.resume`(do nothing) method on StreamSubscription when duration is less than 0(duration < 0)',
      build: () => bloc,
      setUp: () {
        when(subscription?.isPaused).thenReturn(true);
      },
      act: (b) => b.add(TimerCounterResumed()),
      seed: () => TimerCounterPause(-1),
      verify: (_) {
        verifyNever(subscription?.resume());
      },
    );
  });

  group('TimerCounterReset', () {
    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit TimerCounterInitial when `state` is NOT TimerCounterInitial',
      build: () => bloc,
      seed: () => TimerCounterInProgress(3),
      act: (b) => b.add(TimerCounterReset()),
      expect: () =>
          <TimerCounterState>[TimerCounterInitial(timer.pomodoroTime)],
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should NOT emit TimerCounterInitial(do nothing) when `state` is TimerCounterInitial',
      build: () => bloc,
      seed: () => TimerCounterInitial(0),
      act: (b) => b.add(TimerCounterReset()),
      expect: () => <TimerCounterState>[],
    );
  });

  group('TimerCounterChange', () {
    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit TimerCounterInitial with breakTime value when type is TimerType.breakTime',
      build: () => bloc,
      act: (b) => b.add(TimerCounterChange(TimerType.breakTime)),
      expect: () => <TimerCounterState>[TimerCounterInitial(timer.breakTime)],
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit TimerCounterInitial with pomodoroTime value when type is TimerType.pomodoro',
      build: () => bloc,
      act: (b) => b.add(TimerCounterChange(TimerType.pomodoro)),
      expect: () =>
          <TimerCounterState>[TimerCounterInitial(timer.pomodoroTime)],
    );
  });
}
