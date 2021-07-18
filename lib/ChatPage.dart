import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_nearby_connections_example/Payload.dart';
import 'package:nanoid/nanoid.dart';
import 'package:intl/intl.dart';
import 'Conversation.dart';
import 'Msg.dart';
import 'Global.dart';

class ChatPage extends StatefulWidget {
  ChatPage(this.device);

  final Device device;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  ScrollController _scrollController = new ScrollController();

  Widget build(BuildContext context) {
    final myController = TextEditingController();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Chat with ' + widget.device.deviceName),
        ),

        body: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child:Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*.8,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      // reverse: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: Global.conversations[widget.device.deviceId] == null
                          ? 0
                          : Global
                          .conversations[widget.device.deviceId]!.ListOfMsgs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 55,
                          child: Global.conversations[widget.device.deviceId]!
                              .ListOfMsgs[index].msgtype ==
                              'sent'
                              ? Bubble(
                            margin: BubbleEdges.only(top: 10),
                            nip: BubbleNip.rightTop,
                            color: Color(0xffd1c4e9),
                            child: Text(
                                Global.conversations[widget.device.deviceId]!
                                    .ListOfMsgs[index].msgtype +
                                    ": " +
                                    Global.conversations[widget.device.deviceId]!
                                        .ListOfMsgs[index].message,
                                textAlign: TextAlign.right),
                          )
                              : Bubble(
                            nip: BubbleNip.leftTop,
                            color: Color(0xff80DEEA),
                            margin: BubbleEdges.only(top: 10),
                            child: Text(
                              Global.conversations[widget.device.deviceId]!
                                  .ListOfMsgs[index].msgtype +
                                  ": " +
                                  Global.conversations[widget.device.deviceId]!
                                      .ListOfMsgs[index].message,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  TextFormField(
                    controller: myController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'Send Message?',
                      labelText: 'Send Message ',
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        var msgId= nanoid(21);
                        var data={
                          "sender": "$Global.myName",
                          "receiver":"$widget.device.deviceName",
                          "message":"$myController.text",
                          "id":"$msgId",
                          "Timestamp": "$DateTime.now().toUtc().toString()",
                          "type":"Payload"
                        };
                      var   Mesagedata= data.toString();
                        // Global.nearbyService!
                        //     .sendMessage(widget.device.deviceId, Mesagedata);
                        Global.cache[msgId]=Payload(msgId,Global.myName, widget.device.deviceName,myController.text,DateTime.now().toUtc().toString());
                        // Global.devices.forEach((element) {
                        //   Global.nearbyService!
                        //       .sendMessage(element.deviceId, Mesagedata);
                        // });
                        // Global.nearbyService!
                        //     .sendMessage(widget.device.deviceId, myController.text);
                        setState(() {
                          if (Global.conversations[widget.device.deviceId] == null)
                            Global.conversations[widget.device.deviceId] =
                            new Conversation();
                          Global.conversations[widget.device.deviceId]?.ListOfMsgs.add(
                              new Msg(
                                  widget.device.deviceId, myController.text, "sent"));

                        });
                      },
                      child: Text("send")),
                ],
              ),))
    );

  }
}