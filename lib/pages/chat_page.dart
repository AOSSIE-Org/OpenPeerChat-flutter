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
  String converser;
  ChatPage({Key? key, required this.converser}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  List<Msg> messageList = [];

  double fileTransferProgress = 0.0;
  bool isTransferring = false;

  TextEditingController myController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  bool _isPlaying = false;
  final ScrollController _scrollController = ScrollController();
  bool _isFirstBuild = true;  // Add this flag


  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
  @override
  void initState() {
    super.initState();

    _subscribeToProfileUpdates();
  }

  void _subscribeToProfileUpdates() {
    Global.profileNameStream.listen((updatedName) {
      if (widget.converser == Global.myName) {
        setState(() {
          widget.converser = updatedName;
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );

    _audioPlayer.setReleaseMode(ReleaseMode.stop); // Stop when completed
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _currentlyPlayingId = null;
          _isPlaying = false;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    if (Provider.of<Global>(context).conversations[widget.converser] != null) {
      messageList = [];
      Provider.of<Global>(context)
          .conversations[widget.converser]!
          .forEach((key, value) {
        messageList.add(value);
      });
      if (_isFirstBuild) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
          _isFirstBuild = false;
        });

      }
    });
  }

  Future<void> _startFileTransfer(String filePath) async {
    setState(() {
      isTransferring = true;
      fileTransferProgress = 0.0;
    });

    // Simulating file transfer with a loop for progress update
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50)); // Simulate transfer delay
      setState(() {
        fileTransferProgress = i / 100.0;
      });
    }

    setState(() {
      isTransferring = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File transfer completed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    messageList = _getMessageList(context);

    Map<String, List<Msg>> groupedMessages = _groupMessagesByDate(messageList);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.converser),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await exportChatHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat history exported successfully!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messageList.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(

                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: groupedMessages.keys.length,
                    itemBuilder: (context, index) {
                      String date = groupedMessages.keys.elementAt(index);
                      return _buildMessageGroup(date, groupedMessages[date]!);
                    },
                  ),
          ),
          if (isTransferring)
            LinearProgressIndicator(
              value: fileTransferProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          MessagePanel(converser: widget.converser),
        ],
      ),
    );
  }

  List<Msg> _getMessageList(BuildContext context) {
    var conversation = Provider.of<Global>(context).conversations[widget.converser];
    if (conversation == null) return [];
    return conversation.values.toList();
  }

  Map<String, List<Msg>> _groupMessagesByDate(List<Msg> messages) {
    Map<String, List<Msg>> groupedMessages = {};
    for (var msg in messages) {
      String date = DateFormat('dd/MM/yyyy').format(DateTime.parse(msg.timestamp));
      groupedMessages.putIfAbsent(date, () => []).add(msg);
    }
    return groupedMessages;
  }

  Widget _buildMessageGroup(String date, List<Msg> messages) {
    return Column(
      children: [
        _buildDateHeader(date),
        ...messages.map((msg) => _buildMessageBubble(msg)),
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Msg msg) {
    String displayMessage = msg.message;
    if (msg.msgtype == 'text' && Global.myPrivateKey != null) {
      displayMessage = _decryptMessage(msg.message);
    }
    return Column(
      crossAxisAlignment: msg.msgtype == 'sent'
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: msg.msgtype == 'sent'
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Bubble(
            padding: const BubbleEdges.all(12),
            margin: const BubbleEdges.only(top: 10),
            style: BubbleStyle(
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.5),
            ),
            radius: const Radius.circular(10),
            color: msg.msgtype == 'sent'
                ? const Color(0xffd1c4e9)
                : const Color(0xff80DEEA),
            child: msg.message.contains('file')
                ? _buildFileBubble(msg)
                : Text(displayMessage, style: const TextStyle(color: Colors.black87)),
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
  }


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
          MessagePanel(
            converser: widget.converser,
            onMessageSent: () {
              // Scroll to bottom when new message is sent
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            },
          ),
        ],
      ),
    );
  }
  Widget _buildVoiceMessageBubble(Msg msg) {
    final data = jsonDecode(msg.message);
    final bool isCurrentlyPlaying = _currentlyPlayingId == msg.id;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: msg.msgtype == 'sent'
                  ? Colors.deepPurple.withOpacity(0.2)
                  : Colors.cyan.withOpacity(0.2),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                isCurrentlyPlaying && _isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: msg.msgtype == 'sent'
                    ? Colors.deepPurple
                    : Colors.cyan[700],
                size: 24,
              ),
              onPressed: () => _handleVoicePlayback(msg),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Waveform/Progress Bar
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: StreamBuilder<Duration>(
                      stream: _audioPlayer.onPositionChanged,
                      builder: (context, snapshot) {
                        return FutureBuilder<Duration?>(
                          future: _audioPlayer.getDuration(),
                          builder: (context, durationSnapshot) {
                            final totalDuration = durationSnapshot.data?.inMilliseconds ?? 1;
                            return LinearProgressIndicator(
                              value: isCurrentlyPlaying && snapshot.hasData
                                  ? snapshot.data!.inMilliseconds / totalDuration
                                  : 0,
                              backgroundColor: msg.msgtype == 'sent'
                                  ? Colors.deepPurple.withOpacity(0.1)
                                  : Colors.cyan.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                msg.msgtype == 'sent'
                                    ? Colors.deepPurple
                                    : Colors.cyan[700]!,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Duration Text
                StreamBuilder<Duration>(
                  stream: _audioPlayer.onPositionChanged,
                  builder: (context, snapshot) {
                    return FutureBuilder<Duration?>(
                      future: _audioPlayer.getDuration(),
                      builder: (context, durationSnapshot) {
                        String duration = '0:00';
                        if (isCurrentlyPlaying && snapshot.hasData) {
                          duration = _formatDuration(snapshot.data!);
                        } else if (durationSnapshot.hasData) {
                          duration = _formatDuration(durationSnapshot.data!);
                        }
                        return Text(
                          duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: msg.msgtype == 'sent'
                                ? Colors.deepPurple[700]
                                : Colors.cyan[900],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVoicePlayback(Msg msg) async {
    try {
      final data = jsonDecode(msg.message);
      final String filePath = data['filePath'];

      if (_currentlyPlayingId == msg.id && _isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        if (_currentlyPlayingId != msg.id) {
          await _audioPlayer.stop();
          await _audioPlayer.setSource(DeviceFileSource(filePath));
          await _audioPlayer.resume();
        } else {
          await _audioPlayer.resume();
        }
        setState(() {
          _currentlyPlayingId = msg.id;
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error playing voice message')),
      );
    }
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
            style: const TextStyle(color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.file_open, color: Colors.black87),
          onPressed: () => _startFileTransfer(filePath),
        ),
      ],
    );
  }

  String _decryptMessage(String message) {
    try {
      RSAPrivateKey privateKey = Global.myPrivateKey!;
      dynamic data = jsonDecode(message);
      Uint8List encryptedBytes = base64Decode(data['data']);
      Uint8List decryptedBytes = rsaDecrypt(privateKey, encryptedBytes);
      return utf8.decode(decryptedBytes);
    } catch (e) {
      return "[Error decrypting message]";
    }
  }
}

String dateFormatter({required String timeStamp}) {
  DateTime dateTime = DateTime.parse(timeStamp);
  return DateFormat('hh:mm aa').format(dateTime);
}
