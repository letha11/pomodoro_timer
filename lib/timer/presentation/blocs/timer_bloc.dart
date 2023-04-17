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
  })  : _countdown = countdown,
        _getTimerUsecase = getTimerUsecase,
        _setTimerUsecase = setTimerUsecase,
        super(const TimerInitial(0)) {
    on<TimerStarted>(_onTimerStarted);
    on<_TimerTicked>(_onTimerTicked);
    on<TimerPaused>(_onTimerPaused);
  }

  @override
  Future<void> close() {
    _countdownSubscription?.cancel();
    return super.close();
  }

  void _onTimerStarted(TimerStarted event, Emitter<TimerState> emit) async {
    /// cancel the subscription
    /// because we are about to start a new one.
    _countdownSubscription?.cancel();

    _countdown.count(event.duration).fold(
          (err) => emit(TimerFailure(err.toString())),
          (data) => data.listen((d) => add(_TimerTicked(duration: d))),
        );
  }

  _onTimerTicked(_TimerTicked event, Emitter<TimerState> emit) {
    emit(TimerInProgress(event.duration));
  }

  _onTimerPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state.duration > 0 && state is TimerInProgress) {
      _countdownSubscription?.pause();

      emit(TimerPause(state.duration));
    }
  }
}
