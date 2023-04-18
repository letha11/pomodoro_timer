import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_timer/core/utils/countdown.dart';
import 'package:pomodoro_timer/timer/domain/usecase/usecases.dart';

part 'timer_event.dart';

part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Countdown _countdown;
  final GetTimerUsecase _getTimerUsecase;
  final SetTimerUsecase _setTimerUsecase;

  StreamSubscription<int>? _countdownSubscription;

  TimerBloc({
    required Countdown countdown,
    required GetTimerUsecase getTimerUsecase,
    required SetTimerUsecase setTimerUsecase,
    StreamSubscription<int>? streamSubscription,
  })  : _countdown = countdown,
        _getTimerUsecase = getTimerUsecase,
        _setTimerUsecase = setTimerUsecase,
        _countdownSubscription = streamSubscription,
        super(const TimerInitial(0)) {
    on<TimerStarted>(_onTimerStarted);
    on<TimerPaused>(_onTimerPaused);
    on<TimerResumed>(_onTimerResumed);

    on<_TimerTicked>(_onTimerTicked);
  }

  @override
  Future<void> close() {
    _countdownSubscription?.cancel();
    return super.close();
  }

  void _onTimerStarted(TimerStarted event, Emitter<TimerState> emit) async {
    if (event.duration > 0) {
      /// cancel the subscription
      /// because we are about to start a new one.
      _countdownSubscription?.cancel();

      _countdown.count(event.duration).fold(
        (err) => emit(TimerFailure(err.toString())),
        (data) {
          _countdownSubscription = data.listen((d) => add(_TimerTicked(duration: d)));
        }, // listen
      );
    } else {
      emit(const TimerFailure("Could not start time from 0"));
    }
  }

  _onTimerPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state.duration > 0 && state is TimerInProgress) {
      _countdownSubscription?.pause();

      emit(TimerPause(state.duration));
    }
  }

  _onTimerResumed(TimerResumed event, Emitter<TimerState> emit) {
    final isPaused = _countdownSubscription?.isPaused ?? false;

    if (state is TimerPause && isPaused && state.duration > 0) {
      _countdownSubscription?.resume();
    }
  }

  _onTimerTicked(_TimerTicked event, Emitter<TimerState> emit) {
    emit(TimerInProgress(event.duration));
  }
}
