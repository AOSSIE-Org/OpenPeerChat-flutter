import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class FilePreview {
  /// Opens a file based on the platform and file path.
  static Future<void> openFile(String path) async {
    if (Platform.isIOS) {
      await _openFileIOS(path);
    } else if (Platform.isAndroid) {
      if (path.contains("Android/data")) {
        await _openAndroidPrivateFile(path);
      } else if (path.contains("DCIM")) {
        if (path.endsWith(".jpg") || path.endsWith(".jpeg") || path.endsWith(".png")) {
          await _openAndroidExternalImage(path);
        } else if (path.endsWith(".mp4")) {
          await _openAndroidExternalVideo(path);
        } else if (path.endsWith(".mp3") || path.endsWith(".wav")) {
          await _openAndroidExternalAudio(path);
        } else {
          await _openAndroidExternalFile(path);
        }
      } else {
        await _openAndroidOtherAppFile(path);
      }
    }
  }

  /// Opens a file on iOS.
  static Future<void> _openFileIOS(String path) async {
    await OpenFilex.open(path);
  }

  /// Opens a private file on Android (e.g., within `Android/data`).
  static Future<void> _openAndroidPrivateFile(String path) async {
    await OpenFilex.open(path);
  }

  /// Opens a file in another app on Android (if outside private folders).
  static Future<void> _openAndroidOtherAppFile(String path) async {
    if (await _requestPermission(Permission.manageExternalStorage)) {
      await OpenFilex.open(path);
    }
  }

  /// Opens an external image file on Android.
  static Future<void> _openAndroidExternalImage(String path) async {
    if (await _requestPermission(Permission.photos)) {
      await OpenFilex.open(path);
    }
  }

  /// Opens an external video file on Android.
  static Future<void> _openAndroidExternalVideo(String path) async {
    if (await _requestPermission(Permission.videos)) {
      await OpenFilex.open(path);
    }
  }

  /// Opens an external audio file on Android.
  static Future<void> _openAndroidExternalAudio(String path) async {
    if (await _requestPermission(Permission.audio)) {
      await OpenFilex.open(path);
    }
  }

  /// Opens any external file on Android (requires manage storage permission).
  static Future<void> _openAndroidExternalFile(String path) async {
    if (await _requestPermission(Permission.manageExternalStorage)) {
      await OpenFilex.open(path);
    }
  }

  /// Requests a specific permission and returns whether it is granted.
  static Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }
}
