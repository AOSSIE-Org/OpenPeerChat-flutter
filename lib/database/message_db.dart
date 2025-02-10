import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'model.dart';

/// It is the database for the messages.

class MessageDB {
  static final MessageDB instance = MessageDB._init();
  static Database? _database;
  MessageDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('p2p.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $messagesTableName(
        _id PRIMARY KEY, 
        type TEXT NOT NULL,
        msg TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE $conversationsTableName(
        _id PRIMARY KEY, 
        converser TEXT NOT NULL,
        type TEXT NOT NULL,
        msg TEXT NOT NULL,
        timestamp TEXT NOT NULL, 
        ack TEXT NOT NULL,
        senderKey TEXT NOT NULL,
        receiverKey TEXT NOT NULL
      );
      CREATE INDEX idx_sender_receiver ON $conversationsTableName(senderKey, receiverKey);
    ''');

    await db.execute('''
      CREATE TABLE $publicKeyTableName(
        ${PublicKeyFields.converser} TEXT NOT NULL,
        ${PublicKeyFields.publicKey} TEXT NOT NULL,
        PRIMARY KEY (${PublicKeyFields.converser})
      );
    ''');

    await db.execute('''
    CREATE TABLE $userNamesTableName(
      ${UserNameFields.primaryKey} TEXT PRIMARY KEY,
      ${UserNameFields.displayName} TEXT NOT NULL,
      ${UserNameFields.lastUpdated} TEXT NOT NULL
    );
  ''');
  }

  Future<void> upsertUserName(String primaryKey, String displayName) async {
    final db = await instance.database;
    final userNameData = UserNameFromDB(
      primaryKey,
      displayName,
      DateTime.now().toIso8601String(),
    );

    await db.insert(
      userNamesTableName,
      userNameData.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserNameFromDB>> getAllUserNames() async {
    final db = await instance.database;
    final results = await db.query(userNamesTableName);
    return results.map((json) => UserNameFromDB.fromJson(json)).toList();
  }

  Future<UserNameFromDB?> getUserName(String primaryKey) async {
    final db = await instance.database;
    final results = await db.query(
      userNamesTableName,
      where: '${UserNameFields.primaryKey} = ?',
      whereArgs: [primaryKey],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return UserNameFromDB.fromJson(results.first);
    }
    return null;
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $conversationsTableName ADD COLUMN senderKey TEXT DEFAULT ""');
      await db.execute('ALTER TABLE $conversationsTableName ADD COLUMN receiverKey TEXT DEFAULT ""');
    }

    // Add user names table if it doesn't exist
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $userNamesTableName(
      ${UserNameFields.primaryKey} TEXT PRIMARY KEY,
      ${UserNameFields.displayName} TEXT NOT NULL,
      ${UserNameFields.lastUpdated} TEXT NOT NULL
    );
  ''');
  }

  Future<void> insertPublicKey(PublicKeyFromDB publicKey) async {
    final db = await instance.database;

    await db.insert(publicKeyTableName, publicKey.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PublicKeyFromDB>> readAllFromPublicKeyTable() async {
    final db = await instance.database;

    final result = await db.query(publicKeyTableName);

    return result.map((json) => PublicKeyFromDB.fromJson(json)).toList();
  }

  Future<PublicKeyFromDB?> getPublicKey(String converser) async {
    final db = await instance.database;

    final result = await db.query(publicKeyTableName,
        where: '${PublicKeyFields.converser} = ?', whereArgs: [converser]);

    if (result.isNotEmpty) {
      return PublicKeyFromDB.fromJson(result.first);
    } else {
      return null;
    }
  }

// Add method to update display names while maintaining IDs
  Future<int> updateUserDisplayName(String userId, String newDisplayName) async {
    final db = await instance.database;
    return db.update(
      userNamesTableName,
      {
        UserNameFields.displayName: newDisplayName,
        UserNameFields.lastUpdated: DateTime.now().toIso8601String()
      },
      where: '${UserNameFields.primaryKey} = ?',
      whereArgs: [userId],
    );
  }

  Future<void> insertIntoMessagesTable(MessageFromDB message) async {
    final db = await instance.database;
    await db.insert(messagesTableName, message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertIntoConversationsTable(ConversationFromDB message) async {
    final db = await instance.database;
    await db.insert(conversationsTableName, message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Function to get last message id from the database
  // in the conversation table
  // The type can be modified based on the type of message
  // that is being sent or received
  Future<String> getLastMessageId({required String type}) async {
    final db = await instance.database;
    final message = await db.query(
      conversationsTableName,
      where: '${ConversationTableFields.type}=?',
      whereArgs: [type],
      orderBy: '${ConversationTableFields.timestamp} DESC',
      limit: 1,
    );
    if (message.isEmpty) return "-1"; // If error in database.
    return MessageFromDB.fromJson(message[0]).id;
  }

  // Existing methods with updated return types
  Future<List<MessageFromDB>> readAllFromMessagesTable() async {
    final db = await instance.database;
    final result = await db.query(messagesTableName);
    return result.map((json) => MessageFromDB.fromJson(json)).toList();
  }

  Future<List<ConversationFromDB>> readAllFromConversationsTable() async {
    final db = await instance.database;
    final result = await db.query(conversationsTableName);
    return result.map((json) => ConversationFromDB.fromJson(json)).toList();
  }

  Future<ConversationFromDB?> readFromConversationsTable(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      conversationsTableName,
      columns: ConversationTableFields.values,
      where: '${ConversationTableFields.id}=?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ConversationFromDB.fromJson(maps.first);
    } else {
      return null;
    }
  }

  // Updated query methods to include sender and receiver keys
  Future<List<ConversationFromDB>> getConversationsByUser(String userKey) async {
    final db = await instance.database;
    final result = await db.query(
      conversationsTableName,
      where: 'senderKey = ? OR receiverKey = ?',
      whereArgs: [userKey, userKey],
    );
    return result.map((json) => ConversationFromDB.fromJson(json)).toList();
  }

  Future<int> updateMessageTable(MessageFromDB msg) async {
    final db = await instance.database;
    return db.update(messagesTableName, msg.toJson(),
        where: '${MessageTableFields.id}=?', whereArgs: [msg.id]);
  }

  Future<int> updateConversationTable(ConversationFromDB msg) async {
    final db = await instance.database;
    return db.update(conversationsTableName, msg.toJson(),
        where: '${ConversationTableFields.id}=?', whereArgs: [msg.id]);
  }

  Future<int> deleteFromMessagesTable(String id) async {
    final db = await instance.database;
    return db.delete(messagesTableName,
        where: '${MessageTableFields.id}=?', whereArgs: [id]);
  }

  Future<int> deleteFromConversationsTable(String id) async {
    final db = await instance.database;
    return db.delete(conversationsTableName,
        where: '${ConversationTableFields.id}=?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
