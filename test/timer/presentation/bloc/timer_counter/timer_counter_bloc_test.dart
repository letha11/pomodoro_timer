// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/utils/audio_player.dart';
import 'package:pomodoro_timer/core/utils/countdown.dart';
import 'package:pomodoro_timer/core/utils/error_object.dart';
import 'package:pomodoro_timer/core/utils/time_converter.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_timer.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/timer_counter/timer_counter_bloc.dart';

@GenerateNiceMocks([
  MockSpec<Countdown>(),
  MockSpec<StreamSubscription<int>>(),
  MockSpec<TimeConverter>(),
  MockSpec<GetTimerUsecase>(),
  MockSpec<AudioPlayer>()
])
import 'timer_counter_bloc_test.mocks.dart';

void main() {
  const duration = 5;
  const timer = TimerSettingEntity(
    pomodoroTime: duration,
    shortBreak: 3,
    longBreak: 5,
    pomodoroSequence: false,
  );

  late Countdown countdown;
  late TimerCounterBloc bloc;
  late StreamSubscription<int>? subscription;
  late StreamController<TimerSettingEntity> timerStreamController;
  late TimeConverter timeConverter;
  late GetTimerUsecase getTimerUsecase;
  late int timeStamps;
  late AudioPlayerL audioPlayer;

  setUp(() {
    countdown = MockCountdown();
    subscription = MockStreamSubscription();
    timerStreamController = StreamController<TimerSettingEntity>();
    timeConverter = MockTimeConverter();
    getTimerUsecase = MockGetTimerUsecase();
    timeStamps =
        Clock.fixed(DateTime(2022, 09, 01)).now().millisecondsSinceEpoch;
    audioPlayer = AudioPlayerLImpl(player: MockAudioPlayer());

    when(timeConverter.fromSeconds(timer.pomodoroTime)).thenReturn('00:05');
    when(timeConverter.fromSeconds(timer.shortBreak)).thenReturn("00:03");
    when(getTimerUsecase.call())
        .thenReturn(Right(timerStreamController.stream));
    // when(getTimerUsecase())
    //     .thenAnswer((_) => timerStreamController.stream);

    bloc = withClock(
        Clock.fixed(DateTime(2022, 09, 01)),
        () => TimerCounterBloc(
              getTimerUsecase: getTimerUsecase,
              countdown: countdown,
              streamSubscription: subscription,
              audioPlayer: audioPlayer,
              timeConverter: timeConverter,
            ));

    timerStreamController.add(timer);
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
    () {
      expect(bloc.state, equals(TimerCounterInitial('00:05', timeStamps)));
    },
  );

  group('TimerCounterStarted event', () {
    late StreamController<int> timerCounterStartedController;

    setUp(() {
      timerCounterStartedController = StreamController<int>();
    });

    blocTest(
      'should call Counter.count to start the counter',
      build: () => bloc,
      setUp: () {
        when(countdown.count(duration - 1))
            .thenReturn(Right(StreamController<int>().stream));
      },
      act: (b) => b.add(TimerCounterStarted()),
      verify: (_) {
        verify(countdown.count(duration - 1));
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
      when(countdown.count(duration - 1)).thenReturn(Left(FormatFailure()));

      bloc.add(TimerCounterStarted());
      await untilCalled(countdown.count(duration - 1));
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
      'should emit TimerInProgress 00:05,00:04,00:03,00:02,00:01,00:00 when the TimerStarted event get sent',
      build: () => bloc,
      setUp: () async {
        when(countdown.count(duration - 1))
            .thenReturn(Right(timerCounterStartedController.stream));
        when(timeConverter.fromSeconds(4)).thenReturn('00:04');
        when(timeConverter.fromSeconds(3)).thenReturn('00:03');
        when(timeConverter.fromSeconds(2)).thenReturn('00:02');
        when(timeConverter.fromSeconds(1)).thenReturn('00:01');
        when(timeConverter.fromSeconds(0)).thenReturn('00:00');
      },
      act: (b) async {
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(duration - 1));
        timerCounterStartedController.add(4);
        timerCounterStartedController.add(3);
        timerCounterStartedController.add(2);
        timerCounterStartedController.add(1);
        timerCounterStartedController.add(0);
      },
      expect: () => <TimerCounterState>[
        const TimerCounterInProgress("00:05"),
        const TimerCounterInProgress("00:04"),
        const TimerCounterInProgress("00:03"),
        const TimerCounterInProgress("00:02"),
        const TimerCounterInProgress("00:01"),
        const TimerCounterInProgress("00:00"),
      ],
    );

    blocTest(
      'should emit TimerFailure when the count method had an error',
      build: () => bloc,
      setUp: () async {
        when(countdown.count(duration - 1)).thenReturn(Left(FormatFailure()));
      },
      act: (b) async {
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(duration - 1));
      },
      expect: () => <TimerCounterState>[
        TimerCounterFailure(ErrorObject.mapFailureToError(
          FormatFailure(),
        ))
      ],
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit TimerCounterInitial when Stream is finished',
      build: () => bloc,
      setUp: () async {
        when(countdown.count(duration - 1))
            .thenReturn(Right(timerCounterStartedController.stream));
        when(timeConverter.fromSeconds(duration - 1)).thenReturn("00:05");
      },
      act: (b) async {
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(duration - 1));

        await timerCounterStartedController.close();
        await Future.delayed(const Duration(seconds: 1));
      },
      expect: () => <TimerCounterState>[
        TimerCounterInProgress("00:05"), // start of the stream
        TimerCounterInitial("00:03", timeStamps),
      ],
      verify: (_) {
        verify(audioPlayer.stopSound()).called(1);
        verify(audioPlayer.playSound("assets/audio/alarm.wav")).called(1);
      },
    );
  });

  group('TimerCounterPaused event', () {
    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit TimerPause with the current/given duration when TimerPaused event get sent',
      build: () => bloc,
      setUp: () {
        when(timeConverter.convertStringToSeconds("00:02")).thenReturn(2);
      },
      seed: () => TimerCounterInProgress("00:02"),
      act: (b) => b.add(TimerCounterPaused()),
      expect: () => <TimerCounterState>[TimerCounterPause("00:02")],
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit nothing when the state.duration is at 0',
      build: () => bloc,
      setUp: () =>
          when(timeConverter.convertStringToSeconds("00:00")).thenReturn(0),
      seed: () => TimerCounterInProgress("00:00"),
      act: (b) => b.add(TimerCounterPaused()),
      expect: () => <TimerCounterState>[],
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
        when(timeConverter.convertStringToSeconds("00:02")).thenReturn(2);
        when(subscription?.isPaused).thenReturn(true);
      },
      act: (b) => b.add(TimerCounterResumed()),
      seed: () => TimerCounterPause("00:02"),
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
      seed: () => TimerCounterPause("00:02"),
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
      seed: () => TimerCounterInProgress("00:02"),
      verify: (_) {
        verifyNever(subscription?.resume());
      },
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should NOT call `.resume`(do nothing) method on StreamSubscription when duration is less than 1(duration > 0)',
      build: () => bloc,
      setUp: () {
        when(subscription?.isPaused).thenReturn(true);
      },
      act: (b) => b.add(TimerCounterResumed()),
      seed: () => TimerCounterPause("00:00"),
      verify: (_) {
        verifyNever(subscription?.resume());
      },
    );
  });

  group('TimerCounterReset', () {
    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit TimerCounterInitial when `state` is NOT TimerCounterInitial',
      build: () => bloc,
      seed: () => TimerCounterInProgress("00:03"),
      act: (b) => b.add(TimerCounterReset()),
      expect: () => <TimerCounterState>[
        TimerCounterInitial("00:05", timeStamps)
      ], // this TimerCounterInitial depend on timer.pomodoro
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should NOT emit TimerCounterInitial(do nothing) when `state` is TimerCounterInitial',
      build: () => bloc,
      seed: () => TimerCounterInitial("00:00", timeStamps),
      act: (b) => b.add(TimerCounterReset()),
      expect: () => <TimerCounterState>[],
    );
  });

  group('TimerCounterTypeChange', () {
    setUp(() {
      final timer = TimerSettingEntity(
        pomodoroTime: 3,
        shortBreak: 2,
        longBreak: 4,
        pomodoroSequence: false,
      );

      timerStreamController.add(timer);
      when(timeConverter.fromSeconds(3)).thenReturn("00:03");
      when(timeConverter.fromSeconds(2)).thenReturn("00:02");
      when(timeConverter.fromSeconds(4)).thenReturn("00:04");
    });

    withClock(
      Clock.fixed(DateTime(2020, 09, 1)),
      () => blocTest<TimerCounterBloc, TimerCounterState>(
        'should emit TimerCounterInitial with pomodoroTime value when type is TimerType.pomodoro',
        build: () => bloc..type = TimerType.breakTime,
        seed: () => TimerCounterInProgress("00:02"),
        // needed this if not seeded the bloc will not emit anything
        act: (b) => b.add(TimerCounterTypeChange(TimerType.pomodoro)),
        expect: () =>
            <TimerCounterState>[TimerCounterInitial("00:03", timeStamps)],
      ),
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit TimerCounterInitial with breakTime value when type is TimerType.breakTime',
      build: () => bloc,
      act: (b) => b.add(TimerCounterTypeChange(TimerType.breakTime)),
      seed: () => TimerCounterInProgress("00:02"),
      // needed because from the concept i didn't use equatable in TimerCounterInitial
      // expect: () => [],
      expect: () =>
          <TimerCounterState>[TimerCounterInitial("00:02", timeStamps)],
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should emit TimerCounterInitial with longBreak value when type is TimerType.longBreak',
      build: () => bloc,
      act: (b) => b.add(TimerCounterTypeChange(TimerType.longBreak)),
      seed: () => TimerCounterInProgress("00:02"),
      // needed because from the concept i didn't use equatable in TimerCounterInitial
      expect: () =>
          <TimerCounterState>[TimerCounterInitial("00:04", timeStamps)],
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should NOT DO ANYTHING when the given type are the same as the current type',
      build: () => bloc..type = TimerType.pomodoro,
      seed: () => TimerCounterInitial("00:00", timeStamps),
      act: (b) => b.add(TimerCounterTypeChange(TimerType.pomodoro)),
      expect: () => <TimerCounterState>[],
    );
  });
}
