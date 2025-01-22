import 'dart:async';
import 'dart:io';

class FileTransferService {
  /// StreamController for transfer progress
  final StreamController<double> _progressController = StreamController<double>.broadcast();

  /// Get the progress stream
  Stream<double> get progressStream => _progressController.stream;

  /// Upload a file with progress tracking
  Future<void> uploadFile({
    required File file,
    required Function onComplete,
    required Function(String error) onError,
  }) async {
    try {
      final totalBytes = await file.length();
      int bytesTransferred = 0;

      // Simulating chunked file upload
      final chunkSize = 1024 * 512; // 512 KB
      final fileStream = file.openRead();

      await for (final chunk in fileStream) {
        bytesTransferred += chunk.length;

        // Update progress
        final progress = bytesTransferred / totalBytes;
        _progressController.add(progress);

        // Simulate sending the chunk
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Notify completion
      onComplete();
    } catch (e) {
      // Notify error
      onError(e.toString());
    } finally {
      _progressController.close();
    }
  }

  /// Download a file with progress tracking
  Future<void> downloadFile({
    required String savePath,
    required int totalBytes,
    required Stream<List<int>> incomingStream,
    required Function onComplete,
    required Function(String error) onError,
  }) async {
    try {
      final file = File(savePath).openWrite();
      int bytesReceived = 0;

      // Write incoming chunks to the file
      await for (final chunk in incomingStream) {
        bytesReceived += chunk.length;
        file.add(chunk);

        // Update progress
        final progress = bytesReceived / totalBytes;
        _progressController.add(progress);
      }

      await file.close();
      onComplete();
    } catch (e) {
      onError(e.toString());
    } finally {
      _progressController.close();
    }
  }

  /// Dispose the StreamController
  void dispose() {
    _progressController.close();
  }
}
