/// This is the ChatPage. This screen consists of the chat with a single device
/// with whom we had chat. The messages are saved in the database and
/// retrieved from the same using the Provider state management as it allows
/// real time messaging.
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/message_panel.dart';
import 'package:provider/provider.dart';
import '../classes/Msg.dart';
import '../classes/Global.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.converser});

  final String converser;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<Msg> messageList = [];
  TextEditingController myController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  ScrollController _scrollController = new ScrollController();

  Widget build(BuildContext context) {
    /// If we have previously conversed with the device, it is going to store
    /// the conversations in the messageList
    if (Provider.of<Global>(context).conversations[widget.converser] != null) {
      messageList = [];
      Provider.of<Global>(context)
          .conversations[widget.converser]!
          .forEach((key, value) {
        messageList.add(value);
      });
      // Since there can be long list of message, the scroll controller
      // auto scrolls to bottom of the list.
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 50,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Chat with ' + widget.converser),
      ),
      body: Column(
        children: [
          Expanded(
            child: messageList.isEmpty
                ? Center(
                    child: Text('No messages yet'),
                  )
                : ListView.builder(
                    // Builder to view messages chronologically
                    shrinkWrap: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: messageList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Bubble(
                        margin: BubbleEdges.only(top: 10),
                        nip: messageList[index].msgtype == 'sent'
                            ? BubbleNip.rightTop
                            : BubbleNip.leftTop,
                        color: messageList[index].msgtype == 'sent'
                            ? Color(0xffd1c4e9)
                            : Color(0xff80DEEA),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            messageList[index].msgtype +
                                ": " +
                                messageList[index].message,
                            textAlign: messageList[index].msgtype == 'sent'
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                          subtitle: Text(
                            dateFormatter(
                              timeStamp: messageList[index].timestamp,
                            ),
                            textAlign: messageList[index].msgtype == 'sent'
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          MessagePanel(converser: widget.converser),
        ],
      ),
    );
  }
}

// Function to format the date in viewable form
String dateFormatter({required String timeStamp}) {
  // From timestamp to readable date and hour minutes
  DateTime dateTime = DateTime.parse(timeStamp);
  String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
  String formattedTime = DateFormat('hh:mm aa').format(dateTime);
  return formattedDate + " " + formattedTime;
}
