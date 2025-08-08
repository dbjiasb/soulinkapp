import 'package:modules/base/crypt/copywriting.dart';
import './chat_message.dart';

class ChatSystemMessage extends ChatMessage {
  String content = Copywriting.security_notice__Everything_AI_says_is_made_up;
  // ChatSystemMessage({
  //   required super.id,
  //   required super.senderId,
  //   required super.receiverId,
  //   required super.date,
  //   required super.ownerId,
  //   required super.type,
  //   required super.uuid,
  //   required super.info,
  //   required super.lockInfo,
  //   required super.nativeId,
  // });

  ChatSystemMessage()
    : super(id: 0, senderId: 0, receiverId: 0, date: DateTime.now(), ownerId: 0, type: ChatMessageType.system, uuid: '', info: '', lockInfo: {}, nativeId: '');
}
