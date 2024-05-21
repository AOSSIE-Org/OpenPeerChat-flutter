import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../components/message_panel.dart';
import '../classes/Msg.dart';
import '../classes/Global.dart';
import 'dart:convert';
import 'package:pointycastle/asymmetric/api.dart';
import '../components/view_file.dart';
import '../encyption/rsa.dart';  // Assuming this is the correct path for your RSA functions

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.converser}) : super(key: key);

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

  ScrollController _scrollController = ScrollController();

  @override
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
      // Since there can be a long list of messages, the scroll controller
      // auto scrolls to the bottom of the list.
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
                // Decrypt the message if it is
                String displayMessage = messageList[index].message;

                if(Global.myPrivateKey != null) {
                  RSAPrivateKey privateKey = Global.myPrivateKey!;
                  dynamic data = jsonDecode(messageList[index].message);
                  print(data);

                  if (data['type'] == 'text') {
                    Uint8List encryptedBytes = base64Decode(
                        data['data']);
                    Uint8List decryptedBytes = rsaDecrypt(
                        privateKey, encryptedBytes);


                    displayMessage = utf8.decode(decryptedBytes);
                    print("decrypted message: $displayMessage");
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
                          messageList[index].msgtype + ": " + displayMessage,
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
                  }
                  else if (data['type'] == 'file') {

                    String fileName =
                        data['fileName'];
                    print("file name: $fileName");
                    String filePath =
                    data['filePath'];

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
                            messageList[index].msgtype + ": " + fileName,
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
                          trailing: IconButton(
                            icon: Icon(Icons.file_open),
                            onPressed: () {
                              print("file path: $filePath");
                              //save file to downloads
                              FilePreview.openFile(filePath);

                            },
                          ),
                        ),
                      );

                  }
                  // else {
                  //   displayMessage = messageList[index].message;
                  // }
                }

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
