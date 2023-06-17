import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/success.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart';
import 'package:pomodoro_timer/timer/domain/usecase/usecases.dart';
import 'package:pomodoro_timer/timer/domain/repository/timer_repository.dart';

/// Null safety
@GenerateNiceMocks([MockSpec<TimerRepository>()])
import 'timer_usecase_test.mocks.dart';

void main() {
  late TimerRepository timerRepository;
  const timerEntityPopulated = TimerEntity(pomodoroTime: 1, breakTime: 500, longBreak: 900);

  setUp(() {
    timerRepository = MockTimerRepository();
  });

  group('GetTimerUsecase', () {
    late GetTimerUsecase usecase;

    setUp(() {
      timerRepository = MockTimerRepository();
      usecase = GetTimerUsecase(timerRepository);
    });

    test('should get Right(TimerEntity) from repository', () async {
      // arrange
      when(timerRepository.getTimer()).thenAnswer((_) async => const Right(timerEntityPopulated));

      // act
      final response = await usecase();

      // assert
      verify(timerRepository.getTimer()).called(1);
      // to make sure that no interaction is left for timerRepository.
      verifyNoMoreInteractions(timerRepository);
      expect(response, const Right(timerEntityPopulated));
    });

    test('should get Left(DBFailure) from repository when something went wrong', () async {
      // arrange
      when(timerRepository.getTimer()).thenAnswer((_) async => Left(DBFailure()));

      // act
      final response = await usecase();

      // assert
      verify(timerRepository.getTimer()).called(1);
      // to make sure that no interaction is left for timerRepository.
      verifyNoMoreInteractions(timerRepository);
      expect(response, Left(DBFailure()));
    });
  });

  group('SetTimerUsecase', () {
    late SetTimerUsecase usecase;

    setUp(() {
      timerRepository = MockTimerRepository();
      usecase = SetTimerUsecase(timerRepository);
    });

    test('should return Right(Success) from repository', () async {
      // arrange
      when(timerRepository.setTimer(pomodoroTime: anyNamed('pomodoroTime'), breakTime: anyNamed('breakTime')))
          .thenAnswer((realInvocation) async => Right(Success()));

      // act
      final response = await usecase(pomodoroTime: 1500, breakTime: 2000);

      // assert
      verify(timerRepository.setTimer(pomodoroTime: anyNamed('pomodoroTime'), breakTime: anyNamed('breakTime')))
          .called(1);
      // to make sure that no interaction is left for timerRepository.
      verifyNoMoreInteractions(timerRepository);
      expect(response, Right(Success()));
    });

    test('should get Left(DBFailure) from repository when something went wrong', () async {
      // arrange
      when(timerRepository.setTimer(pomodoroTime: anyNamed('pomodoroTime'), breakTime: anyNamed('breakTime')))
          .thenAnswer((realInvocation) async => Left(DBFailure()));

      // act
      final response = await usecase(pomodoroTime: 1500, breakTime: 2000);

      // assert
      verify(timerRepository.setTimer(pomodoroTime: anyNamed('pomodoroTime'), breakTime: anyNamed('breakTime')))
          .called(1);
      // to make sure that no interaction is left for timerRepository.
      verifyNoMoreInteractions(timerRepository);
      expect(response, Left(DBFailure()));
    });
  });
}
