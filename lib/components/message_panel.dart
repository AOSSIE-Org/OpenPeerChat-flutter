import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nanoid/nanoid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:provider/provider.dart';
import '../classes/global.dart';
import '../classes/msg.dart';
import '../classes/payload.dart';
import '../database/database_helper.dart';
import '../encyption/rsa.dart';
import 'audio_service.dart';
import 'view_file.dart';

/// This component is used in the ChatPage.
/// It is the message bar where the message is typed on and sent to
/// connected devices.

class MessagePanel extends StatefulWidget {
  const MessagePanel({Key? key, required this.converser}) : super(key: key);
  final String converser;

  @override
  State<MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  TextEditingController myController = TextEditingController();
  File _selectedFile = File('');
  late final AudioService _audioService;
  bool _isRecording = false;
  String? _currentRecordingPath;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      await _audioService.initRecorder();
    } catch (e) {
      // Show error dialog or snackbar to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              openAppSettings(); // From permission_handler package
            },
          ),
        ),
      );
    }
  }

  Future<void> _handleVoiceRecordingStart() async {
    try {
      _currentRecordingPath = await _audioService.startRecording();
      setState(() => _isRecording = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  Future<void> _handleVoiceRecordingEnd() async {
    if (!_isRecording) return;

    try {
      await _audioService.stopRecording();
      setState(() => _isRecording = false);
      if (_currentRecordingPath != null) {
         _sendVoiceMessage(File(_currentRecordingPath!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop recording: $e')),
        );
      }
    }
  }


  @override
  void dispose() {
    myController.dispose();
    _audioService.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 5,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: myController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () => _navigateToFilePreviewPage(context),
          ),
          GestureDetector(
            onLongPressStart: (_) => _handleVoiceRecordingStart(),
            onLongPressEnd: (_) => _handleVoiceRecordingEnd(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red.withOpacity(0.1) : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                color: _isRecording ? Colors.red : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(context),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    var msgId = nanoid(21);
    if (myController.text.isEmpty) {
      return;
    }
    // Encode the message to base64

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
    // Encrypt the message
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

    // refreshMessages();
    myController.clear();
  }

  /// This function is used to navigate to the file preview page and check the file size.
  void _navigateToFilePreviewPage(BuildContext context) async {
    //max size of file is 30 MB
    double sizeKbs = 0;
    const int maxSizeKbs = 30 * 1024;
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if(result != null) {
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
                  //file size in MB
                  title: Text('File Size: ${(sizeKbs / 1024).ceil()} MB'),
                  subtitle: const Text(
                      'File size should not exceed 30 MB'),
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

//this function is used to open the file preview dialog
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

                  title: Text('File Name: ${_selectedFile.path
                      .split('/')
                      .last}', overflow: TextOverflow.ellipsis,),
                  subtitle: Text(
                      'File Size: ${(sizeKbs / 1024).floor()} MB'),
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


  void _sendVoiceMessage(File audioFile) async {
    final String msgId = nanoid(21);
    final String fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.aac';

    final String data = jsonEncode({
      "sender": Global.myName,
      "type": "voice",
      "fileName": fileName,
      "filePath": audioFile.path,
    });

    final String date = DateTime.now().toUtc().toString();
    final payload = Payload(msgId, Global.myName, widget.converser, data, date);

    Global.cache[msgId] = payload;
     insertIntoMessageTable(payload);

    if (!mounted) return;
    Provider.of<Global>(context, listen: false).sentToConversations(
      Msg(data, "sent", date, msgId),
      widget.converser,
    );
  }

  /// This function is used to send the file message.
  void _sendFileMessage(BuildContext context, File file) async{
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
