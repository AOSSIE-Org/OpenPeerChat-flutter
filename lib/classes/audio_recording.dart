import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorder {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;

  Future<void> initRecorder() async {
    await _recorder.openRecorder();
  }

  Future<String?> startRecording() async {
    if (!_isRecording) {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(toFile: filePath);
      _isRecording = true;
      return filePath;
    }
    return null;
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      await _recorder.stopRecorder();
      _isRecording = false;
    }
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
  }
}
