// lib/services/audio_service.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingPermissionException implements Exception {
  final String message;
  RecordingPermissionException(this.message);

  @override
  String toString() => 'RecordingPermissionException: $message';
}

class PermissionService {
  static Future<bool> handleMicrophonePermission(BuildContext context) async {
    if (Platform.isIOS) {
      final status = await Permission.microphone.status;
      debugPrint('iOS Microphone Permission Status: $status');

      if (status.isDenied) {
        final result = await Permission.microphone.request();
        debugPrint('iOS Permission Request Result: $result');
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showiOSSettingsDialog(context);
        }
        return false;
      }

      return status.isGranted;
    }

    return true;
  }

  static Future<void> _showiOSSettingsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Microphone Access Required'),
          content: const Text(
              'OpenPeerChat needs access to your microphone to record voice messages.\n\n'
                  'Please enable microphone access in Settings.'
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final Record _recorder = Record();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  String? _currentRecordingPath;

  // Getters
  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<bool> _requestPermissions() async {
    try {
      final permissions = [Permission.microphone];
      if (Platform.isAndroid) {
        permissions.add(Permission.storage);
      }

      debugPrint('Requesting permissions: $permissions');
      final statuses = await permissions.request();

      bool allGranted = true;
      statuses.forEach((permission, status) {
        debugPrint('Permission $permission status: $status');
        if (status != PermissionStatus.granted) {
          allGranted = false;
        }
      });

      return allGranted;
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
            'Required permissions were not granted. Please enable microphone access in your device settings.'
        );
      }

      if (!await _recorder.hasPermission()) {
        throw RecordingPermissionException(
            'Microphone permission not available. Please check your device settings.'
        );
      }

      _isRecorderInitialized = true;
      debugPrint('Recorder initialized successfully');
    } catch (e) {
      _isRecorderInitialized = false;
      debugPrint('Recorder initialization failed: $e');
      throw RecordingPermissionException(e.toString());
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

      await _recorder.start(
        path: _currentRecordingPath!,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );

      _isRecording = true;
      debugPrint('Started recording at: $_currentRecordingPath');
      return _currentRecordingPath!;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      debugPrint('Recording failed: $e');
      throw RecordingPermissionException('Failed to start recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      await _recorder.stop();
      _isRecording = false;
      final recordedPath = _currentRecordingPath;
      _currentRecordingPath = null;
      debugPrint('Stopped recording. File saved at: $recordedPath');
      return recordedPath;
    } catch (e) {
      debugPrint('Failed to stop recording: $e');
      throw RecordingPermissionException('Failed to stop recording: $e');
    }
  }

  Future<void> playRecording(String path) async {
    try {
      await _player.setFilePath(path);
      await _player.play();
    } catch (e) {
      debugPrint('Playback failed: $e');
      throw RecordingPermissionException('Failed to play recording: $e');
    }
  }

  Future<void> stopPlaying() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Failed to stop playback: $e');
      throw RecordingPermissionException('Failed to stop playback: $e');
    }
  }

  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await stopRecording();
      }
      await _recorder.dispose();
      await _player.dispose();
      _isRecorderInitialized = false;
      debugPrint('Audio service disposed successfully');
    } catch (e) {
      debugPrint('Failed to dispose audio service: $e');
      throw RecordingPermissionException('Failed to dispose recorder: $e');
    }
  }
}