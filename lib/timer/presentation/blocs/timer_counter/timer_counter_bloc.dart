import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
}

class TimerCounterBloc extends Bloc<TimerCounterEvent, TimerCounterState> {
  final Countdown _countdown;
  final ILogger? _logger;
  final TimeConverter timeConverter;
  final GetStorageTimerUsecase _getStorageTimerUsecase;
  late TimerEntity timer;

  TimerType _type = TimerType.pomodoro;
  StreamSubscription<int>? _countdownSubscription;
  int _duration = 0;
  late final StreamSubscription<TimerEntity> _timerSubscription;

  TimerCounterBloc({
    required Countdown countdown,
    required this.timeConverter,
    required GetStorageTimerUsecase getStorageTimerUsecase,
    ILogger? logger,
    StreamSubscription<int>? streamSubscription,
  })  : _countdown = countdown,
        _countdownSubscription = streamSubscription,
        _logger = logger,
        _getStorageTimerUsecase = getStorageTimerUsecase,
        super(const TimerCounterInitial('00:00')) {
    _subscribeTimer();

    on<TimerCounterStarted>(_onTimerStarted);
    on<TimerCounterPaused>(_onTimerPaused);
    on<TimerCounterResumed>(_onTimerResumed);
    on<TimerCounterReset>(_onTimerReset);
    on<TimerCounterTypeChange>(_onTimerTypeChange);
    on<TimerCounterChange>(_onTimerChange);

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
        TimerCounterInitial(timeConverter.fromSeconds(_duration)),
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
            // will change _duration into breakTime
            if (_type == TimerType.pomodoro) {
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

      emit(TimerCounterInitial(timeConverter.fromSeconds(_duration)));
    }
  }

  _onTimerTypeChange(
      TimerCounterTypeChange event, Emitter<TimerCounterState> emit) {
    _logger?.log(Level.debug,
        "TimerCounterChange event get sent, [type: ${event.type}]");
    _countdownSubscription?.cancel();

    _setDurationByType(event.type);

    emit(TimerCounterInitial(timeConverter.fromSeconds(_duration)));
  }

  _onTimerChange(TimerCounterChange event, Emitter<TimerCounterState> emit) {
    _logger?.log(Level.debug,
        "TimerCounterChange event get sent, [timer: ${event.timer}]");

    _countdownSubscription?.cancel();

    timer = event.timer;
    _setDurationByType();

    emit(TimerCounterInitial(timeConverter.fromSeconds(_duration)));
  }

  _onTimerTicked(_TimerCounterTicked event, Emitter<TimerCounterState> emit) {
    emit(TimerCounterInProgress(event.formattedDuration));
  }

  _setDurationByType([TimerType? type]) {
    _logger?.log(
        Level.debug, "_setDurationByType function get called, [type: $type]");
    _type = type ?? _type;

    switch (type ?? _type) {
      case TimerType.pomodoro:
        _duration = timer.pomodoroTime;
        break;
      case TimerType.breakTime:
        _duration = timer.breakTime;
        break;
      default:
        _duration = timer.pomodoroTime;
    }
  }
}
