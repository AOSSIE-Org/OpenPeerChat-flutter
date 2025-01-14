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

class ChatPage extends StatefulWidget {
  String converser;
  ChatPage({Key? key, required this.converser}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  List<Msg> messageList = [];

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
      }
    });
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
            icon: Icon(Icons.download),
            onPressed: () async {
              await exportChatHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chat history exported successfully!')),
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

  Widget _buildFileBubble(Msg msg) {
    dynamic data = jsonDecode(msg.message);
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
          onPressed: () => FilePreview.openFile(filePath),
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
