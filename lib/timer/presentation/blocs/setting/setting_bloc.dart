import 'dart:async';

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pomodoro_timer/timer/domain/entity/sound_setting_entity.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_sound_setting.dart';
import 'package:pomodoro_timer/timer/domain/usecase/set_sound_setting.dart';

import '../../../../core/utils/error_object.dart';
import '../../../../core/utils/logger.dart';
import '../../../domain/entity/timer_setting_entity.dart';
import '../../../domain/usecase/usecases.dart';

part 'setting_event.dart';

part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final ILogger? _logger;
  final GetTimerUsecase _getTimerUsecase;
  final GetSoundSettingUsecase _getSoundSettingUsecase;
  final SetSoundSettingUsecase _setSoundSettingUsecase;
  final SetTimerUsecase _setTimerUsecase;

  StreamSubscription<dynamic>? groupedStream;
  TimerSettingEntity? _timer;
  SoundSettingEntity? _soundSetting;

  SettingBloc({
    required GetTimerUsecase getTimerUsecase,
    required SetTimerUsecase setTimerUsecase,
    required GetSoundSettingUsecase getSoundSettingUsecase,
    required SetSoundSettingUsecase setSoundSettingUsecase,
    ILogger? logger,
  })  : _getTimerUsecase = getTimerUsecase,
        _setTimerUsecase = setTimerUsecase,
        _getSoundSettingUsecase = getSoundSettingUsecase,
        _setSoundSettingUsecase = setSoundSettingUsecase,
        _logger = logger,
        super(SettingInitial()) {
    _logger?.log(Level.info, "Listening Event of TimerBloc");
    on<SettingGet>(_onSettingGet);
    on<SettingSet>(_onSettingSet);

    on<_SettingChanged>(_onSettingChanged);
  }

  @override
  Future<void> close() async {
    super.close();
    groupedStream?.cancel();
  }

  _onSettingGet(SettingGet event, Emitter<SettingState> emit) async {
    _logger?.log(Level.debug, "SettingGet event get registered");

    bool isError = false;

    emit(SettingLoading());

    late Stream<TimerSettingEntity> timerStream;
    late Stream<SoundSettingEntity> soundSettingStream;
    final t = _getTimerUsecase();

    t.fold(
      (err) {
        isError = true;
        emit(SettingFailed(error: ErrorObject.mapFailureToError(err)));
        return;
      },
      (stream) async {
        timerStream = stream;
      },
    );

    if (isError) return;

    final s = _getSoundSettingUsecase();

    s.fold(
      (err) {
        isError = true;
        emit(SettingFailed(error: ErrorObject.mapFailureToError(err)));
      },
      (stream) async {
        soundSettingStream = stream;
      },
    );

    if (isError) return;

    groupedStream = StreamGroup.merge([
      timerStream,
      soundSettingStream,
    ]).listen((event) {
      if (event is TimerSettingEntity) {
        _timer = event;
      } else if (event is SoundSettingEntity) {
        _soundSetting = event;
      }

      if (_timer != null && _soundSetting != null && !isError) {
        add(_SettingChanged(timer: _timer, soundSetting: _soundSetting));
      }
    });

    // await _setTimerUsecase(pomodoroTime: 100);
  }

  _onSettingSet(SettingSet event, Emitter<SettingState> emit) async {
    // print(state);
    // if (state is SettingLoaded) {
      if (event.pomodoroTime != null ||
          event.pomodoroSequence != null ||
          event.longBreak != null ||
          event.shortBreak != null) {
        final ts = await _setTimerUsecase(
          pomodoroTime: event.pomodoroTime ?? _timer!.pomodoroTime,
          shortBreak: event.shortBreak ?? _timer!.shortBreak,
          longBreak: event.longBreak ?? _timer!.longBreak,
          pomodoroSequence: event.pomodoroSequence ?? _timer!.pomodoroSequence,
        );

        ts.fold(
          (err) {
            emit((state as SettingLoaded)
                .copyWith(error: ErrorObject.mapFailureToError(err)));
          },
          (data) => null,
        );
      }

      if (event.audioPath != null || event.playSound != null) {
        final ss = await _setSoundSettingUsecase(
          audioPath: event.audioPath ?? _soundSetting!.audioPath,
          playSound: event.playSound ?? _soundSetting!.playSound,
        );

        ss.fold(
          (err) {
            emit((state as SettingLoaded)
                .copyWith(error: ErrorObject.mapFailureToError(err)));
            return;
          },
          (data) => null,
        );
      }
    // }
  }

  // _onSetTimerSetting(SetTimerSetting event, Emitter<SettingState> emit) async {
  //   _logger?.log(Level.debug,
  //       "TimerSet event get registered, [pomodoroTime: ${event.pomodoroTime}, breakTime: ${event.shortBreak}, longBreak: ${event.longBreak}]");

  //   /// because when this bloc get initialized, it will
  //   /// sent an TimerGet event, so the state will be TimerLoaded/TimerFailure.
  //   if (state is SettingLoaded) {
  //     final ts = await _setTimerUsecase(
  //       pomodoroTime:
  //           event.pomodoroTime ?? (state as SettingLoaded).timer.pomodoroTime,
  //       shortBreak:
  //           event.shortBreak ?? (state as SettingLoaded).timer.shortBreak,
  //       longBreak: event.longBreak ?? (state as SettingLoaded).timer.longBreak,
  //       pomodoroSequence: event.pomodoroSequence ??
  //           (state as SettingLoaded).timer.pomodoroSequence,
  //     );

  //     ts.fold(
  //       (err) => emit((state as SettingLoaded)
  //           .copyWith(error: ErrorObject.mapFailureToError(err))),
  //       (data) => null,
  //     );
  //   }
  // }

  _onSettingChanged(_SettingChanged event, Emitter<SettingState> emit) {
    _logger?.log(
        Level.debug, "TimerLoaded emitted, [timer: ${event.timer.toString()}]");
    emit(SettingLoaded(
      timer: event.timer ?? _timer!,
      soundSetting: event.soundSetting ?? _soundSetting!,
    ));
  }
}
