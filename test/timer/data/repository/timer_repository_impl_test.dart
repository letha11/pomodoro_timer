import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/timer/data/datasource/local/timer_repository_db.dart';
import 'package:pomodoro_timer/timer/data/models/timer_model.dart';
import 'package:pomodoro_timer/timer/data/repository/timer_repository_impl.dart';

@GenerateNiceMocks([MockSpec<TimerRepositoryHiveDB>()])
import 'timer_repository_impl_test.mocks.dart';
// class MockTimerRepositoryDB extends Mock implements TimerRepositoryHiveDB {}

void main() {
  late TimerRepositoryImpl timerRepository;
  late TimerRepositoryDB timerRepositoryDB;
  late TimerModel timer;

  setUp(() {
    timerRepositoryDB = MockTimerRepositoryHiveDB();
    timerRepository = TimerRepositoryImpl(
      timerRepositoryDB: timerRepositoryDB,
    );
    timer = const TimerModel();
  });

  group('constructor', () {
    test('works', () => expect(TimerRepositoryImpl(timerRepositoryDB: timerRepositoryDB), isNotNull));
  });

  group('getTimer', () {
    test('should return Right(TimerEntity) when success', () async {
      when(timerRepositoryDB.getTimer()).thenReturn(timer);

      final result = await timerRepository.getTimer();

      verify(timerRepositoryDB.getTimer()).called(1);
      expect(result, equals(Right(timer)));
    });

    test('should return Right(Failure) when _DBRepository.getTimer() throws an error', () async {
      when(timerRepositoryDB.getTimer()).thenThrow(Exception('woopsie'));

      final result = await timerRepository.getTimer();

      // Currently only UnhandledFailure available
      expect(result, equals(Left(UnhandledFailure())));
    });
  });
}
