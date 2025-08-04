import 'dart:convert';

import 'package:get/get.dart';
import 'package:modules/core/account/account_service.dart';

class ChatSession {
  String id = '';
  String name = '';
  String avatar = '';
  DateTime lastMessageTime;
  String lastMessageText = '';
  var backgroundUrl = ''.obs;
  bool greeted = false;
  var unreadNumber = 0.obs;
  int accountType = 1;

  int get ownerId => AccountService.instance.account.userId;

  ChatSession({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessageTime,
    required this.lastMessageText,
    required this.accountType,
  });

  @override
  toString() {
    return 'ChatSession{id: $id, name: $name, avatar: $avatar, lastMessageTime: $lastMessageTime, lastMessageText: $lastMessageText, backgroundUrl: ${backgroundUrl.value}, unreadNumber: ${unreadNumber.value}}';
  }

  Map<String, Object?> toDatabase() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'avatar': avatar,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'lastMessageText': lastMessageText,
      'backgroundUrl': backgroundUrl.value,
      'unreadNumber': unreadNumber.value,
      'accountType': accountType,
    };
  }

  ChatSession.fromDatabase(Map<String, Object?> map)
    : id = map['id'] as String,
      name = map['name'] as String,
      avatar = map['avatar'] as String,
      lastMessageTime = DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'] as int),
      lastMessageText = map['lastMessageText'] as String,
      backgroundUrl = (map['backgroundUrl'] as String? ?? '').obs,
      unreadNumber = (map['unreadNumber'] as int? ?? 0).obs,
      accountType = map['accountType'] as int,
      greeted = true {
    // 构造函数主体可以为空
  }

  //从别的页面跳转到聊天页面，用于初始化聊天页面
  ChatSession.fromRouter(Map router)
    : id = router['id'],
      name = router['name'],
      avatar = router['avatar'],
      lastMessageTime = router['lastMessageTime'] == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(router['lastMessageTime']),
      lastMessageText = router['lastMessageText'] ?? '',
      backgroundUrl = (router['backgroundUrl'] as String? ?? '').obs,
      unreadNumber = (router['unreadNumber'] as int? ?? 0).obs, // 修复：显式转换类型后使用 .obs
      greeted = router['greeted'] ?? false;

  String toRouter() {
    //转换成map再用json.encode
    return JsonEncoder().convert({
      'id': id,
      'name': name,
      'avatar': avatar,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'lastMessageText': lastMessageText,
      'greeted': greeted,
      'backgroundUrl': backgroundUrl.value,
      'unreadNumber': unreadNumber.value,
    });
  }

  static String get tableName => 'chat_sessions';
  static String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id TEXT PRIMARY KEY,
      ownerId INTEGER,
      name TEXT,
      avatar TEXT,
      lastMessageTime INTEGER,
      lastMessageText TEXT,
      backgroundUrl TEXT,
      unreadNumber INTEGER DEFAULT 0,
      accountType INTEGER DEFAULT 1
    )
  ''';
}
