import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/core/utils/notifications.dart';
import 'package:pomodoro_timer/timer/data/datasource/local/setting_repository_db.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_sound_setting.dart';
import 'package:pomodoro_timer/timer/domain/usecase/set_sound_setting.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/setting/setting_bloc.dart';

import '../../timer/data/repository/reactive_setting_repository_impl.dart';
import '../../timer/domain/repository/reactive_setting_repository.dart';
import '../../timer/domain/usecase/usecases.dart';
import '../../timer/presentation/blocs/timer_counter/timer_counter_bloc.dart';
import 'audio_player.dart';
import 'countdown.dart';
import 'logger.dart';
import 'time_converter.dart';

// Service Locator
final sl = GetIt.instance;

void init() {
  // Utils
  sl.registerLazySingleton<NotificationHelper>(() => NotificationHelperImpl());
  sl.registerLazySingleton(() => const Countdown());
  sl.registerLazySingleton(() => TimeConverter());
  sl.registerLazySingleton<AudioPlayerL>(() => AudioPlayerLImpl());
  sl.registerLazySingleton<ILogger>(() => LoggerImpl());

  sl.registerSingletonAsync<SettingRepositoryDB>(
    () async => await SettingRepositoryHiveDB.create(logger: sl()),
  );
  sl.registerLazySingleton<ReactiveSettingRepository>(
      () => ReactiveSettingRepositoryImpl(
            dbRepository: sl(),
            logger: sl(),
          ));

  // Usecase
  sl.registerLazySingleton(() => GetTimerUsecase(sl()));
  sl.registerLazySingleton(() => SetTimerUsecase(sl()));
  sl.registerLazySingleton(() => GetSoundSettingUsecase(sl()));
  sl.registerLazySingleton(() => SetSoundSettingUsecase(sl()));

  // Blocs
  sl.registerFactory(
    () => SettingBloc(
      logger: sl(),
      getTimerUsecase: sl(),
      setTimerUsecase: sl(),
      getSoundSettingUsecase: sl(),
      setSoundSettingUsecase: sl(),
    ),
  );
  sl.registerFactory<TimerCounterBloc>(
    () => TimerCounterBloc(
      countdown: sl(),
      timeConverter: sl(),
      notificationHelper: sl(),
      logger: sl(),
      getTimerUsecase: sl(),
      getSoundSettingUsecase: sl(),
      audioPlayer: sl(),
    ),
  );
}
