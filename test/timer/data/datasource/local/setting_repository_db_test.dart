import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/timer/data/datasource/local/setting_repository_db.dart';
import 'package:pomodoro_timer/timer/data/models/setting_model.dart';

@GenerateNiceMocks([MockSpec<HiveInterface>()])
@GenerateMocks([Box])
import 'setting_repository_db_test.mocks.dart';

void main() {
  const SettingModel setting = SettingModel(
    pomodoroSequence: true,
    playSound: true,
  );

  late SettingRepositoryHiveDB settingRepository;
  late HiveInterface hive;
  late MockBox box;

  setUp(() async {
    hive = MockHiveInterface();
    hive.init('setting');
    box = MockBox();

    when(hive.openBox('setting')).thenAnswer((_) async => box);
    settingRepository = await SettingRepositoryHiveDB.create(hive: hive);
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
      'box should be filled when creating a new SettingRepositoryHiveDB instance',
      () async {
        // differentiate this test `hive` and `setUp`
        final hive = MockHiveInterface(); // arrange

        // stubbing
        when(hive.openBox('setting')).thenAnswer((realInvocation) async => box);

        // act
        final result = await SettingRepositoryHiveDB.create(hive: hive);

        // arrange
        expect(result.box, isA<MockBox>());
        verify(hive.openBox('setting')).called(1);
      },
    );
  });

  group('store', () {
    test('should call `.put` method on every field in the given model', () {
      final jsonModel = setting.toJson();
      final keys = jsonModel.keys;

      settingRepository.store(setting);

      for (var key in keys) {
        verify(box.put(key, jsonModel[key])).called(1);
      }
    });
  });

  group('get', () {
    test('should retreive SettingModel', () {
      when(box.get('pomodoro_sequence')).thenReturn(setting.pomodoroSequence);
      when(box.get('play_sound')).thenReturn(setting.playSound);

      final result = settingRepository.get();

      expect(
        result,
        isA<SettingModel>()
            .having((p0) => p0.pomodoroSequence, 'pomodoroSequence',
                setting.pomodoroSequence)
            .having((p0) => p0.playSound, 'playSound', setting.playSound),
      );
    });
  });
}
