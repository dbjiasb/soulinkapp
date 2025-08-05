import './chat_message.dart';

class ChatSystemMessage extends ChatMessage {
  String content = 'Notice: Everything AI says is made up';
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
