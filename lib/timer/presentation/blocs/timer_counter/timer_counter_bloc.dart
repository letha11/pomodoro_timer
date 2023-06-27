import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:clock/clock.dart';

import '../../../../core/utils/audio_player.dart';
import '../../../../core/utils/countdown.dart';
import '../../../../core/utils/time_converter.dart';
import '../../../domain/entity/timer_entity.dart';
import '../../../../core/utils/error_object.dart';
import '../../../../core/utils/logger.dart';
import '../../../domain/usecase/get_storage_timer.dart';

part 'timer_counter_event.dart';

part 'timer_counter_state.dart';

enum TimerType {
  pomodoro,
  breakTime,
  longBreak,
}

extension TTToString on TimerType {
  String toShortString() {
    if (name == "breakTime") {
      return 'break';
    } else if (name == "longBreak") {
      return 'long break';
    } else {
      return 'pomodoro';
    }
  }
}

class TimerCounterBloc extends Bloc<TimerCounterEvent, TimerCounterState> {
  final Countdown _countdown;
  final ILogger? _logger;
  final AudioPlayerL _audioPlayer;
  final TimeConverter timeConverter;
  final GetStorageTimerUsecase _getStorageTimerUsecase;
  late TimerEntity timer;
  TimerType type = TimerType.pomodoro;

  StreamSubscription<int>? _countdownSubscription;
  int _duration = 0;
  int _timeStamps = clock.now().millisecondsSinceEpoch;
  late final StreamSubscription<TimerEntity> _timerSubscription;

  TimerCounterBloc({
    required Countdown countdown,
    required this.timeConverter,
    required GetStorageTimerUsecase getStorageTimerUsecase,
    required AudioPlayerL audioPlayer,
    ILogger? logger,
    StreamSubscription<int>? streamSubscription,
  })  : _countdown = countdown,
        _countdownSubscription = streamSubscription,
        _audioPlayer = audioPlayer,
        _logger = logger,
        _getStorageTimerUsecase = getStorageTimerUsecase,
        super(const TimerCounterInitial('00:00', 0)) {
    _subscribeTimer();

    on<TimerCounterStarted>(_onTimerStarted);
    on<TimerCounterPaused>(_onTimerPaused);
    on<TimerCounterResumed>(_onTimerResumed);
    on<TimerCounterReset>(_onTimerReset);
    on<TimerCounterTypeChange>(_onTimerTypeChange);

    on<_TimerCounterTicked>(_onTimerTicked);
  }

  @override
  Future<void> close() {
    _countdownSubscription?.cancel();
    _timerSubscription.cancel();
    return super.close();
  }

  void _subscribeTimer() {
    _timerSubscription = _getStorageTimerUsecase().listen((data) {
      // cancel countdown subscription
      _countdownSubscription?.cancel();

      timer = data;

      // will change _duration value
      _setDurationByType();

      // ignore: invalid_use_of_visible_for_testing_member
      emit(
        TimerCounterInitial(timeConverter.fromSeconds(_duration), _timeStamps),
      );
    });
  }

  void _onTimerStarted(
      TimerCounterStarted event, Emitter<TimerCounterState> emit) async {
    _logger?.log(Level.debug, "TimerCounterStarted event get sent");

    /// because we are about to start a new one.
    /// cancel the subscription if there are any
    if (state is! TimerCounterInProgress && state is! TimerCounterPause) {
      _countdownSubscription?.cancel();
      _audioPlayer.stopSound();

      await _countdown.count(_duration - 1).fold(
        (err) {
          _logger?.log(Level.warning, "[count] {duration: $_duration}");
          emit(TimerCounterFailure(
            ErrorObject.mapFailureToError(err),
          ));
        },
        (data) async {
          add(_TimerCounterTicked(
              formattedDuration: timeConverter.fromSeconds(_duration)));
          _logger?.log(Level.debug, "Start Listening into a stream");
          _countdownSubscription = data.listen((d) {
            add(_TimerCounterTicked(
                formattedDuration: timeConverter.fromSeconds(d)));
          }, onDone: () async {
            _logger?.log(Level.debug, "Stream Finished");
            await Future.delayed(const Duration(seconds: 1));

            _audioPlayer.playSound("assets/audio/alarm.wav");
            // will change _duration into breakTime
            if (type == TimerType.pomodoro) {
              _setDurationByType(TimerType.breakTime);
            }
            add(TimerCounterReset());
          });
        }, // listen
      );
    }
  }

  _onTimerPaused(TimerCounterPaused event, Emitter<TimerCounterState> emit) {
    _logger?.log(Level.debug, "TimerCounterPaused event get sent");
    final stateDuration = timeConverter.convertStringToSeconds(state.duration);

    if (stateDuration > 0 && state is TimerCounterInProgress) {
      _countdownSubscription!.pause();

      emit(TimerCounterPause(state.duration));
    }
  }

  _onTimerResumed(TimerCounterResumed event, Emitter<TimerCounterState> emit) {
    _logger?.log(Level.debug, "TimerCounterResumed event get sent");
    final isPaused = _countdownSubscription?.isPaused ?? false;
    final stateDuration = timeConverter.convertStringToSeconds(state.duration);

    if (state is TimerCounterPause && isPaused && stateDuration > 0) {
      // stream.resume will delay vaguely one second
      // so i just emulate a `TimerRunning` event with emitting a
      // `TimerCounterInProgress` with the current duration
      emit(TimerCounterInProgress(state.duration));
      _countdownSubscription?.resume();
    }
  }

  _onTimerReset(TimerCounterReset event, Emitter<TimerCounterState> emit) {
    _logger?.log(Level.debug, "TimerCounterReset event get sent");
    if (state is! TimerCounterInitial) {
      _countdownSubscription?.cancel();

      emit(TimerCounterInitial(timeConverter.fromSeconds(_duration), _timeStamps));
    }
  }

  _onTimerTypeChange(
      TimerCounterTypeChange event, Emitter<TimerCounterState> emit) {
    _logger?.log(Level.debug,
        "TimerCounterChange event get sent, [type: ${event.type}, currentType: $type]");

    if (type != event.type) {
      
      _timeStamps = clock.now().millisecondsSinceEpoch; // reassign
      
      _countdownSubscription?.cancel();

      _setDurationByType(event.type);


      emit(TimerCounterInitial(timeConverter.fromSeconds(_duration), _timeStamps));
    }
  }

  _onTimerTicked(_TimerCounterTicked event, Emitter<TimerCounterState> emit) {
    emit(TimerCounterInProgress(event.formattedDuration));
  }

  _setDurationByType([TimerType? typeArgs]) {
    _logger?.log(Level.debug,
        "_setDurationByType function get called, [type: $typeArgs]");
    type = typeArgs ?? type;

    switch (type) {
      case TimerType.pomodoro:
        _duration = timer.pomodoroTime;
        break;
      case TimerType.breakTime:
        _duration = timer.breakTime;
        break;
      case TimerType.longBreak:
        _duration = timer.longBreak;
        break;
      default:
        _duration = timer.pomodoroTime;
    }
  }
}
