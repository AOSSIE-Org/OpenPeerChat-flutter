import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart'; // ADDED
import 'package:flutter/services.dart';
import 'package:nanoid/nanoid.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:provider/provider.dart';
import '../classes/global.dart';
import '../classes/msg.dart';
import '../classes/payload.dart';
import '../database/database_helper.dart';
import '../encyption/rsa.dart';
import 'view_file.dart';

class MessagePanel extends StatefulWidget {
  const MessagePanel({Key? key, required this.converser}) : super(key: key);
  final String converser;

  @override
  State<MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  TextEditingController myController = TextEditingController();
  File _selectedFile = File('');
  FlutterSoundRecorder? _recorder; // ADDED
  bool _isRecording = false; // ADDED
  String? _recordedFilePath; // ADDED

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder(); // ADDED
    _initializeRecorder(); // ADDED
  }

  @override
  void dispose() {
    _recorder?.closeRecorder(); // ADDED
    _recorder = null; // ADDED
    super.dispose();
  }

  // ADDED: Initialize audio recorder
  Future<void> _initializeRecorder() async {
    await _recorder?.openRecorder();
    await _recorder?.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: null,
        controller: myController,
        decoration: InputDecoration(
          icon: const Icon(Icons.person),
          hintText: 'Send Message?',
          labelText: 'Send Message',
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _navigateToFilePreviewPage(context),
                icon: const Icon(Icons.attach_file),
              ),
              IconButton(
                onPressed: _toggleRecording, // ADDED
                icon: Icon(
                  _isRecording ? Icons.mic_off : Icons.mic, // ADDED
                  color: _isRecording ? Colors.red : null, // ADDED
                ),
              ),
              IconButton(
                onPressed: () => _sendMessage(context),
                icon: const Icon(
                  Icons.send,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    var msgId = nanoid(21);
    if (myController.text.isEmpty) {
      return;
    }

    String data = jsonEncode({
      "sender": Global.myName,
      "type": "text",
      "data": myController.text,
    });

    String date = DateTime.now().toUtc().toString();

    Global.cache[msgId] = Payload(
      msgId,
      Global.myName,
      widget.converser,
      data,
      date,
    );
    insertIntoMessageTable(
      Payload(
        msgId,
        Global.myName,
        widget.converser,
        data,
        date,
      ),
    );

    RSAPublicKey publicKey = Global.myPublicKey!;
    Uint8List encryptedMessage = rsaEncrypt(
        publicKey, Uint8List.fromList(utf8.encode(myController.text)));

    String myData = jsonEncode({
      "sender": Global.myName,
      "type": "text",
      "data": base64Encode(encryptedMessage),
    });

    Provider.of<Global>(context, listen: false).sentToConversations(
      Msg(myData, "sent", date, msgId),
      widget.converser,
    );

    myController.clear();
  }

  // ADDED: Start and stop audio recording
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder?.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });
      if (path != null) {
        _sendAudioMessage(context, path); // Send the recorded audio
      }
    } else {
      await _recorder?.startRecorder(
        codec: Codec.aacMP4,
        toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      setState(() {
        _isRecording = true;
      });
    }
  }

  // ADDED: Send recorded audio as a message
  void _sendAudioMessage(BuildContext context, String filePath) {
    var msgId = nanoid(21);
    String fileName = filePath.split('/').last;

    String data = jsonEncode({
      "sender": Global.myName,
      "type": "audio",
      "fileName": fileName,
      "filePath": filePath,
    });

    String date = DateTime.now().toUtc().toString();
    Global.cache[msgId] = Payload(
      msgId,
      Global.myName,
      widget.converser,
      data,
      date,
    );
    insertIntoMessageTable(
      Payload(
        msgId,
        Global.myName,
        widget.converser,
        data,
        date,
      ),
    );

    Provider.of<Global>(context, listen: false).sentToConversations(
      Msg(data, "sent", date, msgId),
      widget.converser,
    );
  }

  // Existing file picker and sender logic
  void _navigateToFilePreviewPage(BuildContext context) async {
    double sizeKbs = 0;
    const int maxSizeKbs = 30 * 1024;
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      sizeKbs = result.files.single.size / 1024;
    }

    if (sizeKbs > maxSizeKbs) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('File Size Exceeded'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('File Size: ${(sizeKbs / 1024).ceil()} MB'),
                  subtitle: const Text('File size should not exceed 30 MB'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('File Preview'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'File Name: ${_selectedFile.path.split('/').last}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('File Size: ${(sizeKbs / 1024).floor()} MB'),
                ),
                ElevatedButton(
                  onPressed: () => FilePreview.openFile(_selectedFile.path),
                  child: const Text('Open File'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendFileMessage(context, _selectedFile);
                },
                icon: const Icon(
                  Icons.send,
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _sendFileMessage(BuildContext context, File file) async {
    var msgId = nanoid(21);

    String fileName = _selectedFile.path.split('/').last;
    String filePath = file.path;

    String data = jsonEncode({
      "sender": Global.myName,
      "type": "file",
      "fileName": fileName,
      "filePath": filePath,
    });

    String date = DateTime.now().toUtc().toString();
    Global.cache[msgId] = Payload(
      msgId,
      Global.myName,
      widget.converser,
      data,
      date,
    );
    insertIntoMessageTable(
      Payload(
        msgId,
        Global.myName,
        widget.converser,
        data,
        date,
      ),
    );

    Provider.of<Global>(context, listen: false).sentToConversations(
      Msg(data, "sent", date, msgId),
      widget.converser,
    );
  }
}
