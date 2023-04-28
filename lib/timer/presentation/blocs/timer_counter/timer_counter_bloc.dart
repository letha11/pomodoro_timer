import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_timer/core/utils/countdown.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart';

part 'timer_counter_event.dart';

part 'timer_counter_state.dart';

enum TimerType {
  pomodoro,
  breakTime,
}

class TimerCounterBloc extends Bloc<TimerCounterEvent, TimerCounterState> {
  final Countdown _countdown;
  // ignore: prefer_final_fields
  int _duration = 0;
  final TimerEntity _timer;

  StreamSubscription<int>? _countdownSubscription;

  TimerCounterBloc({
    required Countdown countdown,
    required TimerEntity timer,
    StreamSubscription<int>? streamSubscription,
  })  : _countdown = countdown,
        _timer = timer,
        _countdownSubscription = streamSubscription,
        super(TimerCounterInitial(timer.pomodoroTime)) {
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
    if (event.duration > 0) {
      /// cancel the subscription
      /// because we are about to start a new one.
      _countdownSubscription?.cancel();

      _countdown.count(event.duration).fold(
        (err) => emit(TimerCounterFailure(err.toString())),
        (data) {
          _countdownSubscription = data.listen((d) => add(_TimerCounterTicked(duration: d)));
        }, // listen
      );
    } else {
      emit(const TimerCounterFailure("Could not start time from 0"));
    }
  }

  _onTimerPaused(TimerCounterPaused event, Emitter<TimerCounterState> emit) {
    if (state.duration > 0 && state is TimerCounterInProgress) {
      _countdownSubscription?.pause();

      emit(TimerCounterPause(state.duration));
    }
  }

  _onTimerResumed(TimerCounterResumed event, Emitter<TimerCounterState> emit) {
    final isPaused = _countdownSubscription?.isPaused ?? false;

    if (state is TimerCounterPause && isPaused && state.duration > 0) {
      _countdownSubscription?.resume();
    }
  }

  _onTimerReset(TimerCounterReset event, Emitter<TimerCounterState> emit) {
    if (state is! TimerCounterInitial) {
      emit(TimerCounterInitial(_duration));
    }
  }

  _onTimerChange(TimerCounterChange event, Emitter<TimerCounterState> emit) {
    switch (event.type) {
      case TimerType.pomodoro:
        _duration = _timer.pomodoroTime;
        break;
      case TimerType.breakTime:
        _duration = _timer.breakTime;
        break;
    }

    emit(TimerCounterInitial(_duration));
  }

  _onTimerTicked(_TimerCounterTicked event, Emitter<TimerCounterState> emit) {
    emit(TimerCounterInProgress(event.duration));
  }
}
