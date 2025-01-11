import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:nanoid/nanoid.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:provider/provider.dart';
import '../classes/global.dart';
import '../classes/msg.dart';
import '../classes/payload.dart';
import '../database/database_helper.dart';
import '../encyption/rsa.dart';
import 'view_file.dart';
import '../classes/audio_playback.dart';
import '../classes/audio_recording.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermissions() async {
  var micStatus = await Permission.microphone.request();
  return micStatus.isGranted;
}

class MessagePanel extends StatefulWidget {
  const MessagePanel({Key? key, required this.converser}) : super(key: key);
  final String converser;

  @override
  State<MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  TextEditingController myController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _recordingFilePath;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  File _selectedFile = File('');

  void initState() {
    super.initState();
    _audioRecorder.initRecorder();
    _audioPlayer.initPlayer();
  }

  void _startRecording() async {
    if (await requestPermissions()) {
      String? filePath = await _audioRecorder.startRecording();
      setState(() {
        _recordingFilePath = filePath;
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      _startRecordingTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied.')),
      );
    }
  }

  void _stopRecording({bool cancel = false}) async {
    await _audioRecorder.stopRecording();
    setState(() {
      _isRecording = false;
      if (cancel) {
        _recordingFilePath = null;
      }
    });

    if (!cancel && _recordingFilePath != null) {
      _confirmAudioMessage();
    }
  }

  void _startRecordingTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
        return true;
      }
      return false;
    });
  }

  void _confirmAudioMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Audio Message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Duration: ${_recordingDuration.inSeconds} seconds'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _playAudio(),
                  ),
                  Lottie.asset('assets/audioAnimation.json',
                      height: 50, width: 50),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _recordingFilePath = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _sendAudioMessage();
              },
              child: const Text('Send'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _playAudio() {
    if (_recordingFilePath != null) {
      _audioPlayer.playAudio(_recordingFilePath!);
    }
  }

  void _sendAudioMessage() async {
  if (_recordingFilePath == null) return;

  // Read the audio file content
  Uint8List audioBytes = await File(_recordingFilePath!).readAsBytes();

  // Encrypt the audio file content
  RSAPublicKey publicKey = Global.myPublicKey!;
  Uint8List encryptedAudio = rsaEncrypt(publicKey, audioBytes);

  // Generate a unique ID for the message
  var msgId = nanoid(21);
  String fileName = _recordingFilePath!.split('/').last;

  // Create the encrypted message payload
  String myData = jsonEncode({
    "sender": Global.myName,
    "type": "audio",
    "fileName": fileName,
    "data": base64Encode(encryptedAudio),
  });

  String date = DateTime.now().toUtc().toString();

  // Add the message to the local cache
  Global.cache[msgId] = Payload(
    msgId,
    Global.myName,
    widget.converser,
    myData,
    date,
  );

  // Save the message to the database
  insertIntoMessageTable(
    Payload(
      msgId,
      Global.myName,
      widget.converser,
      myData,
      date,
    ),
  );

  // Update the conversations in the UI
  Provider.of<Global>(context, listen: false).sentToConversations(
    Msg(myData, "sent", date, msgId),
    widget.converser,
  );

  // Provide feedback to the user
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Audio message sent!')),
  );

  // Reset the recording state
  setState(() {
    _recordingFilePath = null;
    _recordingDuration = Duration.zero;
  });
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
              GestureDetector(
                onLongPress: _startRecording,
                onLongPressUp: () => _stopRecording(cancel: false),
                onTapCancel: () => _stopRecording(cancel: true),
                child: Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  color: _isRecording ? Colors.red : Colors.black,
                ),
              ),
              IconButton(
                onPressed: () => _sendMessage(context),
                icon: const Icon(Icons.send),
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
