import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/timer/timer_bloc.dart';

import '../../../../core/utils/countdown.dart';
import '../../../../core/utils/time_converter.dart';
import '../../../domain/entity/timer_entity.dart';
import '../../../../core/utils/error_object.dart';
import '../../../../core/utils/logger.dart';

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
  final TimerEntity timer;

  TimerType _type = TimerType.pomodoro;
  int _duration = 0;
  StreamSubscription<int>? _countdownSubscription;

  TimerCounterBloc({
    required Countdown countdown,
    required this.timer,
    required this.timeConverter,
    ILogger? logger,
    StreamSubscription<int>? streamSubscription,
  })  : _countdown = countdown,
        _countdownSubscription = streamSubscription,
        _logger = logger,
        super(TimerCounterInitial(
            timeConverter.fromSeconds(timer.pomodoroTime))) {
    _duration = timer.pomodoroTime; // set default timer

    on<TimerCounterStarted>(_onTimerStarted);
    on<TimerCounterPaused>(_onTimerPaused);
    on<TimerCounterResumed>(_onTimerResumed);
    on<TimerCounterReset>(_onTimerReset);
    on<TimerCounterChange>(_onTimerChange);

    on<_TimerCounterTicked>(_onTimerTicked);
  }

  @override
  Future<void> close() {
    _countdownSubscription?.cancel();
    return super.close();
  }

  void _onTimerStarted(
      TimerCounterStarted event, Emitter<TimerCounterState> emit) async {
    _logger?.log(Level.debug, "TimerCounterStarted event get sent");

    /// cancel the subscription if there are any
    /// because we are about to start a new one.
    if (state is! TimerCounterInProgress) {
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
      _countdownSubscription?.resume();
    }
  }

  _onTimerReset(TimerCounterReset event, Emitter<TimerCounterState> emit) {
    _logger?.log(Level.debug, "TimerCounterReset event get sent");
    if (state is! TimerCounterInitial) {
      _countdownSubscription?.cancel();

      _setDurationByType();

      emit(TimerCounterInitial(timeConverter.fromSeconds(_duration)));
    }
  }

  _onTimerChange(TimerCounterChange event, Emitter<TimerCounterState> emit) {
    _logger?.log(Level.debug,
        "TimerCounterChange event get sent, [type: ${event.type}]");
    _setDurationByType(event.type);

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
