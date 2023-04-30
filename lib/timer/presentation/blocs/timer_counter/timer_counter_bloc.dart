import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
        super(TimerCounterInitial(timeConverter.fromSeconds(timer.pomodoroTime))) {
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

  void _onTimerStarted(TimerCounterStarted event, Emitter<TimerCounterState> emit) async {
    /// cancel the subscription
    /// because we are about to start a new one.
    _countdownSubscription?.cancel();

    _countdown.count(_duration).fold(
      (err) {
        _logger?.log(Level.warning, "[count] {duration: $_duration}");
        emit(TimerCounterFailure(
          ErrorObject.mapFailureToError(err),
        ));
      },
      (data) {
        late String formatted;
        _countdownSubscription = data.listen((d) {
          formatted = timeConverter.fromSeconds(d);
          add(_TimerCounterTicked(formattedDuration: formatted));
        });
      }, // listen
    );
  }

  _onTimerPaused(TimerCounterPaused event, Emitter<TimerCounterState> emit) {
    final stateDuration = timeConverter.convertStringToSeconds(state.duration);

    if (stateDuration > 0 && state is TimerCounterInProgress) {
      _countdownSubscription?.pause();

      emit(TimerCounterPause(state.duration));
    }
  }

  _onTimerResumed(TimerCounterResumed event, Emitter<TimerCounterState> emit) {
    final isPaused = _countdownSubscription?.isPaused ?? false;
    final stateDuration = timeConverter.convertStringToSeconds(state.duration);

    if (state is TimerCounterPause && isPaused && stateDuration > 0) {
      _countdownSubscription?.resume();
    }
  }

  _onTimerReset(TimerCounterReset event, Emitter<TimerCounterState> emit) {
    if (state is! TimerCounterInitial) {
      _setDurationByType();

      emit(TimerCounterInitial(timeConverter.fromSeconds(_duration)));
    }
  }

  _onTimerChange(TimerCounterChange event, Emitter<TimerCounterState> emit) {
    _setDurationByType(event.type);

    emit(TimerCounterInitial(timeConverter.fromSeconds(_duration)));
  }

  _onTimerTicked(_TimerCounterTicked event, Emitter<TimerCounterState> emit) {
    emit(TimerCounterInProgress(event.formattedDuration));
  }

  _setDurationByType([TimerType? type]) {
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
