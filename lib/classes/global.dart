import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointycastle/export.dart';
import '../database/database_helper.dart';
import '../p2p/adhoc_housekeeping.dart';
import 'msg.dart';


class Global extends ChangeNotifier {
  static RSAPrivateKey? myPrivateKey;
  static RSAPublicKey? myPublicKey;
  static NearbyService? nearbyService;
  static StreamSubscription? deviceSubscription;
  static StreamSubscription? receivedDataSubscription;

  List<Device> devices = [];
  List<Device> connectedDevices = [];
  static List<Msg> messages = [];
  static Map<String, RSAPublicKey> publicKeys = {};
  Map<String, Map<String, Msg>> conversations = {};
  static String myName = '';
  static Map<String, dynamic> cache = {};
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static var profileNameStream;


  void sentToConversations(Msg msg, String converser, {bool addToTable = true}) {


    conversations.putIfAbsent(converser, () => {});
    conversations[converser]![msg.id] = msg;
    if (addToTable) {
      insertIntoConversationsTable(msg, converser);
    }

    notifyListeners();
    broadcast(scaffoldKey.currentContext!);
  }

  Future<void> receivedToConversations(dynamic decodedMessage, BuildContext context) async {
    var sender = decodedMessage['sender'];
    var message = json.decode(decodedMessage['message']);
    if (kDebugMode) {
      print("Received Message: $message");
    }

    //file decoding and saving
    if (message['type'] == 'voice' || message['type'] == 'file') {
      final String filePath = await decodeAndStoreFile(
        message['data'],
        message['fileName'],
        isVoice: message['type'] == 'voice',
      );
      conversations.putIfAbsent(sender, () => {});
      if (!conversations[sender]!.containsKey(decodedMessage['id'])) {
        print("Adding to conversations");
        print("Message: ${message['type']}");
        decodedMessage['message'] = json.encode({
          'type': message['type'],
          'filePath': filePath,
          'fileName': message['fileName']
        });
        var msg = Msg(
            decodedMessage['message'], "received", decodedMessage['Timestamp'],
            decodedMessage['id']);
        conversations[sender]![decodedMessage["id"]] = msg;
        insertIntoConversationsTable(msg, sender);
        notifyListeners();
      }
    }
    else {
      conversations.putIfAbsent(sender, () => {});
      if (!conversations[sender]!.containsKey(decodedMessage['id'])) {
        var msg = Msg(
            decodedMessage['message'], "received", decodedMessage['Timestamp'],
            decodedMessage['id']);
        conversations[sender]![decodedMessage["id"]] = msg;
        insertIntoConversationsTable(msg, sender);
        notifyListeners();
      }
    }
  }

  Future<String> decodeAndStoreFile(String encodedFile, String fileName, {bool isVoice = false}) async {
    Uint8List fileBytes = base64.decode(encodedFile);

    //to send files encrypted using RSA
    // Uint8List fileData = rsaDecrypt(Global.myPrivateKey!, fileBytes);

    Directory documents ;
    if (Platform.isAndroid) {
      documents = (await getExternalStorageDirectory())!;
    }
    else {
      documents = await getApplicationDocumentsDirectory();
    }

    PermissionStatus status = await Permission.storage.request();

    final String subDir = isVoice ? 'voice_messages' : 'files';
    if (status.isGranted) {

      final Directory finalDir = Directory('${documents.path}/$subDir');
      if (!await finalDir.exists()) {
        await finalDir.create(recursive: true);
      }
      final path ='${finalDir.path}/$fileName';
      File(path).writeAsBytes(fileBytes);
      if (kDebugMode) {
        print("File saved at: $path");
      }
      return path;
    }
    else {
      throw const FileSystemException('Storage permission not granted');
    }
  }


  void updateDevices(List<Device> devices) {

    this.devices = devices;
    notifyListeners();
  }

  void updateConnectedDevices(List<Device> devices) {
    connectedDevices = devices;
    notifyListeners();
  }
}
