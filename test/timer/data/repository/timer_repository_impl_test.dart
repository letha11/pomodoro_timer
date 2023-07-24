import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/timer/data/datasource/local/timer_repository_db.dart';
import 'package:pomodoro_timer/timer/data/models/timer_model.dart';
import 'package:pomodoro_timer/timer/data/repository/timer_repository_impl.dart';

@GenerateNiceMocks([MockSpec<TimerRepositoryHiveDB>()])
import 'timer_repository_impl_test.mocks.dart';

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
    test(
        'works',
        () => expect(TimerRepositoryImpl(timerRepositoryDB: timerRepositoryDB),
            isNotNull));
  });

  group('getTimer', () {
    test('should return Right(TimerEntity) when success', () async {
      when(timerRepositoryDB.getTimer()).thenReturn(timer);

      final result = await timerRepository.getTimer();

      verify(timerRepositoryDB.getTimer()).called(1);
      expect(result, equals(Right(timer)));
    });

    test(
        'should return Left(Failure) when _DBRepository.getTimer() throws an Exception',
        () async {
      when(timerRepositoryDB.getTimer()).thenThrow(Exception('woopsie'));

      final result = await timerRepository.getTimer();

      // Currently only UnhandledFailure available
      expect(result, equals(Left(UnhandledFailure())));
    });
  });

  group('setTimer', () {
    const pomodoroTime = 1000;
    const breakTime = 300;
    const longBreak = 900;

    test('should return Right(TimerEntity) when success', () async {
      final result = await timerRepository.setTimer(
          pomodoroTime: pomodoroTime,
          breakTime: breakTime,
          longBreak: longBreak);

      verify(timerRepositoryDB.setTimer(
        pomodoroTime: pomodoroTime,
        breakTime: breakTime,
        longBreak: longBreak,
      )).called(1);
      expect(result, equals(Right(Success())));
    });

    test(
        'should return Left(Failure) when _DBRepository.setTimer() throws an Exception',
        () async {
      // we dont need all of the parameters for this test to be valid
      when(
        timerRepositoryDB.setTimer(
          pomodoroTime: anyNamed('pomodoroTime'),
          breakTime: anyNamed('breakTime'),
        ),
      ).thenThrow(Exception('woopsie'));

      final result = await timerRepository.setTimer(
          pomodoroTime: pomodoroTime, breakTime: breakTime);

      // Currently only UnhandledFailure available
      expect(result, equals(Left(UnhandledFailure())));
    });
  });
}
