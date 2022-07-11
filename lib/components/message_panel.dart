import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';

import '../classes/Global.dart';
import '../classes/Msg.dart';
import '../classes/Payload.dart';
import '../database/DatabaseHelper.dart';

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
            var data = {
              "sender": "$Global.myName",
              "receiver": "$widget.device.deviceName",
              "message": "$myController.text",
              "id": "$msgId",
              "Timestamp": "${DateTime.now().toUtc().toString()}",
              "type": "Payload"
            };
            Global.cache[msgId] = Payload(
                msgId,
                Global.myName,
                widget.converser,
                myController.text,
                DateTime.now().toUtc().toString());
            insertIntoMessageTable(Payload(
                msgId,
                Global.myName,
                widget.converser,
                myController.text,
                DateTime.now().toUtc().toString()));
            // Global.devices.forEach((element) {
            //   Global.nearbyService!
            //       .sendMessage(element.deviceId, Mesagedata);
            // });
            // Global.nearbyService!
            //     .sendMessage(widget.device.deviceId, myController.text);
            setState(() {
              // Global.conversations[widget.device.deviceName]![msgId](
              //     new Msg(
              //         widget.device.deviceId, myController.text, "sent"));
              Provider.of<Global>(context, listen: false).sentToConversations(
                  Msg(myController.text, "sent", data["Timestamp"]!, msgId),
                  widget.converser);
              // if (Global.conversations[widget.converser] == null) {
              //   Global.conversations[widget.converser] = {};
              // }
              // Global.conversations[widget.converser]![msgId] =
              //     Msg(myController.text, "sent", data["Timestamp"]!, msgId);

              // insertIntoConversationsTable(
              //     Msg(myController.text, "sent", data["Timestamp"]!, msgId),
              //     widget.converser);
            });
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
