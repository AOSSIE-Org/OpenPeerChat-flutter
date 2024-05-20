/// This component is used in the ChatPage.
/// It is the message bar where the message is typed on and sent to
/// connected devices.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nanoid/nanoid.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:provider/provider.dart';

import '../classes/Global.dart';
import '../classes/Msg.dart';
import '../classes/Payload.dart';
import '../database/DatabaseHelper.dart';
import '../encyption/rsa.dart';

class MessagePanel extends StatefulWidget {
  const MessagePanel({Key? key, required this.converser}) : super(key: key);
  final String converser;

  @override
  State<MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  TextEditingController myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: myController,
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        hintText: 'Send Message?',
        labelText: 'Send Message ',
        suffixIcon: IconButton(
          onPressed: () {
            var msgId = nanoid(21);
            if (myController.text.isEmpty) {
              return;
            }
            RSAPublicKey publicKey = Global.myPublicKey!;
            // Encrypt the message
            Uint8List encryptedMessage = rsaEncrypt(publicKey, Uint8List.fromList(utf8.encode(myController.text)));
            // Encode the message to base64
            String encodedMessage = base64.encode(encryptedMessage);
            String date = DateTime.now().toUtc().toString();
            Global.cache[msgId] = Payload(
              msgId,
              Global.myName,
              widget.converser,
                myController.text,
              date,
            );
            insertIntoMessageTable(
              Payload(
                msgId,
                Global.myName,
                widget.converser,
                encodedMessage,
                date,
              ),
            );

            Provider.of<Global>(context, listen: false).sentToConversations(
              Msg(encodedMessage, "sent", date, msgId),
              widget.converser,
            );

            // refreshMessages();
            myController.clear();
          },
          icon: Icon(
            Icons.send,
          ),
        ),
      ),
    );
  }
}
