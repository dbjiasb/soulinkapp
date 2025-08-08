import 'package:modules/base/crypt/other.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/database/data_center.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:sqflite/sqflite.dart';

import 'chat_room_cells/chat_message.dart';

class ChatMessageHandler {
  int get userId => AccountService.instance.account.userId;
  Database get database => DataCenter.instance.database;

  ChatMessageHandler() {
    Map createInfo = DataCenter.instance.createInfo;
    if (createInfo.isNotEmpty) {
      createTable();
    }

    Map upgradeInfo = DataCenter.instance.upgradeInfo;
    if (upgradeInfo.isNotEmpty) {
      upgradeTable();
    }
  }

  Future<void> createTable() async {
    return await database.execute(ChatMessage.createTableSql);
  }

  Future<void> upgradeTable() async {
    Map upgradeInfo = DataCenter.instance.upgradeInfo;
    int oldVersion = upgradeInfo[Security.security_oldVersion] as int;
    int newVersion = upgradeInfo[Security.security_newVersion] as int;

    for (int i = oldVersion; i < newVersion; i++) {
      int toVersion = i + 1;
      await upgradeToVersion(toVersion);
    }
  }

  Future<void> upgradeToVersion(int toVersion) async {
    if (toVersion == 2) {
      database.execute('ALTER TABLE ${ChatMessage.tableName} ADD COLUMN lockInfo TEXT');
      database.execute('ALTER TABLE ${ChatMessage.tableName} ADD COLUMN uuid TEXT');
      database.execute('ALTER TABLE ${ChatMessage.tableName} ADD COLUMN renewInfo TEXT');
    }
  }

  Future<int> insertMessage(ChatMessage message) async {
    return await database.insert(ChatMessage.tableName, message.toDatabase(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateLocalMessage(ChatMessage message) async {
    return await database.update(ChatMessage.tableName, message.toDatabase(), where: Other.security_nativeId___, whereArgs: [message.nativeId]);
  }

  Future<List<ChatMessage>> queryMessages(String sessionId, {List<int>? types, int? limit, int? offset}) async {
    String where = "ownerId = $userId AND sessionId = ?";
    if (types != null && types.isNotEmpty) {
      where += " AND type IN (${types.join(',')})";
    }

    final List<Map<String, dynamic>> results = await database.query(
      ChatMessage.tableName,
      where: where,
      whereArgs: [sessionId],
      orderBy: Other.security_date_DESC__id_DESC,
      limit: limit,
      offset: offset,
    );

    List<ChatMessage> messages =
        results.map((result) {
          return ChatMessage.fromDatabase(result);
        }).toList();

    return messages;
  }

  Future<ChatMessage?> selectMessage(int id) async {
    final List<Map<String, dynamic>> results = await database.query(ChatMessage.tableName, where: Other.security_id____, whereArgs: [id]);

    if (results.isEmpty) return null;
    return ChatMessage.fromDatabase(results.first);
  }
}
