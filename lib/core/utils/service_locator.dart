import 'package:get_it/get_it.dart';

import '../../timer/data/datasource/local/timer_repository_db.dart';
import '../../timer/data/repository/timer_repository_impl.dart';
import '../../timer/domain/entity/timer_entity.dart';
import '../../timer/domain/repository/timer_repository.dart';
import '../../timer/domain/usecase/usecases.dart';
import '../../timer/presentation/blocs/timer/timer_bloc.dart';
import '../../timer/presentation/blocs/timer_counter/timer_counter_bloc.dart';
import 'countdown.dart';
import 'logger.dart';
import 'time_converter.dart';

// Service Locator
final sl = GetIt.instance;

void init() {
  // Utils
  sl.registerLazySingleton(() => const Countdown());
  sl.registerLazySingleton(() => TimeConverter());
  sl.registerLazySingleton<ILogger>(() => LoggerImpl());

  // Repository
  // when we are overriding <T> with an <abstract class>
  // we can use an class that implements that `abstract` class
  // and when some classes need `TimerRepositoryDB` for example
  // because i register the `TimerRepositoryDB` with an `TimerRepositoryHiveDB`
  // everytime i call sl() inside of parameter that accept `TimerRepositoryDB` it will always return `TimerRepositoryHiveDB`
  sl.registerSingletonAsync<TimerRepositoryDB>(
    () async => await TimerRepositoryHiveDB.create(logger: sl()),
  );
  sl.registerLazySingleton<TimerRepository>(
    () => TimerRepositoryImpl(timerRepositoryDB: sl(), logger: sl()),
  );

  // Usecase
  sl.registerLazySingleton(() => GetTimerUsecase(sl()));
  sl.registerLazySingleton(() => SetTimerUsecase(sl()));

  // Blocs
  sl.registerFactory(
    () => TimerBloc(
      logger: sl(),
      getTimerUsecase: sl(),
      setTimerUsecase: sl(),
    ),
  );
  sl.registerFactoryParam<TimerCounterBloc, TimerEntity, dynamic>(
    (timer, _) => TimerCounterBloc(
      countdown: sl(),
      timeConverter: sl(),
      logger: sl(),
      timer: timer,
    ),
  );
}
