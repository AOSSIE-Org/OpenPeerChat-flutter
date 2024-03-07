// import 'package:flutter/foundation.dart';
// // ignore: import_of_legacy_library_into_null_safe
// import 'package:p2p_client_dart/p2p_client_dart.dart';

// class Contact {
//   String displayName;
//   String? roomId;
//   String? userId;

//   Contact(this.displayName);

//   @override
//   String toString() {
//     return displayName;
//   }

//   Contact.fromJson(Map<String, String> json)
//       : displayName = json['displayName']!,
//         roomId = json['roomId'],
//         userId = json['userId'];
// }

// class MatrixServer extends ChangeNotifier {
//   Server _server = Server();
//   Server get server => _server;

//   @override
//   String toString() {
//     return 'Matrix Server - ${server.toString()}';
//   }

//   set server(Server newServer) {
//     this._server = newServer;
//     notifyListeners();
//   }

//   Future<void> setServerConfig(
//       String url, String name, String? username, String? password) async {
//     this._server = server = Server.init(url, name);
//     if (username != null && password != null) {
//       await this._server.login(username, password);
//       print(this._server.isAuthenticated);
//     }
//   }

//   Future<List<Contact>> getContactsList() async {
//     var roomData = await server.getJoinedRooms();
//     List<Contact> contacts = roomData.map((e) {
//       Map<String, String> contact = {};
//       e.retainWhere((e) => e.senderId != server.userId);

//       if (e.length == 0) return Contact("None");
//       contact["roomId"] = e[0].roomId;
//       contact["userId"] = e[0].senderId;
//       contact["displayName"] = e[0].content['displayname'];
//       return Contact.fromJson(contact);
//     }).toList();
//     contacts.retainWhere((element) => element.displayName != "None");
//     return contacts;
//   }
// }
