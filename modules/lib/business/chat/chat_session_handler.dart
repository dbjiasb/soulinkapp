import 'package:modules/base/crypt/other.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:sqflite/sqflite.dart';

import '../../base/database/data_center.dart';
import 'chat_session.dart';

String kEventCenterDidCreatedNewSession = Security.security_kEventCenterDidCreatedNewSession;

class ChatSessionHandler {
  int get ownerId => AccountService.instance.account.userId;
  Database get database => DataCenter.instance.database;

  ChatSessionHandler() {
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
    Database database = DataCenter.instance.database;
    return await database.execute(ChatSession.createTableSql);
  }

  //增删查改
  Future<int> upsertSession(ChatSession session) async {
    return await database.insert(ChatSession.tableName, session.toDatabase(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ChatSession>> querySessions({String? sessionId, int? limit, int? offset}) async {
    String where = "ownerId = ?${sessionId != null ? " AND id = '$sessionId'" : ""}";

    if (offset != null && offset > 0) {
      where += " OFFSET $offset";
    }

    if (limit != null && limit > 0) {
      where += " LIMIT $limit";
    }

    final List<Map<String, dynamic>> sqlSessions = await database.query(
      ChatSession.tableName,
      where: where,
      whereArgs: [ownerId.toString()],
      orderBy: Other.security_lastMessageTime_DESC,
    );

    List<ChatSession> sessions = sqlSessions.map((element) => ChatSession.fromDatabase(element)).toList();
    return sessions;
  }

  Future<ChatSession?> querySession(String sessionId) async {
    List<ChatSession> sessions = await querySessions(sessionId: sessionId);
    return sessions.firstOrNull;
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
    if (toVersion == 3) {
      database.execute('ALTER TABLE ${ChatSession.tableName} ADD COLUMN accountType INTEGER DEFAULT 1;');
    }
  }
}
