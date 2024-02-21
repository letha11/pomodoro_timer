import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

abstract class AudioPlayerL {
  void playSoundFromUint8List(Uint8List bytes);
  void playSound(String path);
  void stopSound();
}

class BytesSource extends StreamAudioSource {
  final Uint8List _buffer;

  BytesSource(this._buffer) : super(tag: 'AudioSource');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _buffer.length;
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.fromIterable([_buffer.sublist(start, end)]),
      contentType: 'audio/wav',
    );
  }
}

class AudioPlayerLImpl extends AudioPlayerL {
  final AudioPlayer _player;

  AudioPlayerLImpl({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  @override
  void playSound(String path) async {
    await _player.setAsset(path);
    _player.play();
  }

  @override
  void stopSound() => _player.stop();

  @override
  void playSoundFromUint8List(Uint8List bytes) async {
    await _player.setAudioSource(BytesSource(bytes));
    _player.play();
  }
}
