import 'package:just_audio/just_audio.dart';

abstract class AudioPlayerL {
  void playSound(String path);
  void stopSound();
}

class AudioPlayerLImpl extends AudioPlayerL {
  final AudioPlayer _player;

  AudioPlayerLImpl({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  @override
  void playSound(String path) async {
    await _player.setAsset(path);
    _player.setClip(end: const Duration(seconds: 3));
    _player.play();
  }

  @override
  void stopSound() => _player.stop();
}
