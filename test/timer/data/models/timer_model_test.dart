import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timer/timer/data/models/timer_model.dart';
import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart';

void main() {
  late TimerModel timer;

  setUp(() {
    timer = const TimerModel(pomodoroTime: 1000, breakTime: 500);
  });

  test('should be a subclass of Timer entity', () {
    expect(
        timer,
        isA<TimerEntity>()
            .having((p0) => p0.pomodoroTime, 'pomodoroTime', 1000)
            .having((p0) => p0.breakTime, 'breakTime', 500));
  });

  group('toJson', () {
    test('works', () {
      final result = timer.toJson();

      expect(result, <String, dynamic>{
        'pomodoro_time': 1000,
        'break_time': 500,
        'long_break': 900,
      });
    });
  });

  group('fromJson', () {
    test('should get TimerModel when given correct json', () {
      final result = TimerModel.fromJson(timer.toJson());

      expect(
          result,
          isA<TimerEntity>()
              .having((p0) => p0.pomodoroTime, 'pomodoroTime', 1000)
              .having((p0) => p0.breakTime, 'breakTime', 500));
    });
  });

  group('Equatable', () {
    test('comparing two TimerModel with the same value should return True', () {
      const timer1 = TimerModel(pomodoroTime: 1000, breakTime: 500);
      const timer2 = TimerModel(pomodoroTime: 1000, breakTime: 500);

      expect(timer1, timer2);
      expect(timer1.props, timer2.props);
    });
  });
}
