import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/error_object.dart';
import '../../../../core/utils/logger.dart';
import '../../../domain/entity/timer_setting_entity.dart';
import '../../../domain/usecase/usecases.dart';

part 'timer_event.dart';

part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final ILogger? _logger;
  final GetTimerUsecase _getTimerUsecase;
  final SetTimerUsecase _setTimerUsecase;
  StreamSubscription<TimerSettingEntity>? _timerSubscription;

  TimerBloc({
    required GetTimerUsecase getTimerUsecase,
    required SetTimerUsecase setTimerUsecase,
    ILogger? logger,
  })  : _getTimerUsecase = getTimerUsecase,
        _setTimerUsecase = setTimerUsecase,
        _logger = logger,
        super(TimerInitial()) {
    _logger?.log(Level.info, "Listening Event of TimerBloc");
    on<TimerGet>(_onTimerGet);
    on<TimerSet>(_onTimerSet);

    on<_TimerChanged>(_onTimerChanged);
  }

  @override
  Future<void> close() async {
    super.close();
    _timerSubscription?.cancel();
  }

  _onTimerGet(TimerGet event, Emitter<TimerState> emit) async {
    _logger?.log(Level.debug, "TimerGet event get registered");

    emit(TimerLoading());

    final timer = _getTimerUsecase();

    timer.fold(
      (err) => emit(TimerFailed(error: ErrorObject.mapFailureToError(err))),
      (data) {
        _timerSubscription = data.listen((d) => add(_TimerChanged(timer: d)));
      },
    );
  }

  _onTimerSet(TimerSet event, Emitter<TimerState> emit) async {
    _logger?.log(Level.debug,
        "TimerSet event get registered, [pomodoroTime: ${event.pomodoroTime}, breakTime: ${event.shortBreak}, longBreak: ${event.longBreak}]");

    /// because when this bloc get initialized, it will
    /// sent an TimerGet event, so the state will be TimerLoaded/TimerFailure.
    if (state is TimerLoaded) {
      final ts = await _setTimerUsecase(
        pomodoroTime:
            event.pomodoroTime ?? (state as TimerLoaded).timer.pomodoroTime,
        shortBreak: event.shortBreak ?? (state as TimerLoaded).timer.shortBreak,
        longBreak: event.longBreak ?? (state as TimerLoaded).timer.longBreak,
        pomodoroSequence: event.pomodoroSequence ??
            (state as TimerLoaded).timer.pomodoroSequence,
      );

      ts.fold(
        (err) => emit((state as TimerLoaded)
            .copyWith(error: ErrorObject.mapFailureToError(err))),
        (data) => null,
      );
    }
  }

  _onTimerChanged(_TimerChanged event, Emitter<TimerState> emit) {
    _logger?.log(
        Level.debug, "TimerLoaded emitted, [timer: ${event.timer.toString()}]");
    emit(TimerLoaded(timer: event.timer));
  }
}
