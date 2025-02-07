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
import '../database/message_db.dart';
import '../p2p/adhoc_housekeeping.dart';
import 'msg.dart';


class Global extends ChangeNotifier {
  // Primary key and profile management
  static String primaryKey = '';
  static String myName = '';
  static Map<String, String> userProfiles = {}; // Store user profiles: primaryKey -> name
  Map<String, String> userNames = {};

  // static variables
  static RSAPrivateKey? myPrivateKey;
  static RSAPublicKey? myPublicKey;
  static NearbyService? nearbyService;
  static StreamSubscription? deviceSubscription;
  static StreamSubscription? receivedDataSubscription;
  static Map<String, dynamic> cache = {};
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Instance variables
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  static List<Msg> messages = [];
  static Map<String, RSAPublicKey> publicKeys = {};
  Map<String, Map<String, Msg>> conversations = {};

  // Enhanced profile management methods
  void updateUserProfile(String primaryKey, String name) {
    userProfiles[primaryKey] = name;
    notifyListeners();
  }

  String getUserName(String primaryKey) {
    return userProfiles[primaryKey] ?? 'Unknown User';
  }

  void updateLocalProfile(String name, BuildContext context) {
    if (myName != name) {
      myName = name;
      updateUserProfile(primaryKey, name);
      notifyListeners();

      // Restart NearbyService to advertise with new name
      WidgetsBinding.instance.addPostFrameCallback((_) {
        restartNearbyService(context);
      });

      // Broadcast the update
      broadcastProfileUpdate(context);
    }
  }

  Future<void> restartNearbyService(BuildContext context) async {
    await Global.nearbyService?.stopAdvertisingPeer();
    await Global.nearbyService?.stopBrowsingForPeers();
    for (var device in connectedDevices) {
      await Global.nearbyService?.disconnectPeer(deviceID: device.deviceId);
    }
    Global.nearbyService = null;
    initiateNearbyService();
    checkDevices(context);
  }

  // conversation management with primary keys
  void sentToConversations(Msg msg, String converserKey, {bool addToTable = true}) {
    conversations.putIfAbsent(converserKey, () => {});
    conversations[converserKey]![msg.id] = msg;
    if (addToTable) {
      insertIntoConversationsTable(msg, converserKey);
    }
    notifyListeners();
    broadcast(scaffoldKey.currentContext!);
  }

  void handleProfileUpdate(String primaryKey, String name) async {
    userNames[primaryKey] = name;
    userProfiles[primaryKey] = name; // Add this line
    await MessageDB.instance.upsertUserName(primaryKey, name);
    notifyListeners();

    // Force UI refresh for all relevant widgets
    if (kDebugMode) {
      print('Profile updated for $primaryKey: $name');
    }
  }
  Future<void> receivedToConversations(dynamic decodedMessage, BuildContext context) async {
    var senderKey = decodedMessage['senderKey'];
    var message = json.decode(decodedMessage['message']);

    if (kDebugMode) {
      print("Received Message from $senderKey: $message");
    }

    conversations.putIfAbsent(senderKey, () => {});
    if (!conversations[senderKey]!.containsKey(decodedMessage['id'])) {
      if (message['type'] == 'voice' || message['type'] == 'file') {
        final String filePath = await decodeAndStoreFile(
          message['data'],
          message['fileName'],
          isVoice: message['type'] == 'voice',
        );

        decodedMessage['message'] = json.encode({
          'type': message['type'],
          'filePath': filePath,
          'fileName': message['fileName']
        });
      }

      var msg = Msg(
        decodedMessage['message'],
        "received",
        decodedMessage['Timestamp'],
        decodedMessage['id'],
        senderKey: senderKey,
        receiverKey: primaryKey,
      );
      conversations[senderKey]![decodedMessage["id"]] = msg;
      insertIntoConversationsTable(msg, senderKey);
      notifyListeners();
    }
  }


  Future<String> decodeAndStoreFile(String encodedFile, String fileName, {bool isVoice = false}) async {
    Uint8List fileBytes = base64.decode(encodedFile);
    Directory documents = Platform.isAndroid
        ? (await getExternalStorageDirectory())!
        : await getApplicationDocumentsDirectory();

    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) {
      throw const FileSystemException('Storage permission not granted');
    }

    final String subDir = isVoice ? 'voice_messages' : 'files';
    final Directory finalDir = Directory('${documents.path}/$subDir');
    if (!await finalDir.exists()) {
      await finalDir.create(recursive: true);
    }

    final path = '${finalDir.path}/$fileName';
    await File(path).writeAsBytes(fileBytes);
    if (kDebugMode) {
      print("File saved at: $path");
    }
    return path;
  }


  void updateDevices(List<Device> devices) {
    this.devices = devices;
    for (var device in devices) {
      var info = parseDeviceInfo(device.deviceName);
      String pk = info['primaryKey'] ?? '';
      String name = info['name'] ?? '';
      if (pk.isNotEmpty) {
        // Update both userProfiles and userNames
        userProfiles[pk] = name;
        userNames[pk] = name;
        MessageDB.instance.upsertUserName(pk, name);
      }
    }
    notifyListeners();
  }

  void updateConnectedDevices(List<Device> devices) {
    connectedDevices = devices;
    notifyListeners();
  }
}
