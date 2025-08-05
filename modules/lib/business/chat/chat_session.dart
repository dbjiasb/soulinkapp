import 'package:modules/base/crypt/security.dart';
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
      Security.security_id: id,
      Security.security_ownerId: ownerId,
      Security.security_name: name,
      Security.security_avatar: avatar,
      Security.security_lastMessageTime: lastMessageTime.millisecondsSinceEpoch,
      Security.security_lastMessageText: lastMessageText,
      Security.security_backgroundUrl: backgroundUrl.value,
      Security.security_unreadNumber: unreadNumber.value,
      Security.security_accountType: accountType,
    };
  }

  ChatSession.fromDatabase(Map<String, Object?> map)
    : id = map[Security.security_id] as String,
      name = map[Security.security_name] as String,
      avatar = map[Security.security_avatar] as String,
      lastMessageTime = DateTime.fromMillisecondsSinceEpoch(map[Security.security_lastMessageTime] as int),
      lastMessageText = map[Security.security_lastMessageText] as String,
      backgroundUrl = (map[Security.security_backgroundUrl] as String? ?? '').obs,
      unreadNumber = (map[Security.security_unreadNumber] as int? ?? 0).obs,
      accountType = map[Security.security_accountType] as int,
      greeted = true
  {
    // 构造函数主体可以为空
  }

  //从别的页面跳转到聊天页面，用于初始化聊天页面
  ChatSession.fromRouter(Map router)
    : id = router[Security.security_id],
      name = router[Security.security_name],
      avatar = router[Security.security_avatar],
      lastMessageTime = router[Security.security_lastMessageTime] == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(router[Security.security_lastMessageTime]),
      lastMessageText = router[Security.security_lastMessageText] ?? '',
      backgroundUrl = (router[Security.security_backgroundUrl] as String? ?? '').obs,
      unreadNumber = (router[Security.security_unreadNumber] as int? ?? 0).obs, // 修复：显式转换类型后使用 .obs
      greeted = router[Security.security_greeted] ?? false;
  String toRouter() {
    //转换成map再用json.encode
    return JsonEncoder().convert({
      Security.security_id: id,
      Security.security_name: name,
      Security.security_avatar: avatar,
      Security.security_lastMessageTime: lastMessageTime.millisecondsSinceEpoch,
      Security.security_lastMessageText: lastMessageText,
      Security.security_greeted: greeted,
      Security.security_backgroundUrl: backgroundUrl.value,
      Security.security_unreadNumber: unreadNumber.value
    });
  }

  static String get tableName => Security.security_chat_sessions;
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
