import 'package:flutter/material.dart';
import 'package:modules/business/chat/chat_room_cells/chat_audio_message.dart';
import 'package:modules/business/chat/chat_room_cells/chat_message.dart';

import 'chat_call_cell.dart';
import 'chat_generating_message.dart';
import 'chat_gift_cell.dart';
import 'chat_image_message.dart';
import 'chat_system_cell.dart';
import 'chat_system_message.dart';
import 'chat_text_cell.dart';
import 'chat_video_message.dart';

enum ChatCellType {
  chat, //聊天室
  category, //历史记录中的类别
}

class ChatCell extends StatelessWidget {
  ChatMessage message;
  ChatCellType type = ChatCellType.chat;
  final Function(ChatMessage message)? resend;
  final Function(ChatMessage message)? onTap; // 添加 final 修饰符
  final Function(ChatMessage message)? unlock;
  final Function(ChatMessage message)? reload;
  final Function(ChatMessage message)? download;

  //工厂方法
  factory ChatCell.create(
    ChatMessage message, {
    ChatCellType type = ChatCellType.chat,
    Function(ChatMessage message)? resend,
    Function(ChatMessage message)? onTap,
    Function(ChatMessage message)? unlock,
    Function(ChatMessage message)? reload,
    Function(ChatMessage message)? download,
  }) {
    switch (message.type) {
      case ChatMessageType.text:
        return ChatTextCell(message as ChatTextMessage, resend: resend, onTap: onTap, unlock: unlock, reload: reload, download: download);
      case ChatMessageType.generating:
        return ChatGeneratingCell(message: message as ChatGeneratingMessage);
      case ChatMessageType.call:
        return ChatCallCell(message: message as ChatCallMessage, onTap: onTap);
      case ChatMessageType.image:
        return ChatImageCell(message as ChatImageMessage, unlock: unlock, reload: reload)..type = type;
      case ChatMessageType.video:
        return ChatVideoCell(message as ChatVideoMessage, unlock: unlock)..type = type;
      case ChatMessageType.gift:
        return ChatGiftCell(message as ChatGiftMessage);
      case ChatMessageType.voice:
        return ChatAudioCell(message as ChatAudioMessage, unlock: unlock, download: download);
      case ChatMessageType.system:
        return ChatSystemCell(message as ChatSystemMessage);
      default:
        return ChatUnsupportedCell(message);
    }
  }

  // 修复构造函数参数声明
  ChatCell(this.message, {super.key, this.resend, this.onTap, this.unlock, this.reload, this.download});

  Widget buildSendStatusView() {
    ChatMessageSendStatus status = message.sendState.value;
    switch (status) {
      case ChatMessageSendStatus.sending:
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE962F6)),
        );
      case ChatMessageSendStatus.failed:
        return GestureDetector(
          onTap: () {
            resend?.call(message);
          },
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.error, size: 24, color: Colors.red)),
        );
      case ChatMessageSendStatus.sent:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ChatUnsupportedCell extends ChatCell {
  ChatUnsupportedCell(super.message, {super.key, super.resend});
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
