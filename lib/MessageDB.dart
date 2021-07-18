import 'dart:async';
import 'package:flutter_nearby_connections_example/Global.dart';
import 'dart:convert';

import 'Payload.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'model.dart';

class MessageDB {
  static final MessageDB instance = MessageDB._init();

  static Database? _database;

  MessageDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('messages.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $tableName($MessageTableFields.id PRIMARY KEY, $MessageTableFields.type TEXT NOT NULL,$MessageTableFields.msg TEXT NOT NULL)');
  }

  void insert(MessageFromDB message) async {
    final db = await instance.database;
    final id = await db.insert(tableName, message.toJson());
    return;
  }

  Future<MessageFromDB?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableName,
      columns: MessageTableFields.values,
      where: '$MessageTableFields.id=?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty)
      return MessageFromDB.fromJson(maps.first);
    else
      return null;
  }

  Future<List<MessageFromDB>> readAll() async {
    final db = await instance.database;
    final result = await db.query(
      tableName,
    );
    return result.map((json) => MessageFromDB.fromJson(json)).toList();
  }

  Future<int> update(MessageFromDB msg) async {
    final db = await instance.database;
    return db.update(tableName, msg.toJson(),
        where: '$MessageTableFields.id=?', whereArgs: [msg.id]);
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return db
        .delete(tableName, where: '$MessageTableFields.id=?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

class DatabaseHelper {
  void readAllUpdateCache() {
    List<MessageFromDB> messages;
    MessageDB.instance.readAll().then((value) => messages = value);
    messages.forEach((element) {
      if (element.type == 'Ack')
        Global.cache[element.id] = convertToAck(element);
      else
        Global.cache[element.id] = convertToPayload(element);
    });
  }

  void insertIntoDB(dynamic msg) {
    if (msg.runtimeType == Payload)
      MessageDB.instance.insert(convertFromPayload(msg));
    else
      MessageDB.instance.insert(convertFromAck(msg));
  }

  void delete(String id) {
    MessageDB.instance.delete(id);
  }

  void update(String id, dynamic msg) {
    if (msg.runtimeType == Payload)
      MessageDB.instance.update(convertFromPayload(msg));
    else
      MessageDB.instance.update(convertFromAck(msg));
  }

  Ack convertToAck(MessageFromDB msg) {
    String id=msg.id;
    return Ack(id);
  }

  Payload convertToPayload(MessageFromDB message) {
    String id=message.id;
    String payload=message.msg;
    var json=  jsonDecode(payload);
    return Payload(id, json['sender'], json['receiver'],json['message'], json['timestamp']);
  }

  MessageFromDB convertFromPayload(Payload msg) {
    String id=msg.id;
    String type='Payload';
    Map<String,String> message={
      "id":  msg.id,
      "type": msg.type,
      "message":msg.message,
      "timestamp":msg.timestamp,
      "sender":msg.sender,
      "receiver":msg.receiver
    };
    return MessageFromDB(id, type, message.toString());
  }

  MessageFromDB convertFromAck(Ack msg) {
    String id=msg.id;
    String type='Ack';
    Map<String,String> message={
      "id":  msg.id,
      "type": msg.type,
    };
    return MessageFromDB(id, type, message.toString());
  }
}
