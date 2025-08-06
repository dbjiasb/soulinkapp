import 'package:flutter/cupertino.dart';
import 'package:modules/shared/widget/thinking_animated_view.dart';

import 'chat_cell.dart';
import 'chat_message.dart';

class ChatGeneratingMessage extends ChatMessage {
  ChatGeneratingMessage({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.date,
    required super.ownerId,
    required super.type,
    required super.uuid,
    required super.info,
    required super.lockInfo,
    required super.nativeId,
  });

  ChatGeneratingMessage.placeholder(int senderId)
    : super(
        id: 0,
        senderId: senderId,
        receiverId: 0,
        date: DateTime.now(),
        ownerId: 0,
        type: ChatMessageType.generating,
        uuid: '',
        nativeId: '',
        info: '',
        lockInfo: {},
      );
}

class ChatGeneratingCell extends ChatCell {
  ChatGeneratingCell({required ChatMessage message}) : super(message);
  bool get isMine => message.isMine();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 56,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isMine ? Color(0xffFFF9B4).withValues(alpha:0.9) : Color(0xff272533).withValues(alpha:0.9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(isMine ? 12 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 12),
            ),
          ),
          child: ThinkingDots(),
        ),
      ),
    );
  }
}
