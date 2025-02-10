import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class RecordingPermissionException implements Exception {
  final String message;
  RecordingPermissionException(this.message);

  @override
  String toString() => 'RecordingPermissionException: $message';
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioRecorder _recorder = AudioRecorder(); // Updated to AudioRecorder
  final player = AudioPlayer();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          if (await Permission.audio.status.isDenied) {
            await Permission.audio.request();
          }
          if (await Permission.videos.status.isDenied) {
            await Permission.videos.request();
          }
        } else {
          if (await Permission.storage.status.isDenied) {
            await Permission.storage.request();
          }
          if (await Permission.manageExternalStorage.status.isDenied) {
            await Permission.manageExternalStorage.request();
          }
        }
      }

      if (await Permission.microphone.status.isDenied) {
        final micStatus = await Permission.microphone.request();
        if (micStatus.isPermanentlyDenied) {
          debugPrint('Microphone permission permanently denied');
          return false;
        }
        return micStatus.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  Future<void> initRecorder() async {
    if (_isRecorderInitialized) return;

    try {
      debugPrint('Initializing recorder...');
      bool permissionsGranted = await _requestPermissions();

      if (!permissionsGranted) {
        throw RecordingPermissionException(
            'Required permissions were not granted. Please enable necessary permissions in your device settings.'
        );
      }

      await _recorder.hasPermission();
      _isRecorderInitialized = true;
      debugPrint('Recorder initialized successfully');
    } catch (e) {
      _isRecorderInitialized = false;
      debugPrint('Recorder initialization failed: $e');
      rethrow;
    }
  }

  Future<String> startRecording() async {
    if (_isRecording) {
      throw RecordingPermissionException('Already recording');
    }

    try {
      if (!_isRecorderInitialized) {
        await initRecorder();
      }

      Directory tempDir = await getTemporaryDirectory();
      _currentRecordingPath = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _recorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
      return _currentRecordingPath!;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      await _recorder.stop();
      _isRecording = false;
      final recordedPath = _currentRecordingPath;
      _currentRecordingPath = null;
      return recordedPath;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> playRecording(String path) async {
    try {
      // Using proper AudioSource as per documentation
      await player.setAudioSource(AudioSource.uri(Uri.parse(path)));
      await player.play();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopPlaying() async {
    try {
      await player.stop();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await stopRecording();
      }
      await _recorder.dispose();
      await player.dispose();
      _isRecorderInitialized = false;
    } catch (e) {
      rethrow;
    }
  }
}
