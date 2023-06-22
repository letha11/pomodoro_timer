import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/error_object.dart';
// import '../../../../core/utils/time_converter.dart';
import '../../../../core/utils/logger.dart';
import '../../../domain/entity/timer_entity.dart';
import '../../../domain/usecase/usecases.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final ILogger? _logger;
  final GetTimerUsecase _getTimerUsecase;
  final SetTimerUsecase _setTimerUsecase;
  final AddStorageTimerUsecase _addStorageTimerUsecase;

  // final TimeConverter timeConverter;

  TimerBloc({
    required GetTimerUsecase getTimerUsecase,
    required SetTimerUsecase setTimerUsecase,
    required AddStorageTimerUsecase addStorageTimerUsecase,
    // required this.timeConverter,
    ILogger? logger,
  })  : _getTimerUsecase = getTimerUsecase,
        _setTimerUsecase = setTimerUsecase,
        _addStorageTimerUsecase = addStorageTimerUsecase,
        _logger = logger,
        super(TimerInitial()) {
    _logger?.log(Level.info, "Listening Event of TimerBloc");
    on<TimerGet>(_onTimerGet);
    on<TimerSet>(_onTimerSet);
  }

  _onTimerGet(TimerGet event, Emitter<TimerState> emit) async {
    _logger?.log(Level.debug, "TimerGet event get registered");

    emit(TimerLoading());

    final timer = await _getTimerUsecase();

    /// this `fold` method will return data that returned by either
    /// ifRight function/params, or ifLeft function/params
    emit(
      timer.fold(
        (err) => TimerFailed(error: ErrorObject.mapFailureToError(err)),
        (data) {
          _logger?.log(
              Level.debug, "TimerLoaded emitted, [timer: ${data.toString()}]");
          // adding timer to reactive repository
          _addStorageTimerUsecase(data);
          return TimerLoaded(timer: data);
        },
      ),
    );
  }

  _onTimerSet(TimerSet event, Emitter<TimerState> emit) async {
    _logger?.log(Level.debug,
        "TimerSet event get registered, [pomodoroTime: ${event.pomodoroTime}, breakTime: ${event.breakTime}, longBreak: ${event.longBreak}]");

    /// because when this bloc get initialized, it will
    /// sent an TimerGet event, so the state will be TimerLoaded/TimerFailure.
    if (state is TimerLoaded) {
      final ts = await _setTimerUsecase.call(
          pomodoroTime: event.pomodoroTime, breakTime: event.breakTime);

      emit(
        ts.fold(
          (err) => (state as TimerLoaded)
              .copyWith(error: ErrorObject.mapFailureToError(err)),
          (data) {
            // final state = state as TimerLoaded;
            final timer = TimerEntity(
              pomodoroTime: event.pomodoroTime ??
                  (state as TimerLoaded).timer.pomodoroTime,
              breakTime:
                  event.breakTime ?? (state as TimerLoaded).timer.breakTime,
              longBreak:
                  event.longBreak ?? (state as TimerLoaded).timer.longBreak,
            );

            // adding timer to reactive repository
            _addStorageTimerUsecase(timer);

            return (state as TimerLoaded).copyWith(timer: timer);
          },
        ),
      );
    }
  }
}
