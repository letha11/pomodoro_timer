// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/constants.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/utils/audio_player.dart';
import 'package:pomodoro_timer/core/utils/countdown.dart';
import 'package:pomodoro_timer/core/utils/error_object.dart';
import 'package:pomodoro_timer/core/utils/notifications.dart';
import 'package:pomodoro_timer/core/utils/time_converter.dart';
import 'package:pomodoro_timer/core/utils/vibration.dart';
import 'package:pomodoro_timer/timer/domain/entity/sound_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_sound_setting.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_timer.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/timer_counter/timer_counter_bloc.dart';

@GenerateNiceMocks([
  MockSpec<Countdown>(),
  MockSpec<StreamSubscription<int>>(),
  MockSpec<TimeConverter>(),
  MockSpec<GetTimerUsecase>(),
  MockSpec<GetSoundSettingUsecase>(),
  MockSpec<AudioPlayerLImpl>(),
  MockSpec<NotificationHelper>(),
  MockSpec<VibrationLImpl>(),
])
import 'timer_counter_bloc_test.mocks.dart';

void main() {
  const duration = 5;
  const timer = TimerSettingEntity(
    pomodoroTime: duration,
    shortBreak: 3,
    longBreak: 7,
    pomodoroSequence: true,
  );
  SoundSettingEntity soundSetting = SoundSettingEntity(
    playSound: true,
    defaultAudioPath: 'assets/audio/alarm.wav',
    type: SoundType.defaults,
    bytesData: Uint8List(100),
  );

  late MockCountdown countdown;
  late TimerCounterBloc bloc;
  late StreamSubscription<int>? subscription;
  late StreamController<TimerSettingEntity> timerStreamController;
  late StreamController<SoundSettingEntity> soundSettingController;
  late TimeConverter timeConverter;
  late GetTimerUsecase getTimerUsecase;
  late GetSoundSettingUsecase getSoundSettingUsecase;
  late MockNotificationHelper notificationHelper;
  late MockVibrationLImpl vibration;
  late int timeStamps;
  late AudioPlayerL audioPlayer;

  setUp(() {
    countdown = MockCountdown();
    subscription = MockStreamSubscription();
    timerStreamController = StreamController<TimerSettingEntity>();
    soundSettingController = StreamController<SoundSettingEntity>();
    timeConverter = MockTimeConverter();
    getTimerUsecase = MockGetTimerUsecase();
    getSoundSettingUsecase = MockGetSoundSettingUsecase();
    notificationHelper = MockNotificationHelper();
    vibration = MockVibrationLImpl();
    timeStamps =
        Clock.fixed(DateTime(2022, 09, 01)).now().millisecondsSinceEpoch;
    audioPlayer = MockAudioPlayerLImpl();

    when(timeConverter.fromSeconds(timer.pomodoroTime)).thenReturn('00:05');
    when(timeConverter.fromSeconds(timer.shortBreak)).thenReturn("00:03");
    when(timeConverter.fromSeconds(timer.longBreak)).thenReturn("00:07");
    when(getTimerUsecase.call())
        .thenReturn(Right(timerStreamController.stream));
    when(getSoundSettingUsecase())
        .thenReturn(Right(soundSettingController.stream));

    bloc = withClock(
        Clock.fixed(DateTime(2022, 09, 01)),
        () => TimerCounterBloc(
              getTimerUsecase: getTimerUsecase,
              getSoundSettingUsecase: getSoundSettingUsecase,
              countdown: countdown,
              streamSubscription: subscription,
              audioPlayer: audioPlayer,
              timeConverter: timeConverter,
              notificationHelper: notificationHelper,
              vibration: vibration,
            ));

    timerStreamController.add(timer);
    soundSettingController.add(soundSetting);
  });

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

    late StreamController<int> pomodoroController;
    late StreamController<int> shortBreakController;
    late StreamController<int> longBreakController;

    setUp(() {
      timerCounterStartedController = StreamController<int>();
      pomodoroController = StreamController<int>.broadcast();
      shortBreakController = StreamController<int>.broadcast();
      longBreakController = StreamController<int>.broadcast();
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
        verify(audioPlayer.playSound(soundSetting.defaultAudioPath)).called(1);
      },
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should called stopSound and playSound when Stream is finished and playSound setting to true',
      build: () => bloc,
      setUp: () async {
        when(countdown.count(duration - 1))
            .thenReturn(Right(timerCounterStartedController.stream));
        when(timeConverter.fromSeconds(duration - 1)).thenReturn("00:05");
      },
      act: (b) async {
        soundSettingController.add(soundSetting);
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(duration - 1));

        await timerCounterStartedController.close();
        await Future.delayed(const Duration(seconds: 1));
      },
      verify: (_) {
        verify(audioPlayer.stopSound()).called(1);
        verify(audioPlayer.playSound(soundSetting.defaultAudioPath)).called(1);
      },
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'should called stopSound and playSoundFromUint8List when Stream is finished and playSound setting to true and type is imported',
      build: () => bloc,
      setUp: () async {
        when(countdown.count(duration - 1))
            .thenReturn(Right(timerCounterStartedController.stream));
        when(timeConverter.fromSeconds(duration - 1)).thenReturn("00:05");
      },
      act: (b) async {
        soundSettingController.add(SoundSettingEntity(
          playSound: true,
          defaultAudioPath: soundSetting.defaultAudioPath,
          type: SoundType.imported,
          bytesData: soundSetting.bytesData!,
        ));
        // soundSettingController.add(soundSetting);
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(duration - 1));

        await timerCounterStartedController.close();
        await Future.delayed(const Duration(seconds: 1));
      },
      verify: (_) {
        verify(audioPlayer.stopSound()).called(1);
        verify(audioPlayer.playSoundFromUint8List(soundSetting.bytesData!))
            .called(1);
      },
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'playSound should not be called when playSounds setting set to false instead stopSound and vibrate should be called',
      build: () => bloc,
      setUp: () async {
        when(countdown.count(duration - 1))
            .thenReturn(Right(timerCounterStartedController.stream));
        when(timeConverter.fromSeconds(duration - 1)).thenReturn("00:05");
      },
      act: (b) async {
        soundSettingController.add(SoundSettingEntity(
          playSound: false,
          defaultAudioPath: soundSetting.defaultAudioPath,
          type: SoundType.defaults,
        ));
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(duration - 1));

        await timerCounterStartedController.close();
      },
      verify: (_) {
        verify(audioPlayer.stopSound()).called(1);
        verify(vibration.vibrate(duration: anyNamed('duration'))).called(1);
        verifyNever(audioPlayer.playSound(soundSetting.defaultAudioPath));
      },
    );

    blocTest<TimerCounterBloc, TimerCounterState>(
      'pomodoroSequence should change to longBreak when pomodoroCounter is 4',
      build: () => bloc,
      setUp: () async {
        when(countdown.count(duration - 1))
            .thenReturn(Right(pomodoroController.stream));
        when(countdown.count(timer.shortBreak - 1))
            .thenReturn(Right(shortBreakController.stream));
        when(countdown.count(timer.longBreak - 1))
            .thenReturn(Right(longBreakController.stream));
      },
      act: (b) async {
        // 1st Pomodoro
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(duration - 1));
        await pomodoroController.close();
        await shortBreakController.close();

        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(timer.shortBreak - 1));
        await pomodoroController.close();
        await shortBreakController.close();

        // 2nd Pomodoro
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(duration - 1));
        await pomodoroController.close();
        await shortBreakController.close();

        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(timer.shortBreak - 1));
        await pomodoroController.close();
        await shortBreakController.close();

        // 3th Pomodoro
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(duration - 1));
        await pomodoroController.close();
        await shortBreakController.close();

        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(timer.shortBreak - 1));
        await pomodoroController.close();
        await shortBreakController.close();

        // 4th Pomodoro
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(duration - 1));
        await pomodoroController.close();
        await shortBreakController.close();

        // Long Break
        b.add(TimerCounterStarted());
        await untilCalled(countdown.count(timer.longBreak - 1));
        await pomodoroController.close();
        await shortBreakController.close();
        await longBreakController.close();
      },
      expect: () => <TimerCounterState>[
        // 1st Pomodoro
        TimerCounterInProgress("00:05"), // start of the stream
        TimerCounterInitial("00:03", timeStamps),
        TimerCounterInProgress("00:03"),
        TimerCounterInitial("00:05", timeStamps),

        // 2nd Pomodoro
        TimerCounterInProgress("00:05"),
        TimerCounterInitial("00:03", timeStamps),
        TimerCounterInProgress("00:03"),
        TimerCounterInitial("00:05", timeStamps),

        // // 3th Pomodoro
        TimerCounterInProgress("00:05"),
        TimerCounterInitial("00:03", timeStamps),
        TimerCounterInProgress("00:03"),
        TimerCounterInitial("00:05", timeStamps),

        // 4th Pomodoro
        TimerCounterInProgress("00:05"),
        TimerCounterInitial("00:07", timeStamps),
        TimerCounterInProgress("00:07"),
        TimerCounterInitial("00:05", timeStamps),
      ],
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
        pomodoroSequence: true,
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
