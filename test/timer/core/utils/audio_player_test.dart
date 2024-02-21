// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/utils/audio_player.dart';
import 'package:just_audio/just_audio.dart';

@GenerateNiceMocks([MockSpec<AudioPlayer>()])
import 'audio_player_test.mocks.dart';

void main() {
  late AudioPlayer player;
  late AudioPlayerL audioPlayer;

  setUp(() {
    player = MockAudioPlayer();
    audioPlayer = AudioPlayerLImpl(player: player);
  });

  group('AudioPlayerL', () {
    test('playSound', () async {
      const pathString = 'something.mp3';
      when(player.setAsset(pathString))
          .thenAnswer((realInvocation) async => const Duration(seconds: 1));
      when(player.setClip(start: anyNamed('start'), end: anyNamed('end')))
          .thenAnswer((realInvocation) async => const Duration(seconds: 1));

      audioPlayer.playSound(pathString);
      await untilCalled(player.play());

      verify(player.setAsset(pathString));
      verify(player.play()).called(1);

      verifyNoMoreInteractions(player);
    });

    test('stopSound', () async {
      audioPlayer.stopSound();

      verify(player.stop()).called(1);
      verifyNoMoreInteractions(player);
    });
  });
}
