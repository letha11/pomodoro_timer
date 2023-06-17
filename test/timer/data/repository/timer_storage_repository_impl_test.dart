import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart';
import 'package:pomodoro_timer/timer/domain/repository/timer_storage_repository.dart';
import 'package:pomodoro_timer/timer/data/repository/timer_storage_repository_impl.dart';

void main() {
  const TimerEntity timer = TimerEntity(
    pomodoroTime: 1000,
    breakTime: 300,
    longBreak: 900,
  );
  late TimerStorageRepository timerStorageRepository;

  setUp(() {
    timerStorageRepository = TimerStorageRepositoryImpl();
  });

  group('stream getter', () {
    test('should return a `Stream` of type `TimerEntity`', () {
      expect(timerStorageRepository.stream, isA<Stream<TimerEntity>>());
    });
  });

  group('add method', () {
    test('should add a `TimerEntity` to the stream', () {
      timerStorageRepository.add(timer);

      expectLater(timerStorageRepository.stream, emits(timer));
    });
  });
}
