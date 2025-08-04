import 'package:modules/base/crypt/security.dart';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:modules/business/chat/chat_room_cells/chat_cell.dart';

import 'chat_message.dart';

class ChatGiftMessage extends ChatMessage {
  ChatGiftMessage({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.type,
    required super.date,
    required super.ownerId,
    required super.uuid,
    required super.info,
    required super.lockInfo,
    required super.nativeId,
  });

  ChatGiftMessage.fromServer(super.data) : super.fromServerData();

  ChatGiftMessage.fromDatabase(super.data) : super.fromLocalData();
  @override
  Map<String, dynamic> toDatabase() {
    return super.toDatabase();
  }

  Map<String, dynamic>? _decodedInfo;
  Map<String, dynamic> get decodedInfo {
    _decodedInfo ??= jsonDecode(info);
    return _decodedInfo ?? {};
  }

  String get imageUrl => decodedInfo[Security.security_giftIcon] ?? '';
  int get giftCount => decodedInfo[Security.security_giftCount] ?? 0;
}

class ChatGiftCell extends ChatCell {
  ChatGiftCell(super.message, {super.key});
  ChatGiftMessage get giftMessage => message as ChatGiftMessage;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: giftMessage.isMine() ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: giftMessage.isMine() ? Color(0xE6E86785) : Color(0xE640252A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: giftMessage.isMine() ? Radius.circular(12) : Radius.circular(4),
                bottomRight: giftMessage.isMine() ? Radius.circular(4) : Radius.circular(12),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min, // 防止横向拉伸
              children: [
                Text(Security.security_Sent, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 11)),
                SizedBox(width: 4),
                CachedNetworkImage(imageUrl: giftMessage.imageUrl, width: 32, height: 32),
                SizedBox(width: 4),
                Text('x${giftMessage.giftCount}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, fontFamily: '.SF Pro Text')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
