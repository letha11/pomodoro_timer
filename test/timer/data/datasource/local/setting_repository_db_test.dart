import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/timer/data/datasource/local/setting_repository_db.dart';
import 'package:pomodoro_timer/timer/data/models/setting_hive_model.dart';

@GenerateNiceMocks([MockSpec<HiveInterface>()])
@GenerateMocks([Box<SettingHiveModel>])
import 'setting_repository_db_test.mocks.dart';

void main() {
  SettingHiveModel settingModel = const SettingHiveModel();

  late SettingRepositoryHiveDB settingRepository;
  late HiveInterface hive;
  late MockBox<SettingHiveModel> box;

  setUp(() async {
    hive = MockHiveInterface();
    hive.init('setting');
    box = MockBox<SettingHiveModel>();

    when(hive.openBox('setting')).thenAnswer((_) async => box);
    when(box.get(0)).thenReturn(settingModel);
    settingRepository = await SettingRepositoryHiveDB.create(hive: hive);
  });

  tearDown(() async {
    await hive.close();
  });

  group('constructor', () {
    test(
      'works',
      () async {
        final result = await SettingRepositoryHiveDB.create(hive: hive);

        expect(result, isA<SettingRepositoryDB>());
      },
    );

    test(
      'box should be opened and filled when creating a new SettingRepositoryHiveDB instance',
      () async {
        // differentiate this test `hive` and `setUp`
        final box = MockBox<SettingHiveModel>();
        final hive = MockHiveInterface(); // arrange

        // stubbing
        when(hive.openBox('setting')).thenAnswer((realInvocation) async => box);
        when(box.get(0)).thenReturn(null);

        // act
        await SettingRepositoryHiveDB.create(hive: hive);

        // arrange
        verify(hive.openBox<SettingHiveModel>('setting')).called(1);
        verify(box.put(0, any)).called(1);
      },
    );
  });

  group('getTimer', () {
    test('should return default value when nothing changed', () async {
      // act
      TimerSettingModel timerSetting = settingRepository.getTimer();

      // assert
      expect(timerSetting.pomodoroTime, equals(25));
      expect(timerSetting.shortBreak, equals(5));
      expect(timerSetting.longBreak, equals(15));
    });
  });

  group('storeTimer', () {
    test(
        'should call box.put with the changed settingModel to store the changed setting',
        () {
      const newSettingModel = SettingHiveModel(
        timerSetting: TimerSettingModel(
          pomodoroTime: 30,
          shortBreak: 15,
          longBreak: 25,
        ),
      );

      // stub
      when(box.get(0)).thenReturn(settingModel);

      settingRepository.storeTimerSetting(
        pomodoroTime: newSettingModel.timerSetting.pomodoroTime,
        shortBreak: newSettingModel.timerSetting.shortBreak,
        longBreak: newSettingModel.timerSetting.longBreak,
      );

      verify(box.put(0, newSettingModel)).called(1);
    });
  });

  group('getSound', () {
    test('should return default value when nothing changed', () async {
      // act
      SoundSettingModel soundSetting = settingRepository.getSound();

      // assert
      expect(soundSetting.playSound, equals(true));
      expect(soundSetting.audioPath, equals('assets/audio/alarm.mp3'));
    });
  });

  group('storeSound', () {
    test('should call box.put with the changed settingModel to store the changed setting', () {
      const newSettingModel = SettingHiveModel(
        soundSetting: SoundSettingModel(
          playSound: true,
          audioPath: 'assets/audio/alarm-new.mp3',
        ),
      );
      settingRepository.storeSoundSetting(
        playSound: newSettingModel.soundSetting.playSound,
        audioPath: newSettingModel.soundSetting.audioPath,
      );

      verify(box.put(0, newSettingModel)).called(1);
    });
  });
}
