import 'dart:typed_data';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../components/message_panel.dart';
import '../classes/msg.dart';
import '../classes/global.dart';
import 'dart:convert';
import 'package:pointycastle/asymmetric/api.dart';
import '../components/view_file.dart';
import '../encyption/rsa.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.converser}) : super(key: key);

  final String converser;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<Msg> messageList = [];
  TextEditingController myController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  bool _isPlaying = false;


  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final ScrollController _scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    if (Provider.of<Global>(context).conversations[widget.converser] != null) {
      messageList = [];
      Provider.of<Global>(context)
          .conversations[widget.converser]!
          .forEach((key, value) {
        messageList.add(value);
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 50,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    Map<String, List<Msg>> groupedMessages = {};
    for (var msg in messageList) {
      String date = DateFormat('dd/MM/yyyy').format(DateTime.parse(msg.timestamp));
      if (groupedMessages[date] == null) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(msg);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.converser),
      ),
      body: Column(
        children: [
          Expanded(
            child: messageList.isEmpty
                ? const Center(
              child: Text('No messages yet'),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: groupedMessages.keys.length,
              itemBuilder: (BuildContext context, int index) {
                String date = groupedMessages.keys.elementAt(index);
                return Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          date,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ...groupedMessages[date]!.map((msg) {
                      String displayMessage = msg.message;
                      if (Global.myPrivateKey != null) {
                        RSAPrivateKey privateKey = Global.myPrivateKey!;
                        dynamic data = jsonDecode(msg.message);
                        if (data['type'] == 'text') {
                          Uint8List encryptedBytes = base64Decode(data['data']);
                          Uint8List decryptedBytes = rsaDecrypt(privateKey, encryptedBytes);
                          displayMessage = utf8.decode(decryptedBytes);
                        }
                      }
                      return Column(
                        crossAxisAlignment: msg.msgtype == 'sent' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: msg.msgtype == 'sent' ? Alignment.centerRight : Alignment.centerLeft,
                            child: Bubble(
                              padding: const BubbleEdges.all(12),
                              margin: const BubbleEdges.only(top: 10),
                              //add shadow
                              style: BubbleStyle(
                                elevation: 3,
                                  shadowColor: Colors.black.withOpacity(0.5),
                              ),
                              // nip: msg.msgtype == 'sent' ? BubbleNip.rightTop : BubbleNip.leftTop,
                              radius: const Radius.circular(10),
                              color: msg.msgtype == 'sent' ? const Color(0xffd1c4e9) : const Color(0xff80DEEA),
                              child: msg.message.contains('file') ? _buildFileBubble(msg) : Text(
                                displayMessage,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 10),
                            child: Text(
                              dateFormatter(timeStamp: msg.timestamp),
                              style: const TextStyle(color: Colors.black54, fontSize: 10),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          MessagePanel(converser: widget.converser),
        ],
      ),
    );
  }
  Widget _buildVoiceMessageBubble(Msg msg) {
    final data = jsonDecode(msg.message);
    final bool isCurrentlyPlaying = _currentlyPlayingId == msg.id;

    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isCurrentlyPlaying && _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black87,
            ),
            onPressed: () => _handleVoicePlayback(msg),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voice Message',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isCurrentlyPlaying)
                  const LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVoicePlayback(Msg msg) async {
    final data = jsonDecode(msg.message);
    final String filePath = data['filePath'];

    if (_currentlyPlayingId == msg.id && _isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      if (_currentlyPlayingId != msg.id) {
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(filePath));
      } else {
        await _audioPlayer.resume();
      }
      setState(() {
        _currentlyPlayingId = msg.id;
        _isPlaying = true;
      });
    }

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _currentlyPlayingId = null;
          _isPlaying = false;
        });
      }
    });
  }

  Widget _buildFileBubble(Msg msg) {
    dynamic data = jsonDecode(msg.message);
    if (data['type'] == 'voice') {
      return _buildVoiceMessageBubble(msg);
    }
    String fileName = data['fileName'];
    String filePath = data['filePath'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            fileName,
            style: const TextStyle(
              color: Colors.black87,
            ),
            overflow: TextOverflow.visible,

          ),
        ),
        IconButton(
          icon: const Icon(Icons.file_open, color: Colors.black87),
          onPressed: () {
            FilePreview.openFile(filePath);
          },
        ),
      ],
    );
  }
}

String dateFormatter({required String timeStamp}) {
  DateTime dateTime = DateTime.parse(timeStamp);
  String formattedTime = DateFormat('hh:mm aa').format(dateTime);
  return formattedTime;
}
