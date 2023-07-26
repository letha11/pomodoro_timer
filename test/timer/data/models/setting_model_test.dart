import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timer/timer/data/models/setting_model.dart';
import 'package:pomodoro_timer/timer/domain/entity/setting_entity.dart';

void main() {
  late SettingModel setting;

  setUp(() {
    setting = const SettingModel(
      pomodoroSequence: true,
      playSound: true,
    );
  });

  test('should be a sub class of SettingEntity', () {
    expect(
      setting,
      isA<SettingEntity>()
          .having((p0) => p0.pomodoroSequence, "pomodoroSequence", true)
          .having((p0) => p0.playSound, "playSound", true),
    );
  });

  group('toJson', () {
    test('works', () {
      final result = setting.toJson();

      expect(
        result,
        <String, dynamic>{
          'pomodoro_sequence': true,
          'play_sound': true,
        },
      );
    });
  });

  group('fromJson', () {
    test('works', () {
      final result = SettingModel.fromJson(setting.toJson());

      expect(
        result,
        isA<SettingEntity>()
            .having((p0) => p0.pomodoroSequence, "pomodoroSequence", true)
            .having((p0) => p0.playSound, "playSound", true),
      );
    });
  });

  group('Equatable', () {
    test('should return true when the value of the model are the same', () {
      const setting1 = SettingModel(pomodoroSequence: true, playSound: true);
      const setting2 = SettingModel(pomodoroSequence: true, playSound: true);

      expect(setting1, setting2);
      expect(setting1.props, setting2.props);
    });
  });
}
