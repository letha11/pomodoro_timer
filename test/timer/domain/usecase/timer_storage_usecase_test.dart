import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart';
import 'package:pomodoro_timer/timer/domain/repository/timer_storage_repository.dart';
import 'package:pomodoro_timer/timer/domain/usecase/get_storage_timer.dart';

@GenerateNiceMocks([MockSpec<TimerStorageRepository>()])
import 'timer_storage_usecase_test.mocks.dart';

// class MockTimerRepository extends Mock implements TimerStorageRepository {}

void main() {
  const timerEntityPopulated = TimerEntity(pomodoroTime: 1000, breakTime: 500, longBreak: 900);
  late TimerStorageRepository timerRepository;
  late StreamController<TimerEntity> streamController;
  late GetStorageTimerUsecase getStorageTimerUsecase;

  setUp(() {
    timerRepository = MockTimerStorageRepository();
    streamController = StreamController<TimerEntity>();
    getStorageTimerUsecase = GetStorageTimerUsecase(timerRepository);
  });

  tearDown(() {
    streamController.close();
  });

  group('GetStorageTimerUsecase', () {
    test('should call `repository.stream`, and get `Stream<TimerEntity>`',
        () async {
      // arrange
      when(timerRepository.stream).thenAnswer((_) => streamController.stream);

      // act
      final response = getStorageTimerUsecase();

      // assert
      verify(timerRepository.stream).called(1);
      // to make sure that no interaction is left for timerRepository.
      verifyNoMoreInteractions(timerRepository);
      expect(response, streamController.stream);
    });
  });

  group('AddStorageTimerUsecase', () {
    test('should call `repository.add`', () {
      // arrange
      when(timerRepository.add(timerEntityPopulated)).thenAnswer((_) async {});

      // act
      timerRepository.add(timerEntityPopulated);

      // assert
      verify(timerRepository.add(timerEntityPopulated)).called(1);
      // to make sure that no interaction is left for timerRepository.
      verifyNoMoreInteractions(timerRepository);
    });
  });
}
