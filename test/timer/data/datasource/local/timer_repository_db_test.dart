import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/timer/data/datasource/local/timer_repository_db.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:pomodoro_timer/timer/data/models/timer_model.dart';

import '../../../../test_utils.dart';

@GenerateNiceMocks([MockSpec<HiveInterface>()])
@GenerateMocks([Box])
import 'timer_repository_db_test.mocks.dart';

void main() {
  late TimerRepositoryHiveDB timerRepository;
  late HiveInterface hive;
  late MockBox box;

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // This is required because we manually register the Linux path provider when on the Linux platform.
    // Will be removed when automatic registration of dart plugins is implemented.
    // See this issue https://github.com/flutter/flutter/issues/52267 for details
    // disablePathProviderPlatformOverride = true;
    PathProviderPlatform.instance = MockPathProviderPlatform();
    hive = MockHiveInterface();
    hive.init('timer');
    box = MockBox();

    when(hive.openBox('timer')).thenAnswer((realInvocation) async => box);
    timerRepository = await TimerRepositoryHiveDB.create(hive: hive);
  });

  group('constructor', () {
    test('instantiate TimerRepositoryDB.create when hive is not provided',
        () => expect(TimerRepositoryHiveDB.create(hive: hive), isNotNull));

    test('box should be filled when constructing a new TimerRepositoryDB', () async {
      /// make another HiveInterface instance
      /// to seperate HiveInterface from [setUp] function
      final hive = MockHiveInterface();

      // stubbing
      when(hive.openBox('timer')).thenAnswer((realInvocation) async => box);

      // act
      final result = await TimerRepositoryHiveDB.create(hive: hive);

      // assert
      expect(result.box, isA<MockBox>());
      verify(hive.openBox('timer')).called(1);
    });
  });

  group('setTimer', () {
    const pomodoroTime = 1000;
    const breakTime = 500;

    test('should store pomodoroTime into \'pomodoro_time\' when only pomodoroTime given', () {
      // arrange
      when(box.get('pomodoro_time')).thenReturn(pomodoroTime);

      // act
      timerRepository.setTimer(pomodoroTime: pomodoroTime);

      // assert
      verify(box.put('pomodoro_time', pomodoroTime)).called(1);
      verifyNever(box.put('break_time', any));
      expect(box.get('pomodoro_time'), pomodoroTime);
    });

    test('should store \'break_time\' when only breakTime given', () {
      // arrange
      when(box.get('break_time')).thenReturn(breakTime);

      // act
      timerRepository.setTimer(breakTime: breakTime);

      // assert
      verify(box.put('break_time', breakTime)).called(1);
      verifyNever(box.put('pomodoro_time', any));
      expect(box.get('break_time'), breakTime);
    });

    test('should store both pomodoroTime and breakTime when both parameters given', () {
      // arrange
      when(box.get('break_time')).thenReturn(breakTime);
      when(box.get('pomodoro_time')).thenReturn(pomodoroTime);

      // act
      timerRepository.setTimer(pomodoroTime: pomodoroTime, breakTime: breakTime);

      // assert
      verify(box.put('break_time', breakTime)).called(1);
      verify(box.put('pomodoro_time', pomodoroTime)).called(1);
      expect(box.get('break_time'), breakTime);
      expect(box.get('pomodoro_time'), pomodoroTime);
    });
  });

  group('getTimer', () {
    const pomodoroTime = 1000;
    const breakTime = 500;

    test('should retrieve TimerModel', () {
      // arrange
      when(box.get('break_time')).thenReturn(breakTime);
      when(box.get('pomodoro_time')).thenReturn(pomodoroTime);

      // act
      final result = timerRepository.getTimer();  

      expect(
          result,
          isA<TimerModel>()
              .having((p0) => p0.breakTime, 'breakTime', breakTime)
              .having((p0) => p0.pomodoroTime, 'pomodoroTime', pomodoroTime));
    });
  });
}
