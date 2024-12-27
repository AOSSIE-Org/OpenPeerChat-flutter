import 'package:flutter_sound/flutter_sound.dart';
class AudioPlayer {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isInitialized=false;

  Future<void> initPlayer() async {
    if(!_isInitialized){
      await _player.openPlayer();
      _isInitialized=true;
    }
  }

  Future<void> playAudio(String filePath) async {
    await _player.startPlayer(fromURI: filePath);
  }

  Future<void> stopAudio() async {
    await _player.stopPlayer();
  }

  Future<void> dispose() async {
    if(_isInitialized){
      await _player.closePlayer();
      _isInitialized=false;
    }
  }
}
